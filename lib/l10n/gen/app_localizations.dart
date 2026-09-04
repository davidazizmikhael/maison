import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @sectionYourPlace.
  ///
  /// In en, this message translates to:
  /// **'YOUR PLACE'**
  String get sectionYourPlace;

  /// No description provided for @sectionUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get sectionUpNext;

  /// No description provided for @sectionTimeline.
  ///
  /// In en, this message translates to:
  /// **'HOUSE TIMELINE'**
  String get sectionTimeline;

  /// No description provided for @homeHealth.
  ///
  /// In en, this message translates to:
  /// **'Home health'**
  String get homeHealth;

  /// No description provided for @onTrack.
  ///
  /// In en, this message translates to:
  /// **'ON TRACK'**
  String get onTrack;

  /// No description provided for @itemsOnRecord.
  ///
  /// In en, this message translates to:
  /// **'items on record'**
  String get itemsOnRecord;

  /// No description provided for @activeWarranties.
  ///
  /// In en, this message translates to:
  /// **'active warranties'**
  String get activeWarranties;

  /// No description provided for @untilNextTask.
  ///
  /// In en, this message translates to:
  /// **'until next task'**
  String get untilNextTask;

  /// No description provided for @taskOverdue.
  ///
  /// In en, this message translates to:
  /// **'task overdue'**
  String get taskOverdue;

  /// No description provided for @statToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get statToday;

  /// No description provided for @statTomorrow.
  ///
  /// In en, this message translates to:
  /// **'tmrw'**
  String get statTomorrow;

  /// No description provided for @statDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String statDays(int days);

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @exportsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Exports'**
  String get exportsTooltip;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your logbook is empty'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Walk the house and snap your first nameplate — the furnace is a great start.'**
  String get emptyBody;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'DUE TODAY'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'DUE TOMORROW'**
  String get dueTomorrow;

  /// No description provided for @dueYesterday.
  ///
  /// In en, this message translates to:
  /// **'DUE YESTERDAY'**
  String get dueYesterday;

  /// No description provided for @overdueDays.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE {days} DAYS'**
  String overdueDays(int days);

  /// No description provided for @inDays.
  ///
  /// In en, this message translates to:
  /// **'IN {days} DAYS'**
  String inDays(int days);

  /// No description provided for @chipBedrooms.
  ///
  /// In en, this message translates to:
  /// **'🛏 {n} bedrooms'**
  String chipBedrooms(int n);

  /// No description provided for @chipBathrooms.
  ///
  /// In en, this message translates to:
  /// **'🚿 {n} bathrooms'**
  String chipBathrooms(String n);

  /// No description provided for @chipGarage.
  ///
  /// In en, this message translates to:
  /// **'🚗 Garage'**
  String get chipGarage;

  /// No description provided for @chipBasement.
  ///
  /// In en, this message translates to:
  /// **'🔦 Basement'**
  String get chipBasement;

  /// No description provided for @addSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to your logbook'**
  String get addSheetTitle;

  /// No description provided for @addSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No forms. Point, shoot, or just say it.'**
  String get addSheetSubtitle;

  /// No description provided for @optionNameplate.
  ///
  /// In en, this message translates to:
  /// **'Scan a nameplate'**
  String get optionNameplate;

  /// No description provided for @optionNameplateSub.
  ///
  /// In en, this message translates to:
  /// **'Furnace, water heater, A/C — AI finds the model & manual'**
  String get optionNameplateSub;

  /// No description provided for @optionReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan a receipt or invoice'**
  String get optionReceipt;

  /// No description provided for @optionReceiptSub.
  ///
  /// In en, this message translates to:
  /// **'Warranty and return window extracted automatically'**
  String get optionReceiptSub;

  /// No description provided for @optionNote.
  ///
  /// In en, this message translates to:
  /// **'Quick note'**
  String get optionNote;

  /// No description provided for @optionNoteSub.
  ///
  /// In en, this message translates to:
  /// **'Type it like a text message — AI structures it'**
  String get optionNoteSub;

  /// No description provided for @scanNameplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan nameplate'**
  String get scanNameplateTitle;

  /// No description provided for @scanReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan receipt'**
  String get scanReceiptTitle;

  /// No description provided for @chooseFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get chooseFromLibrary;

  /// No description provided for @hintNameplateLive.
  ///
  /// In en, this message translates to:
  /// **'Frame the metal label on the appliance,\nthen tap the shutter to open the camera.'**
  String get hintNameplateLive;

  /// No description provided for @hintReceiptLive.
  ///
  /// In en, this message translates to:
  /// **'Flatten the receipt in good light,\nthen tap the shutter to open the camera.'**
  String get hintReceiptLive;

  /// No description provided for @hintNameplateDemo.
  ///
  /// In en, this message translates to:
  /// **'Frame the metal label on the appliance.\nDemo mode: a furnace nameplate is pre-loaded.'**
  String get hintNameplateDemo;

  /// No description provided for @hintReceiptDemo.
  ///
  /// In en, this message translates to:
  /// **'Flatten the receipt in the frame.\nDemo mode: a Canadian Tire receipt is pre-loaded.'**
  String get hintReceiptDemo;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable — try the photo library. ({error})'**
  String cameraUnavailable(String error);

  /// No description provided for @photoReadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read that photo. ({error})'**
  String photoReadError(String error);

  /// No description provided for @quickNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick note'**
  String get quickNoteTitle;

  /// No description provided for @quickNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Write it like you\'d text a friend.'**
  String get quickNoteHint;

  /// No description provided for @quickNoteButton.
  ///
  /// In en, this message translates to:
  /// **'Let Maison file it'**
  String get quickNoteButton;

  /// No description provided for @stepReadingNameplate.
  ///
  /// In en, this message translates to:
  /// **'Reading nameplate…'**
  String get stepReadingNameplate;

  /// No description provided for @stepIdentifyingModel.
  ///
  /// In en, this message translates to:
  /// **'Identifying model…'**
  String get stepIdentifyingModel;

  /// No description provided for @stepFindingManual.
  ///
  /// In en, this message translates to:
  /// **'Finding the manual…'**
  String get stepFindingManual;

  /// No description provided for @stepCheckingRecalls.
  ///
  /// In en, this message translates to:
  /// **'Checking recalls…'**
  String get stepCheckingRecalls;

  /// No description provided for @stepScanningReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scanning receipt…'**
  String get stepScanningReceipt;

  /// No description provided for @stepExtractingItems.
  ///
  /// In en, this message translates to:
  /// **'Extracting items & prices…'**
  String get stepExtractingItems;

  /// No description provided for @stepReadingWarranty.
  ///
  /// In en, this message translates to:
  /// **'Reading warranty terms…'**
  String get stepReadingWarranty;

  /// No description provided for @stepTrackingReturn.
  ///
  /// In en, this message translates to:
  /// **'Tracking return window…'**
  String get stepTrackingReturn;

  /// No description provided for @stepReadingNote.
  ///
  /// In en, this message translates to:
  /// **'Reading your note…'**
  String get stepReadingNote;

  /// No description provided for @stepExtractingDetails.
  ///
  /// In en, this message translates to:
  /// **'Extracting the details…'**
  String get stepExtractingDetails;

  /// No description provided for @stepFilingRoom.
  ///
  /// In en, this message translates to:
  /// **'Filing under the right room…'**
  String get stepFilingRoom;

  /// No description provided for @confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what I got'**
  String get confirmTitle;

  /// No description provided for @confirmTitleEditing.
  ///
  /// In en, this message translates to:
  /// **'Fix the details'**
  String get confirmTitleEditing;

  /// No description provided for @youGaveMe.
  ///
  /// In en, this message translates to:
  /// **'You gave me: {input}'**
  String youGaveMe(String input);

  /// No description provided for @labelWhat.
  ///
  /// In en, this message translates to:
  /// **'What'**
  String get labelWhat;

  /// No description provided for @labelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelName;

  /// No description provided for @labelRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get labelRoom;

  /// No description provided for @labelCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get labelCost;

  /// No description provided for @labelVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get labelVendor;

  /// No description provided for @labelSerial.
  ///
  /// In en, this message translates to:
  /// **'Serial'**
  String get labelSerial;

  /// No description provided for @labelWarranty.
  ///
  /// In en, this message translates to:
  /// **'Warranty'**
  String get labelWarranty;

  /// No description provided for @warrantyUntil.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String warrantyUntil(String date);

  /// No description provided for @labelReturnBy.
  ///
  /// In en, this message translates to:
  /// **'Return by'**
  String get labelReturnBy;

  /// No description provided for @labelManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get labelManual;

  /// No description provided for @manualFound.
  ///
  /// In en, this message translates to:
  /// **'Found ✓ (attached as PDF)'**
  String get manualFound;

  /// No description provided for @remindersBox.
  ///
  /// In en, this message translates to:
  /// **'🔔 Reminders I\'ll set for you'**
  String get remindersBox;

  /// No description provided for @remindMeCard.
  ///
  /// In en, this message translates to:
  /// **'Remind me about this'**
  String get remindMeCard;

  /// No description provided for @reminderOnDate.
  ///
  /// In en, this message translates to:
  /// **'Reminder on {date}'**
  String reminderOnDate(String date);

  /// No description provided for @remindOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional — pick a follow-up date'**
  String get remindOptional;

  /// No description provided for @willAppearUpNext.
  ///
  /// In en, this message translates to:
  /// **'Will appear in Up next'**
  String get willAppearUpNext;

  /// No description provided for @removeReminder.
  ///
  /// In en, this message translates to:
  /// **'Remove reminder'**
  String get removeReminder;

  /// No description provided for @followUpDetail.
  ///
  /// In en, this message translates to:
  /// **'Follow-up you set when saving this'**
  String get followUpDetail;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Looks right — save it'**
  String get saveButton;

  /// No description provided for @saveCorrections.
  ///
  /// In en, this message translates to:
  /// **'Save my corrections'**
  String get saveCorrections;

  /// No description provided for @savingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingLabel;

  /// No description provided for @fixFirst.
  ///
  /// In en, this message translates to:
  /// **'Fix something first'**
  String get fixFirst;

  /// No description provided for @keepAiVersion.
  ///
  /// In en, this message translates to:
  /// **'Never mind — keep the AI version'**
  String get keepAiVersion;

  /// No description provided for @savedSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved to your house timeline ✓'**
  String get savedSnack;

  /// No description provided for @savedCorrectionsSnack.
  ///
  /// In en, this message translates to:
  /// **'Saved with your corrections ✓'**
  String get savedCorrectionsSnack;

  /// No description provided for @parseError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t parse that — check your connection and try again. ({error})'**
  String parseError(String error);

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save — try again. ({error})'**
  String saveError(String error);

  /// No description provided for @exportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exports'**
  String get exportsTitle;

  /// No description provided for @exportsIntro.
  ///
  /// In en, this message translates to:
  /// **'The documents that make the subscription worth it — generated from your timeline in one tap.'**
  String get exportsIntro;

  /// No description provided for @claimPackTitle.
  ///
  /// In en, this message translates to:
  /// **'Warranty claim pack'**
  String get claimPackTitle;

  /// No description provided for @claimPackBody.
  ///
  /// In en, this message translates to:
  /// **'Receipt, serial number, purchase date and warranty terms for any item — formatted the way the manufacturer asks for it.'**
  String get claimPackBody;

  /// No description provided for @claimPackCta.
  ///
  /// In en, this message translates to:
  /// **'Generate for an item'**
  String get claimPackCta;

  /// No description provided for @inventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Insurance contents inventory'**
  String get inventoryTitle;

  /// No description provided for @inventoryBody.
  ///
  /// In en, this message translates to:
  /// **'Every item on record with photos, values and receipts — the document every fire or flood victim wishes they had.'**
  String get inventoryBody;

  /// No description provided for @inventoryCta.
  ///
  /// In en, this message translates to:
  /// **'Generate inventory ({n} items)'**
  String inventoryCta(int n);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'House history report'**
  String get historyTitle;

  /// No description provided for @historyBody.
  ///
  /// In en, this message translates to:
  /// **'The full maintenance and upgrade story of your home — a trust-builder that adds real value when you sell.'**
  String get historyBody;

  /// No description provided for @historyCta.
  ///
  /// In en, this message translates to:
  /// **'Generate house history'**
  String get historyCta;

  /// No description provided for @pdfReady.
  ///
  /// In en, this message translates to:
  /// **'📄  PDF ready'**
  String get pdfReady;

  /// No description provided for @pdfBody.
  ///
  /// In en, this message translates to:
  /// **'{what} is ready — share it or save it to Files.'**
  String pdfBody(String what);

  /// No description provided for @niceButton.
  ///
  /// In en, this message translates to:
  /// **'Nice'**
  String get niceButton;

  /// No description provided for @obWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Snap it.\nMaison files it.\nForever.'**
  String get obWelcomeTitle;

  /// No description provided for @obWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Every appliance, receipt, repair and warranty in your home — photographed once, organized for good.'**
  String get obWelcomeBody;

  /// No description provided for @obWhereTitle.
  ///
  /// In en, this message translates to:
  /// **'Where\'s home?'**
  String get obWhereTitle;

  /// No description provided for @obWhereBody.
  ///
  /// In en, this message translates to:
  /// **'One logbook per home. You can add a condo, rental or chalet later.'**
  String get obWhereBody;

  /// No description provided for @obAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get obAddressHint;

  /// No description provided for @obDescribeTitle.
  ///
  /// In en, this message translates to:
  /// **'Describe your place\nlike you\'d tell a friend.'**
  String get obDescribeTitle;

  /// No description provided for @obDescribeBody.
  ///
  /// In en, this message translates to:
  /// **'No steppers, no dropdowns. Maison turns your words into your home\'s profile — rooms, checklists, and reminders follow from it.'**
  String get obDescribeBody;

  /// No description provided for @obStructureIt.
  ///
  /// In en, this message translates to:
  /// **'Structure it'**
  String get obStructureIt;

  /// No description provided for @obStructuring.
  ///
  /// In en, this message translates to:
  /// **'Structuring…'**
  String get obStructuring;

  /// No description provided for @obHeresYourPlace.
  ///
  /// In en, this message translates to:
  /// **'HERE\'S YOUR PLACE'**
  String get obHeresYourPlace;

  /// No description provided for @obWrongEdit.
  ///
  /// In en, this message translates to:
  /// **'Wrong? Just edit the sentence and structure it again. Maison keeps refining this as you log.'**
  String get obWrongEdit;

  /// No description provided for @obHowTitle.
  ///
  /// In en, this message translates to:
  /// **'Three ways to log.\nZero forms.'**
  String get obHowTitle;

  /// No description provided for @obHow1Title.
  ///
  /// In en, this message translates to:
  /// **'Snap a nameplate'**
  String get obHow1Title;

  /// No description provided for @obHow1Body.
  ///
  /// In en, this message translates to:
  /// **'AI reads the model & serial, finds the manual, and schedules its maintenance.'**
  String get obHow1Body;

  /// No description provided for @obHow2Title.
  ///
  /// In en, this message translates to:
  /// **'Snap a receipt'**
  String get obHow2Title;

  /// No description provided for @obHow2Body.
  ///
  /// In en, this message translates to:
  /// **'Price, store, warranty end date and return window — extracted and deadline-tracked.'**
  String get obHow2Body;

  /// No description provided for @obHow3Title.
  ///
  /// In en, this message translates to:
  /// **'Type it like a note'**
  String get obHow3Title;

  /// No description provided for @obHow3Body.
  ///
  /// In en, this message translates to:
  /// **'\"Water heater replaced, \$1,850, Joe\'s Plumbing\" becomes a structured record.'**
  String get obHow3Body;

  /// No description provided for @obContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get obContinue;

  /// No description provided for @obStartProfile.
  ///
  /// In en, this message translates to:
  /// **'Start my home profile'**
  String get obStartProfile;

  /// No description provided for @obSettingUp.
  ///
  /// In en, this message translates to:
  /// **'Setting up your home…'**
  String get obSettingUp;

  /// No description provided for @obCreateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create your home — check your connection. ({error})'**
  String obCreateError(String error);

  /// No description provided for @bootCantReach.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach your logbook'**
  String get bootCantReach;

  /// No description provided for @bootTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get bootTryAgain;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get deleteRecord;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this record?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed from your logbook permanently, along with its photo and reminders.'**
  String get deleteConfirmBody;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deletedSnack.
  ///
  /// In en, this message translates to:
  /// **'Record deleted'**
  String get deletedSnack;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// No description provided for @pickItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Which item?'**
  String get pickItemTitle;

  /// No description provided for @noItemsSnack.
  ///
  /// In en, this message translates to:
  /// **'Nothing to export yet — add a record first.'**
  String get noItemsSnack;

  /// No description provided for @generatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get generatingLabel;

  /// No description provided for @pdfGeneratedBy.
  ///
  /// In en, this message translates to:
  /// **'Generated by Maison — {date}'**
  String pdfGeneratedBy(String date);

  /// No description provided for @pdfTotalValue.
  ///
  /// In en, this message translates to:
  /// **'Total documented value'**
  String get pdfTotalValue;

  /// No description provided for @pdfAddedOn.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get pdfAddedOn;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markDone;

  /// No description provided for @snoozeWeek.
  ///
  /// In en, this message translates to:
  /// **'Snooze 1 week'**
  String get snoozeWeek;

  /// No description provided for @reminderDoneSnack.
  ///
  /// In en, this message translates to:
  /// **'Reminder completed ✓'**
  String get reminderDoneSnack;

  /// No description provided for @reminderSnoozedSnack.
  ///
  /// In en, this message translates to:
  /// **'Snoozed to {date}'**
  String reminderSnoozedSnack(String date);

  /// No description provided for @sectionCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get sectionCompleted;

  /// No description provided for @pdfMaintenanceLog.
  ///
  /// In en, this message translates to:
  /// **'Maintenance log'**
  String get pdfMaintenanceLog;

  /// No description provided for @pdfDoneOn.
  ///
  /// In en, this message translates to:
  /// **'Done {date}'**
  String pdfDoneOn(String date);

  /// No description provided for @tapToSet.
  ///
  /// In en, this message translates to:
  /// **'Tap to set'**
  String get tapToSet;

  /// No description provided for @editRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit record'**
  String get editRecord;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountAnonymousTitle.
  ///
  /// In en, this message translates to:
  /// **'Your logbook isn\'t protected yet'**
  String get accountAnonymousTitle;

  /// No description provided for @accountAnonymousBody.
  ///
  /// In en, this message translates to:
  /// **'Right now your data is tied to this device. If the app is deleted, it can\'t be recovered. Sign in with Apple to keep your logbook safe and restorable.'**
  String get accountAnonymousBody;

  /// No description provided for @linkWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get linkWithApple;

  /// No description provided for @accountLinkedTitle.
  ///
  /// In en, this message translates to:
  /// **'Protected with Apple'**
  String get accountLinkedTitle;

  /// No description provided for @accountLinkedBody.
  ///
  /// In en, this message translates to:
  /// **'Your logbook is tied to your Apple ID and can be restored on any device.'**
  String get accountLinkedBody;

  /// No description provided for @linkedSnack.
  ///
  /// In en, this message translates to:
  /// **'Account protected ✓'**
  String get linkedSnack;

  /// No description provided for @appleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Apple sign-in isn\'t enabled in this build yet — coming with the beta.'**
  String get appleUnavailable;

  /// No description provided for @composeHint.
  ///
  /// In en, this message translates to:
  /// **'Add anything — type it or snap it'**
  String get composeHint;

  /// No description provided for @fileIt.
  ///
  /// In en, this message translates to:
  /// **'File it'**
  String get fileIt;

  /// No description provided for @newEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get newEntryTitle;

  /// No description provided for @doneShort.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get doneShort;

  /// No description provided for @todayHeader.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayHeader;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hey there'**
  String get homeGreeting;

  /// No description provided for @healthGreat.
  ///
  /// In en, this message translates to:
  /// **'House in great shape'**
  String get healthGreat;

  /// No description provided for @healthGood.
  ///
  /// In en, this message translates to:
  /// **'House in good shape'**
  String get healthGood;

  /// No description provided for @healthAttention.
  ///
  /// In en, this message translates to:
  /// **'A few things need attention'**
  String get healthAttention;

  /// No description provided for @healthBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 thing coming up. Knock it out today?} other{{count} things coming up. Knock one out today?}}'**
  String healthBody(num count);

  /// No description provided for @healthClear.
  ///
  /// In en, this message translates to:
  /// **'Nothing due. Enjoy the quiet.'**
  String get healthClear;

  /// No description provided for @sectionRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently filed'**
  String get sectionRecent;

  /// No description provided for @returnWindowReminder.
  ///
  /// In en, this message translates to:
  /// **'Return window closes'**
  String get returnWindowReminder;

  /// No description provided for @deleteAccountAction.
  ///
  /// In en, this message translates to:
  /// **'Delete account & data'**
  String get deleteAccountAction;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and every record, photo and reminder. There is no undo — export your documents first if you want a copy.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountDoneSnack.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get deleteAccountDoneSnack;

  /// No description provided for @rateLimitedError.
  ///
  /// In en, this message translates to:
  /// **'You\'ve hit today\'s AI limit. It resets tomorrow — your photo stays on your phone in the meantime.'**
  String get rateLimitedError;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Full backup'**
  String get backupTitle;

  /// No description provided for @backupBody.
  ///
  /// In en, this message translates to:
  /// **'Everything you\'ve ever filed — records, reminders and original photos — as open JSON, CSV and images in one ZIP. Your data is never locked in.'**
  String get backupBody;

  /// No description provided for @backupCta.
  ///
  /// In en, this message translates to:
  /// **'Export everything'**
  String get backupCta;

  /// No description provided for @backupReady.
  ///
  /// In en, this message translates to:
  /// **'📦  Backup ready'**
  String get backupReady;

  /// No description provided for @backupReadyBody.
  ///
  /// In en, this message translates to:
  /// **'{count} records with their photos, as JSON + CSV in one ZIP. Save it anywhere — it\'s yours.'**
  String backupReadyBody(int count);

  /// No description provided for @parseFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t go through'**
  String get parseFailedTitle;

  /// No description provided for @parseFailedBody.
  ///
  /// In en, this message translates to:
  /// **'The photo and your note are still right here — check your connection and try again.'**
  String get parseFailedBody;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryButton;

  /// No description provided for @labelPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get labelPhone;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// No description provided for @lowConfidenceBanner.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t read everything clearly — worth double-checking the details below.'**
  String get lowConfidenceBanner;

  /// No description provided for @modeNameplate.
  ///
  /// In en, this message translates to:
  /// **'Nameplate'**
  String get modeNameplate;

  /// No description provided for @modeReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get modeReceipt;

  /// No description provided for @discardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButton;

  /// No description provided for @filedSnack.
  ///
  /// In en, this message translates to:
  /// **'Filed ✓'**
  String get filedSnack;

  /// No description provided for @filedCheckSnack.
  ///
  /// In en, this message translates to:
  /// **'Filed — I wasn\'t sure about everything. Worth a look.'**
  String get filedCheckSnack;

  /// No description provided for @reviewAction.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewAction;

  /// No description provided for @composePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Type it like a text…'**
  String get composePlaceholder;

  /// No description provided for @hintPhotoLive.
  ///
  /// In en, this message translates to:
  /// **'Frame the nameplate or the receipt — I\'ll work out which.'**
  String get hintPhotoLive;

  /// No description provided for @hintPhotoDemo.
  ///
  /// In en, this message translates to:
  /// **'Frame a nameplate or a receipt — I\'ll work out which.\nDemo mode: a furnace nameplate is pre-loaded.'**
  String get hintPhotoDemo;

  /// No description provided for @stepLookingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Looking at the photo…'**
  String get stepLookingPhoto;

  /// No description provided for @stepDecidingKind.
  ///
  /// In en, this message translates to:
  /// **'Nameplate or receipt? Deciding…'**
  String get stepDecidingKind;

  /// No description provided for @statRecords.
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get statRecords;

  /// No description provided for @statCovered.
  ///
  /// In en, this message translates to:
  /// **'covered'**
  String get statCovered;

  /// No description provided for @statSpent.
  ///
  /// In en, this message translates to:
  /// **'filed'**
  String get statSpent;

  /// No description provided for @statNextDue.
  ///
  /// In en, this message translates to:
  /// **'next due'**
  String get statNextDue;

  /// No description provided for @statNone.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get statNone;

  /// No description provided for @voiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Voice input isn\'t available on this device.'**
  String get voiceUnavailable;

  /// No description provided for @listeningHint.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listeningHint;

  /// No description provided for @voiceFrenchMissing.
  ///
  /// In en, this message translates to:
  /// **'French dictation isn\'t installed on this phone — add it under Settings › General › Keyboard › Dictation Languages. Listening in your phone\'s language for now.'**
  String get voiceFrenchMissing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
