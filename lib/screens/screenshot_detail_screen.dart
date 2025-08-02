import 'dart:io';
import 'package:flutter/material.dart';

class ScreenshotDetailScreen extends StatelessWidget {
  final File imageFile;
  final DateTime timestamp;
  final String? appName;

  const ScreenshotDetailScreen({
    super.key,
    required this.imageFile,
    required this.timestamp,
    this.appName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta != null && details.primaryDelta! > 8) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: appName != null
              ? Text(
                  appName!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          centerTitle: true,
        ),
        body: Center(
          child: Hero(
            tag: imageFile.path,
            child: Image.file(
              imageFile,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.red.shade900,
                  child: const Icon(Icons.error_outline, color: Colors.white, size: 64),
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.black.withOpacity(0.7),
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${timestamp.day}/${timestamp.month}, ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
