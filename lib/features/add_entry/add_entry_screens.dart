import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme.dart';
import '../../data/backend.dart';
import '../../data/models.dart';
import '../session/session_cubit.dart';
import '../timeline/timeline_cubit.dart';

/// Hands a capture to the timeline: the item appears on the home screen at
/// once and parses in place — no intermediate screens.
void fileCapture(BuildContext context, CaptureMode mode,
    {String? noteText, Uint8List? imageBytes}) {
  final session = context.read<SessionCubit>().state;
  final homeId = session is SessionReady ? session.homeId : null;
  context.read<TimelineCubit>().captureAndFile(
        mode,
        noteText: noteText,
        imageBytes: imageBytes,
        homeId: homeId,
        returnReminderTitle: context.l10n.returnWindowReminder,
      );
}

/// Camera button flow: open the sheet, then file whatever comes back. The
/// AI works out nameplate vs receipt itself — no mode to pick.
Future<void> startCapture(BuildContext context, [CaptureMode mode = CaptureMode.photo]) async {
  final result = await showCaptureSheet(context, mode);
  if (result == null || !context.mounted) return;
  fileCapture(context, result.mode, imageBytes: result.bytes);
}

/// Camera as a bottom sheet (ChatGPT-style): the live viewfinder slides up
/// over the current screen as a rounded panel, controls overlaid inside it.
/// Resolves with the captured bytes + chosen mode (null bytes = demo mode).
Future<CaptureResult?> showCaptureSheet(BuildContext context, CaptureMode mode) {
  return showModalBottomSheet<CaptureResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    // Size from the screen, not the caller — a button's own render box is tiny.
    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
    builder: (_) => CaptureSheet(mode: mode),
  );
}

class CaptureResult {
  const CaptureResult(this.bytes, this.mode);
  final Uint8List? bytes;
  final CaptureMode mode;
}

class CaptureSheet extends StatefulWidget {
  const CaptureSheet({super.key, required this.mode});
  final CaptureMode mode;

  @override
  State<CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends State<CaptureSheet> {
  late final CaptureMode _mode = widget.mode;
  CameraController? _controller;
  bool _initializing = BackendConfig.enabled;
  bool _shooting = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    if (BackendConfig.enabled) _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('none', 'No camera on this device');
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(back, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _cameraError = '$e';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _shoot() async {
    if (!BackendConfig.enabled) {
      Navigator.of(context).pop(CaptureResult(null, _mode)); // demo: canned parse
      return;
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      // Camera unavailable (simulator, denied) — shutter falls through to library.
      await _pickFromLibrary();
      return;
    }
    if (_shooting) return;
    setState(() => _shooting = true);
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      if (mounted) Navigator.of(context).pop(CaptureResult(bytes, _mode));
    } catch (e) {
      if (mounted) {
        setState(() => _shooting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.cameraUnavailable('$e'))));
      }
    }
  }

  Future<void> _pickFromLibrary() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 82,
      );
      if (file == null) return; // user cancelled the picker, keep the sheet
      final bytes = await file.readAsBytes();
      if (mounted) Navigator.of(context).pop(CaptureResult(bytes, _mode));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.photoReadError('$e'))));
      }
    }
  }

  Widget _roundButton({required Widget child, VoidCallback? onTap, Key? key}) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.45),
        ),
        child: child,
      ),
    );
  }

  Widget _viewfinder(BuildContext context, bool isNameplate) {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      final preview = controller.value.previewSize!;
      return FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          // Preview size is landscape; swap for portrait rendering.
          width: preview.height,
          height: preview.width,
          child: CameraPreview(controller),
        ),
      );
    }
    if (_initializing) {
      return const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(strokeWidth: 3, color: MaisonColors.accent),
        ),
      );
    }
    // Demo mode, or the camera failed (e.g. simulators have none).
    return Container(
      color: const Color(0xFF15181F),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.center_focus_weak, size: 56, color: Colors.white.withValues(alpha: 0.8)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _cameraError != null
                    ? context.l10n.cameraUnavailable(_cameraError!)
                    : _mode == CaptureMode.photo
                        ? context.l10n.hintPhotoDemo
                        : (isNameplate
                            ? context.l10n.hintNameplateDemo
                            : context.l10n.hintReceiptDemo),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75), fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNameplate = _mode == CaptureMode.nameplate;
    final cameraLive = _controller?.value.isInitialized ?? false;
    return FractionallySizedBox(
      heightFactor: 0.86,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _viewfinder(context, isNameplate),
            if (cameraLive)
              Positioned(
                top: 14,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    (_mode == CaptureMode.photo
                            ? context.l10n.hintPhotoLive
                            : isNameplate
                                ? context.l10n.hintNameplateLive
                                : context.l10n.hintReceiptLive)
                        .replaceAll('\n', ' '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.35),
                  ),
                ),
              ),
            Positioned(
              left: 28,
              right: 28,
              bottom: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _roundButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
                  ),
                  GestureDetector(
                    key: const Key('capture'),
                    onTap: _shooting ? null : _shoot,
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white70, width: 3),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _shooting ? Colors.white54 : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (BackendConfig.enabled)
                    _roundButton(
                      onTap: _pickFromLibrary,
                      child: const Icon(Icons.photo_library_outlined,
                          color: Colors.white, size: 24),
                    )
                  else
                    const SizedBox(width: 52),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

