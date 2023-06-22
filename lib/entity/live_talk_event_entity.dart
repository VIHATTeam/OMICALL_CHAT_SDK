class LiveTalkEventEntity {
  final String eventName;
  final Map<String, dynamic>? data;

  const LiveTalkEventEntity({
    required this.eventName,
    this.data,
  });
}
