// CLEVO Pro - Local Demo Version (No Firebase)
// Completely standalone - no external screen imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cleaning_request_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CLEVOProApp());
}

class CLEVOProApp extends StatelessWidget {
  const CLEVOProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CleaningRequestProvider()..initialize(),
      child: MaterialApp(
        title: 'CLEVO Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

/// Haupt-Screen mit Bottom Navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreenLocal(),
    const RequestsScreenLocal(),
    const OrdersScreenLocal(),
    const StatisticsScreenLocal(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Anfragen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Aufträge',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }
}

// ============ LOCAL SCREENS ============

class DashboardScreenLocal extends StatelessWidget {
  const DashboardScreenLocal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CleaningRequestProvider>(
      builder: (context, provider, _) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0D47A1), Color(0xFF1565C0)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.business, color: Colors.white, size: 32),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CLEVO Pro',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'CRM & Offerten-Management',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            _DemoBadge(),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Stats Row
                        Row(
                          children: [
                            _StatCard(
                              title: 'Neue Anfragen',
                              value: provider.newRequestsCount.toString(),
                              icon: Icons.mail,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              title: 'Offene Offerten',
                              value: provider.openQuotesCount.toString(),
                              icon: Icons.description,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            _StatCard(
                              title: 'Aufträge',
                              value: provider.ordersCount.toString(),
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Recent Requests
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Neueste Anfragen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (provider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (provider.requests.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('Keine Anfragen vorhanden'),
                        ),
                      )
                    else
                      ...provider.requests.take(5).map((req) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(req.status),
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(req.customerName),
                              subtitle: Text(req.address),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(req.status).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  req.statusText,
                                  style: TextStyle(
                                    color: _getStatusColor(req.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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
      default:
        return Colors.grey;
    }
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'DEMO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class RequestsScreenLocal extends StatelessWidget {
  const RequestsScreenLocal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CleaningRequestProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Anfragen'),
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.requests.length,
                    itemBuilder: (context, index) {
                      final req = provider.requests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      req.customerName[0],
                                      style: TextStyle(color: Colors.blue.shade700),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          req.customerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          req.serviceType,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _StatusBadge(status: req.status),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(req.address, style: const TextStyle(fontSize: 13))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(req.phone, style: const TextStyle(fontSize: 13)),
                                  const Spacer(),
                                  const Icon(Icons.home, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text('${req.rooms} Zimmer', style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case 'new':
        color = Colors.blue;
        text = 'NEU';
        break;
      case 'sent':
        color = Colors.orange;
        text = 'GESENDET';
        break;
      case 'thinking':
        color = Colors.purple;
        text = 'ÜBERLEGT';
        break;
      case 'accepted':
        color = Colors.green;
        text = 'AKZEPTIERT';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'ABGELEHNT';
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class OrdersScreenLocal extends StatelessWidget {
  const OrdersScreenLocal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CleaningRequestProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Aufträge'),
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
          ),
          body: provider.orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Keine Aufträge vorhanden', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.orders.length,
                  itemBuilder: (context, index) {
                    final order = provider.orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(Icons.check, color: Colors.green.shade700),
                        ),
                        title: Text(order['customer_name'] ?? 'Unbekannt'),
                        subtitle: Text(order['order_number'] ?? ''),
                        trailing: Text(
                          'CHF ${(order['total'] ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class StatisticsScreenLocal extends StatelessWidget {
  const StatisticsScreenLocal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CleaningRequestProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Statistik'),
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Übersicht',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatTile(
                      title: 'Anfragen',
                      value: provider.requests.length.toString(),
                      icon: Icons.inbox,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _StatTile(
                      title: 'Aufträge',
                      value: provider.orders.length.toString(),
                      icon: Icons.assignment,
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatTile(
                      title: 'Umsatz',
                      value: 'CHF ${provider.totalRevenue.toStringAsFixed(0)}',
                      icon: Icons.euro,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _StatTile(
                      title: 'Conversion',
                      value: '${provider.conversionRate.toStringAsFixed(0)}%',
                      icon: Icons.trending_up,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
