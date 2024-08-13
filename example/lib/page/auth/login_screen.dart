import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:livetalk_sdk/livetalk.dart';
import 'package:livetalk_sdk_example/page/messages/message_screen.dart';

import '../../chat_screen.dart';
import '../../dialog/dialog.dart';
import '../../main.dart';
import '../chats/chats_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _userNameController = TextEditingController()
    ..text = "N 0909689867";
  late final TextEditingController _phoneController = TextEditingController()
    ..text = uuid;
  late final TextEditingController _emailController = TextEditingController()
    ..text = '';

  bool _isAutoExpired = false;

  @override
  void initState() {
    super.initState();
    requestFCM();
  }

  Future<void> requestFCM() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint(token);
    FirebaseMessaging.onMessage.listen((event) {
      //have message on foreground => by pass notification
      debugPrint(event.data.toString());
    });
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool isEmailCorrect = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.deepPurpleAccent,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/chat_bubble.png",
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    'Log In Now',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    'Please login to continue using our app',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w300,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 400,
                    width: MediaQuery.of(context).size.width / 1.1,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: TextFormField(
                              controller: _userNameController,
                              onChanged: (val) {},
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.deepPurpleAccent,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Username",
                                hintText: 'Enter username',
                                labelStyle: const TextStyle(
                                    color: Colors.deepPurpleAccent),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 21,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onPressed: () {
                                    _userNameController.clear();
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Colors.deepPurpleAccent,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Phone number",
                                hintText: 'Enter phone',
                                labelStyle: const TextStyle(
                                  color: Colors.deepPurpleAccent,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 21,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onPressed: () {
                                    _phoneController.clear();
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: Colors.deepPurpleAccent,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                labelText: "Email",
                                hintText: 'Enter email',
                                labelStyle: const TextStyle(
                                  color: Colors.deepPurpleAccent,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 21,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  onPressed: () {
                                    _phoneController.clear();
                                  },
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                              top: 16,
                              right: 24,
                              bottom: 10,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isAutoExpired = !_isAutoExpired;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    _isAutoExpired
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    size: 22,
                                    color: _isAutoExpired
                                        ? Colors.pinkAccent
                                        : Colors.white,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Auto Expired",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _isAutoExpired
                                          ? Colors.pinkAccent
                                          : Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: double.infinity,
                            height: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                backgroundColor: Colors.pinkAccent,
                              ),
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                if (_phoneController.text.isEmpty ||
                                    _userNameController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Invalid Data',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  EasyLoading.show();
                                  final fcm = await FirebaseMessaging.instance
                                      .getToken();
                                  final result = await LiveTalkSdk.shareInstance
                                      .createRoom(
                                    phone: _phoneController.text,
                                    fullName: _userNameController.text,
                                    uuid: _phoneController.text,
                                    autoExpired: _isAutoExpired,
                                    fcm: fcm,
                                  );
                                  EasyLoading.dismiss();
                                  if (result != null && mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MessagesScreen(),
                                        //ChatScreen(),
                                      ),
                                    );
                                  }
                                } catch (error) {
                                  EasyLoading.dismiss();
                                  if (error is LiveTalkError) {
                                    showCustomDialog(
                                      context: context,
                                      message:
                                          error.message["message"] as String,
                                    );
                                  }
                                }
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const ChatsScreen(),
                                //   ),
                                // );
                              },
                              child: const Text(
                                'Log In',
                                style: TextStyle(fontSize: 17),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'You have\'t any account?',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
