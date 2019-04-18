import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moneyv3/models/model_user.dart';
import 'package:moneyv3/payment/list_payment.dart';
import 'package:moneyv3/recieved/list_recieved.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  ModelUser model_user = ModelUser();
  var photo_bg;
  /*================ upload profile and update phtoto  ==================*/
  FirebaseStorage _storage = FirebaseStorage.instance;
  Future<Uri> getImageProfile(var type) async {
    File image = (type == 'camera')
        ? await ImagePicker.pickImage(source: ImageSource.camera)
        : await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        // _image = imageFile;
        // isloadimg = true;
      });
      /*============ Drop Images =================*/
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          ratioX: 1.0,
          ratioY: 1.0,
          toolbarTitle: 'Crop photo',
          toolbarColor: Colors.red);
      if (croppedFile != null) {
        var rng = new Random();
        var l = rng.nextInt(100);
        //Create a reference to the location you want to upload to in firebase
        StorageReference reference = _storage.ref().child("images/$l");

        //Upload the file to firebase
        StorageUploadTask uploadTask = reference.putFile(croppedFile);
        var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
        var url = dowurl.toString();
        // print(url);
        // save photo
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Firestore.instance
            .collection("user")
            .document(prefs.get('token'))
            .updateData({'photo': url});
        prefs.setString('photo', url);
      }
    }
  }

  /*================ upload bg photo  and update phtoto  ==================*/
  Future<Uri> getImageBGProfile(var type) async {
    File image = (type == 'camera')
        ? await ImagePicker.pickImage(source: ImageSource.camera)
        : await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      /*============ Drop Images =================*/
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          ratioX: 1.8,
          ratioY: 1.0,
          toolbarTitle: 'Crop photo',
          toolbarColor: Colors.red);
      if (croppedFile != null) {
        var rng = new Random();
        var l = rng.nextInt(100);
        //Create a reference to the location you want to upload to in firebase
        StorageReference reference = _storage.ref().child("images/$l");

        //Upload the file to firebase
        StorageUploadTask uploadTask = reference.putFile(croppedFile);
        var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
        var url = dowurl.toString();
        // print(url);
        // save photo
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Firestore.instance
            .collection("user")
            .document(prefs.get('token'))
            .updateData({'bg_photo': url});
        prefs.setString('photo_bg', url);
      }
    }
  }

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      model_user.photo = prefs.get('photo');
      model_user.photo_bg = prefs.get('photo_bg');
      model_user.first_name = prefs.get('first_name');
      model_user.last_name = prefs.get('last_name');
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Widget build(BuildContext context) {
    /*============== menu left ============*/
    Widget drawer = Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            onDetailsPressed: () {
              showDialog(
                  context: context,
                  child: AlertDialog(
                      content: Container(
                    height: 80.0,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'ປ່ຽນ​ພາບ​ພື້ນຫຼັງ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: <Widget>[
                              OutlineButton.icon(
                                label: Text('GALLERY',
                                    style: TextStyle(
                                        fontSize: 10.0, color: Colors.black)),
                                icon: Icon(
                                  Icons.image,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  getImageBGProfile('gallery');

                                  Navigator.of(context).pop();
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: OutlineButton.icon(
                                  label: Text('CAMERA',
                                      style: TextStyle(fontSize: 10.0)),
                                  icon: Icon(
                                    Icons.camera,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    getImageBGProfile('camera');

                                    Navigator.of(context).pop();
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )));
            },
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: model_user.photo_bg == null
                      ? AssetImage('assets/img/bg.jpg')
                      : NetworkImage(model_user.photo_bg),
                  fit: BoxFit.fill),
            ),
            currentAccountPicture: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                          content: Container(
                        height: 80.0,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'ປ່​ຽນ​ຮູບ​ໂປ​ຣ​ໄຟ​ຣ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: <Widget>[
                                  OutlineButton.icon(
                                    label: Text('GALLERY',
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black)),
                                    icon: Icon(
                                      Icons.image,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      getImageProfile('gallery');

                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: OutlineButton.icon(
                                      label: Text('CAMERA',
                                          style: TextStyle(fontSize: 10.0)),
                                      icon: Icon(
                                        Icons.camera,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        getImageProfile('camera');

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )));
                },
                child: CircleAvatar(
                    backgroundImage: model_user.photo == null
                        ? AssetImage('assets/img/user.jpg')
                        : NetworkImage(model_user.photo))),
            accountName: Text(
              model_user.first_name,
              style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            accountEmail: Text(
              model_user.last_name,
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.accessible_forward,
              color: Colors.red,
            ),
            title: Text(
              'ຈັດ​ການ​ເງີນ​ທີ່​ຈ່າຍ​ອອກ',
              style: TextStyle(fontSize: 18.0),
            ),
            subtitle: Text(
              '​ປ້ອນ​ລາຍ​ລະ​ອຽດເງີນ​ທີ່​ຈ່າຍ​ອອກ​ແຕ່​ລະ​ມື້',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.accessible_forward),
            onTap: () {
              Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => ListPayment()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.accessible,
              color: Colors.blue,
            ),
            title: Text(
              'ຈັດ​ການ​ເງີນ​ທີ່​ຮັບ​ເຂົ້າ',
              style: TextStyle(fontSize: 18.0),
            ),
            subtitle: Text(
              '​ປ້ອນ​ລາຍ​ລະ​ອຽດເງີນ​ທີ່​ຮັບ​ເຂົ້າ​ແຕ່​ລະ​ມື້',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.accessible),
            onTap: () {
              Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => ListRecieved()));
            },
          ),
          Divider(),
          
          ListTile(
            leading: Icon(
              Icons.bubble_chart,
              color: Colors.blue,
            ),
            title: Text(
              '​ລາຍ​ງານ​ລາຍ​ຮັບ',
              style: TextStyle(fontSize: 18.0),
            ),
            subtitle: Text(
              '​ເບີ່ງລາຍ​ງານ​ລາຍ​ຮັບ',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.bubble_chart),
            onTap: () {
             // Navigator.of(context).pushNamed('/reportrecive');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.insert_chart,
              color: Colors.red,
            ),
            title: Text(
              '​ລາຍ​ງານ​ລາຍ​ຈ່າຍ',
              style: TextStyle(fontSize: 18.0),
            ),
            subtitle: Text(
              '​ເບີ່ງລາຍ​ງານ​ລາຍ​​ຈ່າຍ',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.insert_chart),
            onTap: () {
              // Navigator.of(context).pushNamed('/listhouseuser');
           //   Navigator.of(context).pushNamed('/reportpayment');
            },
          ),
        ],
      ),
    );
    return Scaffold(
      drawer: drawer,
      appBar: AppBar(
        title: Text("ໜ້າຫຼັກ"),
      ),
    );
  }
}
