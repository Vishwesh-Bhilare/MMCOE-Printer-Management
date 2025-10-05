import 'package:firebase_core/firebase_core.dart';

/// Setup Firebase for widget/unit tests
Future<void> setupFirebaseMocks() async {
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'fake',
      appId: 'fake',
      messagingSenderId: 'fake',
      projectId: 'fake',
    ),
  );
}
