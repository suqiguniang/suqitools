import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/web_card_model.dart';

class WebCardService {
  static const String _webCardsKey = 'web_cards';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<List<WebCardModel>> getWebCards() async {
    final prefs = await _prefs;
    final String? jsonStr = prefs.getString(_webCardsKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((e) => WebCardModel.fromJson(e)).toList();
    } catch (e) {
      print('解析网页卡片失败: $e');
      return [];
    }
  }

  static Future<void> saveWebCards(List<WebCardModel> cards) async {
    final prefs = await _prefs;
    final String jsonStr = jsonEncode(cards.map((e) => e.toJson()).toList());
    await prefs.setString(_webCardsKey, jsonStr);
  }

  static Future<void> addWebCard(WebCardModel card) async {
    final cards = await getWebCards();
    cards.add(card);
    await saveWebCards(cards);
  }

  static Future<void> updateWebCard(WebCardModel card) async {
    final cards = await getWebCards();
    final index = cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      cards[index] = card;
      await saveWebCards(cards);
    }
  }

  static Future<void> deleteWebCard(String id) async {
    final cards = await getWebCards();
    cards.removeWhere((c) => c.id == id);
    await saveWebCards(cards);
  }
}
