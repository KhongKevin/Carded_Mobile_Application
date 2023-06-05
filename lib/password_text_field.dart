import 'package:flutter/material.dart';


class PasswordTextField extends StatefulWidget {

  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<PasswordTextField> {
  final controller = TextEditingController();
  String text = "";
  @override
  void dispose(){
    super.dispose();
    controller.dispose();
  }

  void changeText(text){
    setState(() {
      this.text = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children:<Widget>[
      Container(
        width: 300,
        child:
        TextField(
          controller: this.controller,
          decoration: InputDecoration(
              labelText: "Password:",
              prefixIcon: Icon(Icons.account_circle)),
          onChanged: (text)=> this.changeText(text),
        ),
      ),
      Text(text)
    ]);

  }
}
