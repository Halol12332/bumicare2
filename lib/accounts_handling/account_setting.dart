import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeAccountInfoScreen extends StatefulWidget {
  @override
  _ChangeAccountInfoScreenState createState() => _ChangeAccountInfoScreenState();
}

class _ChangeAccountInfoScreenState extends State<ChangeAccountInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  bool _isLoading = false;
  String _selectedAvatar = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user is logged in.');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.email)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _birthDateController.text = data?['birthDate'] ?? '';
          _phoneNumberController.text = data?['phoneNumber'] ?? '';
          _nicknameController.text = data?['nickname'] ?? '';
          _selectedAvatar = data?['avatar'] ?? 'avatar1';
        });
      } else {
        throw Exception('User document does not exist.');
      }
    } catch (e) {
      print("Error loading user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load user data: $e")),
      );
    }
  }

  Future<void> _updateUserInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('No user is logged in.');

      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.email);

      await userDocRef.update({
        'birthDate': _birthDateController.text,
        'phoneNumber': _phoneNumberController.text,
        'nickname': _nicknameController.text,
        'avatar': "../assets/avatar_leaderboards/$_selectedAvatar.png",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account information updated successfully!')),
      );

      Navigator.pop(context); // Navigate back to the previous screen
    } catch (e) {
      print("Error updating user info: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update account information: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildAvatarSelector() {
    const avatars = [
      'avatar1',
      'avatar2',
      'avatar3',
      'avatar4',
      'avatar5',
      'avatar6',
      'avatar7',
      'avatar8',
      'avatar9',
      'avatar10',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatar = avatars[index];
        final isSelected = avatar == _selectedAvatar;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAvatar = avatar;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              '../assets/avatar_leaderboards/$avatar.png',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Account Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Birth Date Field
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(
                  labelText: 'Birth Date',
                  hintText: 'YYYY-MM-DD',
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your birth date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nickname Field
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your nickname';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Avatar Selector
              const Text(
                'Select Avatar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildAvatarSelector(),
              const SizedBox(height: 24),

              // Update Button
              ElevatedButton(
                onPressed: _isLoading ? null : _updateUserInfo,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
