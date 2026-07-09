import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5F5), // Match app background color
      appBar: AppBar(
        title: const Text('Help & Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Apply a maximum width constraint for Desktop view
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 800 ? 600 : double.infinity,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHelpItem(
                          icon: Icons.help_outline_rounded,
                          title: 'FAQ',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildHelpItem(
                          icon: Icons.call_outlined,
                          title: 'Contact Us',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildHelpItem(
                          icon: Icons.access_time_rounded,
                          title: 'Order Issues',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildHelpItem(
                          icon: Icons.credit_card_outlined,
                          title: 'Payment Issues',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildHelpItem(
                          icon: Icons.local_shipping_outlined,
                          title: 'Delivery Issues',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildHelpItem(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'App Feedback',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF1C1C1C)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212529),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF3F3F3));
  }
}
