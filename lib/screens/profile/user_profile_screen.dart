import 'package:flutter/material.dart';
import 'package:pet_peeves/services/auth_service.dart';
import 'package:pet_peeves/services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  final AuthService authService;
  final UserService userService;

  const UserProfileScreen({
    super.key,
    required this.authService,
    required this.userService,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _vetNameController;
  late TextEditingController _vetPhoneController;
  late TextEditingController _vetAddressController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = widget.authService.currentUser;
    _nameController = TextEditingController(text: user?.displayName);
    _emailController = TextEditingController(text: user?.email);
    _vetNameController = TextEditingController();
    _vetPhoneController = TextEditingController();
    _vetAddressController = TextEditingController();
    _loadVetInfo();
  }

  Future<void> _loadVetInfo() async {
    try {
      final vetInfo = await widget.userService.getVetInfo();
      if (vetInfo != null) {
        _vetNameController.text = vetInfo['name'] ?? '';
        _vetPhoneController.text = vetInfo['phone'] ?? '';
        _vetAddressController.text = vetInfo['address'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vet info: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _vetNameController.dispose();
    _vetPhoneController.dispose();
    _vetAddressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await widget.userService.updateProfile(
        displayName: _nameController.text,
      );

      await widget.userService.updateVetInfo({
        'name': _vetNameController.text,
        'phone': _vetPhoneController.text,
        'address': _vetAddressController.text,
      });

      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await widget.authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              _buildUserInfo(),
              const SizedBox(height: 24),
              _buildVetInfo(),
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : null,
            child: user?.photoURL == null
                ? Text(
                    user?.displayName?[0].toUpperCase() ?? 'U',
                    style: const TextStyle(fontSize: 40),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          if (_isEditing)
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Name is required' : null,
            )
          else
            Text(
              user?.displayName ?? 'User',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Email',
              _isEditing
                  ? TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      enabled: false,
                    )
                  : Text(widget.authService.currentUser?.email ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVetInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Veterinarian Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Name',
              _isEditing
                  ? TextFormField(
                      controller: _vetNameController,
                      decoration: const InputDecoration(
                        labelText: 'Vet Name',
                        border: OutlineInputBorder(),
                      ),
                    )
                  : Text(_vetNameController.text),
            ),
            _buildInfoRow(
              'Phone',
              _isEditing
                  ? TextFormField(
                      controller: _vetPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    )
                  : Text(_vetPhoneController.text),
            ),
            _buildInfoRow(
              'Address',
              _isEditing
                  ? TextFormField(
                      controller: _vetAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    )
                  : Text(_vetAddressController.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }
} 