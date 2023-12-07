import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presensi/cuti-page.dart';
import 'package:presensi/history-page.dart';
import 'package:presensi/models/home-response.dart';
import 'package:presensi/setting-page.dart';
import 'package:presensi/simpan-page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name, _token;
  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];
  var absen = "00:00";

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
    // print(hariIni?.masuk);
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
        print(hariIni?.pulang);
      } else {
        riwayat.add(element);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Home"),
      // ),
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
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      // height: 400,
                      child: Center(
                        child: Container(
                          width: 400,
                          // height: 500,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(66, 162, 232, 1),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(66, 162, 232, 1),
                                  spreadRadius: 5),
                            ],
                            // border: OutlineInputBorder(
                            //   borderRadius: BorderRadius.circular(5),
                            // ),
                            // enabledBorder: OutlineInputBorder(
                            //   borderRadius: BorderRadius.circular(5),
                            //   borderSide: const BorderSide(
                            //       color: Color.fromRGBO(66, 162, 232, 1),
                            //       width: 0.0),
                            // ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(children: [
                              Text(hariIni?.tanggal ?? '-',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              SizedBox(
                                height: 30,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(hariIni?.masuk ?? '-',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24)),
                                      Text("Masuk",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16))
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(hariIni?.pulang ?? '-',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24)),
                                      Text("Pulang",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16))
                                    ],
                                  )
                                ],
                              )
                            ]),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Container(
                        child: Column(
                          children: [
                            // Container(child: Image.asset('profil.jpg')),
                            SizedBox(height: 20),
                            Container(
                              child: hariIni?.pulang == null ||
                                      hariIni?.pulang == absen
                                  ? ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    SimpanPage()))
                                            .then((value) {
                                          setState(() {});
                                        });
                                      },
                                      child: hariIni?.pulang == absen
                                          ? Text("Check Out")
                                          : Text("Check In"))
                                  : ElevatedButton(
                                      onPressed: null,
                                      child: Text("Check Out")),
                            ),
                            SizedBox(height: 20),
                            Container(
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => CutiPage()))
                                          .then((value) {
                                        setState(() {});
                                      });
                                    },
                                    child: Text("Ajukan Cuti"))),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Text("Riwayat Presensi"),
                    Expanded(
                      child: Column(),
                    ),
                    Row(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => HistoryPage()))
                                .then((value) {
                              setState(() {});
                            });
                          },
                          icon: Icon(Icons.book),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => HomePage()))
                                .then((value) {
                              setState(() {});
                            });
                          },
                          icon: Icon(Icons.home),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => SettingPage()))
                                .then((value) {
                              setState(() {});
                            });
                          },
                          icon: Icon(Icons.settings),
                        ),
                      ],
                    )
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
