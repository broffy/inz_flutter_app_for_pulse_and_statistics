import 'dart:async';

import 'package:flutter_myapp/models/user.dart';
import 'package:flutter_myapp/data/CtrQuery/login_ctr.dart';

class LoginRequest {
  LoginCtr con = new LoginCtr();
  Future<User> getLogin(String username) {
    var result = con.getLogin(username);
    return result;
  }
}