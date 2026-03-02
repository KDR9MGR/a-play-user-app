import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:a_play/features/authentication/presentation/providers/auth_provider.dart';
import 'package:a_play/features/profile/providers/profile_provider.dart';
import 'package:a_play/features/profile/models/profile_model.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  bool _isLoading = false;
  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;
  bool _isNavigating = false;
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      // Load profile from Supabase profiles table
      final profile = await ref.read(profileProvider).getProfile();

      if (mounted) {
        setState(() {
          _fullNameController.text = profile.fullName ?? '';
          _phoneController.text = profile.phone ?? '';
          if (profile.avatarUrl != null) {
            _imageProvider = NetworkImage(profile.avatarUrl!);
          }
        });
      }
    } catch (e) {
      // If profile doesn't exist yet, initialize with empty values
      // This is fine - user will fill in their details
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _imageProvider = null;
    _selectedImageBytes = null;
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
    final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512, // Limit image size
        maxHeight: 512,
        imageQuality: 85, // Compress image
      );
    
      if (image != null && mounted) {
      final imageBytes = await image.readAsBytes();
      setState(() {
        _selectedImagePath = image.path;
        _selectedImageBytes = imageBytes;
          _imageProvider = MemoryImage(_selectedImageBytes!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('No user logged in');
      }
      
      String? newPhotoUrl;
      if (_selectedImageBytes != null && _selectedImagePath != null) {
        final extension = _selectedImagePath!.split('.').last;
        final fileName = '${user.id}.$extension';
        
        // Upload to Supabase Storage
        final storage = ref.read(supabaseProvider).storage;
        await storage.from('avatars').uploadBinary(
          fileName,
          _selectedImageBytes!,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );
        
        newPhotoUrl = storage
            .from('avatars')
            .getPublicUrl(fileName);
      }

      // Get current profile data
      final currentProfile = await ref.read(profileProvider).getProfile();
      
      // Create updated profile model
      final updatedProfile = ProfileModel(
        id: currentProfile.id,
        fullName: _fullNameController.text,
        avatarUrl: newPhotoUrl ?? currentProfile.avatarUrl,
        phone: _phoneController.text,
        createdAt: currentProfile.createdAt,
        isPremium: currentProfile.isPremium,
        isOrganizer: currentProfile.isOrganizer,
      );

      // Update profile in Supabase
      await ref.read(profileProvider).updateProfile(updatedProfile);

      // Update auth metadata without triggering a full refresh
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _fullNameController.text,
            'phone_number': _phoneController.text.replaceAll(RegExp(r'[^\d+]'), ''),
            if (newPhotoUrl != null) 'avatar_url': newPhotoUrl,
          },
        ),
      );

      // Refresh only the necessary providers
      ref.invalidate(profileFutureProvider);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        
        // Clear resources
        setState(() {
          _isLoading = false;
          _imageProvider = null;
          _selectedImageBytes = null;
        });

        // Navigate back using GoRouter
        if (context.mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // Update the back button handler
  Future<void> _handleBack() async {
    if (!_isNavigating && mounted) {
      setState(() {
        _isNavigating = true;
        _imageProvider = null;
        _selectedImageBytes = null;
      });

      if (context.mounted) {
        // Clear any pending snackbars
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // Go back using GoRouter
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _handleBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _handleSave,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
        body: user == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Picture
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImageBytes != null
                            ? _imageProvider
                            : (user.photoUrl != null ? _imageProvider : null),
                        child: (_selectedImageBytes == null &&
                                      user.photoUrl == null)
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          radius: 18,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18),
                            color: Theme.of(context).colorScheme.onPrimary,
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Full Name Field
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^\+?[0-9]{10,}$').hasMatch(value)) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 