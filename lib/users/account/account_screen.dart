import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_service.dart';
import 'edit_account_screen.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadEmailThenFetch();
  }

  Future<void> _loadEmailThenFetch() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString("userEmail");
    print('📧 Loaded email from SharedPreferences: $userEmail');
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (userEmail != null && userEmail!.isNotEmpty) {
      print('🔍 Fetching user data for email: $userEmail');

      // DEBUG: Cek dulu apakah email valid
      print('📧 Email validation: ${userEmail!.contains('@')}');

      final response = await ApiService.getUserByEmail(userEmail!);

      print('📥 API Response success: ${response['success']}');
      print('📥 API Response data: ${response['data']}');
      print('📥 API Response message: ${response['message']}');

      if (response['success'] == true && response['data'] != null) {
        // PERIKSA STRUKTUR DATA
        print('🔍 Checking data structure...');
        print('   response.keys: ${response.keys}');
        print('   response[data].keys: ${response['data'].keys}');
        print('   response[data][user]: ${response['data']['user']}');

        // Handle berbagai kemungkinan struktur
        Map<String, dynamic> userData = {};

        if (response['data']['user'] != null) {
          userData = Map<String, dynamic>.from(response['data']['user']);
        } else if (response['data'] is Map) {
          userData = Map<String, dynamic>.from(response['data']);
        }

        print('✅ User data parsed: $userData');

        setState(() {
          _userData = userData;
          _isLoading = false;
        });

        // Cache data ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', _userData['nama'] ?? '');
        await prefs.setString('userEmail', _userData['email'] ?? userEmail!);
        await prefs.setString('userPhone', _userData['no_hp'] ?? '');
        await prefs.setString('userBio', _userData['bio'] ?? '');
        await prefs.setString('userGender', _userData['jenis_kelamin'] ?? '');
        await prefs.setString(
          'userBirthDate',
          _userData['tanggal_lahir'] ?? '',
        );
        await prefs.setInt('userId', _userData['id_user'] ?? 0);

        print('💾 Saved to SharedPreferences');
      } else {
        print('❌ API failed: ${response['message']}');
        print('   Falling back to SharedPreferences cache...');
        _loadFromSharedPreferences();
      }
    } else {
      print('⚠️ No email found in SharedPreferences');
      _loadFromSharedPreferences();
    }
  }

  Future<void> _loadFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print('📂 Loading from SharedPreferences cache');

    setState(() {
      _userData = {
        'nama': prefs.getString('userName') ?? 'Nama Pengguna',
        'email': prefs.getString('userEmail') ?? 'email@example.com',
        'no_hp': prefs.getString('userPhone') ?? '',
        'bio': prefs.getString('userBio') ?? 'Semangat!',
        'jenis_kelamin': prefs.getString('userGender') ?? 'Perempuan',
        'tanggal_lahir': prefs.getString('userBirthDate'),
        'id_user': prefs.getInt('userId') ?? 0,
      };
      _isLoading = false;
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '--/--/----';
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "--/--/----";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Akun Saya'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchUserData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.person, size: 50, color: Colors.blue),
                  ),
                  SizedBox(height: 16),
                  Text(
                    _userData['nama'] ?? '',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _userData['email'] ?? '',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 32),

                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow("Bio", _userData['bio']),
                          Divider(),
                          _buildInfoRow(
                            "Jenis Kelamin",
                            _userData['jenis_kelamin'],
                          ),
                          Divider(),
                          _buildInfoRow(
                            "Tanggal Lahir",
                            _formatDate(_userData['tanggal_lahir']),
                          ),
                          Divider(),
                          _buildInfoRow("Email", _userData['email']),
                          Divider(),
                          _buildInfoRow("No HP", _userData['no_hp']),
                          Divider(),
                          _buildInfoRow(
                            "User ID",
                            _userData['id_user'].toString(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Spacer(),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditAccountScreen(userData: _userData),
                        ),
                      ).then((_) => _fetchUserData());
                    },
                    child: Text("Edit Profil"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),

                  SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      _showDeleteDialog();
                    },
                    child: Text(
                      "Hapus Akun",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? "-",
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus Akun"),
        content: Text(
          "Apakah Anda yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            child: Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (userEmail != null) {
      final response = await ApiService.deleteUserByEmail(userEmail!);
      if (response['success'] == true) {
        // Clear SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Navigate to login
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus akun: ${response['message']}'),
          ),
        );
      }
    }
  }
}
