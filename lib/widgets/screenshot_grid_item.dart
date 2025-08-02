// FILE: lib/widgets/screenshot_grid_item.dart
import 'dart:io';
import 'package:flutter/material.dart';

class ScreenshotGridItem extends StatelessWidget {
  final File imageFile;
  final DateTime timestamp;

  const ScreenshotGridItem({
    super.key,
    required this.imageFile,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: GridTile(
        footer: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: Text(
            '${timestamp.day}/${timestamp.month}, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
        child: Image.file(
          imageFile,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(context).colorScheme.errorContainer,
              child: const Icon(Icons.error_outline),
            );
          },
        ),
      ),
    );
  }
}