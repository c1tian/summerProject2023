library config.globals;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';


class MyTheme with ChangeNotifier{
  bool _isDark = true;
  final _storeTheme = Hive.box('userData');
  
  
  MyTheme(){
    if(_storeTheme.containsKey('currentTheme')){
      _isDark = _storeTheme.get('currentTheme');
    }
    else{
      _storeTheme.put('currentTheme', _isDark);
    }
  }
  
  ThemeMode currentTheme(){
    return _isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme(){
    _isDark = !_isDark;
    _storeTheme.put('currentTheme', _isDark);
    notifyListeners();
  }
} 

MyTheme currentTheme = MyTheme();