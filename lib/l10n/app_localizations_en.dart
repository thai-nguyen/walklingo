// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'WalkLingo';

  @override
  String get navToday => 'Today';

  @override
  String get navProgress => 'Progress';

  @override
  String get navListen => 'Listen';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get loginSubtitleSignIn => 'Sign in to sync your history';

  @override
  String get loginSubtitleRegister => 'Create an account';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordMinLength => 'At least 6 characters';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signUpButton => 'Sign up';

  @override
  String get toggleToSignIn => 'Already have an account? Sign in';

  @override
  String get toggleToSignUp => 'Don\'t have an account? Sign up';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingMorningMessage =>
      'Start your day with a few English words!';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingAfternoonMessage => 'Keep up your learning habit!';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingEveningMessage => 'Review vocabulary before you rest.';

  @override
  String get greetingNight => 'Hello';

  @override
  String get greetingNightMessage =>
      'Spend a little time on English before bed!';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name!';
  }

  @override
  String greetingNoName(String greeting) {
    return '$greeting!';
  }

  @override
  String get todaySectionLabel => 'Today';

  @override
  String get setupTodoTooltip => 'Set up daily plan';

  @override
  String get signInToUseTodo => 'Sign in to use your daily plan.';

  @override
  String get noPlanToday =>
      'No plan yet. Tap \"Set up daily plan\" to add words and goals.';

  @override
  String get noDataForDay => 'No data for this day.';

  @override
  String streakDays(int count) {
    return 'You\'ve kept your streak for $count days.';
  }

  @override
  String get calendarCollapseTooltip => 'Collapse — current week only';

  @override
  String get calendarExpandTooltip => 'Expand — view full month';

  @override
  String planPercentComplete(int percent, int completed, int total) {
    return '$percent% complete ($completed/$total)';
  }

  @override
  String get sectionReview => 'Review';

  @override
  String get sectionNewWords => 'New words';

  @override
  String get sectionAudioAndSteps => 'Audio & steps';

  @override
  String get quotaAudioTitle => 'Listen to audio';

  @override
  String get quotaStepsTitle => 'Walking';

  @override
  String quotaAudioProgress(int current, int goal) {
    return 'Listened $current / $goal tracks — auto-completes when goal is met.';
  }

  @override
  String quotaStepsProgress(int current, int goal) {
    return 'Walked $current / $goal steps — auto-completes when goal is met.';
  }

  @override
  String genericError(String error) {
    return 'Error: $error';
  }

  @override
  String audioQuotaPreview(int count) {
    return 'Selected $count tracks to listen today';
  }

  @override
  String get setupTodayTitle => 'Set up today';

  @override
  String tracksSelectedCount(int count) {
    return 'Selected: $count tracks';
  }

  @override
  String get collapse => 'Collapse';

  @override
  String get expand => 'Expand';

  @override
  String get selectLibrivoxBook => 'Select a LibriVox book';

  @override
  String get selectBookForTracks => 'Select a book to show the track list.';

  @override
  String get bookNoChapters => 'This book has no chapters yet.';

  @override
  String get missingAudioUrl => 'Missing audio URL';

  @override
  String get trackGoalAutoHint =>
      'Track goal is set automatically to the number of selected tracks';

  @override
  String get stepGoalLabel => 'Step goal';

  @override
  String get wordListLabel =>
      'Word list (English), one per line or comma-separated';

  @override
  String get createDailyTodoButton => 'Create today\'s plan';

  @override
  String get errorEnterAtLeastOneWord => 'Enter at least one English word.';

  @override
  String get errorSelectAtLeastOneTrack =>
      'Select at least 1 track to listen today.';

  @override
  String get errorNoWordsLookedUp => 'Could not look up any words.';

  @override
  String get snackbarPlanCreated => 'Today\'s plan created.';

  @override
  String snackbarPlanCreatedWithSkips(int count) {
    return 'Plan created. Skipped: $count entries.';
  }

  @override
  String trackTitleSeparator(String bookTitle, String chapterTitle) {
    return '$bookTitle — $chapterTitle';
  }

  @override
  String get dictEnglishOnly =>
      'Only English words (Latin script) are supported.';

  @override
  String dictWordNotFound(String lemma) {
    return 'Word \"$lemma\" not found in dictionary.';
  }

  @override
  String dictApiStatus(int statusCode) {
    return 'Dictionary API: $statusCode';
  }

  @override
  String dictNoData(String lemma) {
    return 'No data for \"$lemma\".';
  }

  @override
  String dictLookupError(String error) {
    return 'Lookup error: $error';
  }

  @override
  String get walkingTitle => 'Walking';

  @override
  String get stepsNotSupportedWeb => 'Step counting is not supported on web.';

  @override
  String get stepsPermissionRequired =>
      'Activity/motion permission is required to count steps.';

  @override
  String pedometerError(String error) {
    return 'Pedometer error: $error';
  }

  @override
  String pedometerInitFailed(String error) {
    return 'Could not initialize pedometer: $error';
  }

  @override
  String get todaySessionLabel => 'Today (session)';

  @override
  String stepsCount(int count) {
    return '$count steps';
  }

  @override
  String get resetTodayStepsTooltip => 'Reset today\'s steps';

  @override
  String get stepsResetSnack => 'Today\'s step count has been reset.';

  @override
  String get currentSessionLabel => 'Current session';

  @override
  String get noSessionLabel => 'No active session';

  @override
  String kcalToday(String kcal) {
    return '$kcal kcal today';
  }

  @override
  String get endSessionButton => 'End session';

  @override
  String get startSessionButton => 'Start session';

  @override
  String get profileForCalorieHint =>
      'Enter weight/height in Settings for better calorie estimates.';

  @override
  String get walkSessionEndedTitle => 'Walking session ended';

  @override
  String walkStartedAt(String time) {
    return 'Started: $time';
  }

  @override
  String walkEndedAt(String time) {
    return 'Ended: $time';
  }

  @override
  String walkDuration(String duration) {
    return 'Duration: $duration';
  }

  @override
  String walkSessionSteps(int count) {
    return 'Steps in session: $count';
  }

  @override
  String walkEstimatedKcal(String kcal) {
    return 'Estimated: $kcal kcal';
  }

  @override
  String walkDeviceTotalSteps(int count) {
    return 'Device total steps (current): $count';
  }

  @override
  String get closeButton => 'Close';

  @override
  String durationHoursMinutesSeconds(int hours, int minutes, int seconds) {
    return '${hours}h ${minutes}m ${seconds}s';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String durationSecondsOnly(int seconds) {
    return '${seconds}s';
  }

  @override
  String get todayTrackFallbackTitle => 'Today\'s selected track';

  @override
  String get todayGoalSourceName => 'Today\'s goal';

  @override
  String get playingTrackForWalk =>
      'Playing today\'s selected track for the walking session.';

  @override
  String cannotPlaySelectedTrack(String error) {
    return 'Could not play selected track: $error';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get notSignedIn => 'Not signed in.';

  @override
  String get uploadAvatarTooltip => 'Upload avatar';

  @override
  String get avatarUpdated => 'Avatar updated.';

  @override
  String avatarUploadError(String error) {
    return 'Avatar upload failed: $error';
  }

  @override
  String get displayNameUnset => 'Display name not set';

  @override
  String get ageLabel => 'Age';

  @override
  String get genderLabel => 'Gender';

  @override
  String get weightLabel => 'Weight';

  @override
  String get heightLabel => 'Height';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get genderUnknown => '—';

  @override
  String weightKgValue(String weight) {
    return '$weight kg';
  }

  @override
  String heightCmValue(String height) {
    return '$height cm';
  }

  @override
  String infoChipFormat(String label, String value) {
    return '$label: $value';
  }

  @override
  String get editBasicInfoButton => 'Edit basic info';

  @override
  String get utilitiesSection => 'Utilities';

  @override
  String get learnedWordsTitle => 'Learned words';

  @override
  String get learnedWordsSubtitle => 'Saved vocabulary list';

  @override
  String get librivoxSyncTitle => 'Sync LibriVox';

  @override
  String get librivoxSyncSubtitle =>
      'Sync Latest Data — API + RSS → Firestore books';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get saveButton => 'Save';

  @override
  String saveError(String error) {
    return 'Error: $error';
  }

  @override
  String get weightKgLabel => 'Weight (kg)';

  @override
  String get heightCmLabel => 'Height (cm)';

  @override
  String get progressTitle => 'Progress';

  @override
  String get historyButton => 'History';

  @override
  String get noProgressData => 'No data to chart progress yet.';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get chartLearnedWords => 'Words learned';

  @override
  String get chartTracksListened => 'Tracks listened';

  @override
  String get chartSteps => 'Steps';

  @override
  String get chartKcal => 'Calories (kcal)';

  @override
  String get listenTitle => 'Listen';

  @override
  String get noBooksInFirestore =>
      'No books in Firestore yet.\nSettings → Sync LibriVox → Sync Latest Data.';

  @override
  String get librivoxAuthorFallback => 'LibriVox';

  @override
  String get librivoxTitle => 'LibriVox';

  @override
  String get bookNotFound => 'Book not found.';

  @override
  String get noChaptersSyncHint =>
      'No chapters yet.\nCheck RSS sync for this book.';

  @override
  String get chapterOpenedSnack => 'Chapter loaded — opening player';

  @override
  String cannotPlay(String error) {
    return 'Could not play: $error';
  }

  @override
  String authorPrefix(String author) {
    return 'Author: $author';
  }

  @override
  String chapterError(String error) {
    return 'Chapter error: $error';
  }

  @override
  String get playerTitle => 'Player';

  @override
  String get signInToSaveHistory => 'Sign in to save history.';

  @override
  String get noEpisodePlaying => 'Nothing is playing.';

  @override
  String get historySavedSnack => 'Saved to History.';

  @override
  String historySaveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get noEpisodeSelected =>
      'No episode selected.\nListen → pick a LibriVox book and chapter to play.';

  @override
  String get saveListenSessionButton => 'Save listening session';

  @override
  String sourceLabel(String url) {
    return 'Source: $url';
  }

  @override
  String get historyByDayTitle => 'History by day';

  @override
  String get noHistoryData => 'No daily history data yet.';

  @override
  String historyDaySummary(
    int words,
    int steps,
    String kcal,
    int tracks,
    int percent,
    int completed,
    int total,
  ) {
    return 'Words: $words · Steps: $steps · Kcal: $kcal · Tracks: $tracks\nComplete: $percent% ($completed/$total)';
  }

  @override
  String historyDayDetailTitle(String dateKey) {
    return 'Details for $dateKey';
  }

  @override
  String get thatDayGoals => 'That day\'s goals';

  @override
  String get noTodoData => 'No plan data.';

  @override
  String get todoKindReview => 'Review old word';

  @override
  String get todoKindNewWord => 'New word';

  @override
  String get tracksListenedSection => 'Tracks listened';

  @override
  String get noTracksListened => 'No tracks listened.';

  @override
  String sessionTimeRange(String start, String end, int minutes, int seconds) {
    return '$start - $end · ${minutes}m ${seconds}s';
  }

  @override
  String get kpiWordsLearned => 'Words learned';

  @override
  String get kpiSteps => 'Steps';

  @override
  String get kpiCalories => 'Calories';

  @override
  String get kpiTracks => 'Tracks';

  @override
  String get kpiPercentComplete => '% complete';

  @override
  String get signInToView => 'Sign in to view.';

  @override
  String get noWordsSaved => 'No words saved yet.';

  @override
  String get pronunciationTooltip => 'Play pronunciation';

  @override
  String exampleLabel(String example) {
    return 'Example: $example';
  }

  @override
  String get librivoxSyncDescription =>
      'Fetch audiobooks from the LibriVox API, parse RSS, and write to Firestore (books / chapters). Up to 10 books; existing documents are skipped.\n\nWhen done: open Listen → LibriVox → pick a book → pick a chapter.';

  @override
  String get syncLatestData => 'Sync Latest Data';

  @override
  String get syncInProgress => 'Syncing…';

  @override
  String get syncPressToStart => 'Press the button to start.';

  @override
  String syncSuccess(int written, int skipped, int chapters) {
    return 'Done.\n• Written: $written books\n• Skipped (existing): $skipped\n• Total chapters written: $chapters';
  }

  @override
  String get syncNetworkError =>
      'Network error — check your connection and try again.';

  @override
  String get syncTimeoutError =>
      'Timed out — LibriVox or RSS took too long to respond.';

  @override
  String get syncSignInRequired => 'Sign in before syncing.';

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get playTooltip => 'Play';

  @override
  String get notificationDefaultTitle => 'Notification';

  @override
  String notificationTitleBody(String title, String body) {
    return '$title · $body';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageSection => 'Language';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get accountSection => 'Account';

  @override
  String get signOutButton => 'Sign out';

  @override
  String get deleteAccountButton => 'Delete account';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountMessage =>
      'This action cannot be undone. All learning data, history, and profile will be permanently deleted.';

  @override
  String get deleteAccountPasswordHint => 'Enter password to confirm';

  @override
  String get deleteAccountConfirm => 'Delete permanently';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteAccountSuccess => 'Account deleted.';

  @override
  String deleteAccountError(String error) {
    return 'Could not delete account: $error';
  }

  @override
  String get deleteAccountReauthRequired =>
      'Please sign out, sign in again, then try deleting your account.';

  @override
  String get noEmailForReauth => 'Account has no email for re-authentication.';

  @override
  String get offlineSnack => 'No network connection.';
}
