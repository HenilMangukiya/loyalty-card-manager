import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/card_provider.dart';
import '../models/loyalty_card.dart';
import 'add_card_screen.dart';
import 'card_detail_screen.dart';
import 'profile_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    await cardProvider.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cardProvider = Provider.of<CardProvider>(context);
    final filteredCards = cardProvider.searchCards(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Loyalty Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search cards...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: cardProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCards.isEmpty
                    ? const Center(child: Text('No loyalty cards found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredCards.length,
                        itemBuilder: (context, index) {
                          final card = filteredCards[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: card.logoPath != null
                                  ? Image.file(
                                      File(card.logoPath!),
                                      width: 48,
                                      height: 48,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.credit_card,
                                          size: 48,
                                        );
                                      },
                                    )
                                  : const Icon(Icons.credit_card, size: 48),
                              title: Text(card.name),
                              subtitle: Text(card.cardNumber),
                              trailing: IconButton(
                                icon: const Icon(Icons.qr_code),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CardDetailScreen(card: card),
                                    ),
                                  );
                                },
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CardDetailScreen(card: card),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddCardScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
