class Proposal {
  final String id;
  final String status;
  final String referenceId;
  final String marqueeName;
  final String? eventDate;
  final String? marqueeCover;
  final num totalPrice;
  final int guests;

  const Proposal({
    required this.id,
    required this.status,
    required this.referenceId,
    required this.marqueeName,
    this.eventDate,
    this.marqueeCover,
    required this.totalPrice,
    required this.guests,
  });
}
