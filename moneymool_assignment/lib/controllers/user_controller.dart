import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/user_models.dart';


class UserController extends GetxController{

 RxList<Map<String, dynamic>> userList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getUserList();
    super.onInit();
  }


  Future<dynamic> getUserList() async {
    try {
    var response = ''' [
   {
       "user_id":123,
       "name": "Krishna",
       "role": "admin",
       "city": "Delhi"
   },
   {
       "user_id":123,
       "name": "Krishna",
       "role": "user",
       "city": "Delhi"
   },{
       "user_id":124,
       "name": "Krishna A",
       "role": "admin",
       "city": "Delhi"
   },{
       "user_id":125,
       "name": "Krishna B",
       "role": "user",
       "city": "Mumbai"
   },{
       "user_id":126,
       "name": "Krishna C",
       "role": "admin",
       "city": "Jaipur"
   },
   {
       "user_id":127,
       "name": "Krishna  D",
       "role": "user",
       "city": "Kolkata"
   }
]'''
;
      var userModel = (json.decode(response) as List).cast<Map<String, dynamic>>();
          userList.value = userModel;
      return userModel;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}