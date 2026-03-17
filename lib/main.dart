import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase initialization will be added in Phase 2
  runApp(
    const ProviderScope(
      child: ShreeGirirajApp(),
    ),
  );
}
