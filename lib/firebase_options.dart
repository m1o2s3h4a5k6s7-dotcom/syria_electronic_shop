import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBxLY3PT_G-1gaDx69mnWX2386yRy8kGDc",
    authDomain: "syria-electronic-shop.firebaseapp.com",
    projectId: "syria-electronic-shop",
    storageBucket: "syria-electronic-shop.firebasestorage.app",
    messagingSenderId: "911438979009",
    appId: "1:911438979009:web:bdfebb379b80bc651e9940",
    measurementId: "G-4CDKYJMYJG",
  );
}
