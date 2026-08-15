import 'package:flutter/material.dart';

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
    if (language == 'Filipino' && officeNameFil.isNotEmpty) return officeNameFil;
    return officeName;
  }

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      officeId: json['office_id'] ?? '',
      officeName: json['office_name'] ?? '',
      officeNameFil: json['office_name_fil'] ?? '',
      location: json['location'] ?? 'City Hall',
      schedule: json['schedule'] ?? '',
      contactPhone: json['contact_phone'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      services:
          (json['services'] as List<dynamic>?)
              ?.map((e) => ServiceDetail.fromJson(e as Map<String, dynamic>, json))
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
  });

  String getTitle(String language) {
    if (language == 'Filipino' && titleFil.isNotEmpty) return titleFil;
    return title;
  }

  String getDescription(String language) {
    if (language == 'Filipino' && descriptionFil.isNotEmpty) return descriptionFil;
    return description;
  }

  List<ServiceTab> getTabs(String language) {
    if (language == 'Filipino' && tabsFil.isNotEmpty) return tabsFil;
    return tabs;
  }

  factory ServiceDetail.fromJson(Map<String, dynamic> json, Map<String, dynamic> officeJson) {
    return ServiceDetail(
      serviceId: json['service_id'] ?? '',
      title: json['service_name'] ?? '',
      titleFil: json['service_name_fil'] ?? '',
      description: json['description'] ?? '',
      descriptionFil: json['description_fil'] ?? '',
      tabs:
          (json['tabs'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ServiceTab.fromJson(e as Map<String, dynamic>, officeJson['office_name'] ?? ''),
              )
              .toList() ??
          [],
      tabsFil:
          (json['tabs_fil'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ServiceTab.fromFilJson(e as Map<String, dynamic>, officeJson['office_name_fil'] ?? officeJson['office_name'] ?? ''),
              )
              .toList() ??
          [],
      location: json['location'] ?? officeJson['location'] ?? 'City Hall',
      duration: '',
      contactPhone: json['contact_phone'] ?? officeJson['contact_phone'] ?? '',
      contactEmail: json['contact_email'] ?? officeJson['contact_email'] ?? '',
      cost: '',
    );
  }
}

class ServiceTab {
  final String name;
  final List<RequirementItem> requirements;
  final List<ServiceStep> steps;

  ServiceTab({required this.name, required this.requirements, required this.steps});

  factory ServiceTab.fromJson(Map<String, dynamic> json, String officeName) {
    return ServiceTab(
      name: json['tab_name'] ?? '',
      requirements:
          (json['requirements'] as List<dynamic>?)
              ?.map((e) => RequirementItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      steps:
          (json['procedures'] as List<dynamic>?)
              ?.map((e) => ServiceStep.fromJson(e as Map<String, dynamic>, officeName))
              .toList() ??
          [],
    );
  }

  factory ServiceTab.fromFilJson(Map<String, dynamic> json, String officeName) {
    // Debug: check what's in the JSON
    print('=== fromFilJson keys: ${json.keys.toList()}');
    print('=== procedures_fil exists: ${json.containsKey('procedures_fil')}');
    if (json['procedures_fil'] != null) {
      final first = (json['procedures_fil'] as List).isNotEmpty ? (json['procedures_fil'] as List).first : null;
      print('=== first procedures_fil item keys: ${first?.keys?.toList()}');
      print('=== first procedures_fil item: $first');
    }
    // Build Filipino steps by merging translated text with original data
    List<ServiceStep> filSteps = [];
    final origProcedures = json['procedures'] as List<dynamic>? ?? [];
    final filProcedures = json['procedures_fil'] as List<dynamic>? ?? [];

    for (int i = 0; i < origProcedures.length; i++) {
      final orig = origProcedures[i] as Map<String, dynamic>;
      final fil = i < filProcedures.length ? filProcedures[i] as Map<String, dynamic> : {};
      filSteps.add(ServiceStep(
        title: fil['process_name_fil'] ?? orig['process_name'] ?? '',
        office: officeName,
        instruction: fil['process_description_fil'] ?? orig['process_description'] ?? '',
        fee: orig['fee']?.toString() ?? 'None',
        processingTime: fil['processing_time_fil'] ?? orig['processing_time'] ?? '',
        personsInCharge:
            (orig['person_in_charge'] as String?)
                ?.split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList() ??
            [],
      ));
    }

    // Build Filipino requirements by merging
    List<RequirementItem> filReqs = [];
    final origReqs = json['requirements'] as List<dynamic>? ?? [];
    final filReqsList = json['requirements_fil'] as List<dynamic>? ?? [];

    for (int i = 0; i < origReqs.length; i++) {
      final orig = origReqs[i] as Map<String, dynamic>;
      final fil = i < filReqsList.length ? filReqsList[i] as Map<String, dynamic> : {};
      filReqs.add(RequirementItem(
        title: fil['requirement_name_fil'] ?? orig['requirement_name'] ?? '',
        secureAt: fil['secure_at_fil'] ?? orig['secure_at'] ?? '',
      ));
    }

    return ServiceTab(
      name: json['tab_name_fil'] ?? json['tab_name'] ?? '',
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

  ServiceStep({
    required this.title,
    required this.office,
    required this.instruction,
    this.fee = 'None',
    this.processingTime = '',
    this.personsInCharge = const [],
  });

  factory ServiceStep.fromJson(Map<String, dynamic> json, String officeName) {
    String feeStr = json['fee']?.toString() ?? 'None';
    if (feeStr == '0') feeStr = 'None';

    return ServiceStep(
      title: json['process_name'] ?? '',
      office: officeName,
      instruction: json['process_description'] ?? '',
      fee: json['fee'],
      processingTime: json['processing_time'] ?? '',
      personsInCharge:
          (json['person_in_charge'] as String?)
              ?.split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
    );
  }

  factory ServiceStep.fromFilJson(Map<String, dynamic> json, String officeName) {
    return ServiceStep(
      title: json['process_name_fil'] ?? json['process_name'] ?? '',
      office: officeName,
      instruction: json['process_description_fil'] ?? json['process_description'] ?? '',
      fee: json['fee']?.toString() ?? 'None',
      processingTime: json['processing_time'] ?? '',
      personsInCharge:
          (json['person_in_charge'] as String?)
              ?.split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
    );
  }
}

class RequirementItem {
  final String title;
  final String secureAt;

  RequirementItem({required this.title, required this.secureAt});

  factory RequirementItem.fromJson(Map<String, dynamic> json) {
    return RequirementItem(
      title: json['requirement_name'] ?? '',
      secureAt: json['secure_at'] ?? '',
    );
  }

  factory RequirementItem.fromFilJson(Map<String, dynamic> json) {
    return RequirementItem(
      title: json['requirement_name_fil'] ?? json['requirement_name'] ?? '',
      secureAt: json['secure_at_fil'] ?? json['secure_at'] ?? '',
    );
  }
}

class UIHelper {
  // Dynamically assigns an icon based on keywords in the service name
  static IconData getIconForService(String serviceName) {
    final lower = serviceName.toLowerCase();

    if (lower.contains('business') || lower.contains('permit') || lower.contains('license')) {
      return Icons.store;
    }
    if (lower.contains('tax') || lower.contains('fee') || lower.contains('clearance')) {
      return Icons.receipt_long;
    }
    if (lower.contains('construction') ||
        lower.contains('building') ||
        lower.contains('occupancy')) {
      return Icons.construction;
    }
    if (lower.contains('health') || lower.contains('medical') || lower.contains('hospital')) {
      return Icons.health_and_safety;
    }
    if (lower.contains('marriage') || lower.contains('civil') || lower.contains('birth')) {
      return Icons.volunteer_activism;
    }
    if (lower.contains('child') || lower.contains('student')) return Icons.child_care;
    if (lower.contains('environmental') || lower.contains('tree') || lower.contains('waste')) {
      return Icons.eco;
    }
    if (lower.contains('agriculture') || lower.contains('fish')) return Icons.agriculture;
    if (lower.contains('ict') || lower.contains('tech') || lower.contains('online')) {
      return Icons.computer;
    }
    if (lower.contains('legal') || lower.contains('contract') || lower.contains('court')) {
      return Icons.gavel;
    }
    if (lower.contains('cctv') || lower.contains('safety') || lower.contains('order')) {
      return Icons.security;
    }

    return Icons.article; // Default fallback icon
  }

  // Generates a consistent, visually pleasing pastel background color based on the service name
  static Color getBgColorForService(String serviceName) {
    int hash = serviceName.hashCode;

    // Map the hash to a valid Hue degree on the color wheel (0 to 360).
    // .abs() ensures the result is never a negative number.
    double hue = (hash % 360).abs().toDouble();

    // Mix with white to create a pastel color
    // Set Saturation to 0.85 (85%) so the color remains vibrant and rich.
    // Set Lightness to 0.75 (75%) so it acts as a bright background without being pale.
    return HSLColor.fromAHSL(1.0, hue, 0.85, 0.75).toColor();
  }
}
