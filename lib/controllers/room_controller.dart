import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:haring_admin/admin_page.dart';
import 'package:haring_admin/models/room.dart';

class RoomController extends GetxController {
  final rooms = RxList<Room>([]);
  late RxInt maxGenTime = 0.obs;
  late RxInt minGenTime = 999999.obs;
  RxDouble sliderNumber = 0.0.obs;

  bool isAllSelected = false;
  String stateOfCheckBox = 'blank';

  void calcPassedTime() => rooms.forEach((room) => room.setPassedTime());

  void subLoadDB(DatabaseEvent event) {
    late DateTime loadedGenTime;

    if (event.snapshot.value == null) return;
    var loadedRooms = event.snapshot.value as Map;

    for (var pin in loadedRooms.keys) {
      loadedGenTime = DateTime.parse(loadedRooms[pin]['genTime']);
      rooms.add(Room(pin: pin, genTime: loadedGenTime));
    }
    setMinMaxGenTime();
    sortRooms(radioValue);
    roomCont.setStateOfCheckBox();
  }

  void setMinMaxGenTime() {
    late Duration diff;

    for (Room room in rooms) {
      diff = DateTime.now().difference(room.genTime);
      maxGenTime(max(maxGenTime.value, diff.inSeconds));
      minGenTime(min(minGenTime.value, diff.inSeconds));
    }
  }

  void selectAllRooms() {
    isAllSelected = stateOfCheckBox == 'blank';
    rooms.forEach((room) => room.isSelected = isAllSelected);
  }

  void deSelectAllRooms() {
    rooms.forEach((room) => room.isSelected = false);
    setStateOfCheckBox();
  }

  void setStateOfCheckBox() {
    int num = rooms.where((room) => room.isSelected == true).toList().length;
    stateOfCheckBox = num < rooms.length ? num == 0 ? 'blank' : 'determinate' : 'all';
  }

  void sortRooms(String type) {
    type == 'passedTime' ?
    rooms.sort((room1, room2) => room1.genTime.compareTo(room2.genTime)) :
    rooms.sort((room1, room2) => room1.pin.compareTo(room2.pin));
  }

  void search(String keyword) {
    if (keyword == '') { deSelectAllRooms(); return; }
    final _rooms = RxList<Room>([]);
    deSelectAllRooms();

    rooms.forEach((room) {
      if (room.pin.contains(keyword)) {
        room.isSelected = true;
        _rooms.add(room);
      }
    });
    rooms.forEach((room) { if (!room.pin.contains(keyword)) _rooms.add(room); });
    rooms(_rooms);
  }

  void selectOlderPin(double value) {
    late Duration diff;
    deSelectAllRooms();
    if (value == 0) return;
    rooms.forEach((room) {
      diff = DateTime.now().difference(room.genTime);
      if (diff.inSeconds > value) room.isSelected = true;
    });
  }
}
