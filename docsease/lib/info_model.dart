
import 'package:flutter/material.dart';

/// Safely converts a Firestore value into a List<String>.
/// Accepts a List or a newline-separated String.
List<String> _stringList(dynamic value) {
  if (value == null) return [];

  if (value is List) {
    return value
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  if (value is String) {
    return value
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  return [];
}

String _stringValue(dynamic value) => value?.toString() ?? '';

class Office {
  final String officeId;
  final String officeName;
  final String officeNameFil;
  final String location;
  final String schedule;
  final String contactPhone;
  final String contactEmail;
  final List<ServiceDetail> services;

  Office({
    required this.officeId,
    required this.officeName,
    required this.officeNameFil,
    required this.location,
    required this.schedule,
    required this.contactPhone,
    required this.contactEmail,
    required this.services,
  });

  String getOfficeName(String language) {
    if (language == 'Filipino' && officeNameFil.isNotEmpty) {
      return officeNameFil;
    }
    return officeName;
  }

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      officeId: _stringValue(json['office_id']),
      officeName: _stringValue(json['office_name']),
      officeNameFil: _stringValue(json['office_name_fil']),
      location: _stringValue(json['location']).isNotEmpty
          ? _stringValue(json['location'])
          : 'City Hall',
      schedule: _stringValue(json['schedule']),
      contactPhone: _stringValue(json['contact_phone']),
      contactEmail: _stringValue(json['contact_email']),
      services: (json['services'] as List<dynamic>?)
          ?.map(
            (e) => ServiceDetail.fromJson(
          Map<String, dynamic>.from(e as Map),
          json,
        ),
      )
          .toList() ??
          [],
    );
  }
}

class ServiceDetail {
  final String serviceId;
  final String title;
  final String titleFil;
  final String description;
  final String descriptionFil;
  final List<ServiceTab> tabs;
  final List<ServiceTab> tabsFil;
  final String location;
  final String duration;
  final String contactPhone;
  final String contactEmail;
  final String cost;

  // Legacy service-level fields kept for compatibility with existing screens.
  final String transactionType;
  final String whoMayAvail;
  final String whoMayAvailFil;
  final String totalFee;
  final String totalFeeFil;
  final String totalProcessingTime;
  final String totalProcessingTimeFil;

  ServiceDetail({
    required this.serviceId,
    required this.title,
    required this.titleFil,
    required this.description,
    required this.descriptionFil,
    required this.tabs,
    required this.tabsFil,
    required this.location,
    required this.duration,
    required this.contactPhone,
    required this.contactEmail,
    required this.cost,
    this.transactionType = '',
    this.whoMayAvail = '',
    this.whoMayAvailFil = '',
    this.totalFee = '',
    this.totalFeeFil = '',
    this.totalProcessingTime = '',
    this.totalProcessingTimeFil = '',
  });

  String getTitle(String language) {
    if (language == 'Filipino' && titleFil.isNotEmpty) return titleFil;
    return title;
  }

  String getDescription(String language) {
    if (language == 'Filipino' && descriptionFil.isNotEmpty) {
      return descriptionFil;
    }
    return description;
  }

  // Legacy getters retained to avoid breaking existing code.
  String getWhoMayAvail(String language) {
    if (language == 'Filipino' && whoMayAvailFil.isNotEmpty) {
      return whoMayAvailFil;
    }
    return whoMayAvail;
  }

  String getTotalFee(String language) {
    if (language == 'Filipino' && totalFeeFil.isNotEmpty) {
      return totalFeeFil;
    }
    return totalFee;
  }

  String getTotalProcessingTime(String language) {
    if (language == 'Filipino' && totalProcessingTimeFil.isNotEmpty) {
      return totalProcessingTimeFil;
    }
    return totalProcessingTime;
  }

  List<ServiceTab> getTabs(String language) {
    if (language == 'Filipino' && tabsFil.isNotEmpty) {
      return tabsFil;
    }
    return tabs;
  }

  factory ServiceDetail.fromJson(
      Map<String, dynamic> json,
      Map<String, dynamic> officeJson,
      ) {
    return ServiceDetail(
      serviceId: _stringValue(json['service_id']),
      title: _stringValue(json['service_name']),
      titleFil: _stringValue(json['service_name_fil']),
      description: _stringValue(json['description']),
      descriptionFil: _stringValue(json['description_fil']),
      tabs: (json['tabs'] as List<dynamic>?)
          ?.map(
            (e) => ServiceTab.fromJson(
          Map<String, dynamic>.from(e as Map),
          _stringValue(officeJson['office_name']),
        ),
      )
          .toList() ??
          [],
      tabsFil: (json['tabs_fil'] as List<dynamic>?)
          ?.map(
            (e) => ServiceTab.fromFilJson(
          Map<String, dynamic>.from(e as Map),
          _stringValue(
            officeJson['office_name_fil'] ??
                officeJson['office_name'],
          ),
        ),
      )
          .toList() ??
          [],
      location: _stringValue(
        json['location'] ?? officeJson['location'],
      ).isNotEmpty
          ? _stringValue(json['location'] ?? officeJson['location'])
          : 'City Hall',
      duration: '',
      contactPhone: _stringValue(
        json['contact_phone'] ?? officeJson['contact_phone'],
      ),
      contactEmail: _stringValue(
        json['contact_email'] ?? officeJson['contact_email'],
      ),
      cost: '',

      // Retain support for older Firestore documents.
      transactionType: _stringValue(json['transaction_type']),
      whoMayAvail: _stringValue(json['who_may_avail']),
      whoMayAvailFil: _stringValue(json['who_may_avail_fil']),
      totalFee: _stringValue(json['total_fee']),
      totalFeeFil: _stringValue(json['total_fee_fil']),
      totalProcessingTime: _stringValue(
        json['total_processing_time'],
      ),
      totalProcessingTimeFil: _stringValue(
        json['total_processing_time_fil'],
      ),
    );
  }
}

class ServiceTab {
  final String name;
  final List<RequirementItem> requirements;
  final List<ServiceStep> steps;

  // These fields now belong to each individual tab.
  final String transactionType;
  final String whoMayAvail;
  final String whoMayAvailFil;
  final String totalFee;
  final String totalFeeFil;
  final String totalProcessingTime;
  final String totalProcessingTimeFil;

  ServiceTab({
    required this.name,
    required this.requirements,
    required this.steps,
    this.transactionType = '',
    this.whoMayAvail = '',
    this.whoMayAvailFil = '',
    this.totalFee = '',
    this.totalFeeFil = '',
    this.totalProcessingTime = '',
    this.totalProcessingTimeFil = '',
  });

  String getWhoMayAvail(String language) {
    if (language == 'Filipino' && whoMayAvailFil.isNotEmpty) {
      return whoMayAvailFil;
    }
    return whoMayAvail;
  }

  String getTotalFee(String language) {
    if (language == 'Filipino' && totalFeeFil.isNotEmpty) {
      return totalFeeFil;
    }
    return totalFee;
  }

  String getTotalProcessingTime(String language) {
    if (language == 'Filipino' &&
        totalProcessingTimeFil.isNotEmpty) {
      return totalProcessingTimeFil;
    }
    return totalProcessingTime;
  }

  factory ServiceTab.fromJson(
      Map<String, dynamic> json,
      String officeName,
      ) {
    return ServiceTab(
      name: _stringValue(json['tab_name']),
      transactionType: _stringValue(json['transaction_type']),
      whoMayAvail: _stringValue(json['who_may_avail']),
      whoMayAvailFil: _stringValue(json['who_may_avail_fil']),
      totalFee: _stringValue(json['total_fee']),
      totalFeeFil: _stringValue(json['total_fee_fil']),
      totalProcessingTime: _stringValue(
        json['total_processing_time'],
      ),
      totalProcessingTimeFil: _stringValue(
        json['total_processing_time_fil'],
      ),
      requirements: (json['requirements'] as List<dynamic>?)
          ?.map(
            (e) => RequirementItem.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
          .toList() ??
          [],
      steps: (json['procedures'] as List<dynamic>?)
          ?.map(
            (e) => ServiceStep.fromJson(
          Map<String, dynamic>.from(e as Map),
          officeName,
        ),
      )
          .toList() ??
          [],
    );
  }

  factory ServiceTab.fromFilJson(
      Map<String, dynamic> json,
      String officeName,
      ) {
    final origProcedures =
        json['procedures'] as List<dynamic>? ?? [];
    final filProcedures =
        json['procedures_fil'] as List<dynamic>? ?? [];

    final filSteps = <ServiceStep>[];

    for (int i = 0; i < origProcedures.length; i++) {
      final orig = Map<String, dynamic>.from(
        origProcedures[i] as Map,
      );
      final fil = i < filProcedures.length
          ? Map<String, dynamic>.from(filProcedures[i] as Map)
          : <String, dynamic>{};

      final filActions = _stringList(fil['agency_actions_fil']);
      final filNotes = _stringValue(fil['notes_fil']).trim();

      filSteps.add(
        ServiceStep(
          title: _stringValue(
            fil['process_name_fil'] ?? orig['process_name'],
          ),
          office: officeName,
          instruction: _stringValue(
            fil['process_description_fil'] ??
                orig['process_description'],
          ),
          fee: _stringValue(orig['fee']).isNotEmpty
              ? _stringValue(orig['fee'])
              : 'None',
          processingTime: _stringValue(
            fil['processing_time_fil'] ??
                orig['processing_time'],
          ),
          personsInCharge: _stringValue(orig['person_in_charge'])
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          onlineLink: _stringValue(orig['online_link']),
          navigateTo: _stringValue(orig['navigate_to']),
          agencyActions: filActions.isNotEmpty
              ? filActions
              : _stringList(orig['agency_actions']),
          notes: filNotes.isNotEmpty
              ? filNotes
              : _stringValue(orig['notes']).trim(),
        ),
      );
    }

    final origReqs = json['requirements'] as List<dynamic>? ?? [];
    final filReqsList =
        json['requirements_fil'] as List<dynamic>? ?? [];
    final filReqs = <RequirementItem>[];

    for (int i = 0; i < origReqs.length; i++) {
      final orig = Map<String, dynamic>.from(origReqs[i] as Map);
      final fil = i < filReqsList.length
          ? Map<String, dynamic>.from(filReqsList[i] as Map)
          : <String, dynamic>{};

      filReqs.add(
        RequirementItem(
          title: _stringValue(
            fil['requirement_name_fil'] ??
                orig['requirement_name'],
          ),
          secureAt: _stringValue(
            fil['secure_at_fil'] ?? orig['secure_at'],
          ),
        ),
      );
    }

    return ServiceTab(
      name: _stringValue(
        json['tab_name_fil'] ?? json['tab_name'],
      ),
      transactionType: _stringValue(json['transaction_type']),
      whoMayAvail: _stringValue(json['who_may_avail']),
      whoMayAvailFil: _stringValue(
        json['who_may_avail_fil'] ?? json['who_may_avail'],
      ),
      totalFee: _stringValue(json['total_fee']),
      totalFeeFil: _stringValue(
        json['total_fee_fil'] ?? json['total_fee'],
      ),
      totalProcessingTime: _stringValue(
        json['total_processing_time'],
      ),
      totalProcessingTimeFil: _stringValue(
        json['total_processing_time_fil'] ??
            json['total_processing_time'],
      ),
      requirements: filReqs,
      steps: filSteps,
    );
  }
}

class ServiceStep {
  final String title;
  final String office;
  final String instruction;
  final String fee;
  final String processingTime;
  final List<String> personsInCharge;
  final String onlineLink;
  final String navigateTo;
  final List<String> agencyActions;
  final String notes;

  ServiceStep({
    required this.title,
    required this.office,
    required this.instruction,
    this.fee = 'None',
    this.processingTime = '',
    this.personsInCharge = const [],
    this.onlineLink = '',
    this.navigateTo = '',
    this.agencyActions = const [],
    this.notes = '',
  });

  factory ServiceStep.fromJson(
      Map<String, dynamic> json,
      String officeName,
      ) {
    String feeStr = _stringValue(json['fee']);
    if (feeStr.isEmpty || feeStr == '0') feeStr = 'None';

    return ServiceStep(
      title: _stringValue(json['process_name']),
      office: officeName,
      instruction: _stringValue(json['process_description']),
      fee: feeStr,
      processingTime: _stringValue(json['processing_time']),
      personsInCharge: _stringValue(json['person_in_charge'])
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      onlineLink: _stringValue(json['online_link']),
      navigateTo: _stringValue(json['navigate_to']),
      agencyActions: _stringList(json['agency_actions']),
      notes: _stringValue(json['notes']).trim(),
    );
  }

  factory ServiceStep.fromFilJson(
      Map<String, dynamic> json,
      String officeName,
      ) {
    final filActions = _stringList(json['agency_actions_fil']);
    final filNotes = _stringValue(json['notes_fil']).trim();

    return ServiceStep(
      title: _stringValue(
        json['process_name_fil'] ?? json['process_name'],
      ),
      office: officeName,
      instruction: _stringValue(
        json['process_description_fil'] ??
            json['process_description'],
      ),
      fee: _stringValue(json['fee']).isNotEmpty
          ? _stringValue(json['fee'])
          : 'None',
      processingTime: _stringValue(
        json['processing_time_fil'] ?? json['processing_time'],
      ),
      personsInCharge: _stringValue(json['person_in_charge'])
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      onlineLink: _stringValue(json['online_link']),
      navigateTo: _stringValue(json['navigate_to']),
      agencyActions: filActions.isNotEmpty
          ? filActions
          : _stringList(json['agency_actions']),
      notes: filNotes.isNotEmpty
          ? filNotes
          : _stringValue(json['notes']).trim(),
    );
  }
}

class RequirementItem {
  final String title;
  final String secureAt;

  RequirementItem({
    required this.title,
    required this.secureAt,
  });

  factory RequirementItem.fromJson(Map<String, dynamic> json) {
    return RequirementItem(
      title: _stringValue(json['requirement_name']),
      secureAt: _stringValue(json['secure_at']),
    );
  }

  factory RequirementItem.fromFilJson(
      Map<String, dynamic> json,
      ) {
    return RequirementItem(
      title: _stringValue(
        json['requirement_name_fil'] ?? json['requirement_name'],
      ),
      secureAt: _stringValue(
        json['secure_at_fil'] ?? json['secure_at'],
      ),
    );
  }
}

class UIHelper {
  static IconData getIconForService(String serviceName) {
    final lower = serviceName.toLowerCase();

    if (lower.contains('business') ||
        lower.contains('permit') ||
        lower.contains('license')) {
      return Icons.store;
    }
    if (lower.contains('tax') ||
        lower.contains('fee') ||
        lower.contains('clearance')) {
      return Icons.receipt_long;
    }
    if (lower.contains('construction') ||
        lower.contains('building') ||
        lower.contains('occupancy')) {
      return Icons.construction;
    }
    if (lower.contains('health') ||
        lower.contains('medical') ||
        lower.contains('hospital')) {
      return Icons.health_and_safety;
    }
    if (lower.contains('marriage') ||
        lower.contains('civil') ||
        lower.contains('birth')) {
      return Icons.volunteer_activism;
    }
    if (lower.contains('child') || lower.contains('student')) {
      return Icons.child_care;
    }
    if (lower.contains('environmental') ||
        lower.contains('tree') ||
        lower.contains('waste')) {
      return Icons.eco;
    }
    if (lower.contains('agriculture') || lower.contains('fish')) {
      return Icons.agriculture;
    }
    if (lower.contains('ict') ||
        lower.contains('tech') ||
        lower.contains('online')) {
      return Icons.computer;
    }
    if (lower.contains('legal') ||
        lower.contains('contract') ||
        lower.contains('court')) {
      return Icons.gavel;
    }
    if (lower.contains('cctv') ||
        lower.contains('safety') ||
        lower.contains('order')) {
      return Icons.security;
    }

    return Icons.article;
  }

  static Color getBgColorForService(String serviceName) {
    final hash = serviceName.hashCode;
    final hue = (hash % 360).abs().toDouble();

    return HSLColor.fromAHSL(
      1.0,
      hue,
      0.85,
      0.75,
    ).toColor();
  }
}
