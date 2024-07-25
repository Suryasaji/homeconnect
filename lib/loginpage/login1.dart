import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:p/loginpage/login2.dart';
import 'package:p/loginpage/login3.dart';

class login1 extends StatefulWidget {
  @override
  _Login1State createState() => _Login1State();
}

class _Login1State extends State<login1> {
  Color habitueColor = Color(0xFF999999);
  Color ownerColor = Color(0xFF999999);
  Color createAccountColor = Color(0xFF999999);
  Color haveAccountColor = Color(0xFF999999);
  double linePosition = 0;
  double lineHeight = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000000), Color(0xFF000000)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://storage.googleapis.com/codeless-dev.appspot.com/uploads%2Fimages%2FcbcmxVVQi7l7bydVexSq%2F1980c60d35a3cb908829f5a8d4fddb26.png',
                  width: 28,
                  height: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Text(
                  'HomeConnect',
                  textAlign: TextAlign.left,
                  style: GoogleFonts.lexend(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE1D5FF),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Image.network(
              'https://firebasestorage.googleapis.com/v0/b/codeless-app.appspot.com/o/projects%2FcbcmxVVQi7l7bydVexSq%2F6670446952dbe0fb7166f395a957b88c2ca51fa5Humaaans%20-%201%20Character%201.png?alt=media&token=7da7fa31-85a9-4c89-9b4e-f7798be96a11',
              width: 400,
              height: 277,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 30.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Welcome',
                style: GoogleFonts.lexend(
                  fontSize: 50,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFE1D5FF),
                ),
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              'Homeconnect is made for you. We make it easy now to find your perfect home within your comfort zone',
              textAlign: TextAlign.left,
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: Color(0xFF999999),
              ),
            ),
            SizedBox(height: 15.0),
            Container(
              width: 380,
              height: 330,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE1D5FF)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /*  SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            habitueColor = Color(0xFFE1D5FF);
                            ownerColor = Color(0xFF999999);
                            linePosition = 0.6;
                            lineHeight = 5;
                          });
                        },
                        child: Text(
                          'Habitue',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.lexend(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: habitueColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            ownerColor = Color(0xFFE1D5FF);
                            habitueColor = Color(0xFF999999);
                            linePosition = 1.6;
                            lineHeight = 5;
                          });
                        },
                        child: Text(
                          'Owner',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.lexend(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: ownerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: 100,
                    height: lineHeight,
                    decoration: BoxDecoration(
                      color: Color(0xFFE1D5FF),
                      borderRadius: BorderRadius.circular(10), // Rounded edges
                    ),
                    margin: EdgeInsets.only(
                      top:
                          0, // Negative margin for reducing the vertical distance
                      left: habitueColor == Color(0xFFE1D5FF)
                          ? 0
                          : (MediaQuery.of(context).size.width / 4) *
                              linePosition,
                      right: ownerColor == Color(0xFFE1D5FF)
                          ? 0
                          : (MediaQuery.of(context).size.width / 4) *
                              (1.9 - linePosition),
                    ),
                    curve: Curves.easeInOut,
                  ),*/
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            createAccountColor = Color(0xFFE1D5FF);
                            haveAccountColor = Color(0xFF999999);
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => login2()),
                          );
                        },
                        child: Text(
                          'Create a new account',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.lexend(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0C0C0C),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: createAccountColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 80, vertical: 20),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            haveAccountColor = Color(0xFFE1D5FF);
                            createAccountColor = Color(0xFF999999);
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => login3()),
                          );
                        },
                        child: Text(
                          'Already have an account',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.lexend(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0C0C0C),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: haveAccountColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 70, vertical: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
