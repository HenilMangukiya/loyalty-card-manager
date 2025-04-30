import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../providers/card_provider.dart';
import '../models/loyalty_card.dart';
import 'card_detail_screen.dart';
import 'edit_card_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expiringCards = context.watch<CardProvider>().getExpiringCards();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expiration Notifications'),
      ),
      body: expiringCards.isEmpty
          ? const Center(
              child: Text(
                'No expiring cards found',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expiringCards.length,
              itemBuilder: (context, index) {
                final card = expiringCards[index];
                final daysUntilExpiration =
                    card.expiryDate!.difference(DateTime.now()).inDays;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        daysUntilExpiration.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      card.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expires on: ${DateFormat('MMM d, yyyy').format(card.expiryDate!)}',
                        ),
                        Text(
                          daysUntilExpiration == 0
                              ? 'Expires today!'
                              : daysUntilExpiration == 1
                                  ? 'Expires tomorrow!'
                                  : '$daysUntilExpiration days remaining',
                          style: TextStyle(
                            color: daysUntilExpiration <= 7
                                ? Colors.red
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () => _showCardDetails(context, card),
                    ),
                    onTap: () => _showCardDetails(context, card),
                  ),
                );
              },
            ),
    );
  }

  void _showCardDetails(BuildContext context, LoyaltyCard card) {
    final daysUntilExpiration =
        card.expiryDate!.difference(DateTime.now()).inDays;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.only(top: 50),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (card.logoPath != null)
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: FileImage(File(card.logoPath!)),
                        )
                      else
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            card.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              daysUntilExpiration == 0
                                  ? 'Expires today!'
                                  : daysUntilExpiration == 1
                                      ? 'Expires tomorrow!'
                                      : '$daysUntilExpiration days remaining',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: daysUntilExpiration <= 7
                                        ? Colors.red
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (card.cardNumber.isNotEmpty)
                    Text(
                      'Card Number: ${card.cardNumber}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  if (card.barcode != null && card.barcode!.isNotEmpty)
                    Text(
                      'Barcode: ${card.barcode}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  Text(
                    'Expiry Date: ${DateFormat('MMM d, yyyy').format(card.expiryDate!)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Card'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCardScreen(card: card),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
