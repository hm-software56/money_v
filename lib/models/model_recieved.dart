import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
class ModelRecieved{
  bool isloading=false;
  var user_id;
  Map listuserphoto={};
  Map listtypename={};
  var amount=new MoneyMaskedTextController(decimalSeparator:'.',thousandSeparator: ','); 
  var date=TextEditingController();
  var description=TextEditingController();
  var tye_receive_id=TextEditingController();
  var user=TextEditingController();
  var type_name;
  var type_id;
}