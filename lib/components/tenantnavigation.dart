import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:p/tenantnav/bookdetails.dart';
import 'package:p/tenantnav/habhome.dart';
import 'package:p/tenantnav/habprofile.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _currentIndex = 0;

  List<Widget> screens = [
    habhome(),
    BookingDetailsPage(),
    // habchat(ownerName: "ownerName", ownerId: "ownerId"),
    habprofile(),
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
                'assets/icon/circle-info-solid.svg',
                width: 21,
                height: 21,
                //   color: _currentIndex == 2 ? Colors.white : null,
              ),
            ),
          ),
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
