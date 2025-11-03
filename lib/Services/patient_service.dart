// patient_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orax_hos_sys_app/Models/models.dart';

class PatientService {
  static const String baseUrl = 'http://oraxhosdb2002.runasp.net/api/Patient';
  
  // دالة للحصول على جميع المرضى
  static Future<List<PatientApi>> getAllPatients() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/AllPatient'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => PatientApi.fromJson(item)).toList();
      } else {
        throw Exception('فشل في تحميل البيانات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // دالة لإضافة مريض جديد
  static Future<bool> addPatient(PatientApi patient, UserData userData) async {
    try {
      // تحضير بيانات المريض
      final patientData = patient.toJson();
      
      // تحضير بيانات المستخدم
      final userDataMap = {
        'id': userData.id,
        'username': userData.username,
        'password': userData.password,
        'user_type': userData.User_type,
        'iS_Deleted': userData.IS_Deleted,
        'emp': userData.emp,
      };

      // إنشاء كطلب الإضافة
      final addPatientRequest = AddPatientRequest(
        pat: patientData,
        use: userDataMap,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/AddPatient'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(addPatientRequest.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('فشل في إضافة المريض: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('خطأ في إضافة المريض: $e');
      throw Exception('خطأ في إضافة المريض: $e');
    }
  }

  // دالة لتعديل مريض
  static Future<bool> editPatient(PatientEditApi patient) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/EditPatient'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(patient.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('فشل في تعديل المريض: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('خطأ في تعديل المريض: $e');
      throw Exception('خطأ في تعديل المريض: $e');
    }
  }

  // دالة لحذف مريض
  static Future<bool> deletePatient(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/DeletePatient?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('فشل في حذف المريض: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('خطأ في حذف المريض: $e');
      throw Exception('خطأ في حذف المريض: $e');
    }
  }
}