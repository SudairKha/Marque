class Requirement {
  final String id;
  final String referenceId;
  final String eventType;
  final String eventDate;
  final String location;
  final String? eventTime;
  final int guests;
  final num budget;

  const Requirement({
    required this.id,
    required this.referenceId,
    required this.eventType,
    required this.eventDate,
    required this.location,
    this.eventTime,
    required this.guests,
    required this.budget,
  });
}
