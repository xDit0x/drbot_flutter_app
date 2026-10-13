class SaveAlertRequest {
  final String uid, title, body, type;
  final String? route, messageId;

  const SaveAlertRequest({
    required this.uid,
    required this.title,
    required this.body,
    this.type = 'general',
    this.route,
    this.messageId,
  });
}
