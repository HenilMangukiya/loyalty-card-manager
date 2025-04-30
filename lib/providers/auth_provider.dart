import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  late Box<User> _usersBox;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    _usersBox = await Hive.openBox<User>('users');
    notifyListeners();
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if user already exists
      if (_usersBox.values.any((user) => user.email == email)) {
        throw 'Email already registered';
      }

      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        password: password,
        name: name,
      );

      await _usersBox.put(user.id, user);
      _currentUser = user;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _usersBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
        orElse: () => throw 'Invalid email or password',
      );

      _currentUser = user;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateUserProfile(String newName) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_currentUser == null) {
        throw 'No user logged in';
      }

      final updatedUser = _currentUser!.copyWith(name: newName);
      await _usersBox.put(updatedUser.id, updatedUser);
      _currentUser = updatedUser;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
