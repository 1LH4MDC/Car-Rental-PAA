import 'package:flutter/material.dart';
import 'package:modul6/models/user_model.dart';
import 'package:modul6/services/auth_service.dart';
import 'package:modul6/widgets/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;
  String _errorMessage = '';

  static const _dark = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final user = await AuthService.getUserData();
      if (user == null) {
        throw Exception('Sesi tidak ditemukan, silakan login ulang');
      }
      if (mounted) setState(() => _user = user);
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorMessage = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Konfirmasi Logout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Profil Saya',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _dark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat profil...')
          : _errorMessage.isNotEmpty
              ? _buildError()
              : _user == null
                  ? const Center(child: Text('Data profil tidak ditemukan'))
                  : _buildBody(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            ),
            const SizedBox(height: 16),
            Text(_errorMessage,
                style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(backgroundColor: _dark,
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final u = _user!;
    final isAdmin = u.role == 'admin';

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: _dark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isAdmin
                          ? [Colors.orange.shade300, Colors.orange.shade600]
                          : [Colors.blue.shade300, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isAdmin ? Colors.orange : Colors.blue)
                            .withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _initials(u.name),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  u.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3),
                ),
                const SizedBox(height: 4),
                Text(
                  u.email,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.65), fontSize: 13),
                ),
                const SizedBox(height: 12),
                // Badge role
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isAdmin
                          ? Colors.orange.shade300
                          : Colors.blue.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isAdmin ? '👑' : '👤',
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        isAdmin ? 'Administrator' : 'Pengguna',
                        style: TextStyle(
                          color: isAdmin
                              ? Colors.orange.shade200
                              : Colors.blue.shade200,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Kartu Informasi Akun ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Informasi Akun'),
                const SizedBox(height: 10),
                _buildCard([
                  _infoRow(
                    icon: Icons.person_rounded,
                    iconColor: Colors.indigo,
                    label: 'Nama Lengkap',
                    value: u.name,
                  ),
                  _divider(),
                  _infoRow(
                    icon: Icons.email_rounded,
                    iconColor: Colors.teal,
                    label: 'Email',
                    value: u.email,
                  ),
                  if (u.phone != null && u.phone!.isNotEmpty) ...[
                    _divider(),
                    _infoRow(
                      icon: Icons.phone_rounded,
                      iconColor: Colors.green,
                      label: 'Nomor HP',
                      value: u.phone!,
                    ),
                  ],
                  _divider(),
                  _infoRow(
                    icon: Icons.shield_rounded,
                    iconColor: isAdmin ? Colors.orange : Colors.blue,
                    label: 'Role',
                    value: isAdmin ? 'Administrator' : 'Pengguna',
                    valueColor: isAdmin ? Colors.orange : Colors.blue,
                  ),
                  if (u.id != null && u.id!.isNotEmpty) ...[
                    _divider(),
                    _infoRow(
                      icon: Icons.fingerprint_rounded,
                      iconColor: Colors.purple,
                      label: 'ID Akun',
                      value: '#${u.id!.length >= 8 ? u.id!.substring(0, 8) : u.id!}',
                      valueColor: Colors.grey.shade500,
                    ),
                  ],
                ]),

                const SizedBox(height: 20),

                _sectionTitle('Status Akun'),
                const SizedBox(height: 10),
                _buildCard([
                  _infoRow(
                    icon: Icons.verified_user_rounded,
                    iconColor: u.isActive ? Colors.green : Colors.red,
                    label: 'Status',
                    value: u.isActive ? 'Aktif' : 'Tidak Aktif',
                    valueColor: u.isActive ? Colors.green : Colors.red,
                  ),
                ]),

                const SizedBox(height: 32),

                // ── Tombol Logout ──────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      elevation: 2,
                      shadowColor: Colors.red.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Widget helpers ───────────────────────────────────────────────────────

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.5),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 68, endIndent: 16, thickness: 0.5);

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}