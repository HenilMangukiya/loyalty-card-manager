import 'dart:io';
import 'package:hive/hive.dart';

part 'loyalty_card.g.dart';

@HiveType(typeId: 0)
class LoyaltyCard extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String cardNumber;

  @HiveField(3)
  final String? barcode;

  @HiveField(4)
  final DateTime? expiryDate;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final String? logoPath;

  @HiveField(7)
  final int points;

  @HiveField(8)
  final bool needsSync;

  LoyaltyCard({
    required this.id,
    required this.name,
    required this.cardNumber,
    this.barcode,
    this.expiryDate,
    this.notes,
    this.logoPath,
    this.points = 0,
    this.needsSync = true,
  });

  LoyaltyCard copyWith({
    String? id,
    String? name,
    String? cardNumber,
    String? barcode,
    DateTime? expiryDate,
    String? notes,
    String? logoPath,
    int? points,
    bool? needsSync,
  }) {
    return LoyaltyCard(
      id: id ?? this.id,
      name: name ?? this.name,
      cardNumber: cardNumber ?? this.cardNumber,
      barcode: barcode ?? this.barcode,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      logoPath: logoPath ?? this.logoPath,
      points: points ?? this.points,
      needsSync: needsSync ?? this.needsSync,
    );
  }
}
