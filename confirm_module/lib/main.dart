import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/confirm_screen.dart';

// DIの組み立て(ネイティブ連携チャンネル・リポジトリ・UseCaseの配線)は
// presentation/confirm_providers.dart のRiverpod providerに集約している。
void main() {
  runApp(const ProviderScope(child: ConfirmApp()));
}

class ConfirmApp extends StatelessWidget {
  const ConfirmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConfirmScreen(),
    );
  }
}
