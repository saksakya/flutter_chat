import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _preferences;

  // static Future<void> removeInstance() async{
  //   if(_preferences != null) await _preferences?.remove('uid');
  // }

  static Future<void> setPrefsInstance() async{
    if(_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
      print('インスタンスを生成');
    }
  }

  static Future<void> setUid(String uid) async {
    await _preferences!.setString('uid', uid);
    print('端末保存完了');
  }

  static String? fetchUid() {
    return _preferences!.getString('uid');
  }

}