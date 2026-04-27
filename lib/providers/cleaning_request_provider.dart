// CleaningRequestProvider - Local Demo Version for CLEVO Pro
// Manages cleaning requests with local demo data (no Firebase)

import 'package:flutter/foundation.dart';

class CleaningRequestProvider with ChangeNotifier {
  // Data
  List<CleaningRequestLocal> _requests = [];
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;

  // Getters
  List<CleaningRequestLocal> get requests => _requests;
  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;

  int get newRequestsCount => _requests.where((r) => r.status == 'new').length;
  int get openQuotesCount => _requests.where((r) => r.status == 'sent' || r.status == 'thinking').length;
  int get ordersCount => _orders.length;

  double get totalRevenue => _orders.fold(0.0, (sum, order) {
    final total = order['total'];
    return sum + (total is num ? total.toDouble() : 0.0);
  });

  double get conversionRate {
    if (_requests.isEmpty) return 0.0;
    final accepted = _requests.where((r) => r.status == 'accepted').length;
    return (accepted / _requests.length) * 100;
  }

  // Initialize with demo data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _loadDemoData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _isLoading = false;
    notifyListeners();
  }

  void _loadDemoData() {
    _requests = [
      CleaningRequestLocal(
        id: '1',
        customerName: 'Thomas Weber',
        phone: '+41 79 123 45 67',
        email: 'thomas.weber@email.ch',
        address: 'Winterthurerstrasse 55, 8006 Zürich',
        rooms: 4.5,
        serviceType: 'Endreinigung',
        status: 'new',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CleaningRequestLocal(
        id: '2',
        customerName: 'Maria Müller',
        phone: '+41 78 987 65 43',
        email: 'maria.mueller@email.ch',
        address: 'Bahnhofstrasse 12, 8001 Zürich',
        rooms: 3.5,
        serviceType: 'Wohnungsreinigung',
        status: 'sent',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      CleaningRequestLocal(
        id: '3',
        customerName: 'Hans Schneider',
        phone: '+41 76 555 12 34',
        email: 'hans.schneider@email.ch',
        address: 'Seestrasse 88, 8002 Zürich',
        rooms: 5.5,
        serviceType: 'Grundreinigung',
        status: 'thinking',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CleaningRequestLocal(
        id: '4',
        customerName: 'Lisa Fischer',
        phone: '+41 79 888 99 00',
        email: 'lisa.fischer@email.ch',
        address: 'Limmatstrasse 200, 8005 Zürich',
        rooms: 2.5,
        serviceType: 'Büroreinigung',
        status: 'accepted',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CleaningRequestLocal(
        id: '5',
        customerName: 'Peter Keller',
        phone: '+41 78 111 22 33',
        email: 'peter.keller@email.ch',
        address: 'Badenerstrasse 45, 8004 Zürich',
        rooms: 3.0,
        serviceType: 'Fensterreinigung',
        status: 'new',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      CleaningRequestLocal(
        id: '6',
        customerName: 'Anna Huber',
        phone: '+41 76 444 55 66',
        email: 'anna.huber@email.ch',
        address: 'Hardstrasse 120, 8005 Zürich',
        rooms: 4.0,
        serviceType: 'Endreinigung',
        status: 'new',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      CleaningRequestLocal(
        id: '7',
        customerName: 'Stefan Meyer',
        phone: '+41 79 777 88 99',
        email: 'stefan.meyer@email.ch',
        address: 'Talstrasse 33, 8001 Zürich',
        rooms: 6.0,
        serviceType: 'Grundreinigung',
        status: 'rejected',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    _orders = [
      {
        'id': 'ORD001',
        'order_number': 'AUF-2025-0001',
        'customer_name': 'Lisa Fischer',
        'total': 450.00,
        'status': 'completed',
      },
      {
        'id': 'ORD002',
        'order_number': 'AUF-2025-0002',
        'customer_name': 'Marco Bianchi',
        'total': 680.00,
        'status': 'in_progress',
      },
      {
        'id': 'ORD003',
        'order_number': 'AUF-2025-0003',
        'customer_name': 'Sandra Koch',
        'total': 320.00,
        'status': 'pending',
      },
    ];
  }

  // Update request status
  void updateRequestStatus(String requestId, String newStatus) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(status: newStatus);
      notifyListeners();
    }
  }
}

// Simple local model for cleaning requests
class CleaningRequestLocal {
  final String id;
  final String customerName;
  final String phone;
  final String email;
  final String address;
  final double rooms;
  final String serviceType;
  final String status;
  final DateTime createdAt;

  CleaningRequestLocal({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.address,
    required this.rooms,
    required this.serviceType,
    required this.status,
    required this.createdAt,
  });

  String get statusText {
    switch (status) {
      case 'new':
        return 'Neu';
      case 'sent':
        return 'Gesendet';
      case 'thinking':
        return 'Überlegt';
      case 'accepted':
        return 'Akzeptiert';
      case 'rejected':
        return 'Abgelehnt';
      default:
        return status;
    }
  }

  CleaningRequestLocal copyWith({
    String? id,
    String? customerName,
    String? phone,
    String? email,
    String? address,
    double? rooms,
    String? serviceType,
    String? status,
    DateTime? createdAt,
  }) {
    return CleaningRequestLocal(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      rooms: rooms ?? this.rooms,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
