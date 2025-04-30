import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/loyalty_card.dart';
import '../utils/image_utils.dart';
import '../services/notification_service.dart';

class CardProvider with ChangeNotifier {
  late Box<LoyaltyCard> _cardsBox;
  bool _isLoading = false;
  String? _error;
  final NotificationService _notificationService = NotificationService();

  List<LoyaltyCard> get cards => _cardsBox.values.toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    _cardsBox = await Hive.openBox<LoyaltyCard>('loyalty_cards');
    notifyListeners();
  }

  Future<void> addCard(LoyaltyCard card) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _cardsBox.put(card.id, card);
      if (card.expiryDate != null) {
        await _notificationService.scheduleCardExpirationNotification(
          cardName: card.name,
          expirationDate: card.expiryDate!,
          cardId: card.id,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCard(LoyaltyCard card) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _cardsBox.put(card.id, card);
      if (card.expiryDate != null) {
        await _notificationService.scheduleCardExpirationNotification(
          cardName: card.name,
          expirationDate: card.expiryDate!,
          cardId: card.id,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCard(String cardId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final card = _cardsBox.get(cardId);
      if (card != null && card.logoPath != null) {
        await ImageUtils.deleteImage(card.logoPath);
      }

      await _notificationService.cancelNotification(cardId);
      await _cardsBox.delete(cardId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  LoyaltyCard? getCardById(String cardId) {
    return _cardsBox.get(cardId);
  }

  List<LoyaltyCard> searchCards(String query) {
    if (query.isEmpty) return cards;
    return cards.where((card) {
      return card.name.toLowerCase().contains(query.toLowerCase()) ||
          card.cardNumber.contains(query);
    }).toList();
  }

  List<LoyaltyCard> getExpiringCards() {
    final now = DateTime.now();
    return cards.where((card) {
      if (card.expiryDate == null) return false;
      final difference = card.expiryDate!.difference(now);
      return difference.inDays <= 30 && difference.inDays >= 0;
    }).toList();
  }
}
