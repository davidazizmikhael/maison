import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n_ext.dart';
import '../../core/photo_viewer.dart';
import '../../core/theme.dart';
import '../../data/backend.dart';
import '../../data/models.dart';
import '../session/session_cubit.dart';
import '../timeline/timeline_cubit.dart';
import 'add_entry_cubit.dart';

/// Route that owns one AddEntryCubit for the parse leg of the journey.
Route<void> parsingRoute(CaptureMode mode, {String? noteText, Uint8List? imageBytes}) {
  return MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => AddEntryCubit(Backend.instance)
        ..parse(mode, noteText: noteText, imageBytes: imageBytes),
      child: ParsingScreen(mode: mode, imageBytes: imageBytes),
    ),
  );
}

/// Camera as a bottom sheet (ChatGPT-style): the live viewfinder slides up
/// over the current screen as a rounded panel, controls overlaid inside it.
/// Resolves with the captured bytes (null bytes = demo mode, proceed without).
Future<void> showCaptureSheet(BuildContext context, CaptureMode mode) async {
  final result = await showModalBottomSheet<CaptureResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    constraints: BoxConstraints(maxHeight: context.size!.height * 0.8),
    builder: (_) => CaptureSheet(mode: mode),
  );
  if (result == null || !context.mounted) return; // dismissed
  Navigator.of(context).push(parsingRoute(mode, imageBytes: result.bytes));
}

class CaptureResult {
  const CaptureResult(this.bytes);
  final Uint8List? bytes;
}

class CaptureSheet extends StatefulWidget {
  const CaptureSheet({super.key, required this.mode});
  final CaptureMode mode;

  @override
  State<CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends State<CaptureSheet> {
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
      Navigator.of(context).pop(const CaptureResult(null)); // demo: canned parse
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
      if (mounted) Navigator.of(context).pop(CaptureResult(bytes));
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
      if (mounted) Navigator.of(context).pop(CaptureResult(bytes));
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
            Text(isNameplate ? '🏷️' : '🧾', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _cameraError != null
                    ? context.l10n.cameraUnavailable(_cameraError!)
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
    final isNameplate = widget.mode == CaptureMode.nameplate;
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
                    (isNameplate ? context.l10n.hintNameplateLive : context.l10n.hintReceiptLive)
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

/// Notes-style "New entry": borderless writing surface, quiet scan chips.
class QuickNoteScreen extends StatefulWidget {
  const QuickNoteScreen({super.key});
  @override
  State<QuickNoteScreen> createState() => _QuickNoteScreenState();
}

class _QuickNoteScreenState extends State<QuickNoteScreen> {
  final _controller = TextEditingController(
      text: 'Fixed the leaky bathroom faucet, Moen cartridge, \$38 at Réno-Dépôt');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _file() {
    Navigator.of(context)
        .pushReplacement(parsingRoute(CaptureMode.note, noteText: _controller.text));
  }

  Widget _scanChip(BuildContext context, IconData icon, String label, CaptureMode mode) {
    return GestureDetector(
      onTap: () async {
        // Pop this screen first, then open the sheet from the navigator's own
        // context — this screen's context is defunct once popped.
        final nav = Navigator.of(context);
        nav.pop();
        await showCaptureSheet(nav.context, mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          border: Border.all(color: context.mc.line),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 17, color: context.mc.navy),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 14, color: context.mc.navy)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 52,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancelButton,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w400, color: context.mc.inkSoft)),
            ),
            Text(context.l10n.newEntryTitle,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            GestureDetector(
              onTap: _file,
              child: Text(context.l10n.fileIt,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700, color: context.mc.accent)),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              minLines: 1,
              autofocus: true,
              style: const TextStyle(fontSize: 19, height: 1.45, letterSpacing: -0.2),
              decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true),
            ),
            const SizedBox(height: 12),
            Text(context.l10n.quickNoteHint,
                style: TextStyle(fontSize: 13, color: context.mc.inkSoft, height: 1.5)),
            const SizedBox(height: 24),
            Wrap(spacing: 10, runSpacing: 10, children: [
              _scanChip(context, Icons.photo_camera_outlined, context.l10n.optionNameplate,
                  CaptureMode.nameplate),
              _scanChip(context, Icons.receipt_long_outlined, context.l10n.optionReceipt,
                  CaptureMode.receipt),
            ]),
          ],
        ),
      ),
    );
  }
}

/// The "AI is working" screen: animated step-by-step progress while the
/// AddEntryCubit parses; moves to confirmation when both are done.
class ParsingScreen extends StatefulWidget {
  const ParsingScreen({super.key, required this.mode, this.imageBytes});
  final CaptureMode mode;
  final Uint8List? imageBytes;

  @override
  State<ParsingScreen> createState() => _ParsingScreenState();
}

class _ParsingScreenState extends State<ParsingScreen> {
  static const _stepCount = {
    CaptureMode.nameplate: 4,
    CaptureMode.receipt: 4,
    CaptureMode.note: 3,
  };

  List<String> _steps(BuildContext context) {
    final l = context.l10n;
    return switch (widget.mode) {
      CaptureMode.nameplate => [l.stepReadingNameplate, l.stepIdentifyingModel, l.stepFindingManual, l.stepCheckingRecalls],
      CaptureMode.receipt => [l.stepScanningReceipt, l.stepExtractingItems, l.stepReadingWarranty, l.stepTrackingReturn],
      CaptureMode.note => [l.stepReadingNote, l.stepExtractingDetails, l.stepFilingRoom],
    };
  }
  bool _animationDone = false;
  bool _navigated = false;
  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (t) {
      if (_step < _stepCount[widget.mode]! - 1) {
        setState(() => _step++);
      } else {
        t.cancel();
        _animationDone = true;
        _maybeFinish();
      }
    });
  }

  void _maybeFinish() {
    if (_navigated || !mounted || !_animationDone) return;
    final state = context.read<AddEntryCubit>().state;
    if (state is! AddEntryParsed) return;
    _navigated = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        // pushReplacement disposes this route's cubit, so the confirm screen
        // gets its own — the parsed result and photo travel by constructor.
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => BlocProvider(
                create: (_) => AddEntryCubit(Backend.instance),
                child: ConfirmScreen(result: state.result, photoBytes: widget.imageBytes))));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddEntryCubit, AddEntryState>(
      listener: (context, state) {
        switch (state) {
          case AddEntryParsed():
            _maybeFinish();
          case AddEntryError(:final message):
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(context.l10n.parseError(message))));
            Navigator.of(context).pop();
          case _:
            break;
        }
      },
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(color: context.mc.accent, strokeWidth: 5),
                ),
              ),
              const SizedBox(height: 36),
              ...List.generate(_steps(context).length, (i) {
                final done = i < _step;
                final active = i == _step;
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: i <= _step ? 1 : 0.25,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Icon(
                          done ? Icons.check_circle : (active ? Icons.autorenew : Icons.circle_outlined),
                          size: 22,
                          color: done ? context.mc.green : context.mc.accent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(_steps(context)[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// AI transparency: show what was extracted, let the user fix anything, then save.
class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key, required this.result, this.photoBytes});
  final ParseResult result;
  final Uint8List? photoBytes;

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  ParseResult get result => widget.result;

  bool _editing = false;
  late final TextEditingController _title =
      TextEditingController(text: result.record.title);
  late final TextEditingController _room =
      TextEditingController(text: result.record.room);
  late final TextEditingController _cost = TextEditingController(
      text: result.record.cost?.toStringAsFixed(2) ?? '');
  late final TextEditingController _vendor =
      TextEditingController(text: result.record.vendor ?? '');

  @override
  void dispose() {
    _title.dispose();
    _room.dispose();
    _cost.dispose();
    _vendor.dispose();
    super.dispose();
  }

  /// The record with any user corrections applied on top of the AI parse.
  HomeRecord _correctedRecord() {
    final r = result.record;
    return HomeRecord(
      kind: r.kind,
      title: _title.text.trim().isEmpty ? r.title : _title.text.trim(),
      subtitle: r.subtitle,
      room: _room.text.trim().isEmpty ? r.room : _room.text.trim(),
      cost: double.tryParse(_cost.text.replaceAll(',', '').replaceAll('\$', '')) ?? r.cost,
      vendor: _vendor.text.trim().isEmpty ? r.vendor : _vendor.text.trim(),
      modelSerial: r.modelSerial,
      warrantyUntil: _warrantyUntil,
      returnBy: r.returnBy,
      manualFound: r.manualFound,
      rawInput: r.rawInput,
      addedOn: r.addedOn,
    );
  }

  /// Optional user-chosen follow-up date, saved as an extra reminder.
  DateTime? _remindOn;

  /// Editable warranty end date (starts as the AI's extraction).
  late DateTime? _warrantyUntil = result.record.warrantyUntil;

  Future<void> _pickWarrantyDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _warrantyUntil ?? now.add(const Duration(days: 365)),
      firstDate: DateTime(now.year - 15),
      lastDate: DateTime(now.year + 30),
      helpText: context.l10n.labelWarranty,
    );
    if (picked != null) setState(() => _warrantyUntil = picked);
  }

  Future<void> _pickRoom() async {
    final session = context.read<SessionCubit>().state;
    final profile = session is SessionReady ? session.profile : null;
    final rooms = <String>{
      if (_room.text.trim().isNotEmpty) _room.text.trim(),
      ...?profile?.rooms,
      'Kitchen', 'Living room', 'Bathroom', 'Bedroom', 'Basement', 'Garage', 'Home',
    }.toList();
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.mc.paper,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(sheetContext.l10n.labelRoom,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final room in rooms)
                    ListTile(
                      dense: true,
                      title: Text(room,
                          style: TextStyle(
                              fontWeight: room == _room.text
                                  ? FontWeight.w800
                                  : FontWeight.w500)),
                      trailing: room == _room.text
                          ? Icon(Icons.check, color: sheetContext.mc.accentDeep)
                          : null,
                      onTap: () => Navigator.of(sheetContext).pop(room),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _room.text = chosen);
  }

  /// A tappable value row used in edit mode for picker-driven fields.
  Widget _pickRow(BuildContext context, String label, String value,
      {required VoidCallback onTap, Key? key}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(
            width: 105,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: context.mc.inkSoft))),
        Expanded(
          child: GestureDetector(
            key: key,
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
              decoration: BoxDecoration(
                color: context.mc.paper,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.mc.line),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(value,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600))),
                Icon(Icons.expand_more, size: 18, color: context.mc.inkSoft),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _pickRemindDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _remindOn ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      helpText: context.l10n.remindMeCard,
    );
    if (picked != null) setState(() => _remindOn = picked);
  }

  void _save() {
    final record = _correctedRecord();
    final session = context.read<SessionCubit>().state;
    final homeId = session is SessionReady ? (session.homeId ?? 'demo-home') : 'demo-home';
    context.read<AddEntryCubit>().save(
          homeId,
          ParseResult(
            record: record,
            reminders: [
              ...result.reminders,
              if (_remindOn != null)
                Reminder(
                  title: record.title,
                  detail: context.l10n.followUpDetail,
                  due: _remindOn!,
                ),
            ],
            steps: result.steps,
          ),
          edited: _editing,
          photoBytes: widget.photoBytes,
        );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 105,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: context.mc.inkSoft))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _editRow(BuildContext context, String label, TextEditingController controller, {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
              width: 105,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: context.mc.inkSoft))),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: context.mc.paper,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.mc.line)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.mc.line)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.mc.accent, width: 1.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddEntryCubit, AddEntryState>(
      listener: (context, state) {
        switch (state) {
          case AddEntrySaved(:final saved, :final edited):
            final session = context.read<SessionCubit>().state;
            final liveHomeId = session is SessionReady ? session.homeId : null;
            if (BackendConfig.enabled && liveHomeId != null) {
              // Reload so records and reminders carry their database ids.
              context.read<TimelineCubit>().load(liveHomeId);
            } else {
              context.read<TimelineCubit>().addParsed(saved);
            }
            Navigator.of(context).popUntil((route) => route.isFirst);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(edited
                    ? context.l10n.savedCorrectionsSnack
                    : context.l10n.savedSnack),
                duration: const Duration(seconds: 2)));
          case AddEntryError(:final message, result: final _?):
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(context.l10n.saveError(message))));
          case _:
            break;
        }
      },
      builder: (context, state) => _buildBody(context, saving: state is AddEntrySaving),
    );
  }

  Widget _buildBody(BuildContext context, {required bool saving}) {
    final r = result.record;
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? context.l10n.confirmTitleEditing : context.l10n.confirmTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.photoBytes != null)
            GestureDetector(
              onTap: () => openPhotoViewer(context, bytes: widget.photoBytes),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    widget.photoBytes!,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          if (r.rawInput != null) ...[
            Text(context.l10n.youGaveMe(r.rawInput!),
                style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: context.mc.inkSoft,
                    height: 1.45)),
            const SizedBox(height: 16),
            Container(height: 1, color: context.mc.line),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: context.mc.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.mc.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(r.emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(r.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                ]),
                Divider(height: 26, color: context.mc.line),
                if (_editing) ...[
                  _editRow(context, context.l10n.labelName, _title),
                  _pickRow(context, context.l10n.labelRoom, _room.text,
                      key: const Key('room-edit'), onTap: _pickRoom),
                  _editRow(context, context.l10n.labelCost, _cost, keyboard: const TextInputType.numberWithOptions(decimal: true)),
                  _editRow(context, context.l10n.labelVendor, _vendor),
                  _pickRow(
                      context,
                      context.l10n.labelWarranty,
                      _warrantyUntil != null ? _fmtDate(_warrantyUntil!) : context.l10n.tapToSet,
                      key: const Key('warranty-edit'),
                      onTap: _pickWarrantyDate),
                ] else ...[
                  _row(context, context.l10n.labelWhat, r.subtitle),
                  _row(context, context.l10n.labelRoom, r.room),
                  if (r.cost != null) _row(context, context.l10n.labelCost, '\$${r.cost!.toStringAsFixed(2)}'),
                  if (r.vendor != null) _row(context, context.l10n.labelVendor, r.vendor!),
                ],
                if (r.modelSerial != null) _row(context, context.l10n.labelSerial, r.modelSerial!),
                if (!_editing && r.warrantyUntil != null)
                  _row(context, context.l10n.labelWarranty, context.l10n.warrantyUntil(_fmtDate(r.warrantyUntil!))),
                if (r.returnBy != null) _row(context, context.l10n.labelReturnBy, _fmtDate(r.returnBy!)),
                if (r.manualFound) _row(context, context.l10n.labelManual, context.l10n.manualFound),
              ],
            ),
          ),
          if (result.reminders.isNotEmpty) ...[
            const SizedBox(height: 18),
            ...result.reminders.map((rem) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    Icon(Icons.notifications_none, size: 17, color: context.mc.inkSoft),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(rem.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: context.mc.navy))),
                    Text(_fmtDate(rem.due),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.mc.accentDeep)),
                  ]),
                )),
          ],
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickRemindDate,
            child: SizedBox(
              height: 46,
              child: Row(children: [
                Icon(Icons.calendar_today_outlined, size: 17, color: context.mc.inkSoft),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _remindOn == null
                        ? context.l10n.remindMeCard
                        : context.l10n.reminderOnDate(_fmtDate(_remindOn!)),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _remindOn == null ? context.mc.navy : context.mc.accentDeep),
                  ),
                ),
                if (_remindOn == null)
                  Icon(Icons.add, size: 18, color: context.mc.inkSoft)
                else
                  GestureDetector(
                    onTap: () => setState(() => _remindOn = null),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.close, size: 18, color: context.mc.inkSoft),
                    ),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : const Icon(Icons.check),
            label: Text(saving
                ? context.l10n.savingLabel
                : (_editing ? context.l10n.saveCorrections : context.l10n.saveButton)),
            onPressed: saving ? null : _save,
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: _editing ? context.mc.inkSoft : context.mc.accentDeep,
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            icon: Icon(_editing ? Icons.undo : Icons.edit_outlined, size: 18),
            label: Text(_editing ? context.l10n.keepAiVersion : context.l10n.fixFirst,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            onPressed: () => setState(() {
              if (_editing) {
                // Revert any edits back to what the AI extracted.
                _title.text = result.record.title;
                _room.text = result.record.room;
                _cost.text = result.record.cost?.toStringAsFixed(2) ?? '';
                _vendor.text = result.record.vendor ?? '';
                _warrantyUntil = result.record.warrantyUntil;
              }
              _editing = !_editing;
            }),
          ),
        ],
      ),
    );
  }
}

String _fmtDate(DateTime d) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}
