import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presensi/home-page.dart';
import 'package:http/http.dart' as myHttp;
import 'package:presensi/models/login-response.dart';
import 'package:presensi/register-page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late Future<String> _name, _token;
  final FocusNode _focusNodePassword = FocusNode();
  bool _obscurePassword = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
    checkToken(_token, _name);
  }

  checkToken(token, name) async {
    String tokenStr = await token;
    String nameStr = await name;
    if (tokenStr != "" && nameStr != "") {
      Future.delayed(Duration(seconds: 1), () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HomePage()))
            .then((value) {
          setState(() {});
        });
      });
    }
  }

  Future login(email, password) async {
    LoginResponseModel? loginResponseModel;
    Map<String, String> body = {"email": email, "password": password};
    var response = await myHttp
        .post(Uri.parse('http://127.0.0.1:8000/api/login'), body: body);
    if (response.statusCode == 401) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Email atau password salah")));
    } else {
      loginResponseModel =
          LoginResponseModel.fromJson(json.decode(response.body));
      print('HASIL ' + response.body);
      saveUser(loginResponseModel.data.token, loginResponseModel.data.name);
    }
  }

  Future saveUser(token, name) async {
    try {
      print("LEWAT SINI " + token + " | " + name);
      final SharedPreferences pref = await _prefs;
      pref.setString("name", name);
      pref.setString("token", token);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => HomePage()))
          .then((value) {
        setState(() {});
      });
    } catch (err) {
      print('ERROR :' + err.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  child: Center(
                child: SizedBox(
                  width: 320,
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(66, 162, 232, 1)),
                  ),
                ),
              )),
              SizedBox(height: 20),
              // Text("Email"),
              Center(
                child: SizedBox(
                  width: 320,
                  height: 50,
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(66, 162, 232, 1), width: 0.0),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Text("Password"),
              Center(
                child: SizedBox(
                  width: 320,
                  height: 50,
                  child: TextFormField(
                    controller: passwordController,
                    // obscureText: true,
                    obscureText: _obscurePassword,
                    focusNode: _focusNodePassword,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.password_outlined),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: _obscurePassword
                              ? const Icon(Icons.visibility_outlined)
                              : const Icon(Icons.visibility_off_outlined)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                            color: Color.fromRGBO(66, 162, 232, 1), width: 0.0),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(320, 40),
                    backgroundColor: Color(0xff42a2e8),
                  ),
                  onPressed: () {
                    login(emailController.text, passwordController.text);
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()));
                    },
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
