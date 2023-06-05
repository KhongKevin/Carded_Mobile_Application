import 'package:flutter/material.dart';


class UsernameTextField extends StatefulWidget {
  const UsernameTextField({super.key});


  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<UsernameTextField> {
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
      Center(
        child:SizedBox(
            width: 300,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.account_circle),
                  labelText: "Username:"),
              onChanged: (text)=> changeText(text),
            )
        ),
      ),
      Text(text)
    ]);
  }
}