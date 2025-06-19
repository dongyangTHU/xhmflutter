// lib/viewmodels/profile_viewmodel.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends ChangeNotifier {
  File? _wallpaperImage;
  File? get wallpaperImage => _wallpaperImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickWallpaper() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _wallpaperImage = File(pickedFile.path);
      notifyListeners(); // 通知监听者们刷新UI
    }
  }
}
