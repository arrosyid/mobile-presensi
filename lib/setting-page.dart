import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presensi/home-page.dart';
import 'package:presensi/login-page.dart';
import 'package:presensi/models/home-response.dart';
import 'package:presensi/simpan-page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name, _token;
  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];

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
  }

  // static const String TOKEN_KEY = 'user_token';

  // // Fungsi untuk menyimpan token ke shared preferences
  // static Future<void> saveToken(String token) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(TOKEN_KEY, token);
  // }

  // static Future<String?> getToken() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(TOKEN_KEY);
  // }

  // // Fungsi untuk menghapus token dari shared preferences
  // static Future<void> removeToken() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove(TOKEN_KEY);
  // }

  // static Future<void> logout() async {
  //   try {
  //     // Dapatkan token dari shared preferences
  //     final String? token = await getToken();

  //     if (token != null) {
  //       // Hapus token dari shared preferences
  //       await removeToken();

  //       // Tambahkan logika lain yang diperlukan untuk logout di sisi klien

  //       print('Logout berhasil');
  //     } else {
  //       print('Token tidak ditemukan');
  //     }
  //   } catch (e) {
  //     print('Error during logout: $e');
  //   }
  // }
  void _showSuccessSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove("token");
      preferences.remove("name");
    });
    print("berhasil logout");
    _showSuccessSnackBar(context, 'Logout berhasil');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  Future getData() async {
    final Map<String, String> headres = {
      'Authorization': 'Bearer ' + await _token
    };
    var response = await myHttp.get(
        Uri.parse('http://127.0.0.1:8000/api/get-presensi'),
        headers: headres);
    homeResponseModel = HomeResponseModel.fromJson(json.decode(response.body));
    riwayat.clear();
    homeResponseModel!.data.forEach((element) {
      if (element.isHariIni) {
        hariIni = element;
      } else {
        riwayat.add(element);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return SafeArea(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder(
                        future: _name,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else {
                            if (snapshot.hasData) {
                              print(snapshot.data);
                              return Text(snapshot.data!,
                                  style: TextStyle(fontSize: 18));
                            } else {
                              return Text("-", style: TextStyle(fontSize: 18));
                            }
                          }
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      // height: 400,
                      child: Column(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Container(child: Image.asset('profil.jpg')),
                                SizedBox(height: 20),
                                Container(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    SimpanPage()))
                                            .then((value) {
                                          setState(() {});
                                        });
                                      },
                                      child: Text("Change Profile")),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                        child: Column(
                      children: [
                        Card(
                            child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(child: Text("My Profile")),
                              Container(
                                padding: EdgeInsets.only(left: 40, right: 40),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [Text("Pegawai")],
                                    ),
                                    Row(
                                      children: [Text("Pegawai")],
                                    ),
                                    Row(
                                      children: [Text("Pegawai@gmail.com")],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )),
                      ],
                    )),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: null, child: Text("Change Password")),
                    ElevatedButton(
                        onPressed: null, child: Text("Change Email")),
                    ElevatedButton(
                        onPressed: () async {
                          logOut();
                        },
                        child: Text("Logout"))
                    // Text("Riwayat Presensi"),
                    // Expanded(
                    //   child: ListView.builder(
                    //     itemCount: riwayat.length,
                    //     itemBuilder: (context, index) => Card(
                    //       child: ListTile(
                    //         leading: Text(riwayat[index].tanggal),
                    //         title: Row(children: [
                    //           Column(
                    //             children: [
                    //               Text(riwayat[index].masuk,
                    //                   style: TextStyle(fontSize: 18)),
                    //               Text("Masuk", style: TextStyle(fontSize: 14))
                    //             ],
                    //           ),
                    //           SizedBox(width: 20),
                    //           Column(
                    //             children: [
                    //               Text(riwayat[index].pulang,
                    //                   style: TextStyle(fontSize: 18)),
                    //               Text("Pulang", style: TextStyle(fontSize: 14))
                    //             ],
                    //           ),
                    //         ]),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Row(
                    //   // crossAxisAlignment: CrossAxisAlignment.center,
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [
                    //     IconButton(
                    //       onPressed: () {
                    //         Navigator.of(context)
                    //             .push(MaterialPageRoute(
                    //                 builder: (context) => SimpanPage()))
                    //             .then((value) {
                    //           setState(() {});
                    //         });
                    //       },
                    //       icon: Icon(Icons.book),
                    //     ),
                    //     IconButton(
                    //       onPressed: () {
                    //         Navigator.of(context)
                    //             .push(MaterialPageRoute(
                    //                 builder: (context) => HomePage()))
                    //             .then((value) {
                    //           setState(() {});
                    //         });
                    //       },
                    //       icon: Icon(Icons.home),
                    //     ),
                    //     IconButton(
                    //       onPressed: () {
                    //         Navigator.of(context)
                    //             .push(MaterialPageRoute(
                    //                 builder: (context) => SimpanPage()))
                    //             .then((value) {
                    //           setState(() {});
                    //         });
                    //       },
                    //       icon: Icon(Icons.settings),
                    //     ),
                    //   ],
                    // )
                  ],
                ),
              ));
            }
          }),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context)
      //         .push(MaterialPageRoute(builder: (context) => SimpanPage()))
      //         .then((value) {
      //       setState(() {});
      //     });
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
