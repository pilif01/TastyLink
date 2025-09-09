import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ocr_service.dart';

class CameraService {
  static CameraService? _instance;
  static CameraService get instance => _instance ??= CameraService._();
  
  CameraService._();
  
  final ImagePicker _imagePicker = ImagePicker();
  
  /// Check camera permission
  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    
    return false;
  }
  
  /// Take photo from camera
  Future<File?> takePhoto() async {
    try {
      final hasPermission = await checkCameraPermission();
      if (!hasPermission) {
        throw Exception('Permisiunea camerei a fost refuzată');
      }
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        return File(image.path);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      rethrow;
    }
  }
  
  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        return File(image.path);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      rethrow;
    }
  }
  
  /// Extract recipe from camera image
  Future<RecipeExtractionResult> extractRecipeFromCamera() async {
    try {
      final imageFile = await takePhoto();
      if (imageFile == null) {
        throw Exception('Nu s-a selectat nicio imagine');
      }
      
      return await OcrService.instance.extractRecipeFromImage(imageFile);
    } catch (e) {
      debugPrint('Error extracting recipe from camera: $e');
      rethrow;
    }
  }
  
  /// Extract recipe from gallery image
  Future<RecipeExtractionResult> extractRecipeFromGallery() async {
    try {
      final imageFile = await pickImageFromGallery();
      if (imageFile == null) {
        throw Exception('Nu s-a selectat nicio imagine');
      }
      
      return await OcrService.instance.extractRecipeFromImage(imageFile);
    } catch (e) {
      debugPrint('Error extracting recipe from gallery: $e');
      rethrow;
    }
  }
  
  /// Show image source selection dialog
  Future<File?> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<File?>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selectează sursa imaginii',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.of(context).pop();
                final image = await takePhoto();
                if (image != null) {
                  Navigator.of(context).pop(image);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () async {
                Navigator.of(context).pop();
                final image = await pickImageFromGallery();
                if (image != null) {
                  Navigator.of(context).pop(image);
                }
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anulează'),
            ),
          ],
        ),
      ),
    );
  }
}
