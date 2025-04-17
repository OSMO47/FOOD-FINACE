import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // สำหรับ Input Formatter
import '../utils/auth_helper.dart'; // เรียกใช้ AuthHelper

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับจัดการการลงทะเบียน
  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() { _isLoading = true; });

      final username = _usernameController.text.trim();
      final password = _passwordController.text;
      final phone = _phoneController.text.trim();

      // เรียก AuthHelper เพื่อลงทะเบียน
      final bool success = await AuthHelper.registerUser(username, password, phone);

      if (mounted) { // ตรวจสอบ widget
        setState(() { _isLoading = false; });

        if (success) {
          // ลงทะเบียนสำเร็จ: แสดง SnackBar และกลับไปหน้า Login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ลงทะเบียนสำเร็จ! กรุณาเข้าสู่ระบบ'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // กลับไปหน้าก่อนหน้า (LoginScreen)
        } else {
          // ลงทะเบียนไม่สำเร็จ (Username ซ้ำ): แสดง SnackBar ข้อผิดพลาด
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ชื่อผู้ใช้นี้ถูกใช้ไปแล้ว กรุณาใช้ชื่ออื่น'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- ช่อง Username ---
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อผู้ใช้ (Username)',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกชื่อผู้ใช้';
                    }
                    // อาจจะเพิ่ม validation อื่นๆ เช่น ความยาวขั้นต่ำ
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16.0),

                // --- ช่อง Password ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน (Password)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }
                    if (value.length < 6) { // ตัวอย่าง: กำหนดความยาวขั้นต่ำ
                      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16.0),

                // --- ช่อง Confirm Password ---
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_confirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'ยืนยันรหัสผ่าน',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                     suffixIcon: IconButton(
                      icon: Icon(_confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณายืนยันรหัสผ่าน';
                    }
                    if (value != _passwordController.text) {
                      return 'รหัสผ่านไม่ตรงกัน';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16.0),

                // --- ช่อง Phone Number ---
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'เบอร์โทรศัพท์',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                   keyboardType: TextInputType.phone,
                   inputFormatters: [FilteringTextInputFormatter.digitsOnly], // รับเฉพาะตัวเลข
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกเบอร์โทรศัพท์';
                    }
                    // อาจจะเพิ่ม validation รูปแบบเบอร์โทร
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _isLoading ? null : _handleRegister(),
                ),
                const SizedBox(height: 24.0),

                // --- ปุ่ม Register ---
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('สมัครสมาชิก'),
                ),
                 const SizedBox(height: 16.0),

                // --- ปุ่มกลับไปหน้า Login ---
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // กลับไปหน้าก่อนหน้า
                  },
                  child: const Text('มีบัญชีอยู่แล้ว? เข้าสู่ระบบที่นี่'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
