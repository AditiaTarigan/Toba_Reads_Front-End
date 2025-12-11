import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // TAMBAHAN: Controller untuk field baru
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();

  // TAMBAHAN: Variabel untuk jenis kelamin
  String? _selectedJenisKelamin;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // TAMBAHAN: Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1997),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggalLahirController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF457B9D),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOGO
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Image.asset(
                    'assets/images/logo_tobareads.png',
                    height: MediaQuery.of(context).size.height * 0.15,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // TITLE
              const Text(
                "Daftar",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Buat akun Toba Reads sekarang",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),

              const SizedBox(height: 20),

              // ===== CARD FORM =====
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A486B),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInputField(
                        "Nama Lengkap",
                        Icons.person,
                        _nameController,
                      ),
                      const SizedBox(height: 12),

                      _buildInputField(
                        "Email",
                        Icons.email,
                        _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      _buildInputField(
                        "Nomor Telepon",
                        Icons.phone,
                        _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),

                      // TAMBAHAN: Bio Field
                      _buildInputField(
                        "Bio (Opsional)",
                        Icons.info,
                        _bioController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),

                      // TAMBAHAN: Jenis Kelamin Dropdown
                      _buildJenisKelaminDropdown(),
                      const SizedBox(height: 12),

                      // TAMBAHAN: Tanggal Lahir Field dengan Date Picker
                      _buildTanggalLahirField(context),
                      const SizedBox(height: 12),

                      _buildInputField(
                        "Kata Sandi",
                        Icons.lock,
                        _passwordController,
                        obscure: true,
                      ),
                      const SizedBox(height: 12),

                      _buildInputField(
                        "Konfirmasi Kata Sandi",
                        Icons.lock_outline,
                        _confirmPasswordController,
                        obscure: true,
                      ),

                      const SizedBox(height: 25),

                      // ===== BUTTON REGISTER =====
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6DADE7),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  if (_passwordController.text !=
                                      _confirmPasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Kata sandi dan konfirmasi kata sandi tidak cocok",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _isLoading = true;
                                  });

                                  // ✅ PERBAIKI: GUNAKAN NAMED PARAMETERS DENGAN FIELD BARU
                                  final response = await ApiService.register(
                                    _nameController.text,
                                    _emailController.text,
                                    _passwordController.text,
                                    _phoneController.text,
                                    _bioController.text.isEmpty
                                        ? null
                                        : _bioController.text,
                                    _selectedJenisKelamin,
                                    _tanggalLahirController.text.isEmpty
                                        ? null
                                        : _formatDateForApi(
                                            _tanggalLahirController.text,
                                          ),
                                  );

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  if (response['success'] == true) {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool('isLoggedIn', true);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Pendaftaran berhasil! Selamat datang.",
                                        ),
                                      ),
                                    );

                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/home',
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          response['message'] ??
                                              "Pendaftaran gagal",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Daftar",
                                style: TextStyle(fontSize: 18),
                              ),
                      ),

                      const SizedBox(height: 20),

                      // LINK KE LOGIN PAGE
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: const Text(
                          "Sudah punya akun? Masuk",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAMBAHAN: Widget untuk dropdown jenis kelamin
  Widget _buildJenisKelaminDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedJenisKelamin,
      decoration: InputDecoration(
        hintText: "Jenis Kelamin (Opsional)",
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.person_outline, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      dropdownColor: const Color(0xFF2A486B),
      style: const TextStyle(color: Colors.white),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(
            "Pilih Jenis Kelamin",
            style: TextStyle(color: Colors.white70),
          ),
        ),
        DropdownMenuItem(
          value: 'Laki-laki',
          child: Text('Laki-laki', style: TextStyle(color: Colors.white)),
        ),
        DropdownMenuItem(
          value: 'Perempuan',
          child: Text('Perempuan', style: TextStyle(color: Colors.white)),
        ),
      ],
      onChanged: (String? value) {
        setState(() {
          _selectedJenisKelamin = value;
        });
      },
      validator: (value) {
        // Opsional, tidak perlu validasi required
        return null;
      },
    );
  }

  // TAMBAHAN: Widget untuk tanggal lahir dengan date picker
  Widget _buildTanggalLahirField(BuildContext context) {
    return TextFormField(
      controller: _tanggalLahirController,
      readOnly: true, // Agar keyboard tidak muncul
      decoration: InputDecoration(
        hintText: "Tanggal Lahir (Opsional)",
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      onTap: () {
        _selectDate(context);
      },
      validator: (value) {
        // Opsional, tidak perlu validasi required
        return null;
      },
    );
  }

  Widget _buildInputField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        // Hanya validasi required untuk field yang wajib
        if (hint != "Bio (Opsional)" &&
            hint != "Tanggal Lahir (Opsional)" &&
            (value == null || value.isEmpty)) {
          return "$hint tidak boleh kosong";
        }
        return null;
      },
    );
  }

  // TAMBAHAN: Fungsi untuk format tanggal ke API (YYYY-MM-DD)
  String? _formatDateForApi(String date) {
    try {
      List<String> parts = date.split('/');
      if (parts.length == 3) {
        String day = parts[0].padLeft(2, '0');
        String month = parts[1].padLeft(2, '0');
        String year = parts[2];
        return '$year-$month-$day';
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
