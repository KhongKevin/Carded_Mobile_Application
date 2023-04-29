import 'package:flutter/material.dart';
import 'username_text_field.dart';
import 'password_text_field.dart';
class LoginScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Login Screen")),
      body: FractionallySizedBox(
          heightFactor: 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                UsernameTextField(),
                PasswordTextField(),
                ElevatedButton(onPressed: () {  },
                    child: Text("Login!"))],
            )
        )

    );
  }

}