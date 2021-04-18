import 'package:byciclechecker/mapactivity.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

List<CameraDescription> cameras;

final InterstitialAd myInterstitial = InterstitialAd(
  adUnitId: 'ca-app-pub-3940256099942544/4411468910',
  request: AdRequest(),
  listener: AdListener(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _tab = <Tab> [
    Tab(icon: Icon(Icons.camera)),
    Tab(icon: Icon(Icons.photo))
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "demo",
        theme: ThemeData(
          primarySwatch: Colors.blue
        ),
        home: DefaultTabController(
          length: _tab.length,
            child: Scaffold(
            appBar: AppBar(
              flexibleSpace: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TabBar(
                    tabs: _tab,
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                CameraApp(),
                TabPage2(title: "Photo", icon: Icons.photo)
              ],
            )
          ),
        ),
    );
  }
}

class CameraApp extends StatefulWidget{
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;

  @override
  void initState() {
    super.initState();
    myInterstitial.load();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        child: CameraPreview(controller),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          try{
            final directory = await getApplicationDocumentsDirectory();
            final path = directory.path;

            //位置情報の取得
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best);

            //sharedpreferenceの用意
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setDouble("lat", position.latitude);
            prefs.setDouble("lng", position.longitude);

            //現在時刻の取得
            var format = DateFormat.Hm();
            var dateString = format.format(DateTime.now());

            //時刻をSharedPreferenceに保存
            prefs.setString("Date", dateString);

            //撮影
            final image = await controller.takePicture();

            final imagepath = '$path/image.png';
            File imageFile = File(imagepath);

            //画像の保存
            await imageFile.writeAsBytes(await image.readAsBytes());

            //ダイアログの表示
            Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              flushbarStyle: FlushbarStyle.FLOATING,
              reverseAnimationCurve: Curves.decelerate,
              forwardAnimationCurve: Curves.elasticOut,
              backgroundColor: Colors.red,
              boxShadows: [BoxShadow(color: Colors.blue[800], offset: Offset(0.0, 2.0), blurRadius: 3.0)],
              backgroundGradient: LinearGradient(colors: [Colors.blue, Colors.teal]),
              isDismissible: false,
              duration: Duration(seconds: 4),
              title: "画像を保存しました",
              showProgressIndicator: true,
              progressIndicatorBackgroundColor: Colors.blueGrey,
              titleText: Text(
                "画像を保存しました",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
              ),
              messageText: Text(
                "保存された画像は右タブに表示されます。",
                style: TextStyle(fontSize: 18.0, color: Colors.white70),
              ),


            )..show(context);
            

          }catch(e){

          }
        },
      ),
    );
  }
}

class TabPage2 extends StatelessWidget{
  final IconData icon;
  final String title;

  const TabPage2({Key key, this.icon, this.title}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
        constraints: BoxConstraints.expand(),
        child: FutureBuilder<dynamic>(
          future: loadimage(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              try{
                return FutureBuilder(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot2){
                    if(snapshot2.hasData){
                      //撮影時間の取得
                      var taketime = snapshot2.data.getString("Date");
                      //datetime型に変換
                      DateTime past = getdatetime(taketime);

                      //現在の時刻取得
                      var format = DateFormat.Hm();
                      var dateString = format.format(DateTime.now());
                      
                      //datetime型に変換
                      DateTime now = getdatetime(dateString);

                      //diff算出(時)
                      var diffhour = now.difference(past).inHours;

                      //diff算出(分)
                      var diffmin = now.difference(past).inMinutes;

                      var resultTime;

                      //表示時間の設定
                      if(diffhour == 0){
                        resultTime = diffmin.toString() + "分";
                      }else{
                        resultTime = diffhour.toString() + "時間" + diffmin.toString() + "分";
                      }

                      return Stack(
                        children: [
                          Container(
                            constraints: BoxConstraints.expand(),
                            child: Image.memory(snapshot.data.readAsBytesSync()),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            margin: EdgeInsets.all(20),
                            child: Text(
                              "${resultTime}",
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87
                              ),
                            ),
                          )
                        ],
                      );
                    }else{
                      return CircularProgressIndicator();
                    }
                    

                  },
                );
              }catch(e){
                return Center(
                  child: Container(
                    child: Icon(icon),
                  ),
                );
              }
            }else{
              return Center(
                child: Container(
                  child: Icon(icon),
                ),
              );
            }
          },
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: Icon(Icons.map_outlined),
        onPressed: (){
          myInterstitial.load();
          Navigator.push(context, MaterialPageRoute(builder: (context) => mapactivity()));
        },
      ),
    );
  }

  
  Future loadimage() async{
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final imagepath = '$path/image.png';
    return File(imagepath);
  }

  DateTime getdatetime(String date){
    final _dateFormatter = DateFormat("HH:mm");
    DateTime result;

    // String→DateTime変換
    try {
      result = _dateFormatter.parseStrict(date);
    } catch(e){
      // 変換に失敗した場合の処理
    }
    return result;
  }
}