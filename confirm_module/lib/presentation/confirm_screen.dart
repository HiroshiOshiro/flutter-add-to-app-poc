import 'package:flutter/material.dart';

import '../domain/entities/confirm_form_data.dart';
import '../domain/usecases/complete_confirmation_usecase.dart';
import '../domain/usecases/get_initial_data_usecase.dart';
import '../domain/usecases/submit_confirmation_usecase.dart';

class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({
    super.key,
    required this.getInitialData,
    required this.submitConfirmation,
    required this.completeConfirmation,
  });

  final GetInitialDataUseCase getInitialData;
  final SubmitConfirmationUseCase submitConfirmation;
  final CompleteConfirmationUseCase completeConfirmation;

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  ConfirmFormData _formData =
      const ConfirmFormData(name: '', email: '', message: '');
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final ConfirmFormData data = await widget.getInitialData();
    if (!mounted) return;
    setState(() {
      _formData = data;
      _loading = false;
    });
  }

  Future<void> _onConfirmTapped() async {
    setState(() => _submitting = true);
    bool success = false;
    try {
      success = await widget.submitConfirmation(_formData);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }

    if (!mounted) return;
    if (success) {
      await widget.completeConfirmation();
    } else {
      _showError();
    }
  }

  void _showError() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(_t('submit_failed')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static const Map<String, String> _ja = {
    'greeting': 'こんにちは!',
    'confirm_title': '入力内容の確認',
    'label_name': '名前',
    'label_email': 'メールアドレス',
    'label_message': 'メッセージ',
    'action_confirm': '確定',
    'submit_failed': '送信に失敗しました',
  };

  static const Map<String, String> _en = {
    'greeting': 'Hello!',
    'confirm_title': 'Confirm your details',
    'label_name': 'Name',
    'label_email': 'Email',
    'label_message': 'Message',
    'action_confirm': 'Confirm',
    'submit_failed': 'Failed to submit',
  };

  // このモジュール単体では flutter_localizations は使わず、ネイティブ側の
  // 文言と同じキーを持つ簡易な辞書で日英を切り替える (呼び出し元アプリの
  // Localizable.strings / strings.xml と対になっている)。
  String _t(String key) {
    final String languageCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final Map<String, String> table = languageCode == 'ja' ? _ja : _en;
    return table[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text(_t('confirm_title'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _t('greeting'),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/profile_banner.png',
                  width: 96,
                  height: 96,
                ),
              ),
              const SizedBox(height: 24),
              _row(_t('label_name'), _formData.name),
              const SizedBox(height: 20),
              _row(_t('label_email'), _formData.email),
              const SizedBox(height: 20),
              _row(_t('label_message'), _formData.message),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitting ? null : _onConfirmTapped,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_t('action_confirm')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 17)),
      ],
    );
  }
}
