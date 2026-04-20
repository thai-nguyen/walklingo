enum DailyTodoKind { reviewOldWord, newWord, audioQuota, stepsQuota }

DailyTodoKind dailyTodoKindFromJson(String v) {
  switch (v) {
    case "reviewOldWord":
      return DailyTodoKind.reviewOldWord;
    case "newWord":
      return DailyTodoKind.newWord;
    case "audioQuota":
      return DailyTodoKind.audioQuota;
    case "stepsQuota":
      return DailyTodoKind.stepsQuota;
    default:
      return DailyTodoKind.newWord;
  }
}

String dailyTodoKindToJson(DailyTodoKind k) {
  switch (k) {
    case DailyTodoKind.reviewOldWord:
      return "reviewOldWord";
    case DailyTodoKind.newWord:
      return "newWord";
    case DailyTodoKind.audioQuota:
      return "audioQuota";
    case DailyTodoKind.stepsQuota:
      return "stepsQuota";
  }
}
