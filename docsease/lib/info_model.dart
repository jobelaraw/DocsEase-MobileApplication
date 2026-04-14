class ServiceStep {
  final String title;
  final String office;
  final String instruction;

  ServiceStep({
    required this.title,
    required this.office,
    required this.instruction,
  });
}

class ServiceTab {
  final String name; // e.g. "Walk-in", "Online", "Hybrid"
  final List<String> requirements;
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
  final String personnel;
  final String cost;

  ServiceDetail({
    required this.title,
    required this.description,
    required this.tabs, 
    required this.location,
    required this.duration,
    required this.personnel,
    required this.cost,
  });
}