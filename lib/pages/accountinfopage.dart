import 'package:flutter/material.dart';
import '../utility/router.dart' as route;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({Key? key}) : super(key: key);

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  String? email;

  final _userInfo = Hive.box('userData');

  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();
  late final _rePasswordController = TextEditingController();
  late final _reEmailController = TextEditingController();

  bool _editingPassword = false;

  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    email = FirebaseAuth.instance.currentUser?.email;
  }

  void _toggleEditing(String condition) {
    if (condition == 'Password') {
      setState(() {
        _editingPassword = !_editingPassword;
      });
    }
  }

  void reAuthenticate() async {
    AuthCredential credential = EmailAuthProvider.credential(
        email: _reEmailController.text, password: _rePasswordController.text);

    await FirebaseAuth.instance.currentUser!
        .reauthenticateWithCredential(credential);

    Navigator.of(context).pop();
  }

  void _savePassword(String i) async {
    _toggleEditing('Password');

    try {
      await FirebaseAuth.instance.currentUser!
          .updatePassword(_passwordController.text);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password updated successfully'),
        backgroundColor: Colors.green,
      ));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.add_alert),
            title: const Text('re-authenticate'),
            titleTextStyle: Theme.of(context).textTheme.displayLarge,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _reEmailController,
                  onSaved: (newValue) => _reEmailController.text = newValue!,
                  decoration: const InputDecoration(
                    hintText: ('Email'),
                  ),
                ),
                TextFormField(
                  controller: _rePasswordController,
                  onSaved: (newValue) => _rePasswordController.text = newValue!,
                  decoration: InputDecoration(
                    hintText: ('Old Password'),
                    suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                        ),
                        obscureText: _isObscure,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: reAuthenticate, child: const Text('Ok')),
            ],
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message!),
        backgroundColor: Colors.red,
      ));
    }

    _userInfo.put('Password', _passwordController.text);
  }

  void _saveName(String i) {
    _userInfo.put('Name', i);
  }

  void _saveAddress(String i) {
    _userInfo.put('Address', i);
  }

  void _saveMobile(String i) {
    _userInfo.put('Mobile', i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Info'),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey.shade800),
              child: const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/pfp_placeholder.jpg'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('Home'),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, route.homePage),
            ),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Settings'),
              onTap: () => Navigator.pushNamed(context, route.settingsPage),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/homepage_background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Row(
                  children: const [
                    Icon(Icons.account_circle_rounded),
                    Text('Name:'),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        onFieldSubmitted: (newValue) => _saveName(newValue),
                        decoration: InputDecoration(
                          hintText: _userInfo.get('Name'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  children: const [
                    Icon(Icons.add_ic_call_rounded),
                    Text('Mobile:'),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _mobileController,
                        onFieldSubmitted: (newValue) => _saveMobile(newValue),
                        decoration: InputDecoration(
                          hintText: _userInfo.get('Mobile'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  children: const [
                    Icon(Icons.attach_email_rounded),
                    Text('Email:'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$email',
                      ),
                    ),
                  ],
                ),
                const Divider(
                  height: 40,
                  thickness: 1,
                ),
                const SizedBox(height: 50),
                Row(
                  children: const [
                    Icon(Icons.add_home_rounded),
                    Text('Address:'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _addressController,
                        onFieldSubmitted: (newValue) => _saveAddress(newValue),
                        decoration: InputDecoration(
                          hintText: _userInfo.get('Address'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  children: const [
                    Icon(Icons.add_moderator_rounded),
                    Text('Password:'),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        onFieldSubmitted: (newValue) => _savePassword(newValue),
                        decoration: InputDecoration(
                          hintText: _userInfo.get('Password'),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                        ),
                        obscureText: _isObscure,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
