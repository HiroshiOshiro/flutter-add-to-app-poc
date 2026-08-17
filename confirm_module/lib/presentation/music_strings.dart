import 'package:flutter/widgets.dart';

const Map<String, String> _ja = {
  'search_hint': 'アーティストや曲名で検索',
  'search_button': '検索',
  'no_results': '検索結果がありません',
  'search_error': '検索に失敗しました',
  'detail_title': '曲の詳細',
  'label_album': 'アルバム',
  'label_genre': 'ジャンル',
  'action_add_favorite': 'お気に入りに追加',
  'action_remove_favorite': 'お気に入りを解除',
};

const Map<String, String> _en = {
  'search_hint': 'Search by artist or song',
  'search_button': 'Search',
  'no_results': 'No results found',
  'search_error': 'Search failed',
  'detail_title': 'Track details',
  'label_album': 'Album',
  'label_genre': 'Genre',
  'action_add_favorite': 'Add to favorites',
  'action_remove_favorite': 'Remove from favorites',
};

// confirm_module の他画面と同じく flutter_localizations は使わず、ネイティブ側の
// strings.xml / Localizable.strings と同じキーを持つ簡易な辞書で日英を切り替える。
String musicT(String key) {
  final String languageCode =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  final Map<String, String> table = languageCode == 'ja' ? _ja : _en;
  return table[key] ?? key;
}
