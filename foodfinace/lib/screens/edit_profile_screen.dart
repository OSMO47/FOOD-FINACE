import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/auth_helper.dart';
import '../models/user.dart';

class EditProfileScreen extends StatefulWidget {
  final User currentUser; // รับ User ปัจจุบันมาแสดง

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  final _currentPasswordController =
      TextEditingController(); // สำหรับยืนยันก่อนเปลี่ยนรหัส
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _newPasswordVisible = false;
  bool _confirmNewPasswordVisible = false;
  bool _currentPasswordVisible = false; // สำหรับช่องรหัสปัจจุบัน

  @override
  void initState() {
    super.initState();
    // ตั้งค่าเริ่มต้นให้ Controller จากข้อมูล User ปัจจุบัน
    _usernameController =
        TextEditingController(text: widget.currentUser.username);
    _phoneController =
        TextEditingController(text: widget.currentUser.phoneNumber);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับจัดการการบันทึกข้อมูลที่แก้ไข
  Future<void> _handleSaveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final newUsername = _usernameController.text.trim();
      final newPhone = _phoneController.text.trim();
      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;

      String passwordToSave =
          widget.currentUser.password; // ใช้รหัสเดิมเป็นค่าเริ่มต้น

      // ตรวจสอบว่ามีการกรอกรหัสผ่านใหม่หรือไม่
      if (newPassword.isNotEmpty) {
        // --- ตรวจสอบรหัสผ่านปัจจุบัน ---
        // **คำเตือน:** เปรียบเทียบ Plain text! ไม่ปลอดภัย!
        if (currentPassword != widget.currentUser.password) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('รหัสผ่านปัจจุบันไม่ถูกต้อง'),
                  backgroundColor: Colors.red),
            );
          }
          return; // หยุดการทำงานถ้าไม่ถูก
        }
        // ถ้ารหัสปัจจุบันถูก และรหัสใหม่ผ่าน validation ใน form แล้ว ให้ใช้รหัสใหม่
        passwordToSave = newPassword;
      }

      // เรียก AuthHelper เพื่ออัปเดตข้อมูล
      final bool success = await AuthHelper.updateUser(
        widget.currentUser.username, // Username เดิมสำหรับค้นหา
        newUsername,
        passwordToSave, // รหัสผ่านที่จะบันทึก (อาจจะเป็นอันเดิมหรืออันใหม่)
        newPhone,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
                backgroundColor: Colors.green),
          );
          // อาจจะ pop กลับไปหน้าเดิม หรือ refresh ข้อมูลใน state management (ถ้ามี)
          // ในตัวอย่างนี้ แค่แสดงข้อความ
          // ถ้า username เปลี่ยน อาจจะต้อง pop กลับไปหน้า login หรือ refresh AuthWrapper
          if (widget.currentUser.username.toLowerCase() !=
              newUsername.toLowerCase()) {
            // อาจจะต้อง logout แล้วให้ login ใหม่ หรือ refresh state
            // ตัวอย่าง: กลับไปหน้าก่อนหน้า
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          }
        } else {
          // อาจเกิดจาก Username ใหม่ซ้ำ
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('ไม่สามารถบันทึกข้อมูลได้ (อาจเกิดจากชื่อผู้ใช้ซ้ำ)'),
                backgroundColor: Colors.orange),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขข้อมูลส่วนตัว'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16.0),

              // --- ช่อง Phone Number ---
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'เบอร์โทรศัพท์',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกเบอร์โทรศัพท์';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24.0),

              // --- ส่วนเปลี่ยนรหัสผ่าน (เป็นทางเลือก) ---
              const Text('เปลี่ยนรหัสผ่าน (กรอกเฉพาะเมื่อต้องการเปลี่ยน)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),

              // --- ช่อง Current Password ---
              TextFormField(
                controller: _currentPasswordController,
                obscureText: !_currentPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่านปัจจุบัน (เพื่อยืนยัน)',
                  prefixIcon: const Icon(Icons.lock_open),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_currentPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(() =>
                        _currentPasswordVisible = !_currentPasswordVisible),
                  ),
                ),
                // ไม่ต้องมี validator บังคับกรอก แต่จะเช็คตอนกด save ถ้ามีการกรอกรหัสใหม่
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16.0),

              // --- ช่อง New Password ---
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_newPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'รหัสผ่านใหม่',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_newPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(
                        () => _newPasswordVisible = !_newPasswordVisible),
                  ),
                ),
                validator: (value) {
                  // Validate เฉพาะเมื่อมีการกรอกช่องนี้ หรือช่องยืนยัน
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'รหัสผ่านใหม่ต้องมีอย่างน้อย 6 ตัวอักษร';
                  }
                  if (value != null &&
                      value.isNotEmpty &&
                      _confirmNewPasswordController.text.isNotEmpty &&
                      value != _confirmNewPasswordController.text) {
                    return 'รหัสผ่านใหม่ไม่ตรงกัน';
                  }
                  return null; // ไม่บังคับกรอก
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16.0),

              // --- ช่อง Confirm New Password ---
              TextFormField(
                controller: _confirmNewPasswordController,
                obscureText: !_confirmNewPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'ยืนยันรหัสผ่านใหม่',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_confirmNewPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(() => _confirmNewPasswordVisible =
                        !_confirmNewPasswordVisible),
                  ),
                ),
                validator: (value) {
                  // Validate เฉพาะเมื่อมีการกรอกรหัสผ่านใหม่
                  if (_newPasswordController.text.isNotEmpty &&
                      (value == null || value.isEmpty)) {
                    return 'กรุณายืนยันรหัสผ่านใหม่';
                  }
                  if (value != _newPasswordController.text) {
                    return 'รหัสผ่านใหม่ไม่ตรงกัน';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) =>
                    _isLoading ? null : _handleSaveChanges(),
              ),
              const SizedBox(height: 32.0),

              // --- ปุ่ม Save Changes ---
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSaveChanges,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Colors.orange, // สีปุ่มแตกต่าง
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('บันทึกการเปลี่ยนแปลง'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
