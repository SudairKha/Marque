import 'package:intl/intl.dart';

String money(num? n) => 'PKR ${NumberFormat('#,##0').format(n ?? 0)}';

String fmtDate(String? d) {
  if (d == null || d.isEmpty) return '—';
  try { return DateFormat('dd MMM yyyy').format(DateTime.parse(d)); }
  catch (_) { return d; }
}

String ago(DateTime? ts) {
  if (ts == null) return '';
  final s = DateTime.now().difference(ts).inSeconds;
  if (s < 60) return 'just now';
  if (s < 3600) return '${s ~/ 60}m ago';
  if (s < 86400) return '${s ~/ 3600}h ago';
  return '${s ~/ 86400}d ago';
}

String initials(String? n) {
  final p = (n ?? '?').trim().split(RegExp(r'\s+'));
  return ((p[0].isEmpty ? '?' : p[0][0]) + (p.length > 1 ? p[1][0] : '')).toUpperCase();
}

String eventImage(String type) {
  const map = {
    'Wedding': 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=400',
    'Engagement': 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?q=80&w=400',
    'Corporate': 'https://images.unsplash.com/photo-1511578314322-379afb476865?q=80&w=400',
    'Birthday': 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?q=80&w=400',
  };
  return map[type] ?? 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?q=80&w=400';
}

const fallbackImage = 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=400';
const foodFallback = 'https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=200';
