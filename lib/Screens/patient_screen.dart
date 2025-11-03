// patient_screen.dart
import 'package:flutter/material.dart';
import 'package:orax_hos_sys_app/Models/models.dart';
import 'package:orax_hos_sys_app/Services/patient_service.dart';

class PatientScreen extends StatefulWidget {
  final UserData userData;
  final Branch selectedBranch;
  final User selectedUser;

  const PatientScreen({
    super.key,
    required this.userData,
    required this.selectedBranch,
    required this.selectedUser,
  });

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  List<PatientApi> patients = [];
  bool isLoading = true;
  String errorMessage = '';

  // متغيرات للتحكم في النماذج
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _cardIdController = TextEditingController();
  final TextEditingController _verplaceController = TextEditingController();

  int? _selectedAgeUnit;
  int? _selectedAgeGroup;
  int? _selectedGender;
  int? _selectedCardKind;
  bool _selectedVolunteer = false;
  bool _selectedStatus = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _printUserInfo();
  }

  // دالة لطباعة معلومات المستخدم للتحقق
  void _printUserInfo() {
    print('=== معلومات المستخدم في شاشة المرضى ===');
    print('UserData - ID: ${widget.userData.id}');
    print('UserData - Username: ${widget.userData.username}');
    print('UserData - EMP: ${widget.userData.emp}');
    print('UserData - BranchNo: ${widget.userData.branchNo}');
    print('SelectedBranch - ID: ${widget.selectedBranch.id}');
    print('SelectedBranch - Name: ${widget.selectedBranch.name}');
    print('SelectedUser - ID: ${widget.selectedUser.id}');
    print('SelectedUser - EMP: ${widget.selectedUser.emp}');
    print('====================================');
  }

  // دالة تحميل المرضى من API
  Future<void> _loadPatients() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final patientsList = await PatientService.getAllPatients();
      setState(() {
        patients = patientsList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      _showErrorSnackBar('فشل في تحميل البيانات: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _birthPlaceController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    _cardIdController.dispose();
    _verplaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('إدارة المرضى'),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showUserAndBranchInfo,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPatientDialog,
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'خطأ في تحميل البيانات',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPatients,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return patients.isEmpty ? _buildEmptyState() : _buildPatientsGrid();
  }

  void _showUserAndBranchInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات المستخدم والفرع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات المستخدم:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('اسم المستخدم: ${widget.userData.username}'),
            Text('رقم المستخدم: ${widget.userData.id}'),
            Text('رقم الموظف (EMP): ${widget.userData.emp}'),
            Text('فرع المستخدم: ${widget.userData.branchNo}'),
            const SizedBox(height: 10),
            const Text(
              'معلومات الفرع المحدد:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('اسم الفرع: ${widget.selectedBranch.name}'),
            Text('رقم الفرع: ${widget.selectedBranch.id}'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.selectedBranch.id == widget.userData.branchNo
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.selectedBranch.id == widget.userData.branchNo
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              child: Text(
                widget.selectedBranch.id == widget.userData.branchNo
                    ? '✓ الفرع متطابق مع فرع المستخدم'
                    : '⚠ الفرع مختلف عن فرع المستخدم',
                style: TextStyle(
                  color: widget.selectedBranch.id == widget.userData.branchNo
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'لا يوجد مرضى',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _showAddPatientDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('إضافة مريض جديد'),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'معلومات المستخدم والفرع',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('المستخدم: ${widget.userData.username}'),
                  Text('EMP: ${widget.userData.emp}'),
                  Text('الفرع: ${widget.selectedBranch.name}'),
                  Text('رقم الفرع: ${widget.selectedBranch.id}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsGrid() {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'المستخدم: ${widget.userData.username} (EMP: ${widget.userData.emp})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الفرع: ${widget.selectedBranch.name} (${widget.selectedBranch.id})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: patients.length,
              itemBuilder: (context, index) {
                return _buildPatientCard(patients[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(PatientApi patient) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showPatientDetails(patient),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green.shade100,
                child: Icon(
                  patient.patTyp == 1 ? Icons.man : Icons.woman,
                  size: 30,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                patient.patName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    patient.patMobile,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'الفرع: ${patient.branch}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: patient.stopFlag
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  patient.stopFlag ? 'موقف' : 'نشط',
                  style: TextStyle(
                    fontSize: 10,
                    color: patient.stopFlag ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPatientDetails(PatientApi patient) {
    showDialog(
      context: context,
      builder: (context) => _buildPatientDialog(patient),
    );
  }

  Widget _buildPatientDialog(PatientApi patient) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'بيانات المريض',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'معلومات الفرع',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text('الفرع المحدد: ${widget.selectedBranch.name}'),
                      Text('رقم الفرع المحدد: ${widget.selectedBranch.id}'),
                      Text('رقم فرع المريض: ${patient.branch}'),
                      const SizedBox(height: 5),
                      Text(
                        patient.branch == widget.selectedBranch.id
                            ? '✓ الفرع متطابق'
                            : '✗ الفرع غير متطابق',
                        style: TextStyle(
                          color: patient.branch == widget.selectedBranch.id
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('الاسم', patient.patName),
                _buildDetailRow('العمر', '${patient.patAge} ${_getAgeUnitText(patient.ageUnite)}'),
                _buildDetailRow('الفئة العمرية', _getAgeGroupText(patient.ageGroup)),
                _buildDetailRow('مكان الميلاد', patient.birthPlace),
                _buildDetailRow('العنوان', patient.patAddress),
                _buildDetailRow('رقم الهاتف', patient.patMobile),
                _buildDetailRow('النوع', _getGenderText(patient.patTyp)),
                _buildDetailRow('نوع الهوية', _getCardKindText(patient.cardKind)),
                _buildDetailRow('رقم الهوية', patient.cardID),
                _buildDetailRow('جهة الإصدار', patient.verplace),
                _buildDetailRow('السنة المالية', patient.finYear.toString()),
                _buildDetailRow('حالة التبرع', patient.volunteerFlag ? 'متبرع' : 'غير متبرع'),
                _buildDetailRow('حالة المريض', patient.stopFlag ? 'موقف' : 'نشط'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _editPatient(patient);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('تعديل'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _deletePatient(patient),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('حذف'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$title:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دوال التحويل من قيمة إلى نص
  String _getAgeUnitText(int ageUnit) {
    switch (ageUnit) {
      case 1:
        return 'يوم';
      case 2:
        return 'شهر';
      case 3:
        return 'سنة';
      default:
        return 'غير محدد';
    }
  }

  String _getAgeGroupText(int ageGroup) {
    switch (ageGroup) {
      case 1:
        return 'خدج';
      case 2:
        return 'رضيع';
      case 3:
        return 'طفل';
      case 4:
        return 'مراهقة';
      case 5:
        return 'شباب';
      case 6:
        return 'كبار السن';
      default:
        return 'غير محدد';
    }
  }

  String _getGenderText(int gender) {
    switch (gender) {
      case 1:
        return 'ذكر';
      case 2:
        return 'أنثى';
      default:
        return 'غير محدد';
    }
  }

  String _getCardKindText(int cardKind) {
    switch (cardKind) {
      case 1:
        return 'هوية شخصية';
      case -1:
        return 'هوية إقامة';
      default:
        return 'غير محدد';
    }
  }

  // دوال الإضافة والتعديل والحذف
  void _showAddPatientDialog() {
    _resetForm();
    _showPatientFormDialog(isEditing: false);
  }

  void _editPatient(PatientApi patient) {
    _fillFormWithPatientData(patient);
    _showPatientFormDialog(isEditing: true, patient: patient);
  }

  void _showPatientFormDialog({bool isEditing = false, PatientApi? patient}) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return _buildPatientFormDialog(isEditing, patient, setState);
        },
      ),
    );
  }

  Widget _buildPatientFormDialog(bool isEditing, PatientApi? patient, StateSetter setState) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    isEditing ? 'تعديل بيانات المريض' : 'إضافة مريض جديد',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField('اسم المريض', _nameController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField('العمر', _ageController, keyboardType: TextInputType.number),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _buildAgeUnitDropdown(setState),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAgeGroupDropdown(setState),
                const SizedBox(height: 16),
                _buildTextField('مكان الميلاد', _birthPlaceController),
                const SizedBox(height: 16),
                _buildTextField('العنوان', _addressController),
                const SizedBox(height: 16),
                _buildTextField('رقم الهاتف', _mobileController, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildGenderDropdown(),
                const SizedBox(height: 16),
                _buildCardKindDropdown(),
                const SizedBox(height: 16),
                _buildTextField('رقم الهوية', _cardIdController),
                const SizedBox(height: 16),
                _buildTextField('جهة الإصدار', _verplaceController),
                const SizedBox(height: 16),
                _buildYearField(),
                const SizedBox(height: 16),
                _buildVolunteerDropdown(),
                const SizedBox(height: 16),
                _buildStatusDropdown(),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
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
                    onPressed: () => _savePatient(isEditing, patient),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'تعديل' : 'إضافة',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }

  Widget _buildAgeUnitDropdown(StateSetter setState) {
    List<DropdownMenuItem<int>> ageUnitItems = [];
    
    int? age = int.tryParse(_ageController.text);
    
    if (age == null || age <= 30) {
      ageUnitItems.add(const DropdownMenuItem(value: 1, child: Text('يوم')));
    }
    if (age == null || age <= 12) {
      ageUnitItems.add(const DropdownMenuItem(value: 2, child: Text('شهر')));
    }
    ageUnitItems.add(const DropdownMenuItem(value: 3, child: Text('سنة')));

    return DropdownButtonFormField<int>(
      value: _selectedAgeUnit,
      items: ageUnitItems,
      onChanged: (value) {
        setState(() {
          _selectedAgeUnit = value;
          _updateAgeGroup(setState);
        });
      },
      decoration: InputDecoration(
        labelText: 'الوحدة العمرية',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildAgeGroupDropdown(StateSetter setState) {
    List<DropdownMenuItem<int>> ageGroupItems = [];
    
    if (_selectedAgeUnit == 1) {
      ageGroupItems.add(const DropdownMenuItem(value: 1, child: Text('خدج')));
    } else if (_selectedAgeUnit == 2) {
      ageGroupItems.add(const DropdownMenuItem(value: 2, child: Text('رضيع')));
    } else if (_selectedAgeUnit == 3) {
      int? age = int.tryParse(_ageController.text);
      if (age != null) {
        if (age >= 1 && age <= 12) {
          ageGroupItems.add(const DropdownMenuItem(value: 3, child: Text('طفل')));
        }
        if (age >= 12 && age <= 17) {
          ageGroupItems.add(const DropdownMenuItem(value: 4, child: Text('مراهقة')));
        }
        if (age >= 17 && age <= 65) {
          ageGroupItems.add(const DropdownMenuItem(value: 5, child: Text('شباب')));
        }
        if (age > 65 && age <= 100) {
          ageGroupItems.add(const DropdownMenuItem(value: 6, child: Text('كبار السن')));
        }
      }
    }

    return DropdownButtonFormField<int>(
      value: _selectedAgeGroup,
      items: ageGroupItems,
      onChanged: (value) {
        setState(() {
          _selectedAgeGroup = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'الفئة العمرية',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedGender,
      items: const [
        DropdownMenuItem(value: 1, child: Text('ذكر')),
        DropdownMenuItem(value: 2, child: Text('أنثى')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'النوع',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCardKindDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCardKind,
      items: const [
        DropdownMenuItem(value: 1, child: Text('هوية شخصية')),
        DropdownMenuItem(value: -1, child: Text('هوية إقامة')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCardKind = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'نوع الهوية',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildYearField() {
    return TextField(
      enabled: false,
      decoration: InputDecoration(
        labelText: 'السنة المالية',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
      controller: TextEditingController(text: DateTime.now().year.toString()),
    );
  }

  Widget _buildVolunteerDropdown() {
    return DropdownButtonFormField<bool>(
      value: _selectedVolunteer,
      items: const [
        DropdownMenuItem(value: true, child: Text('متبرع')),
        DropdownMenuItem(value: false, child: Text('غير متبرع')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedVolunteer = value!;
        });
      },
      decoration: InputDecoration(
        labelText: 'حالة التبرع',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<bool>(
      value: _selectedStatus,
      items: const [
        DropdownMenuItem(value: false, child: Text('نشط')),
        DropdownMenuItem(value: true, child: Text('موقف')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value!;
        });
      },
      decoration: InputDecoration(
        labelText: 'حالة المريض',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _updateAgeGroup(StateSetter setState) {
    if (_selectedAgeUnit == 3) {
      int? age = int.tryParse(_ageController.text);
      if (age != null) {
        if (age >= 1 && age <= 12) {
          _selectedAgeGroup = 3;
        } else if (age >= 12 && age <= 17) {
          _selectedAgeGroup = 4;
        } else if (age >= 17 && age <= 65) {
          _selectedAgeGroup = 5;
        } else if (age > 65 && age <= 100) {
          _selectedAgeGroup = 6;
        }
        setState(() {});
      }
    }
  }

  Future<void> _savePatient(bool isEditing, PatientApi? patient) async {
    if (_validateForm()) {
      try {
        if (isEditing && patient != null) {
          // تعديل المريض
          final patientEdit = PatientEditApi(
            proc_id: patient.proc_id,
            replication_code: patient.replication_code ?? '',
            patNum: patient.patNum,
            patName: _nameController.text,
            patAge: _ageController.text,
            ageUnite: _selectedAgeUnit!,
            ageGroup: _selectedAgeGroup!,
            birthDate: patient.birthDate,
            birthPlace: _birthPlaceController.text,
            patAddress: _addressController.text,
            patMobile: _mobileController.text,
            patTyp: _selectedGender!,
            cardKind: _selectedCardKind!,
            cardID: _cardIdController.text,
            verdat: patient.verdat,
            verplace: _verplaceController.text,
            branch: widget.selectedBranch.id,
            finYear: DateTime.now().year,
            volunteerFlag: _selectedVolunteer,
            stopFlag: _selectedStatus,
          );

          final success = await PatientService.editPatient(patientEdit);
          if (success) {
            Navigator.of(context).pop();
            _loadPatients();
            _showSuccessSnackBar('تم تعديل المريض بنجاح');
          } else {
            _showErrorSnackBar('فشل في تعديل المريض');
          }
        } else {
          // إضافة مريض جديد
          final newPatient = PatientApi(
            srl: 0,
            proc_id: 0,
            replication_code: null,
            patNum: 0, // سيقوم السيرفر بتوليد الرقم
            patName: _nameController.text,
            patAge: _ageController.text,
            ageUnite: _selectedAgeUnit!,
            ageGroup: _selectedAgeGroup!,
            birthDate: null,
            birthPlace: _birthPlaceController.text,
            patAddress: _addressController.text,
            patMobile: _mobileController.text,
            patTyp: _selectedGender!,
            cardKind: _selectedCardKind!,
            cardID: _cardIdController.text,
            verdat: null,
            verplace: _verplaceController.text,
            branch: widget.selectedBranch.id,
            finYear: DateTime.now().year,
            volunteerFlag: _selectedVolunteer,
            stopFlag: _selectedStatus,
          );

          final success = await PatientService.addPatient(newPatient, widget.userData);
          if (success) {
            Navigator.of(context).pop();
            _loadPatients();
            _showSuccessSnackBar('تم إضافة المريض بنجاح');
          } else {
            _showErrorSnackBar('فشل في إضافة المريض');
          }
        }
      } catch (e) {
        _showErrorSnackBar('حدث خطأ: $e');
      }
    }
  }

  bool _validateForm() {
    if (_nameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _selectedAgeUnit == null ||
        _selectedAgeGroup == null ||
        _birthPlaceController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _selectedGender == null ||
        _selectedCardKind == null ||
        _cardIdController.text.isEmpty ||
        _verplaceController.text.isEmpty) {
      _showErrorSnackBar('يرجى ملء جميع الحقول');
      return false;
    }
    return true;
  }

  void _resetForm() {
    _nameController.clear();
    _ageController.clear();
    _birthPlaceController.clear();
    _addressController.clear();
    _mobileController.clear();
    _cardIdController.clear();
    _verplaceController.clear();
    _selectedAgeUnit = null;
    _selectedAgeGroup = null;
    _selectedGender = null;
    _selectedCardKind = null;
    _selectedVolunteer = false;
    _selectedStatus = false;
  }

  void _fillFormWithPatientData(PatientApi patient) {
    _nameController.text = patient.patName;
    _ageController.text = patient.patAge;
    _birthPlaceController.text = patient.birthPlace;
    _addressController.text = patient.patAddress;
    _mobileController.text = patient.patMobile;
    _cardIdController.text = patient.cardID;
    _verplaceController.text = patient.verplace;
    _selectedAgeUnit = patient.ageUnite;
    _selectedAgeGroup = patient.ageGroup;
    _selectedGender = patient.patTyp;
    _selectedCardKind = patient.cardKind;
    _selectedVolunteer = patient.volunteerFlag;
    _selectedStatus = patient.stopFlag;
  }

  Future<void> _deletePatient(PatientApi patient) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المريض'),
        content: Text('هل أنت متأكد من حذف المريض ${patient.patName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final success = await PatientService.deletePatient(patient.patNum);
                if (success) {
                  Navigator.of(context).pop();
                  _loadPatients();
                  _showSuccessSnackBar('تم حذف المريض ${patient.patName}');
                } else {
                  _showErrorSnackBar('فشل في حذف المريض');
                }
              } catch (e) {
                _showErrorSnackBar('حدث خطأ أثناء الحذف: $e');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}