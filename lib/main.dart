import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:loyalti_card/models/loyalty_card.dart';
import 'package:loyalti_card/models/user.dart';
import 'package:loyalti_card/providers/auth_provider.dart';
import 'package:loyalti_card/providers/card_provider.dart';
import 'package:loyalti_card/services/notification_service.dart';
import 'package:loyalti_card/services/sync_service.dart';
import 'package:loyalti_card/screens/splash_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(LoyaltyCardAdapter());
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<LoyaltyCard>('loyalty_cards');
  await Hive.openBox<User>('users');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => CardProvider()..initialize()),
        ChangeNotifierProvider(
            create: (_) => NotificationService()..initialize()),
        ChangeNotifierProvider(create: (_) => SyncService()),
        Provider(create: (_) => ConnectivityService()),
      ],
      child: MaterialApp(
        title: 'Loyalty Card Manager',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.light(
            primary: Colors.blue,
            secondary: Colors.blueAccent,
            surface: Colors.white,
            background: Colors.grey[50]!,
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(
            primary: Colors.blue,
            secondary: Colors.blueAccent,
            surface: const Color(0xFF1E1E1E),
            background: const Color(0xFF121212),
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged;
}

Future<void> _showAddCardDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final barcodeController = TextEditingController();
  String? logoPath;

  final result = await showDialog<LoyaltyCard>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add New Card'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Card Name'),
          ),
          TextField(
            controller: cardNumberController,
            decoration: const InputDecoration(labelText: 'Card Number'),
          ),
          TextField(
            controller: barcodeController,
            decoration: const InputDecoration(labelText: 'Barcode (Optional)'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final image =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (image != null) {
                logoPath = image.path;
              }
            },
            child: const Text('Add Logo'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (nameController.text.isNotEmpty &&
                cardNumberController.text.isNotEmpty) {
              final card = LoyaltyCard(
                id: const Uuid().v4(),
                name: nameController.text,
                cardNumber: cardNumberController.text,
                barcode: barcodeController.text.isEmpty
                    ? null
                    : barcodeController.text,
                logoPath: logoPath,
              );
              Navigator.pop(context, card);
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );

  if (result != null) {
    final loyaltyCardBox = Hive.box<LoyaltyCard>('loyalty_cards');
    await loyaltyCardBox.add(result);
  }
}
