// legal_content.dart
//
// DRAFT TEXT: have your legal counsel / privacy officer review it before
// release. The draft follows the Data Privacy Act of 2012 (RA 10173) and
// describes what the app currently does. If your data practices change,
// update the text AND bump [version] so users can be asked to accept again.
//
// BLANKS YOU MUST FILL IN (all three are constants right below):
//   1. effectiveDate ... the date this version is released
//   2. operatorName .... who runs GaBayan
//   3. contactEmail .... one email for questions, privacy requests and
//                        data-subject rights

class LegalSection {
  final String heading;
  final String body;
  const LegalSection(this.heading, this.body);
}

class LegalContent {
  LegalContent._();

  /// Bump whenever the text changes. Stored with each new account and on the
  /// device for guests.
  static const String version = '1.0';

  // ── FILL THESE IN ──────────────────────────────────────────────────────────
  static const String effectiveDate = '[Month DD, YYYY]';
  static const String operatorName = '[Name of Operator]';
  static const String contactEmail = '[contact email]';
  // ───────────────────────────────────────────────────────────────────────────

  static const String _charter =
      "2026 Citizen's Charter (1st Edition) of the City Government of Biñan, Laguna";

  // ---------------------------------------------------------------------------
  // TERMS & CONDITIONS
  // ---------------------------------------------------------------------------
  static const String termsIntro =
      'Please read these Terms & Conditions carefully. By creating a GaBayan '
      'account or continuing as a guest, you agree to be bound by them.';

  static const List<LegalSection> terms = [
    LegalSection(
      'About GaBayan',
      'GaBayan is a mobile application that helps people prepare for public '
          'service transactions at Biñan City Hall. It provides requirement '
          'checklists, step-by-step guides, an AI chatbot and indoor navigation.\n\n'
          'GaBayan is a guide only. You cannot submit documents, make payments '
          'or book appointments through the app. Transactions must be completed '
          'in person or through the official channels of the concerned office.',
    ),
    LegalSection(
      'Source of Information',
      'The requirements, step-by-step procedures, fees, processing times and '
          'persons in charge shown in GaBayan are based on the $_charter.\n\n'
          'GaBayan presents this information as a convenient guide. It is not '
          'the official publication, and the published Charter of the City '
          'Government of Biñan remains the authoritative source.\n\n'
          'Offices and services in the app are added, updated and removed by '
          'authorized administrators through the GaBayan web admin, so they '
          'may change at any time.',
    ),
    LegalSection(
      'Accuracy of Information',
      'We work to keep the information up to date, but City Hall policies, '
          'fees and procedures may change without notice, and updates to the '
          'Charter may not appear in the app right away. The final instructions '
          'of the City Hall evaluating officer always prevail over what the '
          'app shows. If you notice a difference, please tell us through the '
          'Contact Us section.',
    ),
    LegalSection(
      'Processing Times and Queues',
      'The processing times shown in GaBayan are taken from the $_charter. '
          'They are estimates and are not guaranteed. Actual time may be '
          'longer, for example when the queue is long, many clients are being '
          'served, the office is busy, the system or power is interrupted or '
          'your requirements are incomplete.\n\n'
          'GaBayan does not operate or control any office or its queue, and '
          'is not responsible for delays or for waiting time that goes beyond '
          'the processing time shown in the app.',
    ),
    LegalSection(
      'Who May Use GaBayan',
      'GaBayan has no age restriction. Anyone who needs to process a document '
          'or transaction at Biñan City Hall, whether a resident or not, is '
          'free to use the app as a guide.\n\n'
          'Creating an account involves personal information. If you are under '
          '18, please create an account only with the knowledge and consent of '
          'a parent or guardian.',
    ),
    LegalSection(
      'Your Account',
      '• Provide accurate information when you sign up.\n'
          '• Keep your password confidential. You are responsible for all '
          'activity under your account.\n'
          '• For your security, the app signs you out after 15 minutes of '
          'inactivity and temporarily locks sign-in for 10 minutes after 5 '
          'consecutive wrong passwords.\n'
          '• Account holders can save progress, use the chatbot and AR '
          'navigation, and receive notifications.',
    ),
    LegalSection(
      'Using GaBayan as a Guest',
      'You may use GaBayan without an account. Guests can browse services and '
          'read requirements and procedures, but cannot save progress, use the '
          'chatbot or AR navigation, or receive notifications. These Terms '
          'apply to guests too.',
    ),
    LegalSection(
      'Notifications',
      'If you have an account and allow notifications, GaBayan may send you '
          'messages about new or changed services. They can arrive even when '
          'the app is closed or running in the background. You can turn '
          'notifications off at any time in the settings of your phone.',
    ),
    LegalSection(
      'Acceptable Use',
      'You agree not to misuse the app, attempt to disrupt it or gain '
          'unauthorized access, impersonate another person, use the chatbot to '
          'produce unlawful, abusive or misleading content, or copy, '
          'reverse-engineer or resell the app except as allowed by law.',
    ),
    LegalSection(
      'AI Chatbot',
      'The GaBayan Bot is an automated assistant, not a City Hall employee, '
          'and its answers are not official statements of the City Government. '
          'The messages you send are processed by OpenAI to generate replies. '
          'Replies may be incomplete or wrong, so please verify important '
          'details with the concerned office. Do not enter sensitive '
          'information such as passwords, ID numbers or bank details in the chat.\n\n'
          'Chatbot replies can be read aloud using the text-to-speech feature '
          'of your device. You may also dictate your messages with the voice '
          'typing of your keyboard, which is provided by your keyboard app and '
          'not by GaBayan.',
    ),
    LegalSection(
      'Indoor Navigation',
      'AR navigation needs camera access and a stable internet connection. '
          'Directions are a guide only and their accuracy is not guaranteed. '
          'Stay aware of your surroundings and follow posted signs and the '
          'instructions of City Hall personnel while walking.',
    ),
    LegalSection(
      'Links to Other Websites',
      'Some steps include links to websites run by others, such as online '
          'forms or payment portals. GaBayan does not control these sites and '
          'is not responsible for their content, availability or charges. Any '
          'payment you make is between you, that provider and the concerned '
          'office.',
    ),
    LegalSection(
      'Ownership',
      'The app, its design and its original content belong to $operatorName. '
          'The names of the City Government of Biñan and its offices, and the '
          'information taken from its Charter, are used in GaBayan only to '
          'inform the public. You may not copy or redistribute the app except '
          'as allowed by law.',
    ),
    LegalSection(
      'Suspension and Deletion',
      'You may delete your account at any time from your Profile settings, '
          'which permanently erases your saved service history and progress. We '
          'may suspend or remove accounts that violate these Terms.',
    ),
    LegalSection(
      'Disclaimer and Liability',
      'The app is provided "as is" and "as available". To the extent allowed '
          'by Philippine law, $operatorName is not liable for losses caused by '
          'reliance on information in the app, differences between the app and '
          'the official Charter, waiting or processing times longer than '
          'those shown, service interruptions or inaccuracies in navigation. '
          'Please confirm important details with the concerned office.',
    ),
    LegalSection(
      'Changes to These Terms',
      'We may update these Terms. When we do, we will change the version '
          'number and may ask you to review and accept the new version before '
          'you continue using the app.',
    ),
    LegalSection(
      'Governing Law and Contact',
      'These Terms are governed by the laws of the Republic of the '
          'Philippines. For questions, contact $contactEmail.',
    ),
  ];

  // ---------------------------------------------------------------------------
  // PRIVACY POLICY
  // ---------------------------------------------------------------------------
  static const String privacyIntro =
      'This Privacy Policy explains how GaBayan collects, uses, stores and '
      'protects your personal information, in accordance with the Data Privacy '
      'Act of 2012 (Republic Act No. 10173).';

  static const List<LegalSection> privacy = [
    LegalSection(
      'Who Is Responsible',
      'The personal information controller is $operatorName. For privacy '
          'questions or to exercise your rights, contact us at $contactEmail.',
    ),
    LegalSection(
      'Information We Collect',
      '• Account details: username, email address and password. Passwords are '
          'handled by Firebase Authentication and cannot be read by us.\n'
          '• Google sign-in details (name, email address and profile photo) if '
          'you choose Continue with Google.\n'
          '• The profile photo you upload.\n'
          '• Your progress: requirements you check, steps you mark as done and '
          'your service history.\n'
          '• Your conversations with the GaBayan Bot: the messages you type and '
          'the replies you receive.\n'
          '• Notifications sent to your account, and a device notification '
          'token that lets us deliver them to your phone even when the app is '
          'closed.\n'
          '• A record of the version of these documents you accepted, and when.\n'
          '• Camera access, requested only to show AR directions.\n'
          '• Voice: GaBayan does not access your microphone or record your '
          'voice. If you dictate with the voice typing of your keyboard, that '
          'is handled by your keyboard app. Chatbot replies can be read aloud '
          'using the text-to-speech service of your device.\n'
          '• Information stored on your device: your settings (language, dark '
          'mode, font size), offline copies of service information and, if you '
          'use the app as a guest, a random guest ID and your agreement record.',
    ),
    LegalSection(
      'How We Use Your Information',
      'We use your information to create and secure your account, save your '
          'progress, provide chatbot answers, send you notifications about new '
          'or changed services (including when the app is closed), maintain and '
          'improve the app, and comply with the law.',
    ),
    LegalSection(
      'Legal Basis',
      'We process your personal information based on your consent, which you '
          'give by accepting this Policy when you sign up. You may withdraw '
          'your consent by deleting your account.',
    ),
    LegalSection(
      'Who We Share It With',
      'We do not sell your personal information. We use trusted service '
          'providers to run the app: Google Firebase (authentication, '
          'database, storage, cloud functions and notification delivery), '
          'Google Sign-In, and OpenAI, which generates the chatbot replies.\n\n'
          'When you chat with the GaBayan Bot, your messages are sent through '
          'our servers to OpenAI so it can respond. OpenAI processes them '
          'under its own terms and privacy policy and may keep them for a '
          'limited period. Our providers process data only to provide these '
          'services. We may disclose information when required by law or a '
          'lawful order.',
    ),
    LegalSection(
      'Administrators and Access',
      'GaBayan is managed through a web admin used by authorized '
          'administrators. They use it to add and manage offices and services '
          'and to send notifications to users. City Hall offices do not use '
          'GaBayan to process your transactions.\n\n'
          'Administrators do not view your service history or chatbot '
          'conversations. They may access basic account records, such as your '
          'username and email address, only to operate the app, for example to '
          'send notifications or give support.',
    ),
    LegalSection(
      'Storage and Transfers',
      'Your information is stored on Google Firebase servers, and chatbot '
          'messages are processed by OpenAI. Both may be located outside the '
          'Philippines. We use providers that maintain recognized security '
          'standards, and we share only the information needed to run the app.',
    ),
    LegalSection(
      'Retention',
      'We keep your information while your account is active. When you delete '
          'your account, your profile, profile photo, service history, chatbot '
          'conversations and notifications are permanently erased from our '
          'database and storage. Some residual copies may remain in provider '
          'backups for a limited time. Messages already sent to OpenAI are '
          'handled under its own retention practices, which we do not control.\n\n'
          'Information stored on your device stays there until you clear the '
          'app data or uninstall the app.',
    ),
    LegalSection(
      'Security',
      'We apply reasonable organizational, physical and technical safeguards, '
          'including encrypted connections, access controls, automatic '
          'sign-out after inactivity and sign-in lockouts. No system is '
          'completely secure, so please keep your password private.\n\n'
          'If a personal data breach affecting you occurs, we will notify you '
          'and the National Privacy Commission as required by law.',
    ),
    LegalSection(
      'Your Rights',
      'Under the Data Privacy Act you have the right to be informed, to '
          'access, to object, to correct, to erase or block, to data '
          'portability, and to claim damages if your data is misused. You can '
          'edit your profile and delete your account in the app, and you can '
          'turn off notifications in your phone settings. To exercise other '
          'rights, email $contactEmail. You may also file a complaint with the '
          'National Privacy Commission (privacy.gov.ph).',
    ),
    LegalSection(
      'Children and Minors',
      'GaBayan has no age restriction, and guests do not create an account or '
          'profile with us. If you are under 18 and want an account, please ask '
          'a parent or guardian to guide you and give consent. A parent or '
          'guardian may email $contactEmail to ask about, or request deletion '
          'of, the data of a minor.',
    ),
    LegalSection(
      'Changes and Contact',
      'We will change the version number when this Policy is updated and may '
          'ask you to review it again. For questions, contact $contactEmail.',
    ),
  ];
}