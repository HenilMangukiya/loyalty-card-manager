import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/card_provider.dart';
import '../models/loyalty_card.dart';
import 'edit_card_screen.dart';

class CardDetailScreen extends StatelessWidget {
  final LoyaltyCard card;

  const CardDetailScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(card.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EditCardScreen(card: card)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Card'),
                  content: const Text(
                    'Are you sure you want to delete this card?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && context.mounted) {
                final cardProvider = Provider.of<CardProvider>(
                  context,
                  listen: false,
                );
                await cardProvider.deleteCard(card.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (card.logoPath != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  card.logoPath!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.credit_card, size: 100),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Card Number: ${card.cardNumber}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (card.expiryDate != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Expiry Date: ${card.expiryDate!.toLocal().toString().split(' ')[0]}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                    if (card.points != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Points: ${card.points}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (card.barcode?.isNotEmpty ?? false)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Barcode',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      QrImageView(
                        data: card.barcode ?? '',
                        version: QrVersions.auto,
                        size: 200,
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
            if (card.notes != null && card.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(card.notes!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
