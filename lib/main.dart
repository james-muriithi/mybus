import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Bus',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Booked Seats'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _url =
      'https://examinationcomplaint.theschemaqhigh.co.ke/HCI/api/book/?bus_id=1&show_booked_seats';
  Future<List> _seats;

  Future<List> _getSeats() async {
    var data = await get(_url);

    var jsonData = json.decode(data.body);

    List seats = [];
    jsonData = jsonData['data'];

    for (var seat in jsonData) {
      seats.add(seat);
    }

    return seats;
  }

  Future<void> _setPaid(String id) async {
    var myUrl =
        "https://examinationcomplaint.theschemaqhigh.co.ke/HCI/api/book/?set_paid&id=" +
            id;
    var response = await get(myUrl);
    var jsonData = json.decode(response.body);
    var message = jsonData['success'] ?? jsonData['error'];
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  Widget _myButton(bool a, [String id = '']) {
    return a
        ? ButtonTheme.bar(
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: const Text('ALREADY PAID'),
                  color: Colors.green,
                  textColor: Colors.white,
                  onPressed: () {
                    Fluttertoast.showToast(
                        msg: "Seat already paid for...",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM);
                  },
                ),
              ],
            ),
          )
        : ButtonTheme.bar(
            child: new ButtonBar(
              children: <Widget>[
                new FlatButton(
                  child: const Text('SET PAID'),
                  color: Colors.blue,
                  textColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  onPressed: () {
                    if (id != '') {
                      _setPaid(id);
                      setState(() {
                        _seats = this._getSeats();
                      });
                    }
                  },
                ),
              ],
            ),
          );
  }

  Widget _myWidget(String label, String value) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: 10.0, top: 9.0),
        child: RichText(
          text: new TextSpan(
            style: new TextStyle(
              fontSize: 12.5,
              color: Colors.black.withOpacity(0.7),
            ),
            children: <TextSpan>[
              new TextSpan(
                text: label + ' : ',
                style: new TextStyle(fontWeight: FontWeight.bold),
              ),
              new TextSpan(
                text: value,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _seats = _getSeats();
  }

  Future<List> _refresh() async {
    print("object");
  setState(() {
    _seats = _getSeats();
  });
  return _seats;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List>(
            future: this._seats,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              // print(snapshot.data);
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        InkWell(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white70,
                              child: CachedNetworkImage(
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                imageUrl:
                                    'https://media.istockphoto.com/vectors/side-seat-isolated-icon-on-white-background-auto-service-repair-car-vector-id1144131688?k=6&m=1144131688&s=612x612&w=0&h=NohT8qoBE7MT3HRISCIVWv5WttuxQIRXUg0dx4yFKeg=',
                              ),
                            ),
                            title: Text(
                              snapshot.data[index]['fullname'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                            subtitle: Column(
                              children: <Widget>[
                                new Divider(
                                  color: Theme.of(context).accentColor,
                                ),
                                Row(
                                  children: <Widget>[
                                    _myWidget("Seat No",
                                        snapshot.data[index]['seat_no']),
                                    _myWidget(
                                        "Paid",
                                        int.parse(snapshot.data[index]
                                                    ['paid']) ==
                                                0
                                            ? 'No'
                                            : 'Yes'),
                                  ],
                                ),
                                ExpansionTile(
                                  title: Text("More details..."),
                                  children: <Widget>[
                                    //row 2
                                    Row(
                                      children: <Widget>[
                                        _myWidget("Email",
                                            snapshot.data[index]['email']),
                                      ],
                                    ),

                                    //row3
                                    Row(
                                      children: <Widget>[
                                        _myWidget("Phone No",
                                            snapshot.data[index]['phone']),
                                      ],
                                    ),

                                    //row4
                                    Row(
                                      children: <Widget>[
                                        _myWidget("Id No",
                                            snapshot.data[index]['id_number']),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          onTap: () {},
                        ),
                        _myButton(int.parse(snapshot.data[index]['paid']) == 1,
                            snapshot.data[index]['id'])
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
