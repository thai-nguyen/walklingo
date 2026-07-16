import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'WalkLingo'**
  String get appName;

  /// No description provided for @navToday.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get navToday;

  /// No description provided for @navProgress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ'**
  String get navProgress;

  /// No description provided for @navListen.
  ///
  /// In vi, this message translates to:
  /// **'Bài nghe'**
  String get navListen;

  /// No description provided for @navProfile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get navSettings;

  /// No description provided for @loginSubtitleSignIn.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để đồng bộ lịch sử'**
  String get loginSubtitleSignIn;

  /// No description provided for @loginSubtitleRegister.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản'**
  String get loginSubtitleRegister;

  /// No description provided for @emailLabel.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailRequired.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email'**
  String get emailRequired;

  /// No description provided for @passwordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get passwordLabel;

  /// No description provided for @passwordMinLength.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu 6 ký tự'**
  String get passwordMinLength;

  /// No description provided for @signInButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get signInButton;

  /// No description provided for @signUpButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get signUpButton;

  /// No description provided for @toggleToSignIn.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản? Đăng nhập'**
  String get toggleToSignIn;

  /// No description provided for @toggleToSignUp.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản? Đăng ký'**
  String get toggleToSignUp;

  /// No description provided for @greetingMorning.
  ///
  /// In vi, this message translates to:
  /// **'Chào buổi sáng'**
  String get greetingMorning;

  /// No description provided for @greetingMorningMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu ngày mới với vài từ tiếng Anh nhé!'**
  String get greetingMorningMessage;

  /// No description provided for @greetingAfternoon.
  ///
  /// In vi, this message translates to:
  /// **'Chào buổi chiều'**
  String get greetingAfternoon;

  /// No description provided for @greetingAfternoonMessage.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục duy trì thói quen học tập nhé!'**
  String get greetingAfternoonMessage;

  /// No description provided for @greetingEvening.
  ///
  /// In vi, this message translates to:
  /// **'Chào buổi tối'**
  String get greetingEvening;

  /// No description provided for @greetingEveningMessage.
  ///
  /// In vi, this message translates to:
  /// **'Ôn lại từ vựng trước khi nghỉ ngơi.'**
  String get greetingEveningMessage;

  /// No description provided for @greetingNight.
  ///
  /// In vi, this message translates to:
  /// **'Chào bạn'**
  String get greetingNight;

  /// No description provided for @greetingNightMessage.
  ///
  /// In vi, this message translates to:
  /// **'Dành chút thời gian cho tiếng Anh trước khi ngủ nhé!'**
  String get greetingNightMessage;

  /// No description provided for @greetingWithName.
  ///
  /// In vi, this message translates to:
  /// **'{greeting}, {name}!'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @greetingNoName.
  ///
  /// In vi, this message translates to:
  /// **'{greeting}!'**
  String greetingNoName(String greeting);

  /// No description provided for @todaySectionLabel.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get todaySectionLabel;

  /// No description provided for @setupTodoTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Thiết lập todo'**
  String get setupTodoTooltip;

  /// No description provided for @signInToUseTodo.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để dùng todo.'**
  String get signInToUseTodo;

  /// No description provided for @noPlanToday.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có todo. Nhấn «Thiết lập todo» để thêm từ và mục tiêu.'**
  String get noPlanToday;

  /// No description provided for @noDataForDay.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu ngày này.'**
  String get noDataForDay;

  /// No description provided for @streakDays.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã duy trì được {count} ngày liên tục.'**
  String streakDays(int count);

  /// No description provided for @calendarCollapseTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Thu gọn — chỉ tuần hiện tại'**
  String get calendarCollapseTooltip;

  /// No description provided for @calendarExpandTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Mở rộng — xem cả tháng'**
  String get calendarExpandTooltip;

  /// No description provided for @planPercentComplete.
  ///
  /// In vi, this message translates to:
  /// **'{percent}% hoàn thành ({completed}/{total})'**
  String planPercentComplete(int percent, int completed, int total);

  /// No description provided for @sectionReview.
  ///
  /// In vi, this message translates to:
  /// **'Ôn tập'**
  String get sectionReview;

  /// No description provided for @sectionNewWords.
  ///
  /// In vi, this message translates to:
  /// **'Từ mới'**
  String get sectionNewWords;

  /// No description provided for @sectionAudioAndSteps.
  ///
  /// In vi, this message translates to:
  /// **'Audio & bước chân'**
  String get sectionAudioAndSteps;

  /// No description provided for @quotaAudioTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nghe audio'**
  String get quotaAudioTitle;

  /// No description provided for @quotaStepsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đi bộ'**
  String get quotaStepsTitle;

  /// No description provided for @quotaAudioProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đã nghe {current} / {goal} track — tự hoàn thành khi đạt mục tiêu.'**
  String quotaAudioProgress(int current, int goal);

  /// No description provided for @quotaStepsProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đã đi {current} / {goal} bước — tự hoàn thành khi đạt mục tiêu.'**
  String quotaStepsProgress(int current, int goal);

  /// No description provided for @genericError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi: {error}'**
  String genericError(String error);

  /// No description provided for @audioQuotaPreview.
  ///
  /// In vi, this message translates to:
  /// **'Đã chọn {count} track để nghe hôm nay'**
  String audioQuotaPreview(int count);

  /// No description provided for @setupTodayTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thiết lập hôm nay'**
  String get setupTodayTitle;

  /// No description provided for @tracksSelectedCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã chọn: {count} track'**
  String tracksSelectedCount(int count);

  /// No description provided for @collapse.
  ///
  /// In vi, this message translates to:
  /// **'Thu gọn'**
  String get collapse;

  /// No description provided for @expand.
  ///
  /// In vi, this message translates to:
  /// **'Mở rộng'**
  String get expand;

  /// No description provided for @selectLibrivoxBook.
  ///
  /// In vi, this message translates to:
  /// **'Chọn sách LibriVox'**
  String get selectLibrivoxBook;

  /// No description provided for @selectBookForTracks.
  ///
  /// In vi, this message translates to:
  /// **'Chọn sách để hiện danh sách track.'**
  String get selectBookForTracks;

  /// No description provided for @bookNoChapters.
  ///
  /// In vi, this message translates to:
  /// **'Sách chưa có chapter.'**
  String get bookNoChapters;

  /// No description provided for @missingAudioUrl.
  ///
  /// In vi, this message translates to:
  /// **'Thiếu URL audio'**
  String get missingAudioUrl;

  /// No description provided for @trackGoalAutoHint.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu track tự động = số track đã chọn'**
  String get trackGoalAutoHint;

  /// No description provided for @stepGoalLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu bước chân'**
  String get stepGoalLabel;

  /// No description provided for @wordListLabel.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách từ (tiếng Anh), mỗi dòng hoặc dấu phẩy'**
  String get wordListLabel;

  /// No description provided for @createDailyTodoButton.
  ///
  /// In vi, this message translates to:
  /// **'Tạo todo ngày'**
  String get createDailyTodoButton;

  /// No description provided for @errorEnterAtLeastOneWord.
  ///
  /// In vi, this message translates to:
  /// **'Nhập ít nhất một từ tiếng Anh.'**
  String get errorEnterAtLeastOneWord;

  /// No description provided for @errorSelectAtLeastOneTrack.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ít nhất 1 track để nghe hôm nay.'**
  String get errorSelectAtLeastOneTrack;

  /// No description provided for @errorNoWordsLookedUp.
  ///
  /// In vi, this message translates to:
  /// **'Không tra được từ nào.'**
  String get errorNoWordsLookedUp;

  /// No description provided for @snackbarPlanCreated.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo todo hôm nay.'**
  String get snackbarPlanCreated;

  /// No description provided for @snackbarPlanCreatedWithSkips.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo todo. Bỏ qua: {count} dòng.'**
  String snackbarPlanCreatedWithSkips(int count);

  /// No description provided for @trackTitleSeparator.
  ///
  /// In vi, this message translates to:
  /// **'{bookTitle} — {chapterTitle}'**
  String trackTitleSeparator(String bookTitle, String chapterTitle);

  /// No description provided for @dictEnglishOnly.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ hỗ trợ từ tiếng Anh (chữ Latin).'**
  String get dictEnglishOnly;

  /// No description provided for @dictWordNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy từ \"{lemma}\" trong từ điển.'**
  String dictWordNotFound(String lemma);

  /// No description provided for @dictApiStatus.
  ///
  /// In vi, this message translates to:
  /// **'API từ điển: {statusCode}'**
  String dictApiStatus(int statusCode);

  /// No description provided for @dictNoData.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu cho \"{lemma}\".'**
  String dictNoData(String lemma);

  /// No description provided for @dictLookupError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tra từ: {error}'**
  String dictLookupError(String error);

  /// No description provided for @walkingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đi bộ'**
  String get walkingTitle;

  /// No description provided for @stepsNotSupportedWeb.
  ///
  /// In vi, this message translates to:
  /// **'Đếm bước không hỗ trợ trên web.'**
  String get stepsNotSupportedWeb;

  /// No description provided for @stepsPermissionRequired.
  ///
  /// In vi, this message translates to:
  /// **'Cần quyền nhận biết hoạt động / chuyển động để đếm bước.'**
  String get stepsPermissionRequired;

  /// No description provided for @pedometerError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi pedometer: {error}'**
  String pedometerError(String error);

  /// No description provided for @pedometerInitFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không khởi tạo được pedometer: {error}'**
  String pedometerInitFailed(String error);

  /// No description provided for @todaySessionLabel.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay (theo phiên)'**
  String get todaySessionLabel;

  /// No description provided for @stepsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} bước'**
  String stepsCount(int count);

  /// No description provided for @resetTodayStepsTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Reset bước hôm nay'**
  String get resetTodayStepsTooltip;

  /// No description provided for @stepsResetSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã reset số bước hôm nay.'**
  String get stepsResetSnack;

  /// No description provided for @currentSessionLabel.
  ///
  /// In vi, this message translates to:
  /// **'Phiên hiện tại'**
  String get currentSessionLabel;

  /// No description provided for @noSessionLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có phiên'**
  String get noSessionLabel;

  /// No description provided for @kcalToday.
  ///
  /// In vi, this message translates to:
  /// **'{kcal} kcal hôm nay'**
  String kcalToday(String kcal);

  /// No description provided for @endSessionButton.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc phiên'**
  String get endSessionButton;

  /// No description provided for @startSessionButton.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu phiên'**
  String get startSessionButton;

  /// No description provided for @profileForCalorieHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập cân nặng/chiều cao trong Cài đặt để ước lượng calo chính xác hơn.'**
  String get profileForCalorieHint;

  /// No description provided for @walkSessionEndedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phiên đi bộ đã kết thúc'**
  String get walkSessionEndedTitle;

  /// No description provided for @walkStartedAt.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu: {time}'**
  String walkStartedAt(String time);

  /// No description provided for @walkEndedAt.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc: {time}'**
  String walkEndedAt(String time);

  /// No description provided for @walkDuration.
  ///
  /// In vi, this message translates to:
  /// **'Thời lượng: {duration}'**
  String walkDuration(String duration);

  /// No description provided for @walkSessionSteps.
  ///
  /// In vi, this message translates to:
  /// **'Bước trong phiên: {count}'**
  String walkSessionSteps(int count);

  /// No description provided for @walkEstimatedKcal.
  ///
  /// In vi, this message translates to:
  /// **'Ước lượng: {kcal} kcal'**
  String walkEstimatedKcal(String kcal);

  /// No description provided for @walkDeviceTotalSteps.
  ///
  /// In vi, this message translates to:
  /// **'Tổng bước thiết bị (hiện tại): {count}'**
  String walkDeviceTotalSteps(int count);

  /// No description provided for @closeButton.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get closeButton;

  /// No description provided for @durationHoursMinutesSeconds.
  ///
  /// In vi, this message translates to:
  /// **'{hours} giờ {minutes} phút {seconds} giây'**
  String durationHoursMinutesSeconds(int hours, int minutes, int seconds);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In vi, this message translates to:
  /// **'{minutes} phút {seconds} giây'**
  String durationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @durationSecondsOnly.
  ///
  /// In vi, this message translates to:
  /// **'{seconds} giây'**
  String durationSecondsOnly(int seconds);

  /// No description provided for @todayTrackFallbackTitle.
  ///
  /// In vi, this message translates to:
  /// **'Track đã chọn hôm nay'**
  String get todayTrackFallbackTitle;

  /// No description provided for @todayGoalSourceName.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu hôm nay'**
  String get todayGoalSourceName;

  /// No description provided for @playingTrackForWalk.
  ///
  /// In vi, this message translates to:
  /// **'Đang phát track đã chọn cho phiên đi bộ.'**
  String get playingTrackForWalk;

  /// No description provided for @cannotPlaySelectedTrack.
  ///
  /// In vi, this message translates to:
  /// **'Không phát được track đã chọn: {error}'**
  String cannotPlaySelectedTrack(String error);

  /// No description provided for @profileTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get profileTitle;

  /// No description provided for @notSignedIn.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đăng nhập.'**
  String get notSignedIn;

  /// No description provided for @uploadAvatarTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Tải avatar lên'**
  String get uploadAvatarTooltip;

  /// No description provided for @avatarUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật avatar.'**
  String get avatarUpdated;

  /// No description provided for @avatarUploadError.
  ///
  /// In vi, this message translates to:
  /// **'Upload avatar lỗi: {error}'**
  String avatarUploadError(String error);

  /// No description provided for @displayNameUnset.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đặt tên hiển thị'**
  String get displayNameUnset;

  /// No description provided for @ageLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tuổi'**
  String get ageLabel;

  /// No description provided for @genderLabel.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính'**
  String get genderLabel;

  /// No description provided for @weightLabel.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng'**
  String get weightLabel;

  /// No description provided for @heightLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao'**
  String get heightLabel;

  /// No description provided for @genderMale.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get genderOther;

  /// No description provided for @genderUnknown.
  ///
  /// In vi, this message translates to:
  /// **'—'**
  String get genderUnknown;

  /// No description provided for @weightKgValue.
  ///
  /// In vi, this message translates to:
  /// **'{weight} kg'**
  String weightKgValue(String weight);

  /// No description provided for @heightCmValue.
  ///
  /// In vi, this message translates to:
  /// **'{height} cm'**
  String heightCmValue(String height);

  /// No description provided for @infoChipFormat.
  ///
  /// In vi, this message translates to:
  /// **'{label}: {value}'**
  String infoChipFormat(String label, String value);

  /// No description provided for @editBasicInfoButton.
  ///
  /// In vi, this message translates to:
  /// **'Sửa thông tin cơ bản'**
  String get editBasicInfoButton;

  /// No description provided for @utilitiesSection.
  ///
  /// In vi, this message translates to:
  /// **'Tiện ích'**
  String get utilitiesSection;

  /// No description provided for @learnedWordsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Từ đã học'**
  String get learnedWordsTitle;

  /// No description provided for @learnedWordsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách từ vựng đã lưu'**
  String get learnedWordsSubtitle;

  /// No description provided for @librivoxSyncTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ LibriVox'**
  String get librivoxSyncTitle;

  /// No description provided for @librivoxSyncSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Sync Latest Data — API + RSS → Firestore books'**
  String get librivoxSyncSubtitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa hồ sơ'**
  String get editProfileTitle;

  /// No description provided for @displayNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên hiển thị'**
  String get displayNameLabel;

  /// No description provided for @saveButton.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get saveButton;

  /// No description provided for @saveError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi: {error}'**
  String saveError(String error);

  /// No description provided for @weightKgLabel.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng (kg)'**
  String get weightKgLabel;

  /// No description provided for @heightCmLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao (cm)'**
  String get heightCmLabel;

  /// No description provided for @progressTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ'**
  String get progressTitle;

  /// No description provided for @historyButton.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get historyButton;

  /// No description provided for @noProgressData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu để vẽ biểu đồ tiến độ.'**
  String get noProgressData;

  /// No description provided for @periodDay.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In vi, this message translates to:
  /// **'Tuần'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng'**
  String get periodMonth;

  /// No description provided for @chartLearnedWords.
  ///
  /// In vi, this message translates to:
  /// **'Số từ đã học'**
  String get chartLearnedWords;

  /// No description provided for @chartTracksListened.
  ///
  /// In vi, this message translates to:
  /// **'Số track đã nghe'**
  String get chartTracksListened;

  /// No description provided for @chartSteps.
  ///
  /// In vi, this message translates to:
  /// **'Số bước chân'**
  String get chartSteps;

  /// No description provided for @chartKcal.
  ///
  /// In vi, this message translates to:
  /// **'Số kcal'**
  String get chartKcal;

  /// No description provided for @listenTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bài nghe'**
  String get listenTitle;

  /// No description provided for @noBooksInFirestore.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có sách trong Firestore.\nCài đặt → Đồng bộ LibriVox → Sync Latest Data.'**
  String get noBooksInFirestore;

  /// No description provided for @librivoxAuthorFallback.
  ///
  /// In vi, this message translates to:
  /// **'LibriVox'**
  String get librivoxAuthorFallback;

  /// No description provided for @librivoxTitle.
  ///
  /// In vi, this message translates to:
  /// **'LibriVox'**
  String get librivoxTitle;

  /// No description provided for @bookNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy sách.'**
  String get bookNotFound;

  /// No description provided for @noChaptersSyncHint.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có chapter.\nKiểm tra đồng bộ RSS cho sách này.'**
  String get noChaptersSyncHint;

  /// No description provided for @chapterOpenedSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã mở chapter — sang Trình phát'**
  String get chapterOpenedSnack;

  /// No description provided for @cannotPlay.
  ///
  /// In vi, this message translates to:
  /// **'Không phát được: {error}'**
  String cannotPlay(String error);

  /// No description provided for @authorPrefix.
  ///
  /// In vi, this message translates to:
  /// **'Tác giả: {author}'**
  String authorPrefix(String author);

  /// No description provided for @chapterError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi chapter: {error}'**
  String chapterError(String error);

  /// No description provided for @playerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Trình phát'**
  String get playerTitle;

  /// No description provided for @signInToSaveHistory.
  ///
  /// In vi, this message translates to:
  /// **'Cần đăng nhập để lưu lịch sử.'**
  String get signInToSaveHistory;

  /// No description provided for @noEpisodePlaying.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bài đang phát.'**
  String get noEpisodePlaying;

  /// No description provided for @historySavedSnack.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu vào Lịch sử.'**
  String get historySavedSnack;

  /// No description provided for @historySaveFailed.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thất bại: {error}'**
  String historySaveFailed(String error);

  /// No description provided for @noEpisodeSelected.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chọn bài.\nBài nghe → chọn sách LibriVox và một chapter để phát.'**
  String get noEpisodeSelected;

  /// No description provided for @saveListenSessionButton.
  ///
  /// In vi, this message translates to:
  /// **'Lưu session nghe'**
  String get saveListenSessionButton;

  /// No description provided for @sourceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn: {url}'**
  String sourceLabel(String url);

  /// No description provided for @historyByDayTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử theo ngày'**
  String get historyByDayTitle;

  /// No description provided for @noHistoryData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu lịch sử theo ngày.'**
  String get noHistoryData;

  /// No description provided for @historyDaySummary.
  ///
  /// In vi, this message translates to:
  /// **'Từ: {words} · Bước: {steps} · Kcal: {kcal} · Track: {tracks}\nHoàn thành: {percent}% ({completed}/{total})'**
  String historyDaySummary(
    int words,
    int steps,
    String kcal,
    int tracks,
    int percent,
    int completed,
    int total,
  );

  /// No description provided for @historyDayDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết {dateKey}'**
  String historyDayDetailTitle(String dateKey);

  /// No description provided for @thatDayGoals.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu hôm đó'**
  String get thatDayGoals;

  /// No description provided for @noTodoData.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu todo.'**
  String get noTodoData;

  /// No description provided for @todoKindReview.
  ///
  /// In vi, this message translates to:
  /// **'Ôn từ cũ'**
  String get todoKindReview;

  /// No description provided for @todoKindNewWord.
  ///
  /// In vi, this message translates to:
  /// **'Từ mới'**
  String get todoKindNewWord;

  /// No description provided for @tracksListenedSection.
  ///
  /// In vi, this message translates to:
  /// **'Track đã nghe'**
  String get tracksListenedSection;

  /// No description provided for @noTracksListened.
  ///
  /// In vi, this message translates to:
  /// **'Không có track nào.'**
  String get noTracksListened;

  /// No description provided for @sessionTimeRange.
  ///
  /// In vi, this message translates to:
  /// **'{start} - {end} · {minutes}m {seconds}s'**
  String sessionTimeRange(String start, String end, int minutes, int seconds);

  /// No description provided for @kpiWordsLearned.
  ///
  /// In vi, this message translates to:
  /// **'Từ đã học'**
  String get kpiWordsLearned;

  /// No description provided for @kpiSteps.
  ///
  /// In vi, this message translates to:
  /// **'Bước'**
  String get kpiSteps;

  /// No description provided for @kpiCalories.
  ///
  /// In vi, this message translates to:
  /// **'Calo'**
  String get kpiCalories;

  /// No description provided for @kpiTracks.
  ///
  /// In vi, this message translates to:
  /// **'Track'**
  String get kpiTracks;

  /// No description provided for @kpiPercentComplete.
  ///
  /// In vi, this message translates to:
  /// **'% hoàn thành'**
  String get kpiPercentComplete;

  /// No description provided for @signInToView.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để xem.'**
  String get signInToView;

  /// No description provided for @noWordsSaved.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có từ nào được lưu.'**
  String get noWordsSaved;

  /// No description provided for @pronunciationTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Phát âm'**
  String get pronunciationTooltip;

  /// No description provided for @exampleLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: {example}'**
  String exampleLabel(String example);

  /// No description provided for @librivoxSyncDescription.
  ///
  /// In vi, this message translates to:
  /// **'Tải danh sách audiobook từ LibriVox API, parse RSS và ghi vào Firestore (collection books, subcollection chapters). Tối đa 10 sách đầu; sách đã có document sẽ bị bỏ qua.\n\nSau khi xong: mở tab Bài nghe → LibriVox → chọn sách → chọn chapter để nghe.'**
  String get librivoxSyncDescription;

  /// No description provided for @syncLatestData.
  ///
  /// In vi, this message translates to:
  /// **'Sync Latest Data'**
  String get syncLatestData;

  /// No description provided for @syncInProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đang đồng bộ…'**
  String get syncInProgress;

  /// No description provided for @syncPressToStart.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn nút để bắt đầu.'**
  String get syncPressToStart;

  /// No description provided for @syncSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất.\n• Đã ghi: {written} sách\n• Bỏ qua (đã có): {skipped}\n• Tổng chapter ghi: {chapters}'**
  String syncSuccess(int written, int skipped, int chapters);

  /// No description provided for @syncNetworkError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi mạng — kiểm tra kết nối và thử lại.'**
  String get syncNetworkError;

  /// No description provided for @syncTimeoutError.
  ///
  /// In vi, this message translates to:
  /// **'Hết giờ chờ — LibriVox hoặc RSS phản hồi quá lâu.'**
  String get syncTimeoutError;

  /// No description provided for @syncSignInRequired.
  ///
  /// In vi, this message translates to:
  /// **'Cần đăng nhập trước khi đồng bộ.'**
  String get syncSignInRequired;

  /// No description provided for @pauseTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Tạm dừng'**
  String get pauseTooltip;

  /// No description provided for @playTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Phát'**
  String get playTooltip;

  /// No description provided for @notificationDefaultTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notificationDefaultTitle;

  /// No description provided for @notificationTitleBody.
  ///
  /// In vi, this message translates to:
  /// **'{title} · {body}'**
  String notificationTitleBody(String title, String body);

  /// No description provided for @settingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsTitle;

  /// No description provided for @appearanceSection.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get appearanceSection;

  /// No description provided for @themeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get themeDark;

  /// No description provided for @languageSection.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get languageSection;

  /// No description provided for @languageVietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @languageEnglish.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @accountSection.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get accountSection;

  /// No description provided for @signOutButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get signOutButton;

  /// No description provided for @deleteAccountButton.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tài khoản'**
  String get deleteAccountButton;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tài khoản?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In vi, this message translates to:
  /// **'Hành động này không thể hoàn tác. Toàn bộ dữ liệu học tập, lịch sử và hồ sơ sẽ bị xóa vĩnh viễn.'**
  String get deleteAccountMessage;

  /// No description provided for @deleteAccountPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu để xác nhận'**
  String get deleteAccountPasswordHint;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xóa vĩnh viễn'**
  String get deleteAccountConfirm;

  /// No description provided for @cancelButton.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancelButton;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa tài khoản.'**
  String get deleteAccountSuccess;

  /// No description provided for @deleteAccountError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể xóa tài khoản: {error}'**
  String deleteAccountError(String error);

  /// No description provided for @deleteAccountReauthRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng xuất, đăng nhập lại rồi thử xóa tài khoản.'**
  String get deleteAccountReauthRequired;

  /// No description provided for @noEmailForReauth.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản không có email để xác thực lại.'**
  String get noEmailForReauth;

  /// No description provided for @offlineSnack.
  ///
  /// In vi, this message translates to:
  /// **'Không có kết nối mạng.'**
  String get offlineSnack;
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
