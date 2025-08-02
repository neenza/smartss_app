
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ScreenshotDetailScreen extends StatefulWidget {
  final List<ScreenshotDetailData> screenshots;
  final int initialIndex;

  const ScreenshotDetailScreen({
    super.key,
    required this.screenshots,
    required this.initialIndex,
  });

  @override
  State<ScreenshotDetailScreen> createState() => _ScreenshotDetailScreenState();
}

class ScreenshotDetailData {
  final File imageFile;
  final DateTime timestamp;
  final String? appName;
  ScreenshotDetailData({
    required this.imageFile,
    required this.timestamp,
    this.appName,
  });
}

class _ScreenshotDetailScreenState extends State<ScreenshotDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.screenshots[_currentIndex];
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta != null) {
          if (details.primaryDelta! > 8) {
            Navigator.of(context).pop();
          } else if (details.primaryDelta! < -8) {
            // Swipe up to share
            final current = widget.screenshots[_currentIndex];
            Share.shareXFiles([XFile(current.imageFile.path)], text: current.appName ?? 'Screenshot');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: current.appName != null
              ? Text(
                  current.appName!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          centerTitle: true,
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: widget.screenshots.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            final shot = widget.screenshots[index];
            return Center(
              child: Hero(
                tag: shot.imageFile.path,
                child: Image.file(
                  shot.imageFile,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.red.shade900,
                      child: const Icon(Icons.error_outline, color: Colors.white, size: 64),
                    );
                  },
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: Container(
          color: Colors.black.withOpacity(0.7),
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${current.timestamp.day}/${current.timestamp.month}, ${current.timestamp.hour}:${current.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
