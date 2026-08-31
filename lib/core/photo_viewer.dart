import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Full-screen photo viewer with pinch-zoom. Pass either [bytes] (a photo
/// just captured) or [url] (a signed URL from storage).
void openPhotoViewer(BuildContext context, {Uint8List? bytes, String? url}) {
  assert(bytes != null || url != null);
  Navigator.of(context).push(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 6,
          child: bytes != null
              ? Image.memory(bytes)
              : Image.network(
                  url!,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                              strokeWidth: 3, color: Colors.white70)),
                  errorBuilder: (context, error, stack) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white38,
                      size: 48),
                ),
        ),
      ),
    ),
  ));
}
