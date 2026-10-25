import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'volunteer_home_page.dart';

class VolunteerRegistrationPage extends StatefulWidget {
  const VolunteerRegistrationPage({super.key});

  @override
  State<VolunteerRegistrationPage> createState() =>
      _VolunteerRegistrationPageState();
}

class _VolunteerRegistrationPageState
    extends State<VolunteerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _responderType = 'Volunteer';

  final List<String> _availableSpecializations = [
    'Flood Rescue',
    'Food Distribution',
    'Water Supply',
    'Medical Assistance',
    'Ambulance / Transport',
    'Child Emergency Support',
    'Elderly Assistance',
    'Search & Rescue',
    'Shelter Assistance',
    'Fire / Disaster Response',
    'Other',
  ];

  final Set<String> _selectedSpecializations = {};

  bool _available = true;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerVolunteer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSpecializations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one specialization.'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();

    // Mark the registration as in progress before creating
    // the Firebase account, so the root router can recognize it.
    await prefs.setBool(
      'pending_responder_registration',
      true,
    );

    UserCredential? credential;

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Firebase did not return a user account.');
      }

      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      await user.updateDisplayName(name);

      final responderId =
          'VOL-${user.uid.substring(0, 8).toUpperCase()}';
          await prefs.setBool(
  'responder_registered_${user.uid}',
  true,
);

     
      await prefs.setString(
        'responder_name_${user.uid}',
        name,
      );

      await prefs.setString(
        'responder_phone_${user.uid}',
        phone,
      );

      await prefs.setString(
        'responder_id_${user.uid}',
        responderId,
      );

      await prefs.setString(
        'responder_type_${user.uid}',
        _responderType,
      );

      await prefs.setStringList(
        'responder_specializations_${user.uid}',
        _selectedSpecializations.toList(),
      );

      await prefs.setBool(
        'responder_available_${user.uid}',
        _available,
      );

    

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Volunteer registered successfully!',
          ),
        ),
      );
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(
    builder: (_) => const VolunteerHomePage(),
  ),
  (route) => false,
);
    } on FirebaseAuthException catch (e) {
     

      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message =
              'This email already has an account. '
              'Choose Sign In instead.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message =
              'Your password is too weak. '
              'Use a stronger password.';
          break;
        case 'network-request-failed':
          message =
              'Network error. Check your internet connection.';
          break;
        default:
          message = e.message ?? 'Registration failed.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
     

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Registration'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.volunteer_activism,
                    size: 65,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Join ResQAI',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Register to help people during emergencies.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 25),

                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                ),

                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null ||
                        value.trim().length < 10) {
                      return 'Enter a valid phone number.';
                    }
                    return null;
                  },
                ),

                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        !value.trim().contains('@')) {
                      return 'Enter a valid email address.';
                    }
                    return null;
                  },
                ),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  value: _responderType,
                  decoration: const InputDecoration(
                    labelText: 'Responder Type',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Volunteer',
                      child: Text('Volunteer'),
                    ),
                    DropdownMenuItem(
                      value: 'Medical Responder',
                      child: Text('Medical Responder'),
                    ),
                    DropdownMenuItem(
                      value: 'Rescue Team',
                      child: Text('Rescue Team'),
                    ),
                    DropdownMenuItem(
                      value: 'Transport Responder',
                      child: Text('Transport Responder'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _responderType = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  'Specializations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _availableSpecializations.map(
                    (specialization) {
                      return FilterChip(
                        label: Text(specialization),
                        selected: _selectedSpecializations
                            .contains(specialization),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSpecializations.add(
                                specialization,
                              );
                            } else {
                              _selectedSpecializations.remove(
                                specialization,
                              );
                            }
                          });
                        },
                      );
                    },
                  ).toList(),
                ),

                const SizedBox(height: 20),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Available for emergencies',
                  ),
                  subtitle: const Text(
                    'Indicate whether you are currently available.',
                  ),
                  value: _available,
                  activeThumbColor: Colors.red,
                  onChanged: (value) {
                    setState(() => _available = value);
                  },
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _loading ? null : _registerVolunteer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'REGISTER AS VOLUNTEER',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel Registration',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required.';
              }
              return null;
            },
      ),
    );
  }
}