import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/app_logo.dart';
import '../widgets/app_bottom_nav.dart';
import '../routes.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/profile.dart';

// Added imports
import 'package:khangmate_ui/services/listing_service.dart';
import 'package:khangmate_ui/utils/image_utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameC = TextEditingController();
  final usernameC = TextEditingController();
  final cidC = TextEditingController();
  final phoneC = TextEditingController();
  int _navIndex = 4;
  Profile? _profile;
  bool _loading = true;
  bool _saving = false;
  File? _selectedImage;

  final _authService = AuthService();
  final _listingService = ListingService(); // New
  final primary = Colors.red;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final profile = await _authService.getCurrentProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          nameC.text = profile?.fullName ?? '';
          usernameC.text = profile?.username ?? '';
          cidC.text = profile?.cid ?? '';
          phoneC.text = profile?.phone ?? '';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  // Updated _pickImage using ImageUtils
  Future<void> _pickImage() async {
    final image = await ImageUtils.pickImage();
    if (image != null && mounted) {
      setState(() => _selectedImage = image);
    }
  }

  void _onNav(int idx) {
    if (idx == 0) { Navigator.pushNamed(context, Routes.home); return; }
    if (idx == 1) { Navigator.pushNamed(context, Routes.map); return; }
    if (idx == 2) { 
      Navigator.pushNamed(context, Routes.chatHome); 
      return; 
    }
    if (idx == 3) { Navigator.pushNamed(context, Routes.chatHome); return; }
    if (idx == 4) return;
    setState(() => _navIndex = idx);
  }

  Future<void> _confirmSave() async {
    if (!_formKey.currentState!.validate() || _saving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Save'),
        content: const Text('Save changes to your profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(_, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _saving = true);

    try {
      // Upload new profile picture if selected
      String? avatarUrl = _profile?.avatarUrl;
      if (_selectedImage != null) {
        avatarUrl = await _listingService.uploadProfilePicture(_selectedImage!);
      }

      // Update profile
      await _authService.updateProfile(
        fullName: nameC.text.trim(),
        username: usernameC.text.trim(),
        phone: phoneC.text.trim(),
        avatarUrl: avatarUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    nameC.dispose();
    usernameC.dispose();
    cidC.dispose();
    phoneC.dispose();
    super.dispose();
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType type = TextInputType.text, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [AppLogo(size: 28), SizedBox(width: 8), Text('Edit Profile')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!) as ImageProvider
                                : (_profile?.avatarUrl != null && _profile!.avatarUrl!.isNotEmpty
                                    ? NetworkImage(
                                        _listingService.getProfilePictureUrl(_profile!.avatarUrl!))
                                    : null),
                            child: _selectedImage == null &&
                                    (_profile?.avatarUrl == null || _profile!.avatarUrl!.isEmpty)
                                ? const Icon(Icons.person, size: 44)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: primary,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                onPressed: _pickImage,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _field(nameC, 'Full name'),
                    _field(usernameC, 'Username'),
                    _field(cidC, 'CID', type: TextInputType.number),
                    _field(phoneC, 'Phone number', type: TextInputType.phone),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saving ? null : _confirmSave,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save changes'),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: AppBottomNav(currentIndex: _navIndex, onTap: _onNav),
    );
  }
}
