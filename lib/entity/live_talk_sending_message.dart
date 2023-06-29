class LiveTalkSendingMessage {
  final String? message;
  final String? quoteId;
  final List<String>? paths;
  final String? sticker;

  const LiveTalkSendingMessage._({
    this.message,
    this.paths,
    this.quoteId,
    this.sticker,
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

  factory LiveTalkSendingMessage.createSendSticker({required String sticker}) {
    return LiveTalkSendingMessage._(
      sticker: sticker,
    );
  }
}
