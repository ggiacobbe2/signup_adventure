import 'package:flutter/material.dart';
import 'success_screen.dart'; // Make sure this import exists

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _selectedAvatar;
  double _progress = 0.0;

  final List<String> _avatarOptions = [
    'assets/bear_avatar.png',
    'assets/cat_avatar.png',
    'assets/fox_avatar.png',
    'assets/lion_avatar.png',
    'assets/panda_avatar.png',
    'assets/pig_avatar.png',
  ];

  void _updateProgress() {
    int completed = 0;
    if (_nameController.text.isNotEmpty) completed++;
    if (_emailController.text.isNotEmpty) completed++;
    if (_passwordController.text.isNotEmpty) completed++;
    if (_dobController.text.isNotEmpty) completed++;
    if (_selectedAvatar != null) completed++;

    setState(() {
      _progress = completed / 5;
      if (_progress == .25) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Great start! Keep it up!'),
          duration: Duration(seconds: 2),
        ));
      } else if (_progress == .5) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Halfway there!'),
          duration: Duration(seconds: 2),
        ));
      } else if (_progress == .75) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Final Stretch!'),
          duration: Duration(seconds: 2),
        ));
      } else if (_progress == 1.0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('All set! Click below to start!'),
          duration: Duration(seconds: 2),
        ));
      }
    });
  }

  Color _passwordStrengthColor = Colors.red;
  String _passwordStrengthText = 'Weak';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Date Picker Function
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              userName: _nameController.text, 
              strongPassword: _passwordController.text.length >= 10,
              earlySignUp: DateTime.now().hour < 12,
              profileComplete: _nameController.text.isNotEmpty &&
                  _emailController.text.isNotEmpty &&
                  _dobController.text.isNotEmpty &&
                  _selectedAvatar != null,),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account ✅'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Animated Form Header
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates,
                          color: Colors.deepPurple[800]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Complete your adventure profile!',
                          style: TextStyle(
                            color: Colors.deepPurple[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Name Field
                _buildTextField(
                  controller: _nameController,
                  label: 'Adventure Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'What should we call you on this adventure?';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateProgress(),
                ),
                const SizedBox(height: 20),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'We need your email for adventure updates!';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Oops! That doesn\'t look like a valid email';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateProgress(),
                ),
                const SizedBox(height: 20),

                // DOB Field with Calendar
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon:
                        const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: _selectDate,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'When did your adventure begin?';
                    }
                    return null;
                  },
                  onChanged: (_) => _updateProgress(),
                ),
                const SizedBox(height: 20),

                // Password Field with Toggle
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  onChanged: (value) {
                    setState(() {
                      if (value.length >= 8) {
                        _passwordStrengthColor = Colors.green;
                        _passwordStrengthText = 'Strong';
                      } else if (value.length >= 4) {
                        _passwordStrengthColor = Colors.orange;
                        _passwordStrengthText = 'Medium';
                      } else {
                        _passwordStrengthColor = Colors.red;
                        _passwordStrengthText = 'Weak';
                      }
                    });
                    _updateProgress();
                  },
                  decoration: InputDecoration(
                    labelText: 'Secret Password',
                    prefixIcon:
                        const Icon(Icons.lock, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Every adventurer needs a secret password!';
                    }
                    if (value.length < 6) {
                      return 'Make it stronger! At least 6 characters';
                    }
                  },
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      'Password Strength: $_passwordStrengthText',
                      style: TextStyle(color: _passwordStrengthColor),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  'Choose Your Avatar',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _avatarOptions.length,
                  itemBuilder: (context, index) {
                    final avatarPath = _avatarOptions[index];
                    final isSelected = _selectedAvatar == avatarPath;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatarPath;
                        });
                        _updateProgress();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(
                                  color: Colors.deepPurple, width: 3)
                              : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(avatarPath),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[300],
                  color: Colors.deepPurple,
                  minHeight: 10,
                ),
                const SizedBox(height: 10),

                // Submit Button with Loading Animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isLoading ? 60 : double.infinity,
                  height: 60,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Start My Adventure',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.rocket_launch, color: Colors.white),
                            ],
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
    required String? Function(String?) validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }
}