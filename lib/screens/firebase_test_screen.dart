// Firebase Test Screen for CLEVO Pro
// Test Firebase connection and display data from Firestore

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_provider.dart';

class FirebaseTestScreen extends StatelessWidget {
  const FirebaseTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 Firebase Test'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FirebaseProvider>(
        builder: (context, firebaseProvider, child) {
          return RefreshIndicator(
            onRefresh: () => firebaseProvider.loadAllData(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Partner Info Card
                _buildPartnerCard(firebaseProvider),
                const SizedBox(height: 16),

                // Statistics Cards
                _buildStatisticsCard(firebaseProvider),
                const SizedBox(height: 16),

                // Customers Section
                _buildDataSection(
                  title: '👥 Customers',
                  count: firebaseProvider.customers.length,
                  isLoading: firebaseProvider.isLoadingCustomers,
                  items: firebaseProvider.customers,
                  itemBuilder: (customer) => ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      '${customer['first_name']} ${customer['last_name']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(customer['email'] ?? 'No email'),
                    trailing: Text(
                      customer['phone'] ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Requests Section
                _buildDataSection(
                  title: '📋 Requests',
                  count: firebaseProvider.requests.length,
                  isLoading: firebaseProvider.isLoadingRequests,
                  items: firebaseProvider.requests,
                  itemBuilder: (request) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(request['status']),
                      child: const Icon(Icons.cleaning_services, color: Colors.white, size: 20),
                    ),
                    title: Text(
                      request['service_type'] ?? 'Unknown Service',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(request['customer_name'] ?? 'Unknown'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request['status']).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        request['status']?.toUpperCase() ?? 'N/A',
                        style: TextStyle(
                          color: _getStatusColor(request['status']),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quotes Section
                _buildDataSection(
                  title: '💰 Quotes',
                  count: firebaseProvider.quotes.length,
                  isLoading: firebaseProvider.isLoadingQuotes,
                  items: firebaseProvider.quotes,
                  itemBuilder: (quote) => ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.description, color: Colors.white, size: 20),
                    ),
                    title: Text(
                      quote['quote_number'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(quote['customer_name'] ?? 'Unknown'),
                    trailing: Text(
                      'CHF ${(quote['total'] ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Orders Section
                _buildDataSection(
                  title: '📦 Orders',
                  count: firebaseProvider.orders.length,
                  isLoading: firebaseProvider.isLoadingOrders,
                  items: firebaseProvider.orders,
                  itemBuilder: (order) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(order['status']),
                      child: const Icon(Icons.assignment, color: Colors.white, size: 20),
                    ),
                    title: Text(
                      order['order_number'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(order['customer_name'] ?? 'Unknown'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'CHF ${(order['total_amount'] ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order['status']).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            order['status']?.toUpperCase() ?? 'N/A',
                            style: TextStyle(
                              color: _getStatusColor(order['status']),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Users Section
                _buildDataSection(
                  title: '👨‍💼 Users',
                  count: firebaseProvider.users.length,
                  isLoading: firebaseProvider.isLoadingUsers,
                  items: firebaseProvider.users,
                  itemBuilder: (user) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user['role'] == 'admin' 
                          ? Colors.red 
                          : Colors.blue,
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                    title: Text(
                      '${user['first_name']} ${user['last_name']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user['email'] ?? 'No email'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: user['role'] == 'admin' 
                            ? Colors.red.withValues(alpha: 0.2)
                            : Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user['role']?.toUpperCase() ?? 'N/A',
                        style: TextStyle(
                          color: user['role'] == 'admin' ? Colors.red : Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartnerCard(FirebaseProvider provider) {
    final partner = provider.currentPartner;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.blue, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Partner',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        partner?['company_name'] ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (partner != null) ...[
              const Divider(height: 24),
              _buildInfoRow('Contact', partner['contact_person'] ?? 'N/A'),
              _buildInfoRow('Email', partner['email'] ?? 'N/A'),
              _buildInfoRow('Phone', partner['phone'] ?? 'N/A'),
              _buildInfoRow('Plan', partner['subscription_plan']?.toUpperCase() ?? 'N/A'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(FirebaseProvider provider) {
    final requestStats = provider.getRequestStatistics();
    final orderStats = provider.getOrderStatistics();
    final revenue = provider.getTotalRevenue();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Requests',
                    requestStats['total'].toString(),
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Orders',
                    orderStats['total'].toString(),
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Revenue',
                    'CHF ${revenue.toStringAsFixed(0)}',
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection({
    required String title,
    required int count,
    required bool isLoading,
    required List<Map<String, dynamic>> items,
    required Widget Function(Map<String, dynamic>) itemBuilder,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No data available'),
              ),
            )
          else
            ...items.take(5).map((item) => itemBuilder(item)),
          if (items.length > 5)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Text(
                  '+ ${items.length - 5} more',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'sent':
        return Colors.orange;
      case 'thinking':
        return Colors.purple;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
