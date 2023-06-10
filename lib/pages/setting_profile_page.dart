import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/firestore/user_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../model/user.dart';
import '../utils/shared_prefs.dart';

class SettingProfilePage extends StatefulWidget {
  const SettingProfilePage({super.key});

  @override
  State<SettingProfilePage> createState() => _SettingProfilePageState();
}

class _SettingProfilePageState extends State<SettingProfilePage> {
  File? image;
  String imagePath ='';

  final ImagePicker _picker = ImagePicker();
  final TextEditingController controller = TextEditingController();

  Future<void> selectImage() async{
    XFile? pickedImage = await _picker.pickImage(source:ImageSource.gallery);
    if(pickedImage == null) return;

    setState(() {
      image = File(pickedImage.path);
    });
  }

  Future<void> uploadImage() async{
    final ref = FirebaseStorage.instance.ref(SharedPrefs.fetchUid()!);
    final storedImage = await ref.putFile(image!);
    imagePath = await storedImage.ref.getDownloadURL();
  }

  @override

  void initState() {
    super.initState();

    Future(() async{
      final myProfile = await UserFirestore.fetchProfile(SharedPrefs.fetchUid()!);
      controller.text = myProfile.name;
      imagePath = myProfile.imagePath!;
    });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title:const Text('プロフィール編集'),
      ),
      body : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width:120, child: Text('名前')),
                Expanded(child: TextField(
                  controller: controller,
                ))
              ],
            ),
            const SizedBox(height: 50,),
            Row(
              children: [
                const SizedBox(width:120, child: Text('プロフィール画像')),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        await selectImage();
                        uploadImage();
                      },
                      child: const Text('画像を選択')
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height:30,),
            image == null
              ? const SizedBox()
              : SizedBox(
                width :200,
                height :200,
                child: Image.file(image!,fit : BoxFit.cover)
              ),
            const SizedBox(height: 150,),
            SizedBox(
              width: 150,
              height: 30,
              child: ElevatedButton(
                onPressed: () async {
                  User newProfile = User(
                    name: controller.text,
                    imagePath: imagePath,
                    uid: SharedPrefs.fetchUid()!
                  );
                  await UserFirestore.updateuser(newProfile);
                },
                child: const Text('編集')
              ),
            )
          ],
        ),
      )
    );
  }
}