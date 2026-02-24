class Caption {
  int startMs;
  int endMs;
  String text;

  Caption({
    required this.startMs,
    required this.endMs,
    required this.text,
  });

  factory Caption.fromJson(Map<String, dynamic> json) {
    return Caption(
      startMs: json['start_ms'] ?? 0,
      endMs: json['end_ms'] ?? 0,
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_ms': startMs,
      'end_ms': endMs,
      'text': text,
    };
  }
}
