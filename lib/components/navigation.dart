import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:p/ownernav/add1.dart';
import 'package:p/ownernav/chat.dart';
import 'package:p/ownernav/home1.dart';
import 'package:p/ownernav/person.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  List<Widget> screens = [
    home1(),
    add1(),
    // chat(),
    person(),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => screens[index]));
        },
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 72, 11, 73),
        items: [
          BottomNavigationBarItem(
            label: '',
            icon: Padding(
              padding: const EdgeInsets.all(3.0),
              child: SvgPicture.asset(
                'assets/icon/house-solid.svg',
                width: 20,
                height: 20,
                //   color: _currentIndex == 0 ? Colors.white : null,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Padding(
              padding: const EdgeInsets.all(3.0),
              child: SvgPicture.asset(
                'assets/icon/plus-solid.svg',
                width: 20,
                height: 20,
                //       color: _currentIndex == 1 ? Colors.white : null,
              ),
            ),
          ),
          /*   BottomNavigationBarItem(
            label: '',
            icon: Padding(
              padding: const EdgeInsets.all(3.0),
              child: SvgPicture.asset(
                'assets/icon/comment-solid.svg',
                width: 21,
                height: 21,
                //   color: _currentIndex == 2 ? Colors.white : null,
              ),
            ),
          ),*/
          BottomNavigationBarItem(
            label: '',
            icon: Padding(
              padding: const EdgeInsets.all(3.0),
              child: SvgPicture.asset(
                'assets/icon/user-solid.svg',
                width: 20,
                height: 20,
                // color: _currentIndex == 4 ? Colors.white : null,
              ),
            ),
          ),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
