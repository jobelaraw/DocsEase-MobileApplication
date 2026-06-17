import 'package:flutter/material.dart';

class Office {
  final String officeId;
  final String officeName;
  final String location;
  final String schedule;
  final String contactPhone;
  final String contactEmail;
  final List<ServiceDetail> services;

  Office({
    required this.officeId,
    required this.officeName,
    required this.location,
    required this.schedule,
    required this.contactPhone,
    required this.contactEmail,
    required this.services,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      officeId: json['office_id'] ?? '',
      officeName: json['office_name'] ?? '',
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
  final String description;
  final List<ServiceTab> tabs;
  final String location;
  final String duration;
  final String contactPhone;
  final String contactEmail;
  final String cost;

  ServiceDetail({
    required this.serviceId,
    required this.title,
    required this.description,
    required this.tabs,
    required this.location,
    required this.duration,
    required this.contactPhone,
    required this.contactEmail,
    required this.cost,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json, Map<String, dynamic> officeJson) {
    return ServiceDetail(
      serviceId: json['service_id'] ?? '',
      title: json['service_name'] ?? '',
      description: json['description'] ?? '',
      tabs:
          (json['tabs'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ServiceTab.fromJson(e as Map<String, dynamic>, officeJson['office_name'] ?? ''),
              )
              .toList() ??
          [],
      location: officeJson['location'] ?? 'City Hall',
      duration: '', // Can be aggregated from steps if needed
      contactPhone: officeJson['contact_phone'] ?? '',
      contactEmail: officeJson['contact_email'] ?? '',
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
    // Firestore stores fee as either integer 0 or string. toString() handles both.
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
