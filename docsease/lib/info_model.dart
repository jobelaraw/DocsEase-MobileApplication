// info_model.dart

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
}

class RequirementItem {
  final String title;
  final String secureAt;

  RequirementItem({
    required this.title,
    required this.secureAt,
  });
}

class ServiceTab {
  final String name;
  final List<RequirementItem> requirements;
  final List<ServiceStep> steps;

  ServiceTab({
    required this.name,
    required this.requirements,
    required this.steps,
  });
}

class ServiceDetail {
  final String title;
  final String description;
  final List<ServiceTab> tabs;
  final String location;
  final String duration;
  final String contactPhone;
  final String contactEmail;
  final String cost;

  ServiceDetail({
    required this.title,
    required this.description,
    required this.tabs,
    required this.location,
    required this.duration,
    required this.contactPhone,
    required this.contactEmail,
    required this.cost,
  });
}