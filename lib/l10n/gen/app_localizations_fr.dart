// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get sectionYourPlace => 'CHEZ VOUS';

  @override
  String get sectionUpNext => 'À venir';

  @override
  String get sectionTimeline => 'HISTORIQUE DE LA MAISON';

  @override
  String get homeHealth => 'Santé de la maison';

  @override
  String get onTrack => 'EN ORDRE';

  @override
  String get itemsOnRecord => 'articles au dossier';

  @override
  String get activeWarranties => 'garanties actives';

  @override
  String get untilNextTask => 'avant la prochaine tâche';

  @override
  String get taskOverdue => 'tâche en retard';

  @override
  String get statToday => 'auj.';

  @override
  String get statTomorrow => 'demain';

  @override
  String statDays(int days) {
    return '${days}j';
  }

  @override
  String get addButton => 'Ajouter';

  @override
  String get exportsTooltip => 'Exports';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Réglage de l\'appareil';

  @override
  String get emptyTitle => 'Votre carnet est vide';

  @override
  String get emptyBody =>
      'Faites le tour de la maison et photographiez votre première plaque — la fournaise est un bon départ.';

  @override
  String get dueToday => 'POUR AUJOURD\'HUI';

  @override
  String get dueTomorrow => 'POUR DEMAIN';

  @override
  String get dueYesterday => 'DUE HIER';

  @override
  String overdueDays(int days) {
    return 'EN RETARD DE $days JOURS';
  }

  @override
  String inDays(int days) {
    return 'DANS $days JOURS';
  }

  @override
  String chipBedrooms(int n) {
    return '🛏 $n chambres';
  }

  @override
  String chipBathrooms(String n) {
    return '🚿 $n salles de bain';
  }

  @override
  String get chipGarage => '🚗 Garage';

  @override
  String get chipBasement => '🔦 Sous-sol';

  @override
  String get addSheetTitle => 'Ajouter à votre carnet';

  @override
  String get addSheetSubtitle =>
      'Aucun formulaire. Photographiez, ou dites-le simplement.';

  @override
  String get optionNameplate => 'Numériser une plaque signalétique';

  @override
  String get optionNameplateSub =>
      'Fournaise, chauffe-eau, clim — l\'IA trouve le modèle et le manuel';

  @override
  String get optionReceipt => 'Numériser un reçu ou une facture';

  @override
  String get optionReceiptSub =>
      'Garantie et délai de retour extraits automatiquement';

  @override
  String get optionNote => 'Note rapide';

  @override
  String get optionNoteSub => 'Écrivez comme un texto — l\'IA le structure';

  @override
  String get scanNameplateTitle => 'Numériser la plaque';

  @override
  String get scanReceiptTitle => 'Numériser le reçu';

  @override
  String get chooseFromLibrary => 'Choisir dans la photothèque';

  @override
  String get hintNameplateLive =>
      'Cadrez la plaque métallique de l\'appareil,\npuis touchez le déclencheur pour ouvrir l\'appareil photo.';

  @override
  String get hintReceiptLive =>
      'Aplatissez le reçu sous un bon éclairage,\npuis touchez le déclencheur pour ouvrir l\'appareil photo.';

  @override
  String get hintNameplateDemo =>
      'Cadrez la plaque métallique de l\'appareil.\nMode démo : une plaque de fournaise est préchargée.';

  @override
  String get hintReceiptDemo =>
      'Aplatissez le reçu dans le cadre.\nMode démo : un reçu Canadian Tire est préchargé.';

  @override
  String cameraUnavailable(String error) {
    return 'Appareil photo indisponible — essayez la photothèque. ($error)';
  }

  @override
  String photoReadError(String error) {
    return 'Impossible de lire cette photo. ($error)';
  }

  @override
  String get quickNoteTitle => 'Note rapide';

  @override
  String get quickNoteHint => 'Écrivez comme si vous textiez un ami.';

  @override
  String get quickNoteButton => 'Laissez Maison le classer';

  @override
  String get stepReadingNameplate => 'Lecture de la plaque…';

  @override
  String get stepIdentifyingModel => 'Identification du modèle…';

  @override
  String get stepFindingManual => 'Recherche du manuel…';

  @override
  String get stepCheckingRecalls => 'Vérification des rappels…';

  @override
  String get stepScanningReceipt => 'Numérisation du reçu…';

  @override
  String get stepExtractingItems => 'Extraction des articles et prix…';

  @override
  String get stepReadingWarranty => 'Lecture des conditions de garantie…';

  @override
  String get stepTrackingReturn => 'Suivi du délai de retour…';

  @override
  String get stepReadingNote => 'Lecture de votre note…';

  @override
  String get stepExtractingDetails => 'Extraction des détails…';

  @override
  String get stepFilingRoom => 'Classement dans la bonne pièce…';

  @override
  String get confirmTitle => 'Voici ce que j\'ai trouvé';

  @override
  String get confirmTitleEditing => 'Corrigez les détails';

  @override
  String youGaveMe(String input) {
    return 'Vous m\'avez donné : $input';
  }

  @override
  String get labelWhat => 'Quoi';

  @override
  String get labelName => 'Nom';

  @override
  String get labelRoom => 'Pièce';

  @override
  String get labelCost => 'Coût';

  @override
  String get labelVendor => 'Fournisseur';

  @override
  String get labelSerial => 'N° de série';

  @override
  String get labelWarranty => 'Garantie';

  @override
  String warrantyUntil(String date) {
    return 'Jusqu\'au $date';
  }

  @override
  String get labelReturnBy => 'Retour avant';

  @override
  String get labelManual => 'Manuel';

  @override
  String get manualFound => 'Trouvé ✓ (PDF joint)';

  @override
  String get remindersBox => '🔔 Rappels que je vais créer';

  @override
  String get remindMeCard => 'Me le rappeler';

  @override
  String reminderOnDate(String date) {
    return 'Rappel le $date';
  }

  @override
  String get remindOptional => 'Facultatif — choisissez une date de suivi';

  @override
  String get willAppearUpNext => 'Apparaîtra dans À venir';

  @override
  String get removeReminder => 'Retirer le rappel';

  @override
  String get followUpDetail => 'Suivi défini lors de l\'enregistrement';

  @override
  String get saveButton => 'C\'est bon — enregistrer';

  @override
  String get saveCorrections => 'Enregistrer mes corrections';

  @override
  String get savingLabel => 'Enregistrement…';

  @override
  String get fixFirst => 'Corriger quelque chose';

  @override
  String get keepAiVersion => 'Finalement, garder la version IA';

  @override
  String get savedSnack => 'Enregistré dans votre historique ✓';

  @override
  String get savedCorrectionsSnack => 'Enregistré avec vos corrections ✓';

  @override
  String parseError(String error) {
    return 'Analyse impossible — vérifiez votre connexion et réessayez. ($error)';
  }

  @override
  String saveError(String error) {
    return 'Enregistrement impossible — réessayez. ($error)';
  }

  @override
  String get exportsTitle => 'Exports';

  @override
  String get exportsIntro =>
      'Les documents qui justifient l\'abonnement — générés depuis votre historique en un geste.';

  @override
  String get claimPackTitle => 'Dossier de réclamation de garantie';

  @override
  String get claimPackBody =>
      'Reçu, numéro de série, date d\'achat et conditions de garantie — dans le format exigé par le fabricant.';

  @override
  String get claimPackCta => 'Générer pour un article';

  @override
  String get inventoryTitle => 'Inventaire pour l\'assurance';

  @override
  String get inventoryBody =>
      'Chaque article au dossier avec photos, valeurs et reçus — le document que toute victime d\'incendie ou d\'inondation aurait voulu avoir.';

  @override
  String inventoryCta(int n) {
    return 'Générer l\'inventaire ($n articles)';
  }

  @override
  String get historyTitle => 'Rapport d\'historique de la maison';

  @override
  String get historyBody =>
      'Tout l\'entretien et les améliorations de votre maison — un gage de confiance qui ajoute de la valeur à la revente.';

  @override
  String get historyCta => 'Générer l\'historique';

  @override
  String get pdfReady => '📄  PDF prêt';

  @override
  String pdfBody(String what) {
    return '$what est prêt — partagez-le ou enregistrez-le dans Fichiers.';
  }

  @override
  String get niceButton => 'Super';

  @override
  String get obWelcomeTitle => 'Photographiez.\nMaison classe.\nPour toujours.';

  @override
  String get obWelcomeBody =>
      'Chaque appareil, reçu, réparation et garantie de votre maison — photographié une fois, organisé pour de bon.';

  @override
  String get obWhereTitle => 'Où est votre chez-vous ?';

  @override
  String get obWhereBody =>
      'Un carnet par maison. Vous pourrez ajouter un condo, un logement loué ou un chalet plus tard.';

  @override
  String get obAddressHint => 'Adresse';

  @override
  String get obDescribeTitle => 'Décrivez votre logement\ncomme à un ami.';

  @override
  String get obDescribeBody =>
      'Pas de sélecteurs, pas de menus. Maison transforme vos mots en profil de votre logement — pièces, listes et rappels en découlent.';

  @override
  String get obStructureIt => 'Structurer';

  @override
  String get obStructuring => 'Structuration…';

  @override
  String get obHeresYourPlace => 'VOICI VOTRE LOGEMENT';

  @override
  String get obWrongEdit =>
      'Une erreur ? Modifiez la phrase et structurez de nouveau. Maison affine ce profil au fil de vos ajouts.';

  @override
  String get obHowTitle => 'Trois façons de consigner.\nZéro formulaire.';

  @override
  String get obHow1Title => 'Photographiez une plaque';

  @override
  String get obHow1Body =>
      'L\'IA lit le modèle et le numéro de série, trouve le manuel et planifie l\'entretien.';

  @override
  String get obHow2Title => 'Photographiez un reçu';

  @override
  String get obHow2Body =>
      'Prix, magasin, fin de garantie et délai de retour — extraits et suivis.';

  @override
  String get obHow3Title => 'Écrivez une note';

  @override
  String get obHow3Body =>
      '« Chauffe-eau remplacé, 1 850 \$, Plomberie Joe » devient un dossier structuré.';

  @override
  String get obContinue => 'Continuer';

  @override
  String get obStartProfile => 'Créer mon profil maison';

  @override
  String get obSettingUp => 'Création de votre maison…';

  @override
  String obCreateError(String error) {
    return 'Impossible de créer votre maison — vérifiez votre connexion. ($error)';
  }

  @override
  String get bootCantReach => 'Impossible d\'accéder à votre carnet';

  @override
  String get bootTryAgain => 'Réessayer';

  @override
  String get deleteRecord => 'Supprimer l\'enregistrement';

  @override
  String get deleteConfirmTitle => 'Supprimer cet enregistrement ?';

  @override
  String get deleteConfirmBody =>
      'Il sera retiré définitivement de votre carnet, avec sa photo et ses rappels.';

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get deletedSnack => 'Enregistrement supprimé';

  @override
  String get shareButton => 'Partager';

  @override
  String get pickItemTitle => 'Quel article ?';

  @override
  String get noItemsSnack =>
      'Rien à exporter — ajoutez d\'abord un enregistrement.';

  @override
  String get generatingLabel => 'Génération…';

  @override
  String pdfGeneratedBy(String date) {
    return 'Généré par Maison — $date';
  }

  @override
  String get pdfTotalValue => 'Valeur totale documentée';

  @override
  String get pdfAddedOn => 'Ajouté';

  @override
  String get markDone => 'Marquer comme faite';

  @override
  String get snoozeWeek => 'Reporter d\'une semaine';

  @override
  String get reminderDoneSnack => 'Rappel terminé ✓';

  @override
  String reminderSnoozedSnack(String date) {
    return 'Reporté au $date';
  }

  @override
  String get sectionCompleted => 'TERMINÉS';

  @override
  String get pdfMaintenanceLog => 'Journal d\'entretien';

  @override
  String pdfDoneOn(String date) {
    return 'Fait le $date';
  }

  @override
  String get tapToSet => 'Toucher pour définir';

  @override
  String get editRecord => 'Modifier l\'enregistrement';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get accountTitle => 'Compte';

  @override
  String get accountAnonymousTitle => 'Votre carnet n\'est pas encore protégé';

  @override
  String get accountAnonymousBody =>
      'Vos données sont liées à cet appareil. Si l\'application est supprimée, elles ne pourront pas être récupérées. Connectez-vous avec Apple pour protéger et restaurer votre carnet.';

  @override
  String get linkWithApple => 'Se connecter avec Apple';

  @override
  String get accountLinkedTitle => 'Protégé avec Apple';

  @override
  String get accountLinkedBody =>
      'Votre carnet est lié à votre identifiant Apple et peut être restauré sur n\'importe quel appareil.';

  @override
  String get linkedSnack => 'Compte protégé ✓';

  @override
  String get appleUnavailable =>
      'La connexion Apple n\'est pas encore activée dans cette version — bientôt avec la bêta.';

  @override
  String get composeHint =>
      'Ajoutez n\'importe quoi — écrivez ou photographiez';

  @override
  String get fileIt => 'Classer';

  @override
  String get newEntryTitle => 'Nouvelle entrée';

  @override
  String get doneShort => 'fait';

  @override
  String get todayHeader => 'Aujourd\'hui';

  @override
  String get homeGreeting => 'Bonjour';

  @override
  String get healthGreat => 'Maison en pleine forme';

  @override
  String get healthGood => 'Maison en bonne forme';

  @override
  String get healthAttention => 'Quelques choses à surveiller';

  @override
  String healthBody(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count choses à venir. On en règle une aujourd\'hui?',
      one: '1 chose à venir. On la règle aujourd\'hui?',
    );
    return '$_temp0';
  }

  @override
  String get healthClear => 'Rien à l\'horaire. Profitez du calme.';

  @override
  String get sectionRecent => 'Classés récemment';

  @override
  String get returnWindowReminder => 'La fenêtre de retour se termine';

  @override
  String get deleteAccountAction => 'Supprimer le compte et les données';

  @override
  String get deleteAccountTitle => 'Tout supprimer ?';

  @override
  String get deleteAccountBody =>
      'Cette action supprime définitivement votre compte ainsi que tous vos dossiers, photos et rappels. Aucun retour en arrière — exportez d\'abord vos documents si vous voulez une copie.';

  @override
  String get deleteAccountConfirm => 'Tout supprimer';

  @override
  String get deleteAccountDoneSnack => 'Compte supprimé';

  @override
  String get rateLimitedError =>
      'Vous avez atteint la limite quotidienne d\'IA. Elle se réinitialise demain — votre photo reste sur votre téléphone d\'ici là.';

  @override
  String get backupTitle => 'Sauvegarde complète';

  @override
  String get backupBody =>
      'Tout ce que vous avez classé — dossiers, rappels et photos originales — en JSON, CSV et images dans un seul ZIP. Vos données ne sont jamais captives.';

  @override
  String get backupCta => 'Tout exporter';

  @override
  String get backupReady => '📦  Sauvegarde prête';

  @override
  String backupReadyBody(int count) {
    return '$count dossiers avec leurs photos, en JSON + CSV dans un ZIP. Enregistrez-le où vous voulez — il vous appartient.';
  }

  @override
  String get parseFailedTitle => 'Ça n\'a pas fonctionné';

  @override
  String get parseFailedBody =>
      'La photo et votre note sont toujours là — vérifiez votre connexion et réessayez.';

  @override
  String get retryButton => 'Réessayer';

  @override
  String get labelPhone => 'Téléphone';

  @override
  String get labelEmail => 'Courriel';

  @override
  String get lowConfidenceBanner =>
      'Je n\'ai pas tout lu clairement — vérifiez les détails ci-dessous.';

  @override
  String get modeNameplate => 'Plaque';

  @override
  String get modeReceipt => 'Reçu';

  @override
  String get discardButton => 'Ignorer';

  @override
  String get filedSnack => 'Classé ✓';

  @override
  String get filedCheckSnack =>
      'Classé — je n\'étais pas sûr de tout. Un coup d\'œil s\'impose.';

  @override
  String get reviewAction => 'Vérifier';

  @override
  String get composePlaceholder => 'Écrivez-le comme un texto…';

  @override
  String get hintPhotoLive =>
      'Cadrez la plaque ou le reçu — je détermine lequel.';

  @override
  String get hintPhotoDemo =>
      'Cadrez une plaque ou un reçu — je détermine lequel.\nMode démo : une plaque de fournaise est préchargée.';

  @override
  String get stepLookingPhoto => 'J\'examine la photo…';

  @override
  String get stepDecidingKind => 'Plaque ou reçu ? Je décide…';

  @override
  String get statRecords => 'dossiers';

  @override
  String get statCovered => 'couverts';

  @override
  String get statSpent => 'dépensés';

  @override
  String get statNextDue => 'prochain';

  @override
  String get statNone => '—';

  @override
  String get voiceUnavailable =>
      'La saisie vocale n\'est pas disponible sur cet appareil.';

  @override
  String get listeningHint => 'J\'écoute…';
}
