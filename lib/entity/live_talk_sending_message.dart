class LiveTalkSendingMessage {
  final String? message;
  final String? quoteId;
  final List<String>? paths;

  const LiveTalkSendingMessage._({
    this.message,
    this.paths,
    this.quoteId,
  });

  factory LiveTalkSendingMessage.createTxtSendMessage({
    required String message,
    String? quoteId,
  }) {
    return LiveTalkSendingMessage._(
      message: message,
      quoteId: quoteId,
    );
  }

  factory LiveTalkSendingMessage.createTxtSendFiles({required List<String> paths}) {
    return LiveTalkSendingMessage._(
      paths: paths,
    );
  }
}
