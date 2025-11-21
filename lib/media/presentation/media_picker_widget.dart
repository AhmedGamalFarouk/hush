/// Media Picker Widget
/// Allows users to pick images, videos, or files for encrypted sharing
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

class MediaPickerWidget extends StatelessWidget {
  final Function(File file, String type) onFilePicked;

  const MediaPickerWidget({required this.onFilePicked, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPickerButton(
            context,
            icon: Icons.photo_library,
            label: 'Photo',
            onTap: () => _pickImage(context, ImageSource.gallery),
          ),
          _buildPickerButton(
            context,
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: () => _pickImage(context, ImageSource.camera),
          ),
          _buildPickerButton(
            context,
            icon: Icons.attach_file,
            label: 'File',
            onTap: () => _pickFile(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: AppTheme.spacing4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);

      if (image != null) {
        final file = File(image.path);
        onFilePicked(file, 'image');
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath != null) {
          final file = File(filePath);
          onFilePicked(file, 'file');
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick file: $e')));
      }
    }
  }

  /// Show media picker bottom sheet
  static void show(
    BuildContext context, {
    required Function(File file, String type) onFilePicked,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MediaPickerWidget(onFilePicked: onFilePicked),
    );
  }
}
