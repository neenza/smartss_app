// FILE: lib/widgets/screenshot_grid_item.dart
import 'package:flutter/material.dart';
import 'package:screenshot_manager/screens/screenshot_detail_screen.dart';

class ScreenshotGridItem extends StatelessWidget {
  final List<ScreenshotDetailData> screenshots;
  final int index;

  const ScreenshotGridItem({
    super.key,
    required this.screenshots,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final shot = screenshots[index];
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ScreenshotDetailScreen(
              screenshots: screenshots,
              initialIndex: index,
            ),
          ),
        );
      },
      child: ClipRRect(
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
              '${shot.timestamp.day}/${shot.timestamp.month}, ${shot.timestamp.hour}:${shot.timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          child: Hero(
            tag: shot.imageFile.path,
            child: Image.file(
              shot.imageFile,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Icon(Icons.error_outline),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}