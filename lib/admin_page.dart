import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haring_admin/config/palette.dart';
import 'package:haring_admin/controllers/room_controller.dart';
import 'package:haring_admin/models/room.dart';

String radioValue = 'pin';
double sliderValue = 0;
final searchCont = TextEditingController();
final roomCont = Get.put(RoomController());

void deletePopUp(String title, String content, VoidCallback onConfirm) {
  Get.defaultDialog(
    title: title,
    titleStyle: const TextStyle(fontWeight: FontWeight.bold,),
    titlePadding: const EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 5.0),
    content: Column(
      children: [
        Container(
          height: 80.0,
          decoration: BoxDecoration(
            color: Palette.themeColor1.withOpacity(.1),
          ),
          child: Center(
            child: Text(content, textAlign: TextAlign.center,),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: TextButton(
                onPressed: onConfirm,
                child: const Text(
                  '확인',
                  style: TextStyle(
                    color: Palette.themeColor1,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    ),
  );
}

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  // appbar
  PreferredSizeWidget myAppBar() => AppBar(
    backgroundColor: Colors.white.withOpacity(0.0),
    elevation: 0.0,
    iconTheme: const IconThemeData(
      color: Palette.themeColor1,
    ),
    leading: IconButton(
      icon: const Icon(
        Icons.arrow_back_ios,
      ),
      onPressed: () => Get.back(),
    ),
    actions: [
      IconButton(
        onPressed: () => setState(() {
          roomCont.selectAllRooms();
          roomCont.setStateOfCheckBox();
        }),
        icon: Icon(
          roomCont.stateOfCheckBox == 'all' ?
          Icons.check_box :
          roomCont.stateOfCheckBox == 'determinate' ?
          Icons.indeterminate_check_box :
          Icons.check_box_outline_blank,
        ),
      ),
      IconButton(
        onPressed: () => filterPopUp('정렬 및 필터', () {
          setState(() {
            roomCont.sortRooms(radioValue);
            if (radioValue == 'pin') { roomCont.search(searchCont.text); }
            else { roomCont.selectOlderPin(sliderValue); }
            roomCont.setStateOfCheckBox();
            searchCont.text = '';
          });
          Get.back();
        }),
        icon: const Icon(Icons.filter_alt),
      ),
      IconButton(
        onPressed: () async {
          deletePopUp('주의', "정말 선택한 pin 을\n삭제하시겠습니까?", () async {
            final f = FirebaseDatabase.instance.ref('pins');

            for (Room room in roomCont.rooms) {
              if (!room.isSelected) continue;
              DatabaseEvent event = await f.child(room.pin).once();

              if (event.snapshot.exists) {
                f.child(room.pin).remove();
              }
            }
            roomCont.setStateOfCheckBox();
            Get.back();
          });
        },
        icon: const Icon(Icons.delete),
      ),
    ],
  );

  void loadRealDB(DatabaseReference f) {
    Stream<DatabaseEvent> stream = f.onValue;

    stream.listen((event) {
      setState(() {
        roomCont.rooms([]);
        roomCont.subLoadDB(event);
      });
    });
  }

  void filterPopUp(String title, VoidCallback onConfirm) {
    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold,),
      titlePadding: const EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 5.0),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Palette.themeColor1.withOpacity(.1),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0,),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => setState(() => radioValue = 'pin'),
                              child: Row(
                                children: [
                                  const Text(
                                    'pin',
                                    style: TextStyle(
                                      fontFamily: 'MontserratBold',
                                      fontFamilyFallback: ['OneMobileTitle'],
                                      color: Palette.themeColor1,
                                    ),
                                  ),
                                  const SizedBox(width: 5.0,),
                                  Icon(
                                    radioValue == 'pin' ?
                                    Icons.radio_button_checked :
                                    Icons.radio_button_off,
                                    color: Palette.themeColor1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            InkWell(
                              onTap: () => setState(() => radioValue = 'passedTime'),
                              child: Row(
                                children: [
                                  const Text(
                                    '생성시간',
                                    style: TextStyle(
                                      fontFamily: 'MontserratBold',
                                      fontFamilyFallback: ['OneMobileTitle'],
                                      color: Palette.themeColor1,
                                    ),
                                  ),
                                  const SizedBox(width: 5.0,),
                                  Icon(
                                    radioValue == 'pin' ?
                                    Icons.radio_button_off :
                                    Icons.radio_button_checked,
                                    color: Palette.themeColor1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (radioValue == 'pin')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                      child: TextFormField(
                        controller: searchCont,
                        autofocus: false,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'search',
                          contentPadding: EdgeInsets.all(8.0),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Palette.themeColor1,
                              width: 2.0,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontFamily: 'MontserratRegular',
                          fontFamilyFallback: ['OneMobileTitle'],
                          color: Palette.themeColor1,
                        ),
                      ),
                    ),
                    if (radioValue == 'passedTime')
                    Row(
                      children: [
                        Container(
                          width: 90.0,
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            Room.convertToPassedTime(Duration(seconds: roomCont.sliderNumber.value.toInt())),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15.0,
                              color: Palette.themeColor1,
                              fontFamily: 'MontserratBold',
                              fontFamilyFallback: ['OneMobileTitle'],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 150.0,
                          child: SliderTheme(
                            data: const SliderThemeData(
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.0),
                              trackHeight: 4.0,
                            ),
                            child: Slider(
                              min: 0.0,
                              max: roomCont.maxGenTime.value.toDouble(),
                              value: roomCont.sliderNumber.value,
                              inactiveColor: Colors.white,
                              activeColor: Palette.themeColor1,
                              onChanged: (value) => setState(() {
                                roomCont.sliderNumber(value);
                                sliderValue = value;
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: TextButton(
                      onPressed: onConfirm,
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          color: Palette.themeColor1,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        }
      ),
    );
  }

  @override
  void initState() {
    final f = FirebaseDatabase.instance.ref('pins');
    super.initState();
    if (mounted) setState(() => loadRealDB(f));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: roomCont.rooms.length,
        itemBuilder: (BuildContext context, int index) {
          return HeaderTile(roomCont.rooms[index]);
        },
      ),
    );
  }
}

class HeaderTile extends StatefulWidget {
  const HeaderTile(this._room, {Key? key}) : super(key: key);

  final Room _room;

  @override
  State<HeaderTile> createState() => _HeaderTileState();
}

class _HeaderTileState extends State<HeaderTile> {

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() => roomCont.calcPassedTime());
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    _AdminPageState? parent = context
        .findAncestorStateOfType<_AdminPageState>();

    return ListTile(
      onTap: () => parent!.setState(() {
        widget._room.toggleSelection();
        roomCont.setStateOfCheckBox();
      }),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget._room.isSelected ?
            Icons.check_box :
            Icons.check_box_outline_blank,
            color: Palette.themeColor1,
          ),
        ],
      ),
      title: Text(
        widget._room.pin,
        style: const TextStyle(
          fontFamily: 'MontserratBold',
          color: Palette.themeColor1,
        ),
      ),
      subtitle: Text(
        widget._room.passedTime,
        style: const TextStyle(
          fontFamily: 'MontserratRegular',
        ),
      ),

      trailing: IconButton(
        onPressed: () async {
          deletePopUp('주의', "정말 pin '${widget._room.pin}'을\n삭제하시겠습니까?", () async {
            final f = FirebaseDatabase.instance.ref('pins');
            DatabaseEvent event = await f.child(widget._room.pin).once();

            if (event.snapshot.exists) {
              await f.child(widget._room.pin).remove();
            }
            Get.back();
          });
        },
        icon: const Icon(Icons.close),
      ),
    );
  }
}