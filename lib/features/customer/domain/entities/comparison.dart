import 'proposal.dart';

class ComparisonItem {
  final String item;
  final bool requested;
  final bool proposed;

  const ComparisonItem({required this.item, required this.requested, required this.proposed});
}

class ProposalComparison {
  final Proposal proposal;
  final String marqueeName;
  final String marqueeCover;
  final String marqueeLocation;
  final String marqueeWhatsapp;
  final num requestedTotal;
  final num requestedPerHead;
  final List<ComparisonItem> menu;
  final List<ComparisonItem> services;

  const ProposalComparison({
    required this.proposal,
    required this.marqueeName,
    required this.marqueeCover,
    required this.marqueeLocation,
    required this.marqueeWhatsapp,
    required this.requestedTotal,
    required this.requestedPerHead,
    required this.menu,
    required this.services,
  });
}
