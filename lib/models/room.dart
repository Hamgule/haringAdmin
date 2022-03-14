class Room {
  String pin;
  DateTime genTime;
  bool isSelected = false;
  String passedTime = '';

  Room({required this.pin, required this.genTime});

  void toggleSelection() => isSelected = !isSelected;
  void setPassedTime() {
    Duration diffNow = DateTime.now().difference(genTime);
    passedTime = convertToPassedTime(diffNow);
  }

  static String timeFormat(String type, int value) {
    return value < 2 ? '$value $type' : '$value ${type}s';
  }

  static String convertToPassedTime(Duration diffNow) {
    int days = diffNow.inDays;
    int hours = diffNow.inHours;
    int minutes = diffNow.inMinutes;
    int seconds = diffNow.inSeconds;

    return (
      days > 0 ? timeFormat('day', days) :
      hours > 0 ? timeFormat('hour', hours) :
      minutes > 0 ? timeFormat('minute', minutes) :
      timeFormat('second', seconds)
    );
  }
}