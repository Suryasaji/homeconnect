import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:p/admindashboard/accommodation.dart';
import 'package:p/admindashboard/bookings.dart';
import 'package:p/admindashboard/users.dart';

class AdminBottomNavigation extends StatefulWidget {
  const AdminBottomNavigation({Key? key}) : super(key: key);

  @override
  _AdminBottomNavigationState createState() => _AdminBottomNavigationState();
}

class _AdminBottomNavigationState extends State<AdminBottomNavigation> {
  int _currentIndex = 0;

  List<Widget> screens = [
    Bookingdetails(
      title: '',
    ),
    StationDetails(
      title: '',
    ),
    Userdetails(
      title: '',
    ),
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
                'assets/icon/map-pin-solid.svg',
                width: 20,
                height: 20,
                //       color: _currentIndex == 1 ? Colors.white : null,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Padding(
              padding: const EdgeInsets.all(3.0),
              child: SvgPicture.asset(
                'assets/icon/house-user-solid.svg',
                width: 21,
                height: 21,
                //  color: _currentIndex == 2 ? Colors.white : null,
              ),
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Padding(
              padding: const EdgeInsets.all(3.0),
              child: SvgPicture.asset(
                'assets/icon/users-solid.svg',
                width: 21,
                height: 21,
                //  color: _currentIndex == 2 ? Colors.white : null,
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
