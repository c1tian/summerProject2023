import 'package:flutter/material.dart';
import '../pages/homepage.dart';
import '../pages/loginpage.dart';
import '../pages/settings.dart';
import '../pages/registerpage.dart';
import '../pages/accountinfopage.dart';


const String homePage = '/';
const String loginPage = '/login';
const String settingsPage = '/settings';
const String profilePage = '/profile';
const String registerpage = '/register';


Route<dynamic> controller(RouteSettings destination) {
  switch (destination.name) {
    case homePage:
      return MaterialPageRoute(builder: (context) => const HomePage());
    case loginPage:
      return MaterialPageRoute(builder: (context) => const LoginPage());
    case settingsPage:
      return MaterialPageRoute(builder: (context) => const SettingsPage());
    case profilePage:
      return MaterialPageRoute(builder: (context) => const AccountInfoPage());
    case registerpage:
      return MaterialPageRoute(builder: (context) => const RegisterPage());


    default:
      throw ('This route does not exist');
  }
}