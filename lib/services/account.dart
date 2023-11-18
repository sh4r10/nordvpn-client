import 'dart:io';

class AccountService{
 
  static Future<bool> login(String token) async {
    ProcessResult result = await Process.run('nordvpn', ['login', '--token', token]);
    return result.exitCode == 0;
  }

  static Future<bool> isLoggedIn() async {
    ProcessResult result = await Process.run('nordvpn', ['account']);
    return result.exitCode == 0;
  }

}