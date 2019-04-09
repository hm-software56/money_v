import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moneyv3/login.dart';

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
      home:Login(),
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
  @override
  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Expanded(
            child: Text(document['name']),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.red),
            padding: EdgeInsets.all(10),
            child: Text(
              document['votes'].toString(),
            ),
          )
        ],
      ),
      onTap: () {
        //print(document.documentID);
        uploadPic();
      },
    );
  }

  FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Uri> uploadPic() async {
    //Get the file from the image picker and store it
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    var rng = new Random();
  var l = rng.nextInt(100);
    //Create a reference to the location you want to upload to in firebase
    StorageReference reference = _storage.ref().child("images/$l");

    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putFile(image);
 var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var url = dowurl.toString();
    print(url);
  }

  Future select(doc_id) async {
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('bandnames').document(doc_id).get();
    print(snapshot['name']);
  }

  Future selectbycondition() async {
    CollectionReference collectionReference =
        await Firestore.instance.collection('bandnames').reference();
    collectionReference
        .where("name", isEqualTo: 'nt')
        .snapshots()
        .listen((data) {
      print('on snapshot');
      data.documents.forEach((talk) {
        print(talk.documentID + ': ' + talk['name']);
      });
    });
  }

  void update(doc_id) {
    Firestore.instance
        .collection("bandnames")
        .document(doc_id)
        .updateData({'name': "daxiong"});
  }

  void add() {
    Firestore.instance.collection("bandnames").add({
      'name': "ssssss",
      'votes': 1,
    });
  }

  void del(var doc_id) {
    Firestore.instance.collection("bandnames").document(doc_id).delete();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test"),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('bandnames').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text('Laoding..........');
            return ListView.builder(
              itemExtent: 50,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data.documents[index]),
            );
          }),
    );
  }
}
