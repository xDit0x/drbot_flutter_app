class SaveAlertRequest {
  final String uid;
  final String title;
  final String body;
  final String type;
  final String? route;
  final String? messageId;

  const SaveAlertRequest({
    required this.uid,
    required this.title,
    required this.body,
    this.type = 'general',
    this.route,
    this.messageId,
  });
}
