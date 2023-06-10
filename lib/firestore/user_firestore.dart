import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat/firestore/room_firestore.dart';
import 'package:flutter_chat/utils/shared_prefs.dart';

import '../model/user.dart';

// ignore_for_file: avoid_print
class UserFirestore{
  static final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final _userCollection =  _firestoreInstance.collection('user');

  //firestoreにユーザー追加
  static Future<String?> insertNewAccount() async{
    try {
      final newDoc = await _userCollection.add({
        'name' : 'Unknown',
        'image_path' : 'https://firebasestorage.googleapis.com/v0/b/gs-chat-85750.appspot.com/o/default.png?alt=media&token=a2976a16-36fd-4980-8964-fd1fcdfa7f71'
      });

      print('アカウント作成完了');
      return newDoc.id;

    } catch(e) {
      print('アカウント作成失敗 ---$e');
      return null;
    }
  }

  static Future<void> createUser() async{
    final myUid = await insertNewAccount();
    if(myUid != null){
      await RoomFirestore.createRoom(myUid);
      await SharedPrefs.setUid(myUid);
    }
  }

  //firestoreからユーザーリストを呼び出し
  static Future<List<QueryDocumentSnapshot>> fetchUsers() async{
    try {
      final snapshot = await _userCollection.get();
      //var userIds = <String> [];
      for(var user in snapshot.docs){
        //userIds.add(user.id);
        print('ドキュメントID:${user.id} ---名前: ${user.data()['name']}');
      }
      //return userIds;
      return snapshot.docs;
    } catch(e) {
      print('ユーザー情報取得失敗 --- $e');
      rethrow;
    }
  }

  static Future<void> updateuser(User newProfile) async{
    try{
      await _userCollection.doc(newProfile.uid).update({
        'name' : newProfile.name,
        'image_path' : newProfile.imagePath
      });
    } catch(e){
      print('ユーザー情報の更新失敗 ===== $e');
    }
  }


  //profile呼び出し
  static Future<User> fetchProfile(String uid) async{
    try {
      final snapshot = await _userCollection.doc(uid).get();
      User user = User(
      name : snapshot.data()!['name'],
      imagePath : snapshot.data()!['image_path'],
      uid : uid,
    );
    return user;

    } catch(e){
      print('自分のユーザー情報の取得失敗----$e');
      rethrow;
    }
  }
}