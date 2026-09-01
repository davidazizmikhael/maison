import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme.dart';
import '../../data/backend.dart';
import '../../data/models.dart';
import '../session/session_cubit.dart';
import 'pdf_builder.dart';

/// The shared "PDF ready" dialog with a Share action.
Future<void> showPdfReadyDialog(BuildContext context,
    {required String what, required Uint8List bytes, required String filename}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: dialogContext.mc.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(dialogContext.l10n.pdfReady,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      content: Text(dialogContext.l10n.pdfBody(what),
          style: TextStyle(fontSize: 14.5, height: 1.5, color: dialogContext.mc.inkSoft)),
      actions: [
        TextButton.icon(
          icon: Icon(Icons.ios_share, size: 18, color: dialogContext.mc.accentDeep),
          label: Text(dialogContext.l10n.shareButton,
              style:
                  TextStyle(color: dialogContext.mc.accentDeep, fontWeight: FontWeight.w700)),
          onPressed: () => Printing.sharePdf(bytes: bytes, filename: filename),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(dialogContext.l10n.niceButton),
        ),
      ],
    ),
  );
}

/// Generates and offers the warranty claim pack for one record — used by the
/// exports screen and by the record-detail action tile.
Future<void> shareClaimPack(BuildContext context, HomeRecord record) async {
  final session = context.read<SessionCubit>().state;
  final address = session is SessionReady ? session.address : '';
  final l10n = context.l10n;
  try {
    Uint8List? photo;
    if (record.photoPath != null) {
      photo = await Backend.instance.photoBytes(record.photoPath!);
    }
    final bytes =
        await buildClaimPack(l10n: l10n, address: address, record: record, photo: photo);
    if (!context.mounted) return;
    await showPdfReadyDialog(context,
        what: l10n.claimPackTitle, bytes: bytes, filename: 'maison-warranty-claim.pdf');
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.saveError('$e'))));
    }
  }
}
