class JournalPrompt {
  final int id;
  final String text;

  JournalPrompt({required this.id, required this.text});

  factory JournalPrompt.fromJson(dynamic json) {
    // Jika backend secara tidak sengaja mengembalikan string murni
    if (json is String) {
      return JournalPrompt(id: 0, text: json);
    }

    // Membaca 'id' sesuai dengan tipe data integer dari backend
    final parsedId = json['id'] as int? ?? 0;

    // PERBAIKAN UTAMA: Membaca kunci 'question' dari Golang
    // Kita tetap memasukkannya ke variabel 'text' di dalam Flutter agar tidak perlu merombak UI
    final parsedText = json['question'] ?? json['text'] ?? '';

    return JournalPrompt(id: parsedId, text: parsedText.toString());
  }
}
