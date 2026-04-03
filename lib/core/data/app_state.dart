import 'package:flutter/material.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/card/models/digital_card_model.dart';

/// Global app state — accessed via `appState.xxx` anywhere.
/// Listen with `ListenableBuilder(listenable: appState, ...)`.
class AppState extends ChangeNotifier {
  UserModel? _currentUser;
  DigitalCardModel? _currentCard;
  List<DigitalCardModel> _userCards = const [];
  bool _loadingUser = false;
  bool _loadingCard = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  DigitalCardModel? get currentCard => _currentCard;
  List<DigitalCardModel> get userCards => List.unmodifiable(_userCards);
  bool get loadingUser => _loadingUser;
  bool get loadingCard => _loadingCard;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  void setUser(UserModel? user) {
    _currentUser = user;
    _error = null;
    notifyListeners();
  }

  void setCard(DigitalCardModel? card) {
    _currentCard = card;
    if (card == null) {
      _userCards = const [];
    } else {
      final index = _userCards.indexWhere((item) => item.id == card.id);
      if (index == -1) {
        _userCards = [..._userCards, card];
      } else {
        final updated = [..._userCards];
        updated[index] = card;
        _userCards = updated;
      }
    }
    notifyListeners();
  }

  void setCards(List<DigitalCardModel> cards, {String? selectedCardId}) {
    _userCards = List<DigitalCardModel>.unmodifiable(cards);
    if (_userCards.isEmpty) {
      _currentCard = null;
      notifyListeners();
      return;
    }

    final preferredId = selectedCardId ?? _currentCard?.id;
    final selected = preferredId == null
        ? _userCards.first
        : _userCards.cast<DigitalCardModel?>().firstWhere(
            (card) => card?.id == preferredId,
            orElse: () => _userCards.first,
          )!;
    _currentCard = selected;
    notifyListeners();
  }

  void selectCardById(String cardId) {
    final selected = _userCards.cast<DigitalCardModel?>().firstWhere(
      (card) => card?.id == cardId,
      orElse: () => null,
    );
    if (selected == null || selected.id == _currentCard?.id) return;
    _currentCard = selected;
    notifyListeners();
  }

  void addCard(DigitalCardModel card, {bool select = true}) {
    final existingIndex = _userCards.indexWhere((item) => item.id == card.id);
    if (existingIndex == -1) {
      _userCards = [..._userCards, card];
    } else {
      final updated = [..._userCards];
      updated[existingIndex] = card;
      _userCards = updated;
    }
    if (select || _currentCard == null) {
      _currentCard = card;
    }
    notifyListeners();
  }

  void removeCard(String cardId) {
    _userCards = _userCards.where((card) => card.id != cardId).toList();
    if (_currentCard?.id == cardId) {
      _currentCard = _userCards.isEmpty ? null : _userCards.first;
    }
    notifyListeners();
  }

  void updateCard(DigitalCardModel card) {
    _currentCard = card;
    final index = _userCards.indexWhere((item) => item.id == card.id);
    if (index == -1) {
      _userCards = [..._userCards, card];
    } else {
      final updated = [..._userCards];
      updated[index] = card;
      _userCards = updated;
    }
    notifyListeners();
  }

  void setLoadingUser(bool v) {
    _loadingUser = v;
    notifyListeners();
  }

  void setLoadingCard(bool v) {
    _loadingCard = v;
    notifyListeners();
  }

  void setError(String? e) {
    _error = e;
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    _currentCard = null;
    _userCards = const [];
    _loadingUser = false;
    _loadingCard = false;
    _error = null;
    notifyListeners();
  }
}

/// Global singleton — import and use directly.
final appState = AppState();
