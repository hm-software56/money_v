import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyv3/home.dart';
import 'package:moneyv3/models/model_payment.dart';

class ListPayment extends StatefulWidget {
  @override
  _ListPaymentState createState() => _ListPaymentState();
}

class _ListPaymentState extends State<ListPayment> {
  ModelPayment model_payment=ModelPayment();
  /*========================== Loading data ================= */
  Future loadlistpayment() async {
    CollectionReference collectionReference =
        await Firestore.instance.collection('bandnames').reference();
    collectionReference
        .snapshots()
        .listen((data) {
      print('on snapshot');
      data.documents.forEach((talk) {
        Map list_p={'id':talk.documentID,'type':talk['type']};
        model_payment.listpayment.addAll(list_p);
       // print(talk.documentID + ': ' + talk['name']);
      });
    });
    print(model_payment.listpayment);
  }
  
  @override
  void initState() {
    super.initState();
    loadlistpayment();
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
          child: RefreshIndicator(
            onRefresh: loadlistpayment,
            child: model_payment.isloading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: model_payment.listpayment != null ? model_payment.listpayment.length : 0,
                    itemBuilder: (BuildContext context, int index) {
                      final formatter = new NumberFormat("#,###.00");
                      // listpayment[index]['amount']
                      return new Column(
                        children: <Widget>[
                          new ListTile(
                            leading: SizedBox(
                                width: 60.0,
                                height: 60.0,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(''),
                                )),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                IntrinsicHeight(
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                model_payment.listpayment[index]['typePay']
                                                    ['name'],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.0,
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                formatter.format(int.parse(
                                                        model_payment.listpayment[index]
                                                            ['amount'])) +
                                                    ' ກີບ',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              Text(
                                                model_payment.listpayment[index]
                                                    ['description'],
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                maxLines: 2,
                                              ),
                                              Text(
                                                model_payment.listpayment[index]['date'],
                                              ),
                                            ],
                                          ),
                                        ),
                                        model_payment.user_id !=
                                                int.parse(model_payment.listpayment[index]
                                                    ['user_id'])
                                            ? Text('')
                                            : SizedBox(
                                                width: 30.0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.border_color,
                                                        color: Colors.green,
                                                      ),
                                                      onPressed: () {
                                                      /*  Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                fullscreenDialog:
                                                                    true,
                                                                builder: (context) =>
                                                                    FormPayment(
                                                                        listpayment[index]
                                                                            [
                                                                            'id'])));*/
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons
                                                            .remove_circle_outline,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () {
                                                      /*  delcomfirm(
                                                            'ແຈ້ງ​ເຕືອນ',
                                                            'ທ່ານ​ຕ້ອງ​ການ​ລຶບ​ລາຍ​ການນີ້​ແມ​່ນ​ບໍ.?',
                                                            listpayment[index]
                                                                ['id']);*/
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              )
                                      ]),
                                ),
                              ],
                            ),
                          ),
                          new Divider(
                            height: 2.0,
                          ),
                        ],
                      );
                    },
                  ),
          )),
      floatingActionButton: new FloatingActionButton(
          backgroundColor: Colors.red,
          child: new Icon(Icons.add_circle),
          onPressed: () {
            /*Navigator.push(
                context,
                MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => FormPayment(null)));
                    */
            /* Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => FormPayment()));*/
          }),
    );
  }
}
