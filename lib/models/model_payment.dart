import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
class ModelPayment{
  bool isloading=false;
  var user_id;
  Map listuserphoto={};
  Map listtypename={};
  var amount=new MoneyMaskedTextController(decimalSeparator:'.',thousandSeparator: ','); 
  var date=TextEditingController();
  var description=TextEditingController();
  var type_pay_id=TextEditingController();
  var user=TextEditingController();
}