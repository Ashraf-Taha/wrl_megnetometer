import 'dart:async';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter_magnetometer/flutter_magnetometer.dart';

void main() => runApp(MagnetometerExampleApp());

class MagnetometerExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: CompassPage(),
    );
  }
}

class CompassPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CompassPageState();
}
String x,y,z;
class _CompassPageState extends State<CompassPage> {
  MagnetometerData _magnetometerData = MagnetometerData(0.0, 0.0, 0.0);

  StreamSubscription _magnetometerListener;

  /// assign listener and start setting real data over [_magnetometerData]
  @override
  void initState() {
    super.initState();
    _magnetometerListener = FlutterMagnetometer.events
        .listen((MagnetometerData data) => setState(() => _magnetometerData = data));


    x=_magnetometerData.x.toString();
    y=_magnetometerData.y.toString();
    z=_magnetometerData.z.toString();




    formController.submitForm();
  }

  @override
  void dispose() {
    _magnetometerListener.cancel();
    super.dispose();
  }

  FormController formController = FormController((String response){
    print("Response: $response");

  });
  @override
  Widget build(BuildContext context) {
    x=_magnetometerData.x.toString();
    y=_magnetometerData.y.toString();
    z=_magnetometerData.z.toString();



    final double atan2 = math.atan2(_magnetometerData.y, _magnetometerData.x);

    bool ok=true;
    if(ok)
      formController.submitForm();
    ok=false;

    return Scaffold(
      appBar: AppBar(
        title: Text('WRL Magnetometer test'),
      ),
      body: ListView(
        semanticChildCount: 3,
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Transform.rotate(
                // calculate the direction we're heading in degrees, then convert to radian
                angle: math.pi / 2 - atan2,
                child: Image.asset('assets/compass.webp'),
              ),
            ),
          ),
          Text('Raw microtesla values: \n: ${_magnetometerData.toStringDeep()}'),
          //Text('atan2 result:\n $atan2'),
        ],
      ),
    );
  }
}



class FormController {
  // Callback function to give response of status of current request.
  final void Function(String) callback;

  // Google App Script Web URL

  static const String URL = "https://script.google.com/macros/s/AKfycbwgOdPisK0s8EMJ2gnajhr0NhnATTv18y3nPPn1-DiO_eSfA9FKIUsB2-439wkDQNo3WA/exec";

  static const STATUS_SUCCESS = "SUCCESS";

  FormController(this.callback);

  void submitForm() async{
    try{

      String _x=x;
      String _y=y;
      String _z=z;




      await http.get(Uri.parse(URL + "?x=$_x&y=$_y&z=$_z")).then(
              (response){
            callback(convert.jsonDecode(response.body)['status']);
          });
    } catch(e){
      print(e);
    }
  }
}