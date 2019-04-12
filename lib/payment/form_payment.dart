import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyv3/models/model_payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_format/date_format.dart';

class FormPayment extends StatefulWidget {
  var id;
  FormPayment(this.id);
  @override
  _FormPaymentState createState() => _FormPaymentState(this.id);
}

class _FormPaymentState extends State<FormPayment> {
  var id;
  _FormPaymentState(this.id);
  final _formKey = GlobalKey<FormState>();
  ModelPayment modelPayment = ModelPayment();

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
      modelPayment.date.text = new DateFormat.yMd().format(result);
    });
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  List<String> listtypename = [''];
  Map<String, dynamic>listtype ={};
  Future listtypepay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      modelPayment.user_id = prefs.get('token');
    });
    Firestore.instance.collection('type_pay').snapshots().listen((data) {
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

/*================  create ===============*/
  void createpayment() {
   /* print(modelPayment.type_id);
    print(modelPayment.amount.text.replaceAll(".00", "").replaceAll(',', ''));
    print(modelPayment.description.text);
    print(modelPayment.date.text.replaceAll('/', '-'));
    print(modelPayment.user_id);*/
    Firestore.instance.collection("payment").add({
      'amount':modelPayment.amount.text.replaceAll(".00", "").replaceAll(',', ''),
      'date': modelPayment.date.text.replaceAll('/', '-'),
      'description': modelPayment.description.text,
      'type_pay_id': modelPayment.type_id,
      'user': modelPayment.user_id,
    });
    Navigator.of(context).pop();
  }
  @override
  void initState() {
    super.initState();
    listtypepay();
  }

  Widget build(BuildContext context) {
     print(modelPayment.type_id);
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('​ປ້ອນ​ລາຍ​ຈ່າຍ'),
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
                  errorText:(modelPayment.type_pay_id.text.isEmpty)?"ທ່ານ​ຕ້ອງເລືອກ​ປະ​ເພດ​ລາຍ​ຈ່າຍ":null,
                  labelText: 'ເລືອກ​ປະ​ເພດ​ລາຍ​ຈ່າຍ',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
                isEmpty: modelPayment.type_pay_id == null,
                child: new DropdownButtonHideUnderline(
                  child: new DropdownButton<String>(
                    value: modelPayment.type_pay_id.text,
                    isDense: true,
                    onChanged: (String newValue) {
                      setState(() {
                        modelPayment.type_pay_id.text = newValue;
                        modelPayment.type_id= listtype[newValue];
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
                controller: modelPayment.amount,
                validator: (value) {
                  if (value.isEmpty || value == '0.00') {
                    return "ທ່ານ​ຕ້ອງ​ປ້​ອນ​ຈຳ​ນວນ​ເງີນ";
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ຈຳນວນ​ເງີນຈ່າຍ',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: modelPayment.description,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'ອະ​ທີ​ບາຍ​ຈ່າຍ​ຍັງ',
                  contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
              ),
              SizedBox(height: 20.0),
              InkWell(
                onTap: () => _chooseDate(context, modelPayment.date.text),
                child: IgnorePointer(
                  child: TextFormField(
                    // validator: widget.validator,
                    controller: modelPayment.date,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "ທ່ານ​ຕ້ອງ​ເລືອກວັນ​ທີ່";
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'ວັນ​ທີ່​ຈ່າຍ',
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
                  createpayment();
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
