import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../providers/card_provider.dart';
import '../models/loyalty_card.dart';
import '../utils/image_utils.dart';
import 'dart:io';

class EditCardScreen extends StatefulWidget {
  final LoyaltyCard card;

  const EditCardScreen({super.key, required this.card});

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _notesController;
  File? _logoImage;
  DateTime? _expiryDate;
  int? _points;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card.name);
    _cardNumberController = TextEditingController(text: widget.card.cardNumber);
    _barcodeController = TextEditingController(text: widget.card.barcode);
    _notesController = TextEditingController(text: widget.card.notes);
    _expiryDate = widget.card.expiryDate;
    _points = widget.card.points;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final savedPath = await ImageUtils.saveImage(File(pickedFile.path));
      if (savedPath != null) {
        setState(() {
          _logoImage = File(savedPath);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save image')),
        );
      }
    }
  }

  Future<void> _scanBarcode() async {
    try {
      final barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      if (barcode != '-1') {
        setState(() {
          _barcodeController.text = barcode;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error scanning barcode: $e')));
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _updateCard() async {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final updatedCard = widget.card.copyWith(
      name: _nameController.text.trim(),
      cardNumber: _cardNumberController.text.trim(),
      barcode: _barcodeController.text.trim(),
      logoPath: _logoImage?.path ?? widget.card.logoPath,
      expiryDate: _expiryDate,
      points: _points ?? widget.card.points,
      notes: _notesController.text.trim(),
    );

    await cardProvider.updateCard(updatedCard);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Card')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _logoImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_logoImage!, fit: BoxFit.cover),
                      )
                    : widget.card.logoPath != null
                        ? Image.network(
                            widget.card.logoPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child:
                                    Icon(Icons.add_photo_alternate, size: 48),
                              );
                            },
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 48),
                                SizedBox(height: 8),
                                Text('Add Logo'),
                              ],
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Card Name',
                prefixIcon: Icon(Icons.credit_card),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNumberController,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _barcodeController,
                    decoration: const InputDecoration(
                      labelText: 'Barcode',
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _scanBarcode,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _expiryDate == null
                    ? 'Select Expiry Date'
                    : 'Expiry Date: ${_expiryDate!.toLocal().toString().split(' ')[0]}',
              ),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateCard,
              child: const Text('Update Card'),
            ),
          ],
        ),
      ),
    );
  }
}
