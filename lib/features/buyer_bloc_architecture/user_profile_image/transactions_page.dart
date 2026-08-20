// lib/user_profile_image/transactions_page.dart
//
// Displays the user's transaction history.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/core/services/i_auth_service.dart';
import 'package:food_delivery_app/core/repositories/i_user_profile_repository.dart';
import 'package:food_delivery_app/core/widgets/transaction_history.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<IAuthService>().currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Transactions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: uid == null
          ? _buildNotLoggedIn(context)
          : _buildTransactionList(context, uid),
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
            style: TextStyle(color: Colors.black45, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, String uid) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: context.read<IUserProfileRepository>().watchTransactions(uid),
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
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        // Empty
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const TransactionEmptyState(
            title: 'No Transactions Yet',
            subtitle: 'Transactions will appear here\nonce you top-up your wallet',
          );
        }

        final docs = snapshot.data!;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: docs.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final data = docs[index];
                return TransactionItemCard(
                  data: data,
                  onTap: () => showTransactionDetailSheet(context, data),
                );
              },
            ),
          ),
        );
      },
    );
  }
}