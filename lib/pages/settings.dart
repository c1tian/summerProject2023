import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utility/router.dart' as route;
import '../utility/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _light = true;
  bool _biometrics = false;

  final _switchPosition = Hive.box('userData');

  @override
  void initState() {
    super.initState();
    setState(() {
      if (_switchPosition.containsKey('lightPosition')) {
        _light = _switchPosition.get('lightPosition');
      } else {
        _switchPosition.put('lightPosition', _light);
      }

      if (_switchPosition.containsKey('biometricsPosition')) {
        _biometrics = _switchPosition.get('biometricsPosition');
      } else {
        _switchPosition.put('biometricsPosition', _biometrics);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                const Icon(
                  Icons.nightlight_round,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Dark mode",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Switch(
                    value: _light,
                    onChanged: (bool value) {
                      currentTheme.toggleTheme();
                      _switchPosition.put('lightPosition', value);
                      setState(() {
                        _light = value;
                      });
                    }),
              ],
            ),
            const Divider(
              height: 20,
              thickness: 1,
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                const Icon(
                  Icons.fingerprint_rounded,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Enable biometric login",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Switch(
                    value: _biometrics,
                    onChanged: (bool value) async {
                      _switchPosition.put('biometricsPosition', value);
                      setState(() {
                        _biometrics = value;
                      });
                    }),
              ],
            ),
            const Divider(
              height: 20,
              thickness: 1,
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                const Icon(
                  Icons.delete,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Clear local data",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward,
                  ),
                  onPressed: () {
                    clearLocalData();
                  },
                ),
              ],
            ),

            const Divider(
              height: 20,
              thickness: 1,
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                const Icon(
                  Icons.logout,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Log out",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                  ),
                  onPressed: () {
                    logOut(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logOut(BuildContext context) async {
    const CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    navigateToLoginPage();
  }

  void navigateToLoginPage() {
    Navigator.pushNamedAndRemoveUntil(
        context, route.loginPage, (route) => false);
  }

  void clearLocalData() {

    _switchPosition.clear();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Data has been deleted successfully'),
        backgroundColor: Colors.green,
      ));
  }

}