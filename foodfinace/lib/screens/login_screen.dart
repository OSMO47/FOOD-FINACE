import 'package:flutter/material.dart';
import 'register_screen.dart'; // สำหรับ navigate ไปหน้า Register
import 'home_screen.dart'; // สำหรับ navigate ไปหน้า Home หลัง login สำเร็จ
import '../utils/auth_helper.dart'; // เรียกใช้ AuthHelper
import '../models/user.dart'; // Import User model

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Key สำหรับ Form validation
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // สถานะ loading ขณะกดปุ่ม login
  bool _passwordVisible = false; // สถานะการแสดง/ซ่อนรหัสผ่าน

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับจัดการการ Login
  Future<void> _handleLogin() async {
    // ตรวจสอบ validation ของ Form
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // เริ่ม loading
      });

      final username = _usernameController.text.trim();
      final password = _passwordController.text; // ไม่ต้อง trim รหัสผ่าน

      // เรียก AuthHelper เพื่อตรวจสอบ login
      final User? loggedInUser = await AuthHelper.loginUser(username, password);

      // หยุด loading
      if (mounted) { // ตรวจสอบว่า widget ยังอยู่ใน tree
        setState(() {
          _isLoading = false;
        });

        if (loggedInUser != null) {
          // Login สำเร็จ: ไปหน้า HomeScreen และลบหน้า Login ออกจาก stack
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Login ไม่สำเร็จ: แสดง SnackBar ข้อผิดพลาด
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'),
              backgroundColor: Colors.red,
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
        title: const Text('เข้าสู่ระบบ'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView( // ทำให้เลื่อนได้ถ้า content ล้นจอ
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // ผูก Form key
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // ทำให้ปุ่มเต็มความกว้าง
              children: [
                // --- ช่อง Username ---
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อผู้ใช้ (Username)',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกชื่อผู้ใช้';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next, // ปุ่ม Enter ไปช่องถัดไป
                ),
                const SizedBox(height: 16.0),

                // --- ช่อง Password ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible, // ซ่อน/แสดงรหัสผ่าน
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน (Password)',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    // ไอคอนสำหรับกดแสดง/ซ่อนรหัสผ่าน
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done, // ปุ่ม Enter แล้วกด Login
                  onFieldSubmitted: (_) => _isLoading ? null : _handleLogin(), // กด Enter จากช่องนี้ให้ Login เลย
                ),
                const SizedBox(height: 24.0),

                // --- ปุ่ม Login ---
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin, // Disable ปุ่มตอน loading
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox( // แสดง loading indicator บนปุ่ม
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('เข้าสู่ระบบ'),
                ),
                const SizedBox(height: 16.0),

                // --- ปุ่มไปหน้า Register ---
                TextButton(
                  onPressed: () {
                    // Navigate ไปหน้า Register
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('ยังไม่มีบัญชี? สมัครสมาชิกที่นี่'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
