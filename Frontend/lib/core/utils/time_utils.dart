String friendlyTimestamp(String ts) {
  try {
    final dt = DateTime.parse(ts).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    // date format: Mon DD, YYYY HH:MM
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final m = months[dt.month - 1];
    final hh = dt.hour.toString().padLeft(2,'0');
    final mm = dt.minute.toString().padLeft(2,'0');
    return '$m ${dt.day}, ${dt.year} $hh:$mm';
  } catch (_) {
    return ts;
  }
}
