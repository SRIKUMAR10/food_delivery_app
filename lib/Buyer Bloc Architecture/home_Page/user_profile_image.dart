import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import '../CurvedNavigationBarView/CurvedNavigationBarView.dart';

class user_profile_image extends StatefulWidget {
  const user_profile_image({super.key});

  @override
  State<user_profile_image> createState() => _user_profile_imageState();
}

class _user_profile_imageState extends State<user_profile_image> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _imageUrl;
  bool _isLoading = false;
  double _uploadProgress = 0.0; // 0.0 → 1.0 upload progress

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch existing user data from Firestore
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? user.email ?? '';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _imageUrl = data['imageUrl'];
        });
      } else {
        _emailController.text = user.email ?? '';
      }
    }
  }

  // ── Pick, Compress & Upload Image (Web + Mobile) ────────────────────
  // Uses pure-Dart 'image' package — works on Chrome, Android, iOS.
  Future<void> _pickAndUploadImage() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100, // raw pick; we compress manually below
    );
    if (picked == null) return;

    setState(() {
      _isLoading = true;
      _uploadProgress = 0.0;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showSnack('Please login first.', isError: true);
        return;
      }

      // ── Step 1: Read bytes (XFile.readAsBytes works on Web + Mobile) ───
      final Uint8List originalBytes = await picked.readAsBytes();
      final int originalKB = originalBytes.length ~/ 1024;

      // ── Step 2: Decode + compress with 'image' package (pure Dart) ───
      img.Image? decoded = img.decodeImage(originalBytes);
      if (decoded == null) {
        _showSnack(
          'Could not decode image. Please try another file.',
          isError: true,
        );
        return;
      }

      // Resize so longest side ≤ 800 px (preserves aspect ratio)
      if (decoded.width > 800 || decoded.height > 800) {
        decoded = decoded.width >= decoded.height
            ? img.copyResize(decoded, width: 800)
            : img.copyResize(decoded, height: 800);
      }

      // Encode as JPEG at 75% quality — visually excellent, much smaller
      final Uint8List compressedBytes =
          Uint8List.fromList(img.encodeJpg(decoded, quality: 75));

      debugPrint(
        '📸 ${kIsWeb ? "Web" : "Mobile"} '
        '| Original: ${originalKB}KB '
        '→ Compressed: ${compressedBytes.length ~/ 1024}KB '
        '(saved ${originalKB - compressedBytes.length ~/ 1024}KB)',
      );

      // ── Step 3: Upload to Firebase Storage with live progress ───────
      final Reference ref = _storage.ref('user/image/${user.uid}.jpg');

      final UploadTask uploadTask = ref.putData(
        compressedBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Stream progress → circular indicator + % text on avatar
      uploadTask.snapshotEvents.listen((TaskSnapshot snap) {
        if (!mounted) return;
        final total = snap.totalBytes == 0 ? 1 : snap.totalBytes;
        setState(() => _uploadProgress = snap.bytesTransferred / total);
      });

      await uploadTask;

      // ── Step 4: Get download URL ─────────────────────────────────
      final String downloadUrl = await ref.getDownloadURL();

      // ── Step 5: Update Firestore profile ──────────────────────────
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({'imageUrl': downloadUrl}, SetOptions(merge: true));

      // ── Step 6: Immediately refresh UI with new image ──────────────
      if (mounted) setState(() => _imageUrl = downloadUrl);

      _showSnack('✅ Profile photo updated!', isError: false);
    } catch (e) {
      debugPrint('Upload error: $e');
      _showSnack('❌ Upload failed. Please try again.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  /// Styled snackbar helper
  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Save profile details
  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Firestore-ல் பயனர் விவரங்களை (Email உட்பட) புதுப்பித்தல்
      await _firestore.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      // Step 6: Smooth Navigation with Fade Transition
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, anim, secAnim) =>
              const CurvedNavigationBarView(),
          transitionsBuilder: (context, anim, secAnim, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8F9FA), // Modern Light Background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with Profile Image
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          backgroundImage: _imageUrl != null
                              ? NetworkImage(_imageUrl!)
                              : null,
                          child: _imageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFFADB5BD),
                                )
                              : null,
                        ),
                      ),
                      if (_isLoading)
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: CircularProgressIndicator(
                                    value: _uploadProgress > 0 ? _uploadProgress : null,
                                    color: Colors.white,
                                    strokeWidth: 3,
                                    backgroundColor: Colors.white30,
                                  ),
                                ),
                                if (_uploadProgress > 0) ...
                                  [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(_uploadProgress * 100).toInt()}%',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 5,
                        child: GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF2A39),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _nameController.text.isEmpty
                        ? "Guest User"
                        : _nameController.text,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: const Color(0xFF212529),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _emailController.text,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // Form Fields
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 30),
                  children: [
                    _buildModernField(
                      "Full Name",
                      _nameController,
                      Icons.person_outline,
                    ),
                    _buildModernField(
                      "Email Address",
                      _emailController,
                      Icons.mail_outline,
                    ),
                    _buildModernField(
                      "Phone Number",
                      _phoneController,
                      Icons.phone_android_outlined,
                    ),
                    _buildModernField(
                      "Delivery Address",
                      _addressController,
                      Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    // ── Transactions Button ──────────────────
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TransactionsPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE52121), Color(0xFFFF5252)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE52121).withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'View Transactions',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'உங்கள் payment history',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    // Step 4: Button state disabled during loading
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF2A39),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Save Profile",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      await _auth.signOut();
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CurvedNavigationBarView(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text(
                      "Sign Out",
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFFEF2A39)),
            filled: true,
            fillColor: enabled ? const Color(0xFFF8F9FA) : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
          ),
        ),
        // Step 5: More breathing space between fields
        const SizedBox(height: 28),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TRANSACTIONS PAGE — Full-screen, திறக்கும் போது 'View Transactions' click
// ─────────────────────────────────────────────────────────────────────────────

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  static const _primaryRed = Color(0xFFE52121);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transactions',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade100, height: 1),
        ),
      ),
      body: user == null
          ? _buildNotLoggedIn(context)
          : _buildTransactionList(context, user.uid),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Please login to view transactions',
            style: GoogleFonts.poppins(color: Colors.black45, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading transactions',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        // Empty
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: docs.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildTransactionCard(context, data, index);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primaryRed.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: _primaryRed.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Transactions Yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wallet top-up பண்ணியவுடன்\ntransactions இங்கே தெரியும்',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black38,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Map<String, dynamic> data,
    int index,
  ) {
    final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final String status = data['status'] ?? 'success';
    final String currency = data['currency'] ?? 'INR';

    // createdAt (new schema) or timestamp (legacy)
    final Timestamp? ts =
        data['createdAt'] as Timestamp? ?? data['timestamp'] as Timestamp?;
    final DateTime? date = ts?.toDate();
    final String dateStr = date != null ? _formatDate(date) : 'N/A';
    final bool isSuccess = status == 'success';

    return GestureDetector(
      onTap: () => _showDetailSheet(context, data, amount, status, currency, dateStr),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (index * 60)),
        builder: (ctx, val, child) => Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - val)),
            child: child,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Transaction icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Top-up',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        color: Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount + status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+₹${amount.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSuccess
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSuccess
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.black26,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(
    BuildContext context,
    Map<String, dynamic> data,
    double amount,
    String status,
    String currency,
    String dateStr,
  ) {
    final String paymentId = data['paymentId'] ?? data['title'] ?? 'N/A';
    final bool isSuccess = status == 'success';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 36),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),
            // Success icon
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isSuccess
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess
                    ? Icons.check_circle_rounded
                    : Icons.pending_rounded,
                color: isSuccess ? Colors.green : Colors.orange,
                size: 38,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Transaction Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '+₹${amount.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _detailRow('Amount', '₹${amount.toStringAsFixed(2)}',
                valueColor: Colors.green.shade600),
            _detailRow('Currency', currency),
            _detailRow('Status', status,
                valueColor: isSuccess ? Colors.green.shade600 : Colors.orange),
            _detailRow('Payment ID', paymentId, isSmall: true),
            _detailRow('Date & Time', dateStr),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryRed,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {
    Color? valueColor,
    bool isSmall = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: isSmall ? 11 : 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$min $ampm';
  }
}

