import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Models
import 'package:bandnames/src/models/band.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band( id: '1', name: 'Metallica', votes: 5 ),
    Band( id: '2', name: 'Guns & Roses', votes: 1 ),
    Band( id: '3', name: 'Bon Jovi', votes: 2 ),
    Band( id: '4', name: 'Linkin Park', votes: 3 )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Band Names', style: TextStyle( color: Colors.black87)),
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
          itemCount: bands.length,
          itemBuilder: (context, i) => _bandListTile(bands[i])
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon( Icons.add ),
        elevation: 1,
        onPressed: () => addNewBand()
      ),
   );
  }

  Widget _bandListTile( Band band ) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction){
        print('direction: $direction');
        // TODO: Llamar el borrado en el server
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
          print(band.name);
        },
      ),
    );
  }

  addNewBand(){

    final textController = new TextEditingController();
    if ( Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: ( context ) {
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
      this.bands.add( Band( id: DateTime.now().toString(), name: name, votes: 5 ));
      setState(() {});
    }
    Navigator.pop(context);
  }

}