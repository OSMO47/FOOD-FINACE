import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'utils/auth_helper.dart';
import 'models/user.dart';

// Widget นี้ทำหน้าที่ตรวจสอบสถานะ Login และแสดงหน้าจอที่เหมาะสม
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // ใช้ FutureBuilder เพื่อรอผลการตรวจสอบสถานะ login
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: AuthHelper.getCurrentUser(), // เรียกฟังก์ชันตรวจสอบผู้ใช้ปัจจุบัน
      builder: (context, snapshot) {
        // ขณะรอโหลดข้อมูล
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // แสดง loading indicator
          );
        }

        // ถ้ามีข้อมูลผู้ใช้ (login อยู่)
        if (snapshot.hasData && snapshot.data != null) {
          // แสดงหน้า HomeScreen
          return const HomeScreen();
        } else {
          // ถ้าไม่มีข้อมูลผู้ใช้ (ยังไม่ได้ login)
          // แสดงหน้า LoginScreen
          return const LoginScreen();
        }
      },
    );
  }
}
