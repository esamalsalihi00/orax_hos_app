// models.dart

class Branch {
  final int id;
  final String name;

  Branch({required this.id, required this.name});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class User {
  final int id;
  final String username;
  final String? password;
  final int User_type;
  final bool IS_Deleted;
  final int emp;
  final int branchNo;

  User({
    required this.id,
    required this.username,
    this.password,
    required this.User_type,
    required this.IS_Deleted,
    required this.emp,
    required this.branchNo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['Id'] ?? json['ID'] ?? 0,
      username: json['username'] ?? json['UserName'] ?? json['name'] ?? '',
      password: json['password'] ?? json['Password'],
      User_type: json['User_type'] ?? json['userType'] ?? json['user_type'] ?? 0,
      IS_Deleted: json['IS_Deleted'] ?? json['isDeleted'] ?? json['is_deleted'] ?? false,
      emp: json['emp'] ?? json['Emp'] ?? json['employeeId'] ?? 0,
      branchNo: json['branchNo'] ?? json['BranchNo'] ?? json['branchId'] ?? json['BranchId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'User_type': User_type,
      'IS_Deleted': IS_Deleted,
      'emp': emp,
      'branchNo': branchNo,
    };
  }
}

class UserData {
  final int id;
  final String username;
  final String password;
  final int User_type;
  final bool IS_Deleted;
  final int emp;
  final int branchNo;
  final String? email;
  final String? phone;

  UserData({
    required this.id,
    required this.username,
    required this.password,
    required this.User_type,
    required this.IS_Deleted,
    required this.emp,
    required this.branchNo,
    this.email,
    this.phone,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      User_type: json['User_type'] ?? 0,
      IS_Deleted: json['IS_Deleted'] ?? false,
      emp: json['emp'] ?? 0,
      branchNo: json['branchNo'] ?? 0,
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'User_type': User_type,
      'IS_Deleted': IS_Deleted,
      'emp': emp,
      'branchNo': branchNo,
      'email': email,
      'phone': phone,
    };
  }
}

// في ملف models.dart - إضافة الموديلات الجديدة
class PatientApi {
  final int srl;
  final int proc_id;
  final String? replication_code;
  final int patNum;
  final String patName;
  final String patAge;
  final int ageUnite;
  final int ageGroup;
  final DateTime? birthDate;
  final String birthPlace;
  final String patAddress;
  final String patMobile;
  final int patTyp;
  final int cardKind;
  final String cardID;
  final DateTime? verdat;
  final String verplace;
  final int branch;
  final int finYear;
  final bool volunteerFlag;
  final bool stopFlag;

  PatientApi({
    required this.srl,
    required this.proc_id,
    this.replication_code,
    required this.patNum,
    required this.patName,
    required this.patAge,
    required this.ageUnite,
    required this.ageGroup,
    this.birthDate,
    required this.birthPlace,
    required this.patAddress,
    required this.patMobile,
    required this.patTyp,
    required this.cardKind,
    required this.cardID,
    this.verdat,
    required this.verplace,
    required this.branch,
    required this.finYear,
    required this.volunteerFlag,
    required this.stopFlag,
  });

  factory PatientApi.fromJson(Map<String, dynamic> json) {
    return PatientApi(
      srl: json['srl'] ?? 0,
      proc_id: json['proc_id'] ?? 0,
      replication_code: json['replication_code'],
      patNum: json['patNum'] ?? 0,
      patName: json['patName'] ?? '',
      patAge: json['patAge'] ?? '',
      ageUnite: json['ageUnite'] ?? 0,
      ageGroup: json['ageGroup'] ?? 0,
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      birthPlace: json['birthPlace'] ?? '',
      patAddress: json['patAddress'] ?? '',
      patMobile: json['patMobile'] ?? '',
      patTyp: json['patTyp'] ?? 0,
      cardKind: json['cardKind'] ?? 0,
      cardID: json['cardID'] ?? '',
      verdat: json['verdat'] != null ? DateTime.parse(json['verdat']) : null,
      verplace: json['verplace'] ?? '',
      branch: json['branch'] ?? 0,
      finYear: json['finYear'] ?? DateTime.now().year,
      volunteerFlag: json['volunteerFlag'] ?? false,
      stopFlag: json['stopFlag'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'srl': srl,
      'proc_id': proc_id,
      'replication_code': replication_code,
      'patNum': patNum,
      'patName': patName,
      'patAge': patAge,
      'ageUnite': ageUnite,
      'ageGroup': ageGroup,
      'birthDate': birthDate?.toIso8601String(),
      'birthPlace': birthPlace,
      'patAddress': patAddress,
      'patMobile': patMobile,
      'patTyp': patTyp,
      'cardKind': cardKind,
      'cardID': cardID,
      'verdat': verdat?.toIso8601String(),
      'verplace': verplace,
      'branch': branch,
      'finYear': finYear,
      'volunteerFlag': volunteerFlag,
      'stopFlag': stopFlag,
    };
  }
}

class PatientEditApi {
  final int proc_id;
  final String replication_code;
  final int patNum;
  final String patName;
  final String patAge;
  final int ageUnite;
  final int ageGroup;
  final DateTime? birthDate;
  final String birthPlace;
  final String patAddress;
  final String patMobile;
  final int patTyp;
  final int cardKind;
  final String cardID;
  final DateTime? verdat;
  final String verplace;
  final int branch;
  final int finYear;
  final bool volunteerFlag;
  final bool stopFlag;

  PatientEditApi({
    required this.proc_id,
    required this.replication_code,
    required this.patNum,
    required this.patName,
    required this.patAge,
    required this.ageUnite,
    required this.ageGroup,
    this.birthDate,
    required this.birthPlace,
    required this.patAddress,
    required this.patMobile,
    required this.patTyp,
    required this.cardKind,
    required this.cardID,
    this.verdat,
    required this.verplace,
    required this.branch,
    required this.finYear,
    required this.volunteerFlag,
    required this.stopFlag,
  });

  Map<String, dynamic> toJson() {
    return {
      'proc_id': proc_id,
      'replication_code': replication_code,
      'patNum': patNum,
      'patName': patName,
      'patAge': patAge,
      'ageUnite': ageUnite,
      'ageGroup': ageGroup,
      'birthDate': birthDate?.toIso8601String(),
      'birthPlace': birthPlace,
      'patAddress': patAddress,
      'patMobile': patMobile,
      'patTyp': patTyp,
      'cardKind': cardKind,
      'cardID': cardID,
      'verdat': verdat?.toIso8601String(),
      'verplace': verplace,
      'branch': branch,
      'finYear': finYear,
      'volunteerFlag': volunteerFlag,
      'stopFlag': stopFlag,
    };
  }
}

// موديل لإضافة مريض جديد (يشمل بيانات المستخدم)
class AddPatientRequest {
  final Map<String, dynamic> pat;
  final Map<String, dynamic> use;

  AddPatientRequest({
    required this.pat,
    required this.use,
  });

  Map<String, dynamic> toJson() {
    return {
      'pat': pat,
      'use': use,
    };
  }
}