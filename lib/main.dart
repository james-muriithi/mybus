import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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

  String _url = 'https://examinationcomplaint.theschemaqhigh.co.ke/HCI/api/book/?bus_id=1&show_booked_seats';

  Future <List> _getSeats() async{
    var data = await http.get(_url);

    var jsonData = json.decode(data.body);

    List seats = [];
    jsonData = jsonData['data'];

    for (var seat in jsonData) {
      seats.add(seat);
    }

    return seats;

  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: FutureBuilder(
          future: this._getSeats(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Center(
                  child: Text('loading....'),
                ),
              );
            }
            // print(snapshot.data);
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: InkWell(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            new NetworkImage('https://media.istockphoto.com/vectors/side-seat-isolated-icon-on-white-background-auto-service-repair-car-vector-id1144131688?k=6&m=1144131688&s=612x612&w=0&h=NohT8qoBE7MT3HRISCIVWv5WttuxQIRXUg0dx4yFKeg='),
                      ),
                      title: Text(snapshot.data[index]['fullname']),
                      subtitle: Text(snapshot.data[index]['seat_no']),
                    ),
                    onTap: () {
                      // Navigator.push(
                      //     context,
                      //     new MaterialPageRoute(
                      //         builder: (context) =>
                      //             DetailPage(snapshot.data[index])));
                    },
                  ),
                );
              },

            );
          },
        ),
      ),
     
    );
  }
}
