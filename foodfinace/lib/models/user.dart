import 'dart:convert'; // สำหรับ jsonEncode/Decode

// โมเดลสำหรับเก็บข้อมูลผู้ใช้
class User {
  final String username;
  String password; // **คำเตือน:** ในตัวอย่างนี้เก็บเป็น Plain text ไม่ปลอดภัย!
  String phoneNumber;

  User({
    required this.username,
    required this.password,
    required this.phoneNumber,
  });

  // Factory constructor สำหรับสร้าง User จาก Map (ที่ได้จาก JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      password: json['password'] as String, // **คำเตือน:** ดึง Plain text
      phoneNumber: json['phoneNumber'] as String,
    );
  }

  // เมธอดสำหรับแปลง User เป็น Map (เพื่อเก็บเป็น JSON)
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password, // **คำเตือน:** เก็บ Plain text
      'phoneNumber': phoneNumber,
    };
  }

  // Helper สำหรับแปลงเป็น JSON String
  String toJsonString() => jsonEncode(toJson());

  // Helper สำหรับสร้างจาก JSON String
  factory User.fromJsonString(String jsonString) => User.fromJson(jsonDecode(jsonString));
}
