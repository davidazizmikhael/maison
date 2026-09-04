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
  String get sectionUpNext => 'Up next';

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
    return '$what is ready — share it or save it to Files.';
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

  @override
  String get deleteRecord => 'Delete record';

  @override
  String get deleteConfirmTitle => 'Delete this record?';

  @override
  String get deleteConfirmBody =>
      'It will be removed from your logbook permanently, along with its photo and reminders.';

  @override
  String get deleteButton => 'Delete';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deletedSnack => 'Record deleted';

  @override
  String get shareButton => 'Share';

  @override
  String get pickItemTitle => 'Which item?';

  @override
  String get noItemsSnack => 'Nothing to export yet — add a record first.';

  @override
  String get generatingLabel => 'Generating…';

  @override
  String pdfGeneratedBy(String date) {
    return 'Generated by Maison — $date';
  }

  @override
  String get pdfTotalValue => 'Total documented value';

  @override
  String get pdfAddedOn => 'Added';

  @override
  String get markDone => 'Mark as done';

  @override
  String get snoozeWeek => 'Snooze 1 week';

  @override
  String get reminderDoneSnack => 'Reminder completed ✓';

  @override
  String reminderSnoozedSnack(String date) {
    return 'Snoozed to $date';
  }

  @override
  String get sectionCompleted => 'COMPLETED';

  @override
  String get pdfMaintenanceLog => 'Maintenance log';

  @override
  String pdfDoneOn(String date) {
    return 'Done $date';
  }

  @override
  String get tapToSet => 'Tap to set';

  @override
  String get editRecord => 'Edit record';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountAnonymousTitle => 'Your logbook isn\'t protected yet';

  @override
  String get accountAnonymousBody =>
      'Right now your data is tied to this device. If the app is deleted, it can\'t be recovered. Sign in with Apple to keep your logbook safe and restorable.';

  @override
  String get linkWithApple => 'Sign in with Apple';

  @override
  String get accountLinkedTitle => 'Protected with Apple';

  @override
  String get accountLinkedBody =>
      'Your logbook is tied to your Apple ID and can be restored on any device.';

  @override
  String get linkedSnack => 'Account protected ✓';

  @override
  String get appleUnavailable =>
      'Apple sign-in isn\'t enabled in this build yet — coming with the beta.';

  @override
  String get composeHint => 'Add anything — type it or snap it';

  @override
  String get fileIt => 'File it';

  @override
  String get newEntryTitle => 'New entry';

  @override
  String get doneShort => 'done';

  @override
  String get todayHeader => 'Today';

  @override
  String get homeGreeting => 'Hey there';

  @override
  String get healthGreat => 'House in great shape';

  @override
  String get healthGood => 'House in good shape';

  @override
  String get healthAttention => 'A few things need attention';

  @override
  String healthBody(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count things coming up. Knock one out today?',
      one: '1 thing coming up. Knock it out today?',
    );
    return '$_temp0';
  }

  @override
  String get healthClear => 'Nothing due. Enjoy the quiet.';

  @override
  String get sectionRecent => 'Recently filed';

  @override
  String get returnWindowReminder => 'Return window closes';

  @override
  String get deleteAccountAction => 'Delete account & data';

  @override
  String get deleteAccountTitle => 'Delete everything?';

  @override
  String get deleteAccountBody =>
      'This permanently deletes your account and every record, photo and reminder. There is no undo — export your documents first if you want a copy.';

  @override
  String get deleteAccountConfirm => 'Delete everything';

  @override
  String get deleteAccountDoneSnack => 'Account deleted';

  @override
  String get rateLimitedError =>
      'You\'ve hit today\'s AI limit. It resets tomorrow — your photo stays on your phone in the meantime.';

  @override
  String get backupTitle => 'Full backup';

  @override
  String get backupBody =>
      'Everything you\'ve ever filed — records, reminders and original photos — as open JSON, CSV and images in one ZIP. Your data is never locked in.';

  @override
  String get backupCta => 'Export everything';

  @override
  String get backupReady => '📦  Backup ready';

  @override
  String backupReadyBody(int count) {
    return '$count records with their photos, as JSON + CSV in one ZIP. Save it anywhere — it\'s yours.';
  }

  @override
  String get parseFailedTitle => 'That didn\'t go through';

  @override
  String get parseFailedBody =>
      'The photo and your note are still right here — check your connection and try again.';

  @override
  String get retryButton => 'Try again';

  @override
  String get labelPhone => 'Phone';

  @override
  String get labelEmail => 'Email';

  @override
  String get lowConfidenceBanner =>
      'I couldn\'t read everything clearly — worth double-checking the details below.';

  @override
  String get modeNameplate => 'Nameplate';

  @override
  String get modeReceipt => 'Receipt';

  @override
  String get discardButton => 'Discard';

  @override
  String get filedSnack => 'Filed ✓';

  @override
  String get filedCheckSnack =>
      'Filed — I wasn\'t sure about everything. Worth a look.';

  @override
  String get reviewAction => 'Review';
}
