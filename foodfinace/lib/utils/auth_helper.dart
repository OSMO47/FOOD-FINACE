import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

// คลาสช่วยจัดการการยืนยันตัวตนและการเก็บข้อมูล (แบบง่ายและไม่ปลอดภัย)
class AuthHelper {
  static const String _usersKey = 'app_users'; // Key สำหรับเก็บ list ของ users ใน SharedPreferences
  static const String _loggedInUserKey = 'logged_in_user'; // Key สำหรับเก็บ username ที่ login อยู่

  // --- คำเตือนด้านความปลอดภัย ---
  // การเก็บรหัสผ่านเป็น Plain Text ใน SharedPreferences ไม่ปลอดภัยอย่างยิ่ง!
  // นี่เป็นเพียงตัวอย่างเพื่อการสาธิตเท่านั้น
  // แอปจริงควรใช้ Backend, Database, และการ Hashing รหัสผ่าน
  // --- จบคำเตือน ---

  // โหลดรายชื่อผู้ใช้ทั้งหมดจาก SharedPreferences
  static Future<List<User>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? usersJson = prefs.getStringList(_usersKey);
    if (usersJson == null) {
      return []; // ถ้ายังไม่มีข้อมูล user เลย คืนค่า list ว่าง
    }
    // แปลง JSON string list กลับเป็น List<User>
    return usersJson.map((userJson) => User.fromJsonString(userJson)).toList();
  }

  // บันทึกรายชื่อผู้ใช้ทั้งหมดลง SharedPreferences
  static Future<void> _saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    // แปลง List<User> เป็น List<String> (JSON)
    final List<String> usersJson = users.map((user) => user.toJsonString()).toList();
    await prefs.setStringList(_usersKey, usersJson);
  }

  // ลงทะเบียนผู้ใช้ใหม่
  static Future<bool> registerUser(String username, String password, String phoneNumber) async {
    final users = await _loadUsers();

    // ตรวจสอบว่า username ซ้ำหรือไม่ (case-insensitive)
    if (users.any((user) => user.username.toLowerCase() == username.toLowerCase())) {
      return false; // Username ซ้ำ ลงทะเบียนไม่ได้
    }

    // สร้าง User ใหม่และเพิ่มเข้าไปใน list
    final newUser = User(username: username, password: password, phoneNumber: phoneNumber);
    users.add(newUser);

    // บันทึก list ผู้ใช้ที่อัปเดตแล้ว
    await _saveUsers(users);
    return true; // ลงทะเบียนสำเร็จ
  }

  // ตรวจสอบการ Login
  static Future<User?> loginUser(String username, String password) async {
    final users = await _loadUsers();

    try {
      // ค้นหา user ด้วย username (case-insensitive) และตรวจสอบรหัสผ่าน
      final user = users.firstWhere(
        (user) => user.username.toLowerCase() == username.toLowerCase() && user.password == password,
        // **คำเตือน:** เปรียบเทียบ Plain text password! ไม่ปลอดภัย!
      );
      // ถ้าเจอและรหัสผ่านตรงกัน ให้บันทึกสถานะ login
      await _setLoggedInUser(user.username);
      return user; // คืนค่า User ที่ login สำเร็จ
    } catch (e) {
      // ไม่เจอ user หรือรหัสผ่านไม่ตรง
      return null;
    }
  }

  // แก้ไขข้อมูลผู้ใช้
  static Future<bool> updateUser(String currentUsername, String newUsername, String newPassword, String newPhoneNumber) async {
     final users = await _loadUsers();
     final userIndex = users.indexWhere((user) => user.username.toLowerCase() == currentUsername.toLowerCase());

     if (userIndex == -1) {
       return false; // ไม่เจอ user เดิม
     }

     // ตรวจสอบว่า username ใหม่ (ถ้ามีการเปลี่ยน) ซ้ำกับคนอื่นหรือไม่
     if (newUsername.toLowerCase() != currentUsername.toLowerCase() &&
         users.any((user) => user.username.toLowerCase() == newUsername.toLowerCase())) {
        return false; // Username ใหม่ซ้ำ
     }

     // อัปเดตข้อมูล
     users[userIndex] = User(
       username: newUsername,
       password: newPassword, // **คำเตือน:** อัปเดต Plain text password!
       phoneNumber: newPhoneNumber,
     );

     await _saveUsers(users);

     // ถ้า username เปลี่ยน ต้องอัปเดต logged in user ด้วย
     if (newUsername.toLowerCase() != currentUsername.toLowerCase()) {
        await _setLoggedInUser(newUsername);
     }
     return true;
  }

  // ดึงข้อมูลผู้ใช้ที่ login อยู่
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInUsername = prefs.getString(_loggedInUserKey);
    if (loggedInUsername == null) {
      return null;
    }
    final users = await _loadUsers();
    try {
      return users.firstWhere((user) => user.username.toLowerCase() == loggedInUsername.toLowerCase());
    } catch (e) {
      // ไม่เจอ user ที่ login อยู่ (อาจจะเกิดถ้าข้อมูลไม่ sync)
      await logoutUser(); // ล้างค่า login ที่ไม่ถูกต้อง
      return null;
    }
  }

  // บันทึก username ที่ login อยู่
  static Future<void> _setLoggedInUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loggedInUserKey, username);
  }

  // Logout
  static Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInUserKey);
  }
}
