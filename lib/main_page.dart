import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:haring_admin/admin_page.dart';
import 'package:haring_admin/config/Palette.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  Widget mainButton(String text, VoidCallback? onPressed) => SizedBox(
    width: 150.0,
    height: 30.0,
    child: OutlinedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: text == 'create' ? Palette.themeColor2 : Palette.themeColor1,
          fontFamily: 'MontserratRegular',
          fontSize: 10.0,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: text == 'create' ? Palette.themeColor2 : Palette.themeColor1,
          style: BorderStyle.solid,
          width: 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,]);
  }

  @override
  Widget build(BuildContext context) {

    return OrientationBuilder(
        builder: (context, orientation) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Logo('ha', 'ring'),
                  const SizedBox(height: 15.0,),
                  mainButton('ADMINISTRATE', () => Get.to(() => const AdminPage())),
                ],
              ),
            ),
          );
        }
    );
  }
}


// logo
class Logo extends StatefulWidget {
  const Logo(
      this.firstText,
      this.secondText, {
        Key? key,
        this.shadowing = true,
      }) : super(key: key) ;

  final String firstText;
  final String secondText;
  final bool shadowing;

  @override
  State<Logo> createState() => _LogoState();
}
class _LogoState extends State<Logo> {
  List<Shadow>? getShadow() => widget.shadowing ? [
    const Shadow(
      offset: Offset(2.5, 2.5),
      blurRadius: 10.0,
      color: Colors.black38,
    ),
  ] : null;

  Widget logo(String text, Color color) => Text(
    text,
    style: TextStyle(
      color: color,
      fontFamily: 'MontserratBold',
      fontSize: 80.0,
      fontWeight: FontWeight.bold,
      shadows: getShadow(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        logo(widget.firstText, Palette.themeColor2),
        logo(widget.secondText, Palette.themeColor1),
      ],
    );
  }
}