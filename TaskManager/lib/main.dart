export 'app.dart';

import 'package:flutter/material.dart';
import 'app.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool loggedIn = false;
  try {
    final authService = AuthService();
    loggedIn = await authService.isLoggedIn();
  } catch (_) {
    loggedIn = false;
  }

  runApp(TaskManagerApp(isLoggedIn: loggedIn));
}
