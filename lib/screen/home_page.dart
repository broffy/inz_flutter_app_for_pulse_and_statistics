import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_myapp/data/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_myapp/models/oneShot.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:flutter_myapp/screen/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback signOut;
  HomeScreen(this.signOut);
  bool isLoading;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  var value;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }
/*
  Future<List<Map<String, dynamic>>> getRecords() async {
    DatabaseHelper con = new DatabaseHelper();

    var db = await con.db;
    //var user = getPref().value;
    //var user_id = await db.rawQuery(" SELECT id FROM users WHERE screenName='$user'");
    List<Map<String, dynamic>> list = await db.query('SELECT * FROM oneShot ');
    return list;
  }
  */

  Future<List<oneShot>> readRecords() async {
    // Get a reference to the database.
    DatabaseHelper con = new DatabaseHelper();
    var db = await con.db;
    // Query the table for all The records.
    List<Map<String, dynamic>> maps =
    await db.rawQuery('''SELECT * FROM oneShot''');
    //return await db.rawQuery('''SELECT * FROM $table WHERE $columnDate BETWEEN '$twoDaysAgo' AND '$today''');
    // Convert the List<Map<String, dynamic> into a List<Dog>.
    //print(maps);
    return List.generate(maps.length, (i) {
      return oneShot(
          id: maps[i]['id'],
          username: maps[i]['username'],
          pulse: maps[i]['pulse'],
          spo2: maps[i]['spo2'],
          temp: maps[i]['temp'],
          pres: maps[i]['pres'],
          timestamp: maps[i]['timestamp']);
    });
  }




  /*
  @override
  List<oneShot> getAll() {
    List<oneShot> _listDane;
    Future<List<oneShot>> listFuture;
    listFuture = readRecords();
    listFuture.then((value) {
      if (value != null) value.forEach((item) => _listDane.add(item));
    });
    return _listDane == null ? [] : _listDane;
  }
  */

  // list for storing the last parsed Json data
/*
  Future loadSalesData() async {
    DatabaseHelper con = new DatabaseHelper();
    var db = await con.db;
    var dbData = await con.readMap(); // Deserialization Step #1
    //final jsonResponse = json.decode(jsonString); // // Deserialization Step #2

    setState(() {
      // Mapping the retrieved jsonresponse string and adding the chart sales data to the chart data list.
      for (Map i in dbData)
        chartData.add(
            oneShot(
                id: dbData[i]['id'],
                username: dbData[i]['username'],
                pulse: dbData[i]['pulse'],
                spo2: dbData[i]['spo2'],
                temp: dbData[i]['temp'],
                pres: dbData[i]['pres'],
                timestamp: dbData[i]['timestamp']) // Deserialization step #3
        );
    });
  }
*/
  String _ekran = "A";

  @override
  Widget build(BuildContext context) {
    DatabaseHelper dbHelper = new DatabaseHelper();
    // List<oneShot> wykresiki=getAll();
    // print(wykresiki);
    var _selectedItems=dbHelper.readRows();
    var chartData = dbHelper.read_last100_records();
    //chartData=dbHelper.readRows();
    List<oneShot> chartData2 = new List();

    doSomething() {
      setState(() {
        if (_ekran == "A") {
          _ekran = "B";
        } else {
          _ekran = "A";
        }
      });
    }


    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Ekran wizualizacji danych"),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                signOut();
              },
              icon: Icon(Icons.lock_open),
            )
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: ConditionalSwitch.list<String>(
            context: context,
            valueBuilder: (BuildContext context) => _ekran,
            caseBuilders: {
              'A': (BuildContext context) => <Widget>[
                Container(
                  width: 720,
                  height: 550,
                  child: FutureBuilder(
                    future: _selectedItems,
                    builder:
                        (BuildContext context, AsyncSnapshot snapshot) {
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: Text(snapshot.data[index].timestamp),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Puls '),
                                Text(snapshot.data[index].pulse.toString()),
                                Text(' Spo2 '),
                                Text(snapshot.data[index].spo2.toString()),
                                Text(' Temp '),
                                Text(snapshot.data[index].temp.toString()),
                                Text(' Ciśnienie '),
                                Text(snapshot.data[index].pres.toString())
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 720,
                  height: 79,
                  child: InkWell(
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                          ),
                          child: Align(
                              child: Text('Dane archiwalne, surowe dane'),
                              alignment: Alignment(0, 0))),
                      onTap: () {
                        doSomething();
                      }),
                ),
              ],
              'B': (BuildContext context) => <Widget>[
                Container(
                    width: 720,
                    height: 550,
                  child: FutureBuilder(
                    future: chartData,
                    builder:
                        (BuildContext context, AsyncSnapshot snapshot) {
                      return SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          // Chart title
                          title: ChartTitle(text: 'Wykresy danych pomiarowych'),
                          // Enable legend
                          legend: Legend(isVisible: true),
                          // Enable tooltip
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <ChartSeries<oneShot, String>>[
                            LineSeries<oneShot, String>(
                                dataSource: snapshot.data, // Deserialized Json data list retrieved from Firebase Database.
                                xValueMapper: (oneShot dane, _) => dane.timestamp,
                                yValueMapper: (oneShot dane, _) => dane.spo2,
                                legendItemText: "SpO2"
                                // Enable data label
                                //dataLabelSettings: DataLabelSettings(isVisible: true)
                            ),
                            LineSeries<oneShot, String>(
                              dataSource: snapshot.data, // Deserialized Json data list retrieved from Firebase Database.
                              xValueMapper: (oneShot dane, _) => dane.timestamp,
                              yValueMapper: (oneShot dane, _) => dane.pulse,
                                legendItemText: "Puls"
                              // Enable data label
                              //dataLabelSettings: DataLabelSettings(isVisible: true)
                            ),
                            LineSeries<oneShot, String>(
                              dataSource: snapshot.data, // Deserialized Json data list retrieved from Firebase Database.
                              xValueMapper: (oneShot dane, _) => dane.timestamp,
                              yValueMapper: (oneShot dane, _) => dane.temp,
                                legendItemText: "Temperatura"
                              // Enable data label
                              //dataLabelSettings: DataLabelSettings(isVisible: true)
                            ),
                            LineSeries<oneShot, String>(
                              dataSource: snapshot.data, // Deserialized Json data list retrieved from Firebase Database.
                              xValueMapper: (oneShot dane, _) => dane.timestamp,
                              yValueMapper: (oneShot dane, _) => dane.pres,
                                legendItemText: "Ciśnienie"

                              // Enable data label
                              //dataLabelSettings: DataLabelSettings(isVisible: true)
                            )
                          ]);
                    },
                  ),),
                SizedBox(
                  width: 720,
                  height: 79,
                  child: InkWell(
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                          ),
                          child: Align(
                              child: Text('Dane archiwalne na wykresie'),
                              alignment: Alignment(0, 0))),
                      onTap: () {
                        doSomething();
                      }),
                ),
              ],
            },
            fallbackBuilder: (BuildContext context) => <Widget>[
              Text('None of the cases matched!'),
            ],
          ),
        ));
  }
}


