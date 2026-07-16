import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(const HasanBabuClinicApp());
}

class HasanBabuClinicApp extends StatelessWidget {
  const HasanBabuClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'हसन बाबू का अस्पताल',
      debugShowCheckedModeBanner: false,
      // 💡 मॉडर्न थीमिंग: ऐप को Material 3 के लुक में अपग्रेड किया
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal, // मुख्य बटन्स और बार्स के लिए
        ),
        fontFamily: 'NotoSansDevanagari',
        // 💡 ऐप बार का बैकग्राउंड कलर हर स्क्रीन पर सेट करने के लिए
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
