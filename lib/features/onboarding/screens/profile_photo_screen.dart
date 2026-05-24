
import 'dart:io';
import 'package:a_play/features/onboarding/controllers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoScreen extends ConsumerStatefulWidget {
  final PageController pageController;
  const ProfilePhotoScreen({super.key, required this.pageController});

  @override
  ConsumerState<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends ConsumerState<ProfilePhotoScreen> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a profile photo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(Icons.add_a_photo, size: 80)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_image != null) {
                  ref.read(onboardingControllerProvider.notifier).updateProfile(
                        ref.read(onboardingControllerProvider).copyWith(
                              avatarUrl: _image!.path,
                            ),
                      );
                }
                widget.pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
