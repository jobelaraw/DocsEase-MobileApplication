import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:http/http.dart' as http;
import 'package:docsease/info_model.dart';

// ─── Chat AI Reply: Structured answer returned by the model ───
class ChatAiReply {
  final String replyLanguage; // english, tagalog, or taglish, detected from the user's latest message
  final String category; // greeting, specific_service, general, office_info, off_topic, not_found
  final String answer;
  final List<String> serviceIds; // Services to show as cards below the answer
  final String answeredTopic; // requirements, steps, fees, processing_time, persons_in_charge, overview, none

  const ChatAiReply({
    required this.replyLanguage,
    required this.category,
    required this.answer,
    required this.serviceIds,
    required this.answeredTopic,
  });
}

class ChatAiException implements Exception {
  final int statusCode;
  final String? reasonPhrase;
  final String body;
  const ChatAiException(this.statusCode, this.reasonPhrase, this.body);

  @override
  String toString() => 'ChatAiException($statusCode): $body';
}

// ─── Chat AI Service: Answers only from Biñan City Hall's offices and services in Firestore ───
// Every request carries a compact catalog (offices + service names). Full service details
// (requirements, steps, fees, persons in charge) are fetched by the model through a tool call
// only when it needs them, which keeps requests small enough for the API's rate limits.
class ChatAiService {
  static const _url = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';
  static const _timeout = Duration(seconds: 30);

  final String apiKey;
  final List<Office> offices;

  ChatAiService({required this.apiKey, required this.offices});

  // ─── Ask: history is the recent conversation, ending with the user's new message ───
  Future<ChatAiReply> ask(List<Map<String, String>> history) async {
    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': _systemPrompt.replaceFirst('{CATALOG}', _buildCatalog())},
      ...history,
    ];
    // Kept as the last message (also after tool results) so earlier turns and the English data
    // don't pull the reply into another language
    final latestUserMessage = history.lastWhere((m) => m['role'] == 'user')['content'] ?? '';
    final languageReminder = {'role': 'system', 'content': _languageInstruction(latestUserMessage)};

    var message = await _complete([...messages, languageReminder], toolChoice: 'auto');
    final fetchedIds = <String>[];

    // The model asked for full details of some services: send them back, then get the answer
    final toolCalls = message['tool_calls'] as List<dynamic>?;
    if (toolCalls != null && toolCalls.isNotEmpty) {
      messages.add({'role': 'assistant', 'content': message['content'], 'tool_calls': toolCalls});
      for (final call in toolCalls) {
        final args = jsonDecode(call['function']['arguments'] as String) as Map<String, dynamic>;
        final ids = List<String>.from(args['service_ids'] ?? const []).take(3).toList();
        fetchedIds.addAll(ids);
        messages.add({'role': 'tool', 'tool_call_id': call['id'], 'content': _buildDetails(ids)});
      }
      message = await _complete([...messages, languageReminder], toolChoice: 'none');
    }

    final content = message['content'] as String?;
    if (content == null) throw ChatAiException(200, null, 'No answer: ${message['refusal']}');
    final reply = jsonDecode(content) as Map<String, dynamic>;

    final category = reply['category'] as String;
    var serviceIds = List<String>.from(reply['service_ids'] ?? const []);
    // After fetching details the model sometimes leaves service_ids empty; use the service it looked up
    if (category == 'specific_service' && serviceIds.isEmpty) serviceIds = fetchedIds.take(1).toList();

    return ChatAiReply(
      replyLanguage: reply['reply_language'] as String,
      category: category,
      answer: composeAnswer(reply['answer'] as Map<String, dynamic>),
      serviceIds: serviceIds,
      answeredTopic: reply['answered_topic'] as String,
    );
  }

  Future<Map<String, dynamic>> _complete(
    List<Map<String, dynamic>> messages, {
    required String toolChoice,
  }) async {
    final response = await http
        .post(
          Uri.parse(_url),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
          body: jsonEncode({
            'model': _model,
            'messages': messages,
            'temperature': 0.2,
            'max_tokens': 700,
            'response_format': _responseFormat,
            'tools': _tools,
            'tool_choice': toolChoice,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw ChatAiException(response.statusCode, response.reasonPhrase, response.body);
    }
    // Decode as UTF-8 explicitly so "Biñan" and other accents come through intact
    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return data['choices'][0]['message'] as Map<String, dynamic>;
  }

  // ─── Compose Answer: Builds Markdown with a bold main point and indented details per item ───
  @visibleForTesting
  static String composeAnswer(Map<String, dynamic> answer) {
    final parts = <String>[];
    final intro = (answer['intro'] as String).trim();
    if (intro.isNotEmpty) parts.add(intro);

    final items = answer['items'] as List<dynamic>;
    if (items.isNotEmpty) {
      final numbered = answer['list_style'] == 'numbered';
      final lines = <String>[];
      for (var i = 0; i < items.length; i++) {
        final item = items[i] as Map<String, dynamic>;
        final (point, extraDetails) = _splitParentheses((item['point'] as String).replaceAll('**', '').trim());
        final details = [...extraDetails, ...List<String>.from(item['details'])];

        final marker = numbered ? '${i + 1}.' : '-';
        lines.add('$marker **$point**');
        // Nested list indented to the item's text so Markdown renders it under the point
        final indent = ' ' * (marker.length + 1);
        for (final detail in details.map((d) => d.trim()).where((d) => d.isNotEmpty)) {
          lines.add('$indent- $detail');
        }
      }
      parts.add(lines.join('\n'));
    }

    final closing = (answer['closing'] as String).trim();
    if (closing.isNotEmpty) parts.add(closing);
    return parts.join('\n\n');
  }

  // Safety net: moves "(...)" at the start or end of a point into its details,
  // e.g. "Occupancy Permit (if applicable)" or "(For representatives) Authorization Letter".
  // Acronyms such as "(OBO)" stay in the point.
  static (String, List<String>) _splitParentheses(String point) {
    final leading = <String>[];
    final trailing = <String>[];
    var rest = point;
    bool isAcronym(String text) => RegExp(r'^[A-Z0-9&/.\-]{2,10}$').hasMatch(text.trim());
    String capitalize(String text) => text[0].toUpperCase() + text.substring(1);

    while (true) {
      final start = RegExp(r'^\(([^()]+)\)\s*(\S.*)$').firstMatch(rest);
      if (start == null || isAcronym(start.group(1)!)) break;
      leading.add(capitalize(start.group(1)!.trim()));
      rest = start.group(2)!;
    }
    while (true) {
      final end = RegExp(r'^(.*\S)\s*\(([^()]+)\)$').firstMatch(rest);
      if (end == null || isAcronym(end.group(2)!)) break;
      trailing.insert(0, capitalize(end.group(2)!.trim()));
      rest = end.group(1)!;
    }
    return (rest, [...leading, ...trailing]);
  }

  // ─── Catalog: Every office (schedule, contacts) and its services, one line each ───
  String _buildCatalog() {
    final lines = <String>[];
    for (final office in offices.where((o) => o.services.isNotEmpty)) {
      lines.add(
        '- ${_clean(office.officeName)} (${office.officeId})'
        ' | Location: ${_orNotListed(office.location)}'
        ' | Schedule: ${_orNotListed(office.schedule)}'
        ' | Phone: ${_orNotListed(office.contactPhone)}'
        ' | Email: ${_orNotListed(office.contactEmail)}',
      );
      for (final service in office.services.where((s) => s.title.trim().isNotEmpty)) {
        final description = _firstSentence(service.description);
        lines.add(
          '  - [${service.serviceId}] ${_clean(service.title)}'
          '${description.isEmpty ? '' : ': $description'}',
        );
      }
    }
    return lines.join('\n');
  }

  // ─── Details: Full requirements and steps of the requested services (tool result) ───
  String _buildDetails(List<String> serviceIds) {
    final lines = <String>[];
    for (final id in serviceIds) {
      final office = offices.where((o) => o.services.any((s) => s.serviceId == id)).firstOrNull;
      final service = office?.services.firstWhere((s) => s.serviceId == id);
      if (office == null || service == null) {
        lines.add('[$id] not found');
        continue;
      }

      lines.add('[$id] ${_clean(service.title)} — offered by ${_clean(office.officeName)}, Biñan City Hall');
      if (service.description.trim().isNotEmpty) lines.add('Description: ${_clean(service.description)}');
      for (final tab in service.tabs) {
        if (tab.name.trim().isNotEmpty) lines.add('Option: ${_clean(tab.name)}');
        if (tab.requirements.isNotEmpty) {
          lines.add('Requirements:');
          for (final req in tab.requirements) {
            final secureAt = _clean(req.secureAt);
            lines.add('- ${_clean(req.title)}${secureAt.isEmpty ? '' : ' | Secure at: $secureAt'}');
          }
        }
        if (tab.steps.isNotEmpty) {
          lines.add('Steps:');
          for (var i = 0; i < tab.steps.length; i++) {
            final step = tab.steps[i];
            lines.add(
              '${i + 1}. ${_clean(step.title)}: ${_clean(step.instruction)}'
              ' | Fee: ${_clean(step.fee).isEmpty ? 'None' : _clean(step.fee)}'
              ' | Processing time: ${_orNotListed(step.processingTime)}'
              ' | Persons in charge: ${_orNotListed(step.personsInCharge.join(', '))}',
            );
          }
        }
      }
      lines.add('');
    }
    return lines.join('\n');
  }

  // ─── Language: Tagalog, English, or Taglish, from the function words in the message ───
  // Nouns like "business permit" are ignored, so "ano ang kailangan para sa business permit?" is Tagalog.
  static String? detectLanguage(String message) {
    final words = message.toLowerCase().split(RegExp(r"[^a-zñ']+")).where((w) => w.isNotEmpty);
    final hasTagalog = words.any(_tagalogWords.contains);
    final hasEnglish = words.any(_englishWords.contains);
    if (hasTagalog && hasEnglish) return 'taglish';
    if (hasTagalog) return 'tagalog';
    if (hasEnglish) return 'english';
    return null; // e.g. "ok" or "BPLO?": let the model decide
  }

  static String _languageInstruction(String latestUserMessage) {
    const descriptions = {
      'tagalog': 'Tagalog (natural Filipino)',
      'english': 'English',
      'taglish': 'Taglish (mix Tagalog and English casually, the way the user wrote)',
    };
    final language = detectLanguage(latestUserMessage);
    final choice = language == null
        ? 'the language of this latest user message: "$latestUserMessage"'
        : '${descriptions[language]}, so reply_language = "$language"';
    return 'Write the answer in $choice. This only sets the language; '
        'still follow every other rule, including calling get_service_details when needed.';
  }

  static const _tagalogWords = {
    'ang', 'ng', 'nang', 'mga', 'sa', 'si', 'ni', 'ko', 'mo', 'ka', 'ako', 'ikaw', 'siya', 'kami',
    'tayo', 'kayo', 'sila', 'niya', 'namin', 'natin', 'nila', 'nyo', 'niyo', 'ninyo', 'po', 'opo',
    'ho', 'ba', 'pa', 'na', 'naman', 'lang', 'lamang', 'din', 'rin', 'daw', 'raw', 'nga', 'yung',
    'iyong', 'ung', 'ano', 'anong', 'paano', 'pano', 'papaano', 'saan', 'san', 'nasaan', 'sino',
    'kailan', 'kelan', 'magkano', 'gaano', 'bakit', 'ilan', 'alin', 'kailangan', 'gusto', 'pwede',
    'puwede', 'pede', 'meron', 'mayroon', 'wala', 'walang', 'hindi', 'di', 'oo', 'salamat', 'ito',
    'iyan', 'yan', 'iyon', 'yon', 'dito', 'diyan', 'dyan', 'doon', 'para', 'kung', 'kasi', 'dahil',
    'pero', 'tapos', 'kumuha', 'makakuha', 'kukuha', 'kamusta', 'kumusta', 'magandang', 'sayo',
    'sakin', 'akin', 'atin', 'bayad', 'magbayad',
  };

  static const _englishWords = {
    'the', 'a', 'an', 'is', 'are', 'was', 'were', 'be', 'been', 'do', 'does', 'did', 'what', 'how',
    'where', 'when', 'who', 'which', 'why', 'can', 'could', 'would', 'should', 'will', 'i', "i'm",
    'you', 'my', 'your', 'me', 'we', 'our', 'they', 'it', 'its', 'this', 'that', 'these', 'those',
    'for', 'of', 'to', 'from', 'with', 'about', 'much', 'many', 'there', 'here', 'need', 'get',
    'please', 'hello', 'hi', 'thanks', 'thank', 'and', 'or', 'if', 'not', 'have', 'has', 'any',
    'some', 'also', 'just', 'only', 'in', 'on', 'by',
  };

  static String _clean(String text) => text.replaceAll(RegExp(r'\s+'), ' ').trim();

  static String _orNotListed(String text) => _clean(text).isEmpty ? 'not listed' : _clean(text);

  // Keeps the catalog small: first sentence of the description, at most ~100 characters
  static String _firstSentence(String description) {
    final sentence = _clean(description).split(RegExp(r'(?<=\.)\s')).first;
    return sentence.length <= 100 ? sentence : '${sentence.substring(0, 100).trimRight()}…';
  }

  static const _tools = [
    {
      'type': 'function',
      'function': {
        'name': 'get_service_details',
        'strict': true,
        'description':
            'Get full details of Biñan City Hall services: requirements, step-by-step procedure, '
            'fees, processing time, and persons in charge.',
        'parameters': {
          'type': 'object',
          'additionalProperties': false,
          'required': ['service_ids'],
          'properties': {
            'service_ids': {
              'type': 'array',
              'items': {'type': 'string'},
              'description': 'Service IDs from the catalog (max 3).',
            },
          },
        },
      },
    },
  ];

  static const _responseFormat = {
    'type': 'json_schema',
    'json_schema': {
      'name': 'chat_reply',
      'strict': true,
      'schema': {
        'type': 'object',
        'additionalProperties': false,
        'required': ['reply_language', 'category', 'answer', 'service_ids', 'answered_topic'],
        // reply_language comes first so the model commits to the language before writing the answer
        'properties': {
          'reply_language': {
            'type': 'string',
            'enum': ['english', 'tagalog', 'taglish'],
          },
          'category': {
            'type': 'string',
            'enum': ['greeting', 'specific_service', 'general', 'office_info', 'off_topic', 'not_found'],
          },
          'answer': {
            'type': 'object',
            'additionalProperties': false,
            'required': ['intro', 'list_style', 'items', 'closing'],
            'properties': {
              'intro': {'type': 'string'},
              'list_style': {
                'type': 'string',
                'enum': ['none', 'bullets', 'numbered'],
              },
              'items': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'additionalProperties': false,
                  'required': ['point', 'details'],
                  'properties': {
                    'point': {'type': 'string'},
                    'details': {
                      'type': 'array',
                      'items': {'type': 'string'},
                    },
                  },
                },
              },
              'closing': {'type': 'string'},
            },
          },
          'service_ids': {
            'type': 'array',
            'items': {'type': 'string'},
          },
          'answered_topic': {
            'type': 'string',
            'enum': ['requirements', 'steps', 'fees', 'processing_time', 'persons_in_charge', 'overview', 'none'],
          },
        },
      },
    },
  };

  static const _systemPrompt = '''
You are DocsEase Bot, the virtual assistant of Biñan City Hall (City of Biñan, Laguna, Philippines). You ONLY help people with Biñan City Hall offices, services, and document processes.

KNOWLEDGE RULES
- Your only source of truth is the Biñan City Hall data below and the get_service_details tool. Never use general knowledge about other city halls, other cities, or the internet. Never invent requirements, fees, steps, processing times, names, schedules, or contacts.
- Before answering about a specific service's requirements, steps, fees, processing time, or persons in charge, call get_service_details with its service ID from the catalog.
- If the data does not contain what the user asked, say Biñan City Hall's records here don't include that information and suggest visiting or contacting the office in charge (use its contact details only if listed).
- Always name "Biñan City Hall" (e.g., "Biñan City Hall's offices are open Mon-Fri, 8AM-5PM"), never talk about city halls in general.

CATEGORIES (choose one)
- greeting: greetings or small talk. Reply with a short friendly greeting and ask what Biñan City Hall document or service they need.
- specific_service: the user asks about ONE particular service, including follow-up questions about the service being discussed (e.g., "magkano?", "who is in charge?"). Answer ONLY the exact part asked and nothing else:
  - requirements: list only the requirements (with where to secure them if listed).
  - steps: list only the step names and what to do; no fees, processing times, or persons in charge. Also use steps for "how do I get/apply/renew" questions (e.g., "paano mag-renew ng business permit?", "how do I get a cedula?"). If a step says to submit the requirements, do not list the requirements. If the service has several options (e.g., Walk-In and Online), give the steps of the first option only and mention the other options exist.
  - fees: only the fees. processing_time: only the processing time. persons_in_charge: only the persons in charge.
  - overview: if they only ask what the service is (e.g., "what is a cedula?"), answer in 1-2 sentences saying what it is and which office handles it.
  Never combine parts the user did not ask for (e.g., no steps when asked for requirements, no requirements and steps when asked how to get it).
  service_ids MUST be [that service ID], also for follow-up questions. answered_topic = the part you answered.
- general: a vague or broad question (e.g., "how do I start a business?", "I need a certificate"). Give a brief 1-2 sentence answer and put up to 3 service IDs in service_ids, most relevant first. Only include services that directly help with what the user wants to do (e.g., for starting a business, not renewals); fewer than 3 is fine. If no service clearly matches, use not_found instead. Do not list the suggested services in the answer; they are shown to the user separately.
- office_info: questions about Biñan City Hall's offices, schedule, location, or contact details. Answer from the office data.
- off_topic: anything not about Biñan City Hall services (coding, math, trivia, news, other cities or city halls, personal advice). Politely say you are designed only to answer questions about Biñan City Hall services and document processes, and invite them to ask about those. Do not answer the off-topic question.
- not_found: about a government document or service that is not in Biñan City Hall's list (e.g., passport, driver's license, NBI clearance). Say it is not among Biñan City Hall's services, without saying which other agency handles it. Put up to 3 closely related Biñan City Hall service IDs if any truly relate; otherwise [].
Use service_ids = [] and answered_topic = "none" whenever they don't apply.

LANGUAGE
- Set reply_language from the user's LATEST message only. Ignore the language of earlier messages, your previous answers, and the data.
  - english: the message is in English (e.g., "what are the requirements for a business permit?").
  - tagalog: the message is in Tagalog/Filipino, even if it is short or names a document in English (e.g., "magkano?", "saan po ito?", "paano kumuha ng cedula?", "ano ang kailangan para sa business permit?").
  - taglish: the message mixes Tagalog and English phrasing (e.g., "ano yung requirements for business permit?", "pwede ba mag-apply online?", "how much po yung cedula?").
- Write the WHOLE answer in reply_language: natural Filipino for tagalog, a casual Tagalog-English mix for taglish, plain English for english. Translate the data into that language, but keep official names of offices, services, forms, and documents as written.

STYLE
- Be short and direct.

FORMAT (the answer object)
- intro: the sentence(s) before any list; for answers without a list, the whole answer goes here. When there is a list, keep intro to one short lead-in sentence and don't repeat the list's content in it. Bold the key information with **double asterisks** (e.g., "Biñan City Hall's offices are open **Monday to Friday, 8AM-5PM**.").
- items: use for requirements, steps, fees, persons in charge, or any other list. point = only the main point, short, with no parentheses. details = the extra information that would otherwise go in parentheses or after it, one short line each (e.g., point "Occupancy Permit", details ["If applicable", "Secure at: City Engineering Office"]; point "Application and Assessment", details ["Submit the requirements and fill out the application form."]). Leave items empty when there is no list.
- list_style: "numbered" for steps, "bullets" for other lists, "none" when items is empty.
- closing: an optional short sentence after the list; usually empty.
- Never write Markdown list markers or parentheses in intro or closing.
- Never mention buttons, cards, service IDs, tools, or "the data".

BIÑAN CITY HALL DATA
Offices and their services (service ID in brackets):
{CATALOG}''';
}
