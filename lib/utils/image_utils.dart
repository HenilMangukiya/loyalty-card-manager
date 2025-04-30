import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageUtils {
  static Future<String?> saveImage(File imageFile) async {
    try {
      // Get the application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');

      // Create the images directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate a unique filename
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final savedImage = File('${imagesDir.path}/$fileName');

      // Copy the image to the new location
      await imageFile.copy(savedImage.path);

      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  static Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null) return;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
