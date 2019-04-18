import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyv3/home.dart';
import 'package:moneyv3/models/model_recieved.dart';
import 'package:moneyv3/models/model_user.dart';
import 'package:moneyv3/payment/form_payment.dart';
import 'package:moneyv3/recieved/form_recieved.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListRecieved extends StatefulWidget {
  @override
  _ListRecievedState createState() => _ListRecievedState();
}

class _ListRecievedState extends State<ListRecieved> {
  @override
  ModelRecieved model_recieved=ModelRecieved();
  ModelUser model_user = ModelUser();

  Future selectbycondition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      model_recieved.user_id = prefs.get('token');
    });

    Firestore.instance
        .collection('recieved')
        .orderBy("sort", descending: true)
        .limit(50)
        .snapshots()
        .listen((data) {
      data.documents.forEach((talk) async {
        DocumentSnapshot snapshot = await Firestore.instance
            .collection('user')
            .document(talk['user_id'].toString())
            .get();
        DocumentSnapshot recieved_type = await Firestore.instance
            .collection('tye_receive')
            .document(talk['tye_receive_id'].toString())
            .get();
        Map<String, dynamic> photo = {talk.documentID: snapshot['photo']};
        Map<String, dynamic> typename = {talk.documentID: recieved_type['name']};
        if (mounted) {
          setState(() {
            model_recieved.listuserphoto.addAll(photo);
            model_recieved.listtypename.addAll(typename);
          });
        }
      });
    });
  }

/*========================== delete =================*/
  void delpayment(id) {
    Firestore.instance.collection("recieved").document(id).delete();
    selectbycondition();
  }

/*====================Cormfirt delete ====================*/
  void delcomfirm(title, detail, id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          title: Center(child: title),
          content: Container(
            height: 30,
            child: Center(
              child: Text("${detail}"),
            ),
          ),
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.thumb_up),
              label: new Text("Yes"),
              onPressed: () {
                delpayment(id);
                Navigator.of(context).pop();
              },
            ),
            FlatButton.icon(
              icon: Icon(Icons.thumb_down),
              label: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    selectbycondition();
  }

  Widget build(BuildContext context) {
    print(model_recieved.listuserphoto);
    return Scaffold(
      appBar: AppBar(
        title: Text('ລາຍ​ການ​ລາຍ​ຮັບ​ທັງ​ໝົດ'),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            }),
      ),
      body: Container(
        padding: const EdgeInsets.all(5.0),
        alignment: Alignment.center,
        child: StreamBuilder(
            stream: Firestore.instance
                .collection('recieved')
                .orderBy("sort", descending: true)
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Text('ກຳ​ລັງ​ໂຫລດ..........'); 
              return ListView.builder(
                  //itemExtent: 50,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    final formatter = new NumberFormat("#,###.00");
                    var photo = (model_recieved.listuserphoto[
                                snapshot.data.documents[index].documentID] !=
                            null)
                        ? model_recieved.listuserphoto[
                            snapshot.data.documents[index].documentID]
                        : "";
                    var type = (model_recieved.listtypename[
                                snapshot.data.documents[index].documentID] !=
                            null)
                        ? model_recieved.listtypename[
                            snapshot.data.documents[index].documentID]
                        : "";
                    return ListTile(
                      leading: SizedBox(
                          width: 60.0,
                          height: 60.0,
                          child: CircleAvatar(
                            backgroundImage: NetworkImage('$photo'),
                          )),
                      title: Text(
                        type,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.black),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            formatter.format(int.parse(snapshot
                                    .data.documents[index]['amount']
                                    .toString())) +
                                ' ກີບ',
                            style: TextStyle(color: Colors.red),
                          ),
                          Text(
                            snapshot.data.documents[index]['description'],
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 2,
                          ),
                          Text(
                            snapshot.data.documents[index]['date'].toString(),
                          ),
                          (model_recieved.user_id ==
                                  snapshot.data.documents[index]['user_id'])
                              ? Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  fullscreenDialog: true,
                                                  builder: (context) =>
                                                      FormRecieved(snapshot
                                                          .data
                                                          .documents[index]
                                                          .documentID)));
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          delcomfirm(
                                              Icon(
                                                Icons.warning,
                                                color: Colors.red,
                                              ),
                                              'ລຶບ​ລາຍ​ການນີ້​ບໍ່.?',
                                              snapshot.data.documents[index]
                                                  .documentID);
                                           },
                                      ),
                                    ),
                                  ],
                                )
                              : Text(''),
                          Divider()
                        ],
                      ),
                      onTap: () {
                        //print(document.documentID);
                        //uploadPic();
                      },
                    );
                  });
            }),
      ),
      floatingActionButton: new FloatingActionButton(
          backgroundColor: Colors.red,
          child: new Icon(Icons.add_circle),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => FormRecieved(null)));
          }),
    );
  }
}
