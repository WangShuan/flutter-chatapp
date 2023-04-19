import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;
  const UserImagePicker(this.imagePickFn, {super.key});

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  String _previewImage = '';
  void _pickImage() async {
    final imageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (imageFile == null) {
      return;
    }

    setState(() {
      _previewImage = imageFile.path;
    });
    widget.imagePickFn(File(_previewImage));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).primaryColorLight,
          backgroundImage: _previewImage == ''
              ? null
              : FileImage(
                  File(_previewImage),
                ),
        ),
        IconButton(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
        ),
      ],
    );
  }
}
