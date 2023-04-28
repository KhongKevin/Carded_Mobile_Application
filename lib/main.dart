import 'package:carded/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carded',
      theme: ThemeData(

        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CardedHomePage(),
    );
  }
}


class CardedHomePage extends StatelessWidget{
  const CardedHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Carded")),
        body: Container(
            child: FractionallySizedBox(
              heightFactor: 0.7,
              child:
              Center(
                child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 200.0, // set the desired width here
                        child: ElevatedButton(
                          child: Text("Login Page"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 50),
                      SizedBox(
                        width: 200.0, // set the desired width here
                        child: ElevatedButton(
                          child: Text("Sign Up Page"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpScreen()),
                            );
                          },
                        ),
                      ),


                      SizedBox(height: 50),
                      SizedBox(
                        width: 200.0, // set the desired width here
                        child: ElevatedButton(
                          child: Text("Settings Page"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SettingsScreen()),
                            );
                          },
                        ),
                      ),]
                ),
              )
            )
          )
        );

  }

}

