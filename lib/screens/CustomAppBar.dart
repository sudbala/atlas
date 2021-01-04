import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends AppBar {
  BuildContext context;
  String titleText;
  List<Widget> actions;
  Widget myLeading;
  PreferredSizeWidget myBottom;
  Widget flexible;
  CustomAppBar(
      String titleText, List actions, BuildContext context, Widget leading,
      [PreferredSizeWidget bottom, Widget flexible]) {
    this.titleText = titleText;
    this.actions = actions;
    this.context = context;
    this.myLeading = leading;
    this.myBottom = bottom;
    this.flexible = flexible;
  }

  static const TextStyle headerStyle = TextStyle(
    fontSize: 25,
  );

  @override
  // TODO: implement flexibleSpace
  Widget get flexibleSpace => Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomLeft,
                colors: <Color>[
              Color.fromRGBO(39, 124, 161, 1),
              Color.fromRGBO(39, 155, 175, 1),
            ])),
        //child: flexible,
      );

  @override
  // TODO: implement title
  Widget get title => FittedBox(
      fit: BoxFit.fitWidth,
      child: Text(titleText,
          style: GoogleFonts.ebGaramond(textStyle: headerStyle)));

  @override
  // TODO: implement preferredSize
  Size get preferredSize => (this.myBottom != null)
      ? Size.fromHeight(MediaQuery.of(context).size.height * (1 / 8.5))
      : Size.fromHeight(MediaQuery.of(context).size.height * (1 / 20));

  @override
  // TODO: implement leading

  Widget get leading =>
      (this.myLeading != null) ? this.myLeading : super.leading;

  @override
  // TODO: implement bottom
  PreferredSizeWidget get bottom =>
      (this.myBottom != null) ? this.myBottom : super.bottom;
}
