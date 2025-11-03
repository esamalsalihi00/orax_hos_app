// services_login.dart
import 'package:http/http.dart' as http;
import 'package:orax_hos_sys_app/Models/models.dart';
import 'dart:convert';

class LoginService {
  static const String _baseUrl = 'http://oraxhosdb2002.runasp.net/api';

  // اختبار الاتصال بالـ API
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Connection/Connect'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('خطأ في اختبار الاتصال: $e');
      return false;
    }
  }

  // جلب جميع الفروع
  static Future<List<Branch>> getBranches() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Branches/AllBranches'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((branch) => Branch.fromJson(branch)).toList();
      } else {
        throw Exception('فشل في جلب الفروع: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في جلب الفروع: $e');
      throw Exception('خطأ في جلب الفروع: $e');
    }
  }

  // جلب المستخدمين بناءً على الفرع
  static Future<List<User>> getUsersByBranch(int branchId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Users/AllUser?BranchNo=$branchId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('فشل في جلب المستخدمين: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في جلب المستخدمين: $e');
      throw Exception('خطأ في جلب المستخدمين: $e');
    }
  }

  // تسجيل الدخول - محدث ليتوافق مع موديل UserData الجديد
  static Future<UserData> login(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/Users/Login?id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // تحويل البيانات من نموذج ASP.NET Core إلى UserData
        return UserData(
          id: jsonData['id'] ?? 0,
          username: jsonData['username'] ?? '',
          password: jsonData['password'] ?? '',
          User_type: jsonData['User_type'] ?? 0,
          IS_Deleted: jsonData['IS_Deleted'] ?? false,
          emp: jsonData['emp'] ?? 0,
          branchNo: jsonData['branchNo'] ?? 0,
          email: jsonData['email'],
          phone: jsonData['phone'],
        );
      } else {
        throw Exception('فشل في تسجيل الدخول: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في تسجيل الدخول: $e');
      throw Exception('خطأ في تسجيل الدخول: $e');
    }
  }

  // دالة مساعدة لتحويل User إلى UserData إذا لزم الأمر
  static UserData convertUserToUserData(User user) {
    return UserData(
      id: user.id,
      username: user.username,
      password: user.password ?? '',
      User_type: user.User_type,
      IS_Deleted: user.IS_Deleted,
      emp: user.emp,
      branchNo: user.branchNo,
      email: null,
      phone: null,
    );
  }
}