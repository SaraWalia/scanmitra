class Event {
  final String id;
  final String title;
  final DateTime startTime;
  final String venue;
  final String description;

  const Event({
    required this.id,
    required this.title,
    required this.startTime,
    required this.venue,
    required this.description,
  });
}
