import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyv3/models/model_payment.dart';
import 'package:moneyv3/models/model_recieved.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_format/date_format.dart';

class FormRecieved extends StatefulWidget {
  var id;
  FormRecieved(this.id);
  @override
  _FormRecievedState createState() => _FormRecievedState(this.id);
}

class _FormRecievedState extends State<FormRecieved> {
  var id;
  _FormRecievedState(this.id);
  final _formKey = GlobalKey<FormState>();
  ModelRecieved modelRecieved = ModelRecieved();

  /*===================== Select date picker =================*/
  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(2018),
        lastDate: new DateTime(9999));

    if (result == null) return;

    setState(() {
      modelRecieved.date.text = new DateFormat('yyyy-MM-dd').format(result);
    });
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat('yyyy-MM-dd').parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  /*================== load data type payment =================*/
  List<String> listtypename = [''];
  Map<String, dynamic> listtype = {};
  Future listtypepay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      modelRecieved.user_id = prefs.get('token');
    });
    Firestore.instance.collection('tye_receive').where('status',isEqualTo:true).snapshots().listen((data) {
      data.documents.forEach((talk) {
        if (mounted) {
          setState(() {
            listtypename.add(talk['name'].toString());
            listtype.addAll({talk['name']: talk.documentID});
          });
        }
      });
    });
  }

/*================  create payment ===============*/
  void createpayment() {
    var amount = modelRecieved.amount.text
        .substring(0, modelRecieved.amount.text.length - 3);
    var y = modelRecieved.date.text.substring(0,modelRecieved.date.text.length - 6);
    var m = modelRecieved.date.text.substring(5,modelRecieved.date.text.length - 3);
    var d = modelRecieved.date.text.substring(8,modelRecieved.date.text.length - 0);
       
    var date=d+'-'+m+'-'+y;
    int sort=int.parse(y+''+m+''+d);
    Firestore.instance.collection("recieved").add({
      'amount': int.parse(amount.replaceAll(',', '')),
      'date':date,
      'description': modelRecieved.description.text,
      'tye_receive_id': modelRecieved.type_id,
      'user_id': modelRecieved.user_id,
      'sort':sort,
    });
    Navigator.of(context).pop();
  }

  /*===================== update payment =================*/
  void updatepayment() {
    var amount = modelRecieved.amount.text
        .substring(0, modelRecieved.amount.text.length - 3);
    var y = modelRecieved.date.text.substring(0,modelRecieved.date.text.length - 6);
    var m = modelRecieved.date.text.substring(5,modelRecieved.date.text.length - 3);
    var d = modelRecieved.date.text.substring(8,modelRecieved.date.text.length - 0);
    var date=d+'-'+m+'-'+y;
    int sort=int.parse(y+''+m+''+d);
    Firestore.instance.collection("recieved").document(this.id).updateData({
      'amount': int.parse(amount.replaceAll(',', '')),
      'date': date,
      'description': modelRecieved.description.text,
      'tye_receive_id': modelRecieved.type_id,
      'user_id': modelRecieved.user_id,
      'sort':sort,
    });
    Navigator.of(context).pop();
  }

  /*===================== load data update ==================*/
  void loaddataupdate() async {
    if (this.id != null) {
      DocumentSnapshot recieved = await Firestore.instance
          .collection('recieved')
          .document(this.id)
          .get();
      DocumentSnapshot recieved_type = await Firestore.instance
          .collection('tye_receive')
          .document(recieved['tye_receive_id'].toString())
          .get();
      setState(() {
        modelRecieved.amount.text = recieved['amount'].toString() + '00';
        modelRecieved.date.text =
            recieved['date'].toString().replaceAll('-', '/');
        modelRecieved.description.text = recieved['description'].toString();
        modelRecieved.tye_receive_id.text = recieved_type['name'];
        modelRecieved.type_id = recieved['tye_receive_id'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    listtypepay();
    loaddataupdate();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('​ປ້ອນ​ລາຍ​ຮັບ'),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              InputDecorator(
                decoration: InputDecoration(
                  errorText: (modelRecieved.tye_receive_id.text.isEmpty)
                      ? "ທ່ານ​ຕ້ອງເລືອກ​ປະ​ເພດ​ລາຍ​ຮັບ"
                      : null,
                  labelText: 'ເລືອກ​ປະ​ເພດ​ລາຍ​ຮັບ',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
                isEmpty: modelRecieved.tye_receive_id == null,
                child: new DropdownButtonHideUnderline(
                  child: new DropdownButton<String>(
                    value: modelRecieved.tye_receive_id.text,
                    isDense: true,
                    onChanged: (String newValue) {
                      setState(() {
                        modelRecieved.tye_receive_id.text = newValue;
                        modelRecieved.type_id = listtype[newValue];
                      });
                    },
                    items: listtypename.map((value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: modelRecieved.amount,
                validator: (value) {
                  if (value.isEmpty || value == '0.00') {
                    return "ທ່ານ​ຕ້ອງ​ປ້​ອນ​ຈຳ​ນວນ​ເງີນ";
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ຈຳນວນ​ເງີນຮັບ',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: modelRecieved.description,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'ອະ​ທີ​ບາຍ​ຮັບຍັງ',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
              ),
              SizedBox(height: 20.0),
              InkWell(
                onTap: () => _chooseDate(context, modelRecieved.date.text),
                child: IgnorePointer(
                  child: TextFormField(
                    // validator: widget.validator,
                    controller: modelRecieved.date,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "ທ່ານ​ຕ້ອງ​ເລືອກວັນ​ທີ່";
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'ວັນ​ທີ່​ຮັບ',
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      suffixIcon: Icon(Icons.date_range),
                    ),
                  ),
                ),
              ),
              RaisedButton.icon(
                icon: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                label: Text(
                  'ບັນ​ທຶກ',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                key: null,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    if (this.id != null) {
                      updatepayment();
                    } else {
                      createpayment();
                    }
                  }
                },
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
