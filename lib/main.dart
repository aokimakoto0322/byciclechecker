import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:overlay_support/overlay_support.dart';


List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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


            //撮影
            final image = await controller.takePicture();

            final imagepath = '$path/image.png';
            File imageFile = File(imagepath);

            //画像の保存
            await imageFile.writeAsBytes(await image.readAsBytes());

            
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
    return Center(
      child: FutureBuilder<dynamic>(
        future: loadimage(),
        builder: (context, snapshot){
          return snapshot.hasData ? Image.memory(snapshot.data.readAsBytesSync()) : Icon(icon);
        },
      )
    );
  }

  
  Future loadimage() async{
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final imagepath = '$path/image.png';
    return File(imagepath);
  }
}

