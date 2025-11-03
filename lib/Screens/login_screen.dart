// login_screen.dart
import 'package:flutter/material.dart';
import 'package:orax_hos_sys_app/Screens/patient_screen.dart';
import '../../Models/models.dart';
import '../../Services/services_login.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();

  // القيم الافتراضية للـ ComboBox
  Branch? _selectedBranch;
  User? _selectedUser;

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isLoadingBranches = false;
  bool _isLoadingUsers = false;

  // قائمة الفروع من API
  List<Branch> _branches = [];

  // قائمة المستخدمين من API
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // تهيئة التطبيق
  Future<void> _initializeApp() async {
    await _testConnection();
    await _loadBranches();
  }

  // اختبار الاتصال
  Future<void> _testConnection() async {
    setState(() => _isConnecting = true);

    try {
      final isConnected = await LoginService.testConnection();
      setState(() {
        _isConnected = isConnected;
        _isConnecting = false;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isConnecting = false;
      });
    }
  }

  // جلب الفروع
  Future<void> _loadBranches() async {
    setState(() => _isLoadingBranches = true);

    try {
      final branches = await LoginService.getBranches();
      setState(() {
        _branches = branches;
        _isLoadingBranches = false;
      });
    } catch (e) {
      setState(() => _isLoadingBranches = false);
      _showErrorDialog('فشل في جلب الفروع');
    }
  }

  // جلب المستخدمين
  Future<void> _loadUsers(int branchId) async {
    setState(() {
      _isLoadingUsers = true;
      _selectedUser = null;
      _users = [];
    });

    try {
      final users = await LoginService.getUsersByBranch(branchId);
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _users = [];
        _isLoadingUsers = false;
      });
      _showErrorDialog('فشل في جلب المستخدمين');
    }
  }

  // تسجيل الدخول
  Future<void> _login() async {
    if (_selectedBranch == null ||
        _selectedUser == null ||
        _passwordController.text.isEmpty) {
      _showErrorDialog('يرجى ملء جميع الحقول');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userData = await LoginService.login(_selectedUser!.id);

      if (_passwordController.text == userData.password) {
        // كلمة المرور صحيحة - الانتقال إلى الشاشة الرئيسية

        // طباعة البيانات المرسلة للتحقق
        _printLoginData(userData, _selectedBranch!);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PatientScreen(
              userData: userData,
              selectedBranch: _selectedBranch!,
              selectedUser: _selectedUser!,
            ),
          ),
        );
      } else {
        _showErrorDialog('كلمة المرور خاطئة');
      }
    } catch (e) {
      _showErrorDialog('فشل في تسجيل الدخول: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // دالة لطباعة البيانات المرسلة للتحقق
  void _printLoginData(UserData userData, Branch selectedBranch) {
    print('=== بيانات تسجيل الدخول المرسلة ===');
    print('بيانات المستخدم (UserData):');
    print('- ID: ${userData.id}');
    print('- Username: ${userData.username}');
    print('- EMP: ${userData.emp}');
    print('- Branch No: ${userData.branchNo}');
    print('الفرع المحدد (SelectedBranch):');
    print('- Branch ID: ${selectedBranch.id}');
    print('- Branch Name: ${selectedBranch.name}');
    print('المستخدم المحدد (SelectedUser):');
    print('- User ID: ${_selectedUser!.id}');
    print('- Username: ${_selectedUser!.username}');
    print('- EMP: ${_selectedUser!.emp}');
    print('- Branch No: ${_selectedUser!.branchNo}');
    print('================================');
  }

  // عرض رسالة الخطأ
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildErrorDialog(message),
    );
  }

  // بناء واجهة رسالة الخطأ
  Widget _buildErrorDialog(String message) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة الخطأ
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'خطأ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 25),

              // زر الموافقة
              _buildDialogButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text(
          'موافق',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade700,
              Colors.green.shade500,
              Colors.green.shade300,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildConnectionStatus(),
                      const SizedBox(height: 16),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildBranchDropdown(),
                      const SizedBox(height: 24),
                      _buildUsersDropdown(),
                      const SizedBox(height: 24),
                      _buildPasswordField(),
                      const SizedBox(height: 32),
                      Divider(color: Colors.grey[300], thickness: 1),
                      const SizedBox(height: 24),
                      _buildLoginButton(),
                      const SizedBox(height: 24),
                      // عرض معلومات الاتصال للتحقق
                      _buildDebugInfo(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // إضافة قسم لعرض معلومات الاتصال للتحقق
  Widget _buildDebugInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'معلومات الاتصال:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'حالة الاتصال: ${_isConnected ? 'متصل' : 'غير متصل'}',
          style: TextStyle(
            fontSize: 10,
            color: _isConnected ? Colors.green : Colors.red,
          ),
        ),
        Text(
          'عدد الفروع: ${_branches.length}',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        Text(
          'عدد المستخدمين: ${_users.length}',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        if (_selectedBranch != null)
          Text(
            'الفرع المحدد: ${_selectedBranch!.name} (ID: ${_selectedBranch!.id})',
            style: const TextStyle(fontSize: 10, color: Colors.green),
          ),
        if (_selectedUser != null)
          Text(
            'المستخدم المحدد: ${_selectedUser!.username} (ID: ${_selectedUser!.id}, EMP: ${_selectedUser!.emp})',
            style: const TextStyle(fontSize: 10, color: Colors.green),
          ),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isConnecting
              ? Colors.orange
              : (_isConnected ? Colors.green : Colors.red),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isConnecting)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              Icon(
                _isConnected ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 16,
              ),
            const SizedBox(width: 8),
            Text(
              _isConnecting
                  ? 'جاري الاتصال...'
                  : (_isConnected ? 'متصل' : 'لايوجد اتصال'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Text(
        'تسجيل الدخول',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.green.shade700,
        ),
      ),
    );
  }

  Widget _buildBranchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الفرع',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedBranch == null ? Colors.grey : Colors.green,
                width: _selectedBranch == null ? 1 : 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<Branch>(
                value: _selectedBranch,
                items: _buildBranchItems(),
                onChanged: _isLoadingBranches ? null : _onBranchChanged,
                decoration: InputDecoration(
                  hintText:
                      _isLoadingBranches ? 'جاري التحميل...' : 'اختر الفرع',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: _isLoadingBranches ? Colors.grey[300] : Colors.grey,
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<Branch>> _buildBranchItems() {
    if (_isLoadingBranches) {
      return [
        const DropdownMenuItem(
          value: null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text(
                  'جاري تحميل الفروع...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        )
      ];
    }

    return _branches.map((branch) {
      return DropdownMenuItem(
        value: branch,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${branch.name} (${branch.id})',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      );
    }).toList();
  }

  void _onBranchChanged(Branch? newValue) {
    setState(() {
      _selectedBranch = newValue;
      _selectedUser = null;
    });

    if (newValue != null) {
      _loadUsers(newValue.id);
    } else {
      setState(() => _users = []);
    }
  }

  Widget _buildUsersDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المستخدمين',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedUser == null ? Colors.grey : Colors.green,
                width: _selectedUser == null ? 1 : 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<User>(
                value: _selectedUser,
                items: _buildUserItems(),
                onChanged: _canSelectUser() ? _onUserChanged : null,
                decoration: InputDecoration(
                  hintText: _getUserHintText(),
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: _canSelectUser() ? Colors.grey : Colors.grey[300],
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<User>> _buildUserItems() {
    if (_isLoadingUsers) {
      return [
        const DropdownMenuItem(
          value: null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text(
                  'جاري تحميل المستخدمين...',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        )
      ];
    }

    return _users.map((user) {
      return DropdownMenuItem(
        value: user,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username.isNotEmpty ? user.username : 'اسم غير معروف',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              Text(
                'EMP: ${user.emp}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  bool _canSelectUser() {
    return !_isLoadingUsers && _selectedBranch != null && _users.isNotEmpty;
  }

  String _getUserHintText() {
    if (_selectedBranch == null) return 'اختر الفرع أولاً';
    if (_isLoadingUsers) return 'جاري التحميل...';
    if (_users.isEmpty) return 'لا يوجد مستخدمين';
    return 'اختر المستخدم';
  }

  void _onUserChanged(User? newValue) {
    setState(() => _selectedUser = newValue);
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'كلمة المرور',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          cursor: SystemMouseCursors.text,
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'أدخل كلمة المرور',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _canLogin() ? _login : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'دخـــــــــــول',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  bool _canLogin() {
    return !_isLoading && _selectedBranch != null && _selectedUser != null;
  }
}
