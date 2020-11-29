import 'dart:async';
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:oscilloscope/oscilloscope.dart';




class SensorPage extends StatefulWidget {

  const SensorPage({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _SensorPageState createState() => _SensorPageState();

}

class _SensorPageState extends State<SensorPage> {

  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  bool isReady;
  Stream<List<int>>  stream;
  List<double> traceOxy = List();
  List<double> traceBpm = List();
  List<double> traceTemp = List();
  List<double> tracePressure = List();
  List<double> traceIrVal = List();
  List<double> traceSpo2 = List();

  @override
  initState(){
    super.initState();
    isReady=false;
    connectToDevice();
  }

  connectToDevice() async {
    if(widget.device ==null){
      _Pop();
      return;
    }
    new Timer(const Duration(seconds: 15),(){
      if(!isReady){
        disconnectFromDevice();
        _Pop();
      }
    });
    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice(){
    if(widget.device ==null){
      _Pop();
      return;
    }
    widget.device.disconnect();
  }

  discoverServices() async {
    if(widget.device ==null){
      _Pop();
      return;
    }
    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      if(service.uuid.toString()==SERVICE_UUID){
        service.characteristics.forEach((characteristic) {
          if(characteristic.uuid.toString()==CHARACTERISTIC_UUID){
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;

            setState(() {
              isReady = true;
            });
          }
        });
      }
    });

    if(!isReady){
      _Pop();
    }
  }

  Future<bool> _onWillPop() {
    return showDialog(
        context: context,
        builder: (context) =>
        new AlertDialog(
          title: Text('Jestes pewien?'),
          content: Text('Chesz sie rozlaczycz i wrocic?'),
          actions: <Widget>[
            new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Nie')),
            new FlatButton(
                onPressed: () {
                  disconnectFromDevice();
                  Navigator.of(context).pop(true);
                  },
                  child: new Text ('Tak')),
          ],
        ) ??
        false);
  }

  _Pop(){
    Navigator.of(context).pop(true);
  }

 

  String _dataParser(List<int> dataFromDevice){

    return utf8.decode(dataFromDevice);
  }
/*
  _dataParser(String data) {
    if (data.isNotEmpty) {
      var oxyValue = data.split(",")[0];
      var bpmValue = data.split(",")[1];

      print("tempValue: ${oxyValue}");
      print("humidityValue: ${bpmValue}");

      setState(() {
        traceOxy = (oxyValue) as List<double>;
        traceBpm = (bpmValue) as List<double>;
      });
    }
    */



  @override
  Widget build(BuildContext context) {

    Oscilloscope oscilloscope_oxy = Oscilloscope(
      showYAxis: true,
      padding: 0.0,
      backgroundColor: Colors.black,
      traceColor: Colors.lightBlueAccent,
      yAxisMax: 100.0,
      yAxisMin: 0.0,
      dataSet: traceOxy,

    );

    Oscilloscope oscilloscope_bpm = Oscilloscope(
      showYAxis: true,
      padding: 0.0,
      backgroundColor: Colors.black,
      traceColor: Colors.redAccent,
      yAxisMax: 100.0,
      yAxisMin: 0.0,
      dataSet: traceBpm,

    );

    DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.directions_car)),
              Tab(icon: Icon(Icons.directions_transit)),
              Tab(icon: Icon(Icons.directions_bike)),
            ],
          ),
        ),
      ),
    );

    return WillPopScope(
      onWillPop: _onWillPop ,
      child: Scaffold(
      appBar: AppBar(
        title: Text('SPO2 and BPM sensor'),
      ),
      body: Container(
        child: !isReady
        ? Center(
          child: Text(
            "Waiting...",
            style: TextStyle(fontSize: 24, color: Colors.red),
          ),
        )
            : Container(
          child: StreamBuilder<List<int>>(
            stream: stream,
            builder: (BuildContext context,
                AsyncSnapshot<List<int>> snapshot) {
              if(snapshot.hasError)
                return Text('Error: ${snapshot.error}');

              if(snapshot.connectionState==
                  ConnectionState.active){
                var currentValue = _dataParser(snapshot.data);
                var oxyAvg = currentValue.split(",")[0];
                var bpmAvg = currentValue.split(",")[1];
                var tempAvg = currentValue.split(",")[2];
                var pressureAvg = currentValue.split(",")[3];
                //var irVal = currentValue.split(",")[4];
                var Spo2 = currentValue.split(",")[4];
                traceOxy.add(double.tryParse(oxyAvg) ?? 0);
                traceBpm.add(double.tryParse(bpmAvg) ?? 0);
                traceTemp.add(double.tryParse(tempAvg) ?? 0);
                tracePressure.add(double.tryParse(pressureAvg) ?? 0);
               // traceIrVal.add(double.tryParse(irVal) ?? 0);
                traceSpo2.add(double.tryParse(Spo2) ?? 0);

                return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Temp                           Pressure',
                                    style: TextStyle(fontSize: 14)),
                                Text('  ${tempAvg} °C              ${pressureAvg} hPa',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24))


                              ]),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Spo2',
                                    style: TextStyle(fontSize: 14)),
                                //chrysre dopomóż mnie bo zgrzeszyłem
                                Text('${Spo2}',
                                    style: TextStyle(color: Colors.white,fontSize: 14)),
                                //chrysre dopomóż mnie bo zgrzeszyłem
                                Text('  ${oxyAvg} %',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24))

                              ]),
                        ),

                        Expanded(
                          flex: 3,
                          child: oscilloscope_oxy,

                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('BPM',
                                    style: TextStyle(fontSize: 14)),
                                Text('${bpmAvg}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24))
                              ]),
                        ),
                        Expanded(
                          flex: 3,
                          child: oscilloscope_bpm,
                        )
                      ],
                    ));
              } else {
                return Text('Check the stream');
                }
              },
            ),
          )),
        ),
      );
  }
}












