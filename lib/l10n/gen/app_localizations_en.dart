// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sectionYourPlace => 'YOUR PLACE';

  @override
  String get sectionUpNext => 'UP NEXT';

  @override
  String get sectionTimeline => 'HOUSE TIMELINE';

  @override
  String get homeHealth => 'Home health';

  @override
  String get onTrack => 'ON TRACK';

  @override
  String get itemsOnRecord => 'items on record';

  @override
  String get activeWarranties => 'active warranties';

  @override
  String get untilNextTask => 'until next task';

  @override
  String get taskOverdue => 'task overdue';

  @override
  String get statToday => 'today';

  @override
  String get statTomorrow => 'tmrw';

  @override
  String statDays(int days) {
    return '${days}d';
  }

  @override
  String get addButton => 'Add';

  @override
  String get exportsTooltip => 'Exports';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get emptyTitle => 'Your logbook is empty';

  @override
  String get emptyBody =>
      'Walk the house and snap your first nameplate — the furnace is a great start.';

  @override
  String get dueToday => 'DUE TODAY';

  @override
  String get dueTomorrow => 'DUE TOMORROW';

  @override
  String get dueYesterday => 'DUE YESTERDAY';

  @override
  String overdueDays(int days) {
    return 'OVERDUE $days DAYS';
  }

  @override
  String inDays(int days) {
    return 'IN $days DAYS';
  }

  @override
  String chipBedrooms(int n) {
    return '🛏 $n bedrooms';
  }

  @override
  String chipBathrooms(String n) {
    return '🚿 $n bathrooms';
  }

  @override
  String get chipGarage => '🚗 Garage';

  @override
  String get chipBasement => '🔦 Basement';

  @override
  String get addSheetTitle => 'Add to your logbook';

  @override
  String get addSheetSubtitle => 'No forms. Point, shoot, or just say it.';

  @override
  String get optionNameplate => 'Scan a nameplate';

  @override
  String get optionNameplateSub =>
      'Furnace, water heater, A/C — AI finds the model & manual';

  @override
  String get optionReceipt => 'Scan a receipt or invoice';

  @override
  String get optionReceiptSub =>
      'Warranty and return window extracted automatically';

  @override
  String get optionNote => 'Quick note';

  @override
  String get optionNoteSub => 'Type it like a text message — AI structures it';

  @override
  String get scanNameplateTitle => 'Scan nameplate';

  @override
  String get scanReceiptTitle => 'Scan receipt';

  @override
  String get chooseFromLibrary => 'Choose from library';

  @override
  String get hintNameplateLive =>
      'Frame the metal label on the appliance,\nthen tap the shutter to open the camera.';

  @override
  String get hintReceiptLive =>
      'Flatten the receipt in good light,\nthen tap the shutter to open the camera.';

  @override
  String get hintNameplateDemo =>
      'Frame the metal label on the appliance.\nDemo mode: a furnace nameplate is pre-loaded.';

  @override
  String get hintReceiptDemo =>
      'Flatten the receipt in the frame.\nDemo mode: a Canadian Tire receipt is pre-loaded.';

  @override
  String cameraUnavailable(String error) {
    return 'Camera unavailable — try the photo library. ($error)';
  }

  @override
  String photoReadError(String error) {
    return 'Couldn\'t read that photo. ($error)';
  }

  @override
  String get quickNoteTitle => 'Quick note';

  @override
  String get quickNoteHint => 'Write it like you\'d text a friend.';

  @override
  String get quickNoteButton => 'Let Maison file it';

  @override
  String get stepReadingNameplate => 'Reading nameplate…';

  @override
  String get stepIdentifyingModel => 'Identifying model…';

  @override
  String get stepFindingManual => 'Finding the manual…';

  @override
  String get stepCheckingRecalls => 'Checking recalls…';

  @override
  String get stepScanningReceipt => 'Scanning receipt…';

  @override
  String get stepExtractingItems => 'Extracting items & prices…';

  @override
  String get stepReadingWarranty => 'Reading warranty terms…';

  @override
  String get stepTrackingReturn => 'Tracking return window…';

  @override
  String get stepReadingNote => 'Reading your note…';

  @override
  String get stepExtractingDetails => 'Extracting the details…';

  @override
  String get stepFilingRoom => 'Filing under the right room…';

  @override
  String get confirmTitle => 'Here\'s what I got';

  @override
  String get confirmTitleEditing => 'Fix the details';

  @override
  String youGaveMe(String input) {
    return 'You gave me: $input';
  }

  @override
  String get labelWhat => 'What';

  @override
  String get labelName => 'Name';

  @override
  String get labelRoom => 'Room';

  @override
  String get labelCost => 'Cost';

  @override
  String get labelVendor => 'Vendor';

  @override
  String get labelSerial => 'Serial';

  @override
  String get labelWarranty => 'Warranty';

  @override
  String warrantyUntil(String date) {
    return 'Until $date';
  }

  @override
  String get labelReturnBy => 'Return by';

  @override
  String get labelManual => 'Manual';

  @override
  String get manualFound => 'Found ✓ (attached as PDF)';

  @override
  String get remindersBox => '🔔 Reminders I\'ll set for you';

  @override
  String get remindMeCard => 'Remind me about this';

  @override
  String reminderOnDate(String date) {
    return 'Reminder on $date';
  }

  @override
  String get remindOptional => 'Optional — pick a follow-up date';

  @override
  String get willAppearUpNext => 'Will appear in Up next';

  @override
  String get removeReminder => 'Remove reminder';

  @override
  String get followUpDetail => 'Follow-up you set when saving this';

  @override
  String get saveButton => 'Looks right — save it';

  @override
  String get saveCorrections => 'Save my corrections';

  @override
  String get savingLabel => 'Saving…';

  @override
  String get fixFirst => 'Fix something first';

  @override
  String get keepAiVersion => 'Never mind — keep the AI version';

  @override
  String get savedSnack => 'Saved to your house timeline ✓';

  @override
  String get savedCorrectionsSnack => 'Saved with your corrections ✓';

  @override
  String parseError(String error) {
    return 'Couldn\'t parse that — check your connection and try again. ($error)';
  }

  @override
  String saveError(String error) {
    return 'Couldn\'t save — try again. ($error)';
  }

  @override
  String get exportsTitle => 'Exports';

  @override
  String get exportsIntro =>
      'The documents that make the subscription worth it — generated from your timeline in one tap.';

  @override
  String get claimPackTitle => 'Warranty claim pack';

  @override
  String get claimPackBody =>
      'Receipt, serial number, purchase date and warranty terms for any item — formatted the way the manufacturer asks for it.';

  @override
  String get claimPackCta => 'Generate for an item';

  @override
  String get inventoryTitle => 'Insurance contents inventory';

  @override
  String get inventoryBody =>
      'Every item on record with photos, values and receipts — the document every fire or flood victim wishes they had.';

  @override
  String inventoryCta(int n) {
    return 'Generate inventory ($n items)';
  }

  @override
  String get historyTitle => 'House history report';

  @override
  String get historyBody =>
      'The full maintenance and upgrade story of your home — a trust-builder that adds real value when you sell.';

  @override
  String get historyCta => 'Generate house history';

  @override
  String get pdfReady => '📄  PDF ready';

  @override
  String pdfBody(String what) {
    return '$what generated from your timeline.\n\nIn the real app this opens the iOS share sheet — email it to your insurer, agent, or the manufacturer.';
  }

  @override
  String get niceButton => 'Nice';

  @override
  String get obWelcomeTitle => 'Snap it.\nMaison files it.\nForever.';

  @override
  String get obWelcomeBody =>
      'Every appliance, receipt, repair and warranty in your home — photographed once, organized for good.';

  @override
  String get obWhereTitle => 'Where\'s home?';

  @override
  String get obWhereBody =>
      'One logbook per home. You can add a condo, rental or chalet later.';

  @override
  String get obAddressHint => 'Street address';

  @override
  String get obDescribeTitle =>
      'Describe your place\nlike you\'d tell a friend.';

  @override
  String get obDescribeBody =>
      'No steppers, no dropdowns. Maison turns your words into your home\'s profile — rooms, checklists, and reminders follow from it.';

  @override
  String get obStructureIt => 'Structure it';

  @override
  String get obStructuring => 'Structuring…';

  @override
  String get obHeresYourPlace => 'HERE\'S YOUR PLACE';

  @override
  String get obWrongEdit =>
      'Wrong? Just edit the sentence and structure it again. Maison keeps refining this as you log.';

  @override
  String get obHowTitle => 'Three ways to log.\nZero forms.';

  @override
  String get obHow1Title => 'Snap a nameplate';

  @override
  String get obHow1Body =>
      'AI reads the model & serial, finds the manual, and schedules its maintenance.';

  @override
  String get obHow2Title => 'Snap a receipt';

  @override
  String get obHow2Body =>
      'Price, store, warranty end date and return window — extracted and deadline-tracked.';

  @override
  String get obHow3Title => 'Type it like a note';

  @override
  String get obHow3Body =>
      '\"Water heater replaced, \$1,850, Joe\'s Plumbing\" becomes a structured record.';

  @override
  String get obContinue => 'Continue';

  @override
  String get obStartProfile => 'Start my home profile';

  @override
  String get obSettingUp => 'Setting up your home…';

  @override
  String obCreateError(String error) {
    return 'Couldn\'t create your home — check your connection. ($error)';
  }

  @override
  String get bootCantReach => 'Couldn\'t reach your logbook';

  @override
  String get bootTryAgain => 'Try again';
}
