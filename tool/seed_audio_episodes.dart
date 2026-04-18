// Seed catalog `audio_episodes` trên Firestore (một bản ghi demo).
//
// Chạy từ thư mục gốc repo:
//   dart run tool/seed_audio_episodes.dart
//
// Điều kiện:
// - Đã `flutterfire configure` và `lib/firebase_options.dart` trùng project.
// - Rules Firestore cho phép GHI collection `audio_episodes` khi chạy script
//   (SDK client không có quyền admin; có thể tạm rule test hoặc nhập tay trên Console).
//
// URL mẫu là audio công khai để kiểm tra phát — thay bằng URL hợp pháp (Zapp English)
// sau khi bạn có quyền phân phối.

import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:walklingo/firebase_options.dart";

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final fs = FirebaseFirestore.instance;

  await fs.collection("audio_episodes").doc("demo_intro").set({
    "title": "[Demo] Thay tiêu đề và streamUrl — ghi nguồn Zapp English",
    "description":
        "Record mẫu để kiểm tra player. Thay streamUrl bài thật từ catalog của bạn.",
    "streamUrl":
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    "durationSec": null,
    "order": 1,
    "sourceName": "Zapp! English",
    "sourceUrl": "https://zappenglish.com/",
    "publishedAt": FieldValue.serverTimestamp(),
  });

  // ignore: avoid_print
  print("Đã ghi audio_episodes/demo_intro (hoặc lỗi quyền Firestore).");
}
