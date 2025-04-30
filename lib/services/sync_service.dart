import '../models/loyalty_card.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

class SyncService extends ChangeNotifier {
  final Box<LoyaltyCard> _cardsBox = Hive.box<LoyaltyCard>('loyalty_cards');

  Future<void> syncCards() async {
    try {
      // Get all local cards
      final localCards = _cardsBox.values.toList();

      // Mark all cards as synced
      for (final card in localCards) {
        await _cardsBox.put(card.id, card.copyWith(needsSync: false));
      }
    } catch (e) {
      print('Error syncing cards: $e');
    }
  }

  Future<void> uploadCard(LoyaltyCard card) async {
    try {
      await _cardsBox.put(card.id, card.copyWith(needsSync: false));
    } catch (e) {
      print('Error uploading card: $e');
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      await _cardsBox.delete(cardId);
    } catch (e) {
      print('Error deleting card: $e');
    }
  }
}
