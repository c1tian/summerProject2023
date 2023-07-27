import 'package:flutter/material.dart';
import '../utility/router.dart' as route;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final bool _isObscure = true;
  int counterValue = 0;

  void _fetchCounterValue() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDocRef =
          FirebaseFirestore.instance.collection('Users').doc(user.uid);
      final userSnapshot = await userDocRef.get();
      if (userSnapshot.exists) {
        final userData = userSnapshot.data(); // Get the document data as a map
        if (userData != null && userData.containsKey('points')) {
          setState(() {
            counterValue = userData['points'];
          });
        } else {
          // If the 'points' field does not exist or is null, set the counterValue to 0
          setState(() {
            counterValue = 0;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    email = FirebaseAuth.instance.currentUser?.email;
    _fetchCounterValue();
    _nameController.text = _userInfo.get('Name') ?? '';
    _addressController.text = _userInfo.get('Address') ?? '';
    _mobileController.text = _userInfo.get('Mobile') ?? '';
  }

  @override
  void dispose() {
    // Save the field values to the Hive box when the user leaves the page
    _userInfo.put('Name', _nameController.text);
    _userInfo.put('Address', _addressController.text);
    _userInfo.put('Mobile', _mobileController.text);
    super.dispose();
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
      email: _reEmailController.text,
      password: _rePasswordController.text,
    );

    await FirebaseAuth.instance.currentUser!
        .reauthenticateWithCredential(credential);

    // Save the new password after successful re-authentication
    _savePassword(_passwordController.text);

    Navigator.of(context).pop();
  }

  Future<bool> _savePassword(String i) async {
    _toggleEditing('Password');

    try {
      await FirebaseAuth.instance.currentUser!.updatePassword(i);

      _userInfo.put('Password', i);
      return true; // Indicate success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.add_alert),
            title: const Text('re-authenticate'),
            titleTextStyle: Theme.of(context).textTheme.headline6,
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
                  decoration: const InputDecoration(
                    hintText: 'Old Password',
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle other exceptions if necessary
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    return false; // Indicate failure
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

  void _editPassword(String i) async {
    showDialog(
      context: context,
      builder: (context) {
        bool isObscure = true;
        TextEditingController rePasswordController = TextEditingController();
        TextEditingController passwordController = TextEditingController();

        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: rePasswordController,
                onSaved: (newValue) => rePasswordController.text = newValue!,
                decoration: const InputDecoration(
                  hintText: 'Old Password',
                ),
                obscureText: isObscure,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                onSaved: (newValue) => passwordController.text = newValue!,
                decoration: const InputDecoration(
                  hintText: 'Enter new password',
                ),
                obscureText: isObscure,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the AlertDialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                bool success = await _savePassword(passwordController.text);
                if (success) {
                  Navigator.of(context).pop(); // Close the AlertDialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Info'),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopify, size: 30),
              ),
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red, // Customize the background color
                  ),
                  child: Text(
                    counterValue.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Customize the text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
              leading: const Icon(Icons.directions_car_rounded),
              title: const Text('Car Washes'),
              onTap: () => Navigator.pushNamed(context, route.homePage),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                const Row(
                  children: [
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
                          hintText: _nameController.text.isEmpty
                              ? 'Add/edit your name'
                              : null, // Set hintText or text based on the condition
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                const Row(
                  children: [
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
                          hintText: _mobileController.text.isEmpty
                              ? 'Add/edit your mobile number'
                              : null, // Set hintText or text based on the condition
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                const Row(
                  children: [
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
                const Row(
                  children: [
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
                          hintText: _addressController.text.isEmpty
                              ? 'Add/edit your address'
                              : null, // Set hintText or text based on the condition
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min, // Minimize height
                      children: [
                        Icon(Icons.add_moderator_rounded),
                        Text('Password:'),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => _editPassword(_passwordController.text),
                      child: const Text('Change Password'),
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
