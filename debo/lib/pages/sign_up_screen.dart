import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/generalprovider.dart';
import '../utils/color.dart';
import '../utils/utils.dart';
import '../widget/mytext.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _mobileController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _mobileController.dispose();
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
    if (value.length < 6) {
      return 'password_length';
    }
    return null;
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final generalProvider = Provider.of<GeneralProvider>(context, listen: false);

    try {
      await generalProvider.registerNormal(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _mobileController.text.trim(),
      );

      if (!mounted) return;

      if (generalProvider.registerNormalModel.status == 200) {
        Utils.showSnackbar(
          context,
          "success",
          generalProvider.registerNormalModel.message ?? "registration_success",
          false,
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = generalProvider.registerNormalModel.message ??
              "registration_failed";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "something_went_wrong";
      });
      printLog("Registration error: $e");
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
                text: "create_account",
                fontsizeNormal: 24,
                fontsizeWeb: 28,
                multilanguage: true,
                fontweight: FontWeight.bold,
                maxline: 1,
              ),
              const SizedBox(height: 10),
              MyText(
                color: descTextColor,
                text: "sign_up_note",
                fontsizeNormal: 14,
                fontsizeWeb: 16,
                multilanguage: true,
                fontweight: FontWeight.w500,
                maxline: 3,
              ),

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 15),
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
              ],
              const SizedBox(height: 15),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "full_name",
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
                validator: (value) => value?.isEmpty ?? true
                    ? 'name_required'
                    : null,
              ),
              const SizedBox(height: 15),

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

              // Mobile Field
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: "mobile_number",
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
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true
                    ? 'mobile_required'
                    : null,
              ),
              const SizedBox(height: 15),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "password",
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
                  labelText: "confirm_password",
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

              // Sign Up Button
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
                  onPressed: _isLoading ? null : _registerUser,
                  child: _isLoading
                      ? CircularProgressIndicator(color: white)
                      : MyText(
                    color: white,
                    text: "sign_up",
                    fontsizeNormal: 16,
                    fontsizeWeb: 18,
                    multilanguage: true,
                    fontweight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Already have an account? Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText(
                    color: descTextColor,
                    text: "already_have_account",
                    fontsizeNormal: 14,
                    fontsizeWeb: 16,
                    multilanguage: true,
                    fontweight: FontWeight.w500,
                  ),
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: MyText(
                      color: colorPrimary,
                      text: "login",
                      fontsizeNormal: 14,
                      fontsizeWeb: 16,
                      multilanguage: true,
                      fontweight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}