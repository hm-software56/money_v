import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyv3/home.dart';
import 'package:moneyv3/models/model_payment.dart';
import 'package:moneyv3/models/model_user.dart';
import 'package:moneyv3/payment/form_payment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPayment extends StatefulWidget {
  @override
  _ListPaymentState createState() => _ListPaymentState();
}

class _ListPaymentState extends State<ListPayment> {
  ModelPayment model_payment = ModelPayment();
  ModelUser model_user = ModelUser();

  Future selectbycondition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      model_payment.user_id = prefs.get('token');
    });

    Firestore.instance
        .collection('payment')
        .orderBy("date", descending: true)
        .snapshots()
        .listen((data) {
      data.documents.forEach((talk) async {
        DocumentSnapshot snapshot = await Firestore.instance
            .collection('user')
            .document(talk['user'].toString())
            .get();
        DocumentSnapshot payment_type = await Firestore.instance
            .collection('type_pay')
            .document(talk['type_pay_id'].toString())
            .get();
        Map<String, dynamic> photo = {talk.documentID: snapshot['photo']};
        Map<String, dynamic> typename = {talk.documentID: payment_type['name']};
        if (mounted) {
          setState(() {
            model_payment.listuserphoto.addAll(photo);
            model_payment.listtypename.addAll(typename);
          });
        }
      });
    });
  }


/*========================== delete =================*/
  void delpayment(id) {
    Firestore.instance.collection("payment").document(id).delete();
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
              onPressed:  () {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('ລາຍ​ການ​ລາຍ​ຈ່າຍ​ທັງ​ໝົດ'),
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
                .collection('payment')
                .orderBy("date", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Text('Laoding..........');
              return ListView.builder(
                  //itemExtent: 50,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    final formatter = new NumberFormat("#,###.00");
                    var photo = (model_payment.listuserphoto.isNotEmpty)
                        ? model_payment.listuserphoto[
                            snapshot.data.documents[index].documentID]
                        : "";
                    var type = (model_payment.listtypename.isNotEmpty)
                        ? model_payment.listtypename[
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
                          (model_payment.user_id ==
                                  snapshot.data.documents[index]['user'])
                              ? Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.red,
                                        ),
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
                                          // delpayment(snapshot.data.documents[index].documentID);
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
                    builder: (context) => FormPayment(null)));
           
          }),
    );
  }
}
