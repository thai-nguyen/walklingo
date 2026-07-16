// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'WalkLingo';

  @override
  String get navToday => 'Hôm nay';

  @override
  String get navProgress => 'Tiến độ';

  @override
  String get navListen => 'Bài nghe';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get loginSubtitleSignIn => 'Đăng nhập để đồng bộ lịch sử';

  @override
  String get loginSubtitleRegister => 'Tạo tài khoản';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailRequired => 'Nhập email';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get passwordMinLength => 'Tối thiểu 6 ký tự';

  @override
  String get signInButton => 'Đăng nhập';

  @override
  String get signUpButton => 'Đăng ký';

  @override
  String get toggleToSignIn => 'Đã có tài khoản? Đăng nhập';

  @override
  String get toggleToSignUp => 'Chưa có tài khoản? Đăng ký';

  @override
  String get greetingMorning => 'Chào buổi sáng';

  @override
  String get greetingMorningMessage =>
      'Bắt đầu ngày mới với vài từ tiếng Anh nhé!';

  @override
  String get greetingAfternoon => 'Chào buổi chiều';

  @override
  String get greetingAfternoonMessage =>
      'Tiếp tục duy trì thói quen học tập nhé!';

  @override
  String get greetingEvening => 'Chào buổi tối';

  @override
  String get greetingEveningMessage => 'Ôn lại từ vựng trước khi nghỉ ngơi.';

  @override
  String get greetingNight => 'Chào bạn';

  @override
  String get greetingNightMessage =>
      'Dành chút thời gian cho tiếng Anh trước khi ngủ nhé!';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name!';
  }

  @override
  String greetingNoName(String greeting) {
    return '$greeting!';
  }

  @override
  String get todaySectionLabel => 'Hôm nay';

  @override
  String get setupTodoTooltip => 'Thiết lập todo';

  @override
  String get signInToUseTodo => 'Đăng nhập để dùng todo.';

  @override
  String get noPlanToday =>
      'Chưa có todo. Nhấn «Thiết lập todo» để thêm từ và mục tiêu.';

  @override
  String get noDataForDay => 'Không có dữ liệu ngày này.';

  @override
  String streakDays(int count) {
    return 'Bạn đã duy trì được $count ngày liên tục.';
  }

  @override
  String get calendarCollapseTooltip => 'Thu gọn — chỉ tuần hiện tại';

  @override
  String get calendarExpandTooltip => 'Mở rộng — xem cả tháng';

  @override
  String planPercentComplete(int percent, int completed, int total) {
    return '$percent% hoàn thành ($completed/$total)';
  }

  @override
  String get sectionReview => 'Ôn tập';

  @override
  String get sectionNewWords => 'Từ mới';

  @override
  String get sectionAudioAndSteps => 'Audio & bước chân';

  @override
  String get quotaAudioTitle => 'Nghe audio';

  @override
  String get quotaStepsTitle => 'Đi bộ';

  @override
  String quotaAudioProgress(int current, int goal) {
    return 'Đã nghe $current / $goal track — tự hoàn thành khi đạt mục tiêu.';
  }

  @override
  String quotaStepsProgress(int current, int goal) {
    return 'Đã đi $current / $goal bước — tự hoàn thành khi đạt mục tiêu.';
  }

  @override
  String genericError(String error) {
    return 'Lỗi: $error';
  }

  @override
  String audioQuotaPreview(int count) {
    return 'Đã chọn $count track để nghe hôm nay';
  }

  @override
  String get setupTodayTitle => 'Thiết lập hôm nay';

  @override
  String tracksSelectedCount(int count) {
    return 'Đã chọn: $count track';
  }

  @override
  String get collapse => 'Thu gọn';

  @override
  String get expand => 'Mở rộng';

  @override
  String get selectLibrivoxBook => 'Chọn sách LibriVox';

  @override
  String get selectBookForTracks => 'Chọn sách để hiện danh sách track.';

  @override
  String get bookNoChapters => 'Sách chưa có chapter.';

  @override
  String get missingAudioUrl => 'Thiếu URL audio';

  @override
  String get trackGoalAutoHint => 'Mục tiêu track tự động = số track đã chọn';

  @override
  String get stepGoalLabel => 'Mục tiêu bước chân';

  @override
  String get wordListLabel =>
      'Danh sách từ (tiếng Anh), mỗi dòng hoặc dấu phẩy';

  @override
  String get createDailyTodoButton => 'Tạo todo ngày';

  @override
  String get errorEnterAtLeastOneWord => 'Nhập ít nhất một từ tiếng Anh.';

  @override
  String get errorSelectAtLeastOneTrack =>
      'Chọn ít nhất 1 track để nghe hôm nay.';

  @override
  String get errorNoWordsLookedUp => 'Không tra được từ nào.';

  @override
  String get snackbarPlanCreated => 'Đã tạo todo hôm nay.';

  @override
  String snackbarPlanCreatedWithSkips(int count) {
    return 'Đã tạo todo. Bỏ qua: $count dòng.';
  }

  @override
  String trackTitleSeparator(String bookTitle, String chapterTitle) {
    return '$bookTitle — $chapterTitle';
  }

  @override
  String get dictEnglishOnly => 'Chỉ hỗ trợ từ tiếng Anh (chữ Latin).';

  @override
  String dictWordNotFound(String lemma) {
    return 'Không tìm thấy từ \"$lemma\" trong từ điển.';
  }

  @override
  String dictApiStatus(int statusCode) {
    return 'API từ điển: $statusCode';
  }

  @override
  String dictNoData(String lemma) {
    return 'Không có dữ liệu cho \"$lemma\".';
  }

  @override
  String dictLookupError(String error) {
    return 'Lỗi tra từ: $error';
  }

  @override
  String get walkingTitle => 'Đi bộ';

  @override
  String get stepsNotSupportedWeb => 'Đếm bước không hỗ trợ trên web.';

  @override
  String get stepsPermissionRequired =>
      'Cần quyền nhận biết hoạt động / chuyển động để đếm bước.';

  @override
  String pedometerError(String error) {
    return 'Lỗi pedometer: $error';
  }

  @override
  String pedometerInitFailed(String error) {
    return 'Không khởi tạo được pedometer: $error';
  }

  @override
  String get todaySessionLabel => 'Hôm nay (theo phiên)';

  @override
  String stepsCount(int count) {
    return '$count bước';
  }

  @override
  String get resetTodayStepsTooltip => 'Reset bước hôm nay';

  @override
  String get stepsResetSnack => 'Đã reset số bước hôm nay.';

  @override
  String get currentSessionLabel => 'Phiên hiện tại';

  @override
  String get noSessionLabel => 'Chưa có phiên';

  @override
  String kcalToday(String kcal) {
    return '$kcal kcal hôm nay';
  }

  @override
  String get endSessionButton => 'Kết thúc phiên';

  @override
  String get startSessionButton => 'Bắt đầu phiên';

  @override
  String get profileForCalorieHint =>
      'Nhập cân nặng/chiều cao trong Cài đặt để ước lượng calo chính xác hơn.';

  @override
  String get walkSessionEndedTitle => 'Phiên đi bộ đã kết thúc';

  @override
  String walkStartedAt(String time) {
    return 'Bắt đầu: $time';
  }

  @override
  String walkEndedAt(String time) {
    return 'Kết thúc: $time';
  }

  @override
  String walkDuration(String duration) {
    return 'Thời lượng: $duration';
  }

  @override
  String walkSessionSteps(int count) {
    return 'Bước trong phiên: $count';
  }

  @override
  String walkEstimatedKcal(String kcal) {
    return 'Ước lượng: $kcal kcal';
  }

  @override
  String walkDeviceTotalSteps(int count) {
    return 'Tổng bước thiết bị (hiện tại): $count';
  }

  @override
  String get closeButton => 'Đóng';

  @override
  String durationHoursMinutesSeconds(int hours, int minutes, int seconds) {
    return '$hours giờ $minutes phút $seconds giây';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes phút $seconds giây';
  }

  @override
  String durationSecondsOnly(int seconds) {
    return '$seconds giây';
  }

  @override
  String get todayTrackFallbackTitle => 'Track đã chọn hôm nay';

  @override
  String get todayGoalSourceName => 'Mục tiêu hôm nay';

  @override
  String get playingTrackForWalk => 'Đang phát track đã chọn cho phiên đi bộ.';

  @override
  String cannotPlaySelectedTrack(String error) {
    return 'Không phát được track đã chọn: $error';
  }

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String get notSignedIn => 'Chưa đăng nhập.';

  @override
  String get uploadAvatarTooltip => 'Tải avatar lên';

  @override
  String get avatarUpdated => 'Đã cập nhật avatar.';

  @override
  String avatarUploadError(String error) {
    return 'Upload avatar lỗi: $error';
  }

  @override
  String get displayNameUnset => 'Chưa đặt tên hiển thị';

  @override
  String get ageLabel => 'Tuổi';

  @override
  String get genderLabel => 'Giới tính';

  @override
  String get weightLabel => 'Cân nặng';

  @override
  String get heightLabel => 'Chiều cao';

  @override
  String get genderMale => 'Nam';

  @override
  String get genderFemale => 'Nữ';

  @override
  String get genderOther => 'Khác';

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
  String get editBasicInfoButton => 'Sửa thông tin cơ bản';

  @override
  String get utilitiesSection => 'Tiện ích';

  @override
  String get learnedWordsTitle => 'Từ đã học';

  @override
  String get learnedWordsSubtitle => 'Danh sách từ vựng đã lưu';

  @override
  String get librivoxSyncTitle => 'Đồng bộ LibriVox';

  @override
  String get librivoxSyncSubtitle =>
      'Sync Latest Data — API + RSS → Firestore books';

  @override
  String get editProfileTitle => 'Chỉnh sửa hồ sơ';

  @override
  String get displayNameLabel => 'Tên hiển thị';

  @override
  String get saveButton => 'Lưu';

  @override
  String saveError(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get weightKgLabel => 'Cân nặng (kg)';

  @override
  String get heightCmLabel => 'Chiều cao (cm)';

  @override
  String get progressTitle => 'Tiến độ';

  @override
  String get historyButton => 'Lịch sử';

  @override
  String get noProgressData => 'Chưa có dữ liệu để vẽ biểu đồ tiến độ.';

  @override
  String get periodDay => 'Ngày';

  @override
  String get periodWeek => 'Tuần';

  @override
  String get periodMonth => 'Tháng';

  @override
  String get chartLearnedWords => 'Số từ đã học';

  @override
  String get chartTracksListened => 'Số track đã nghe';

  @override
  String get chartSteps => 'Số bước chân';

  @override
  String get chartKcal => 'Số kcal';

  @override
  String get listenTitle => 'Bài nghe';

  @override
  String get noBooksInFirestore =>
      'Chưa có sách trong Firestore.\nCài đặt → Đồng bộ LibriVox → Sync Latest Data.';

  @override
  String get librivoxAuthorFallback => 'LibriVox';

  @override
  String get librivoxTitle => 'LibriVox';

  @override
  String get bookNotFound => 'Không tìm thấy sách.';

  @override
  String get noChaptersSyncHint =>
      'Chưa có chapter.\nKiểm tra đồng bộ RSS cho sách này.';

  @override
  String get chapterOpenedSnack => 'Đã mở chapter — sang Trình phát';

  @override
  String cannotPlay(String error) {
    return 'Không phát được: $error';
  }

  @override
  String authorPrefix(String author) {
    return 'Tác giả: $author';
  }

  @override
  String chapterError(String error) {
    return 'Lỗi chapter: $error';
  }

  @override
  String get playerTitle => 'Trình phát';

  @override
  String get signInToSaveHistory => 'Cần đăng nhập để lưu lịch sử.';

  @override
  String get noEpisodePlaying => 'Chưa có bài đang phát.';

  @override
  String get historySavedSnack => 'Đã lưu vào Lịch sử.';

  @override
  String historySaveFailed(String error) {
    return 'Lưu thất bại: $error';
  }

  @override
  String get noEpisodeSelected =>
      'Chưa chọn bài.\nBài nghe → chọn sách LibriVox và một chapter để phát.';

  @override
  String get saveListenSessionButton => 'Lưu session nghe';

  @override
  String sourceLabel(String url) {
    return 'Nguồn: $url';
  }

  @override
  String get historyByDayTitle => 'Lịch sử theo ngày';

  @override
  String get noHistoryData => 'Chưa có dữ liệu lịch sử theo ngày.';

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
    return 'Từ: $words · Bước: $steps · Kcal: $kcal · Track: $tracks\nHoàn thành: $percent% ($completed/$total)';
  }

  @override
  String historyDayDetailTitle(String dateKey) {
    return 'Chi tiết $dateKey';
  }

  @override
  String get thatDayGoals => 'Mục tiêu hôm đó';

  @override
  String get noTodoData => 'Không có dữ liệu todo.';

  @override
  String get todoKindReview => 'Ôn từ cũ';

  @override
  String get todoKindNewWord => 'Từ mới';

  @override
  String get tracksListenedSection => 'Track đã nghe';

  @override
  String get noTracksListened => 'Không có track nào.';

  @override
  String sessionTimeRange(String start, String end, int minutes, int seconds) {
    return '$start - $end · ${minutes}m ${seconds}s';
  }

  @override
  String get kpiWordsLearned => 'Từ đã học';

  @override
  String get kpiSteps => 'Bước';

  @override
  String get kpiCalories => 'Calo';

  @override
  String get kpiTracks => 'Track';

  @override
  String get kpiPercentComplete => '% hoàn thành';

  @override
  String get signInToView => 'Đăng nhập để xem.';

  @override
  String get noWordsSaved => 'Chưa có từ nào được lưu.';

  @override
  String get pronunciationTooltip => 'Phát âm';

  @override
  String exampleLabel(String example) {
    return 'Ví dụ: $example';
  }

  @override
  String get librivoxSyncDescription =>
      'Tải danh sách audiobook từ LibriVox API, parse RSS và ghi vào Firestore (collection books, subcollection chapters). Tối đa 10 sách đầu; sách đã có document sẽ bị bỏ qua.\n\nSau khi xong: mở tab Bài nghe → LibriVox → chọn sách → chọn chapter để nghe.';

  @override
  String get syncLatestData => 'Sync Latest Data';

  @override
  String get syncInProgress => 'Đang đồng bộ…';

  @override
  String get syncPressToStart => 'Nhấn nút để bắt đầu.';

  @override
  String syncSuccess(int written, int skipped, int chapters) {
    return 'Hoàn tất.\n• Đã ghi: $written sách\n• Bỏ qua (đã có): $skipped\n• Tổng chapter ghi: $chapters';
  }

  @override
  String get syncNetworkError => 'Lỗi mạng — kiểm tra kết nối và thử lại.';

  @override
  String get syncTimeoutError =>
      'Hết giờ chờ — LibriVox hoặc RSS phản hồi quá lâu.';

  @override
  String get syncSignInRequired => 'Cần đăng nhập trước khi đồng bộ.';

  @override
  String get pauseTooltip => 'Tạm dừng';

  @override
  String get playTooltip => 'Phát';

  @override
  String get notificationDefaultTitle => 'Thông báo';

  @override
  String notificationTitleBody(String title, String body) {
    return '$title · $body';
  }

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get appearanceSection => 'Giao diện';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get languageSection => 'Ngôn ngữ';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get accountSection => 'Tài khoản';

  @override
  String get signOutButton => 'Đăng xuất';

  @override
  String get deleteAccountButton => 'Xóa tài khoản';

  @override
  String get deleteAccountTitle => 'Xóa tài khoản?';

  @override
  String get deleteAccountMessage =>
      'Hành động này không thể hoàn tác. Toàn bộ dữ liệu học tập, lịch sử và hồ sơ sẽ bị xóa vĩnh viễn.';

  @override
  String get deleteAccountPasswordHint => 'Nhập mật khẩu để xác nhận';

  @override
  String get deleteAccountConfirm => 'Xóa vĩnh viễn';

  @override
  String get cancelButton => 'Hủy';

  @override
  String get deleteAccountSuccess => 'Đã xóa tài khoản.';

  @override
  String deleteAccountError(String error) {
    return 'Không thể xóa tài khoản: $error';
  }

  @override
  String get deleteAccountReauthRequired =>
      'Vui lòng đăng xuất, đăng nhập lại rồi thử xóa tài khoản.';

  @override
  String get noEmailForReauth => 'Tài khoản không có email để xác thực lại.';

  @override
  String get offlineSnack => 'Không có kết nối mạng.';
}
