import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Lib
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

// Service
import 'package:bandnames/src/services/socket_service.dart';

// Models
import 'package:bandnames/src/models/band.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    // Band( id: '1', name: 'Metallica', votes: 5 ),
    // Band( id: '2', name: 'Guns & Roses', votes: 1 ),
    // Band( id: '3', name: 'Bon Jovi', votes: 2 ),
    // Band( id: '4', name: 'Linkin Park', votes: 3 )
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands );
    super.initState();
  }

  _handleActiveBands( dynamic payload ){
    this.bands = (payload as List)
      .map( (band) => Band.fromMap(band))
      .toList();

    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Band Names', style: TextStyle( color: Colors.black87)),
        elevation: 1,
        backgroundColor: Colors.white,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only( right: 10 ),
            child: ( socketService.serverStatus == ServerStatus.Online ) 
              ? Icon( Icons.check_circle, color: Colors.blue[300]) 
              : Icon( Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          _showPieChart(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandListTile(bands[i])
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon( Icons.add ),
        elevation: 1,
        onPressed: () => addNewBand()
      ),
   );
  }

  Widget _bandListTile( Band band ) {

    final socketService = Provider.of<SocketService>(context, listen: false );

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_){
        socketService.emit('delete-band', {
          'id': band.id
        });
      },
      background: Container(
        padding: EdgeInsets.only( left:8.0),
        alignment: Alignment.centerLeft,
        color: Colors.red,
        child: Text('Delete band', style: TextStyle(color: Colors.white),),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text( band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text( band.name ),
        trailing: Text('${ band.votes }', style: TextStyle( fontSize: 20)),
        onTap: (){
          socketService.emit('vote-band', {
            'id': band.id
          });
        },
      ),
    );
  }

  addNewBand(){

    final textController = new TextEditingController();
    if ( Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("New band name:"),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                child: Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList( textController.text)
              )
            ],
          );
        }, 
      );
    } else {
      showCupertinoDialog(
        context: context, 
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text('New band name:'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Add'),
                onPressed: () => addBandToList( textController.text),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Dismiss'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        }
      );
    }

  }

  void addBandToList( String name ){
    if ( name.length > 1){
      final socketService = Provider.of<SocketService>(context,listen:false);
      socketService.emit('new-band', {
        'name': name
      });
    }
    Navigator.pop(context);
  }

  Widget _showPieChart() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) { 
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.yellowAccent    
    ];

    return Container(
      padding: EdgeInsets.only(top:10),
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 0.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        ringStrokeWidth: 32,
        centerText: "HYBRID",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendShape: BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: ChartValuesOptions(
          decimalPlaces: 0,
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
        ),
      )
    );
  }

}