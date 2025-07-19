import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/generalprovider.dart';
import '../utils/color.dart';
import '../utils/utils.dart';
import '../widget/mytext.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'email_required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'invalid_email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'password_required';
    }
    if (value.length < 8) {
      return 'password_length';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final generalProvider = Provider.of<GeneralProvider>(context, listen: false);

    try {
      final response = await generalProvider.resetPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      if (!mounted) return;

      if (response['status'] == 200) {
        setState(() {
          _successMessage = response['message'] ?? 'password_reset_success';
          Navigator.pop(context);
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'password_reset_failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'something_went_wrong';
      });
      printLog("Password reset error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                color: titleTextColor,
                text: "reset_password",
                fontsizeNormal: 24,
                fontsizeWeb: 28,
                multilanguage: true,
                fontweight: FontWeight.bold,
                maxline: 1,
              ),
              const SizedBox(height: 10),
              MyText(
                color: descTextColor,
                text: "enter_new_password_note",
                fontsizeNormal: 14,
                fontsizeWeb: 16,
                multilanguage: true,
                fontweight: FontWeight.w500,
                maxline: 3,
              ),
              const SizedBox(height: 20),

              // Success Message
              if (_successMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: MyText(
                    text: _successMessage!,
                    color: Colors.green,
                    multilanguage: true,
                    fontsizeNormal: 14,
                    textalign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 15),
              ],

              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: MyText(
                    text: _errorMessage!,
                    color: Colors.red,
                    multilanguage: true,
                    fontsizeNormal: 14,
                    textalign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 15),
              ],

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "email",
                  labelStyle: TextStyle(color: descTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: colorPrimary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: colorPrimary),
                  ),
                  filled: true,
                  fillColor: edtViewShadowColor,
                ),
                style: TextStyle(color: white),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 15),

              // New Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "new_password",
                  labelStyle: TextStyle(color: descTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: colorPrimary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: colorPrimary),
                  ),
                  filled: true,
                  fillColor: edtViewShadowColor,
                ),
                style: TextStyle(color: white),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 15),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: "confirm_new_password",
                  labelStyle: TextStyle(color: descTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: colorPrimary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: colorPrimary),
                  ),
                  filled: true,
                  fillColor: edtViewShadowColor,
                ),
                style: TextStyle(color: white),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'confirm_password_required';
                  }
                  if (value != _passwordController.text) {
                    return 'password_mismatch';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _isLoading ? null : _resetPassword,
                  child: _isLoading
                      ? CircularProgressIndicator(color: white)
                      : MyText(
                    color: white,
                    text: "update_password",
                    fontsizeNormal: 16,
                    fontsizeWeb: 18,
                    multilanguage: true,
                    fontweight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
