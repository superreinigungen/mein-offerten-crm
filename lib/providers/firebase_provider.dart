// Firebase Provider for CLEVO Pro
// Manages Firebase data state with Provider pattern

import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';

class FirebaseProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  // Current partner (for multi-tenant support)
  String _currentPartnerId = 'PARTNER_001'; // Default demo partner
  Map<String, dynamic>? _currentPartner;

  // Data lists
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _quotes = [];
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _users = [];

  // Loading states
  bool _isLoadingCustomers = false;
  bool _isLoadingRequests = false;
  bool _isLoadingQuotes = false;
  bool _isLoadingOrders = false;
  bool _isLoadingUsers = false;

  // Getters
  String get currentPartnerId => _currentPartnerId;
  Map<String, dynamic>? get currentPartner => _currentPartner;
  List<Map<String, dynamic>> get customers => _customers;
  List<Map<String, dynamic>> get requests => _requests;
  List<Map<String, dynamic>> get quotes => _quotes;
  List<Map<String, dynamic>> get orders => _orders;
  List<Map<String, dynamic>> get users => _users;

  bool get isLoadingCustomers => _isLoadingCustomers;
  bool get isLoadingRequests => _isLoadingRequests;
  bool get isLoadingQuotes => _isLoadingQuotes;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isLoadingUsers => _isLoadingUsers;

  // Initialize provider
  Future<void> initialize() async {
    await loadCurrentPartner();
    await loadAllData();
  }

  // Load current partner information
  Future<void> loadCurrentPartner() async {
    try {
      _currentPartner = await _firebaseService.getPartnerById(_currentPartnerId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading current partner: $e');
      }
    }
  }

  // Load all data for current partner
  Future<void> loadAllData() async {
    await Future.wait([
      loadCustomers(),
      loadRequests(),
      loadQuotes(),
      loadOrders(),
      loadUsers(),
    ]);
  }

  // ===== CUSTOMERS =====

  Future<void> loadCustomers() async {
    _isLoadingCustomers = true;
    notifyListeners();

    try {
      _customers = await _firebaseService.getCustomersByPartner(_currentPartnerId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading customers: $e');
      }
      _customers = [];
    } finally {
      _isLoadingCustomers = false;
      notifyListeners();
    }
  }

  Future<bool> addCustomer(Map<String, dynamic> customerData) async {
    try {
      final customerId = await _firebaseService.addCustomer(customerData);
      if (customerId != null) {
        await loadCustomers(); // Reload list
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding customer: $e');
      }
      return false;
    }
  }

  // ===== REQUESTS =====

  Future<void> loadRequests() async {
    _isLoadingRequests = true;
    notifyListeners();

    try {
      _requests = await _firebaseService.getRequestsByPartner(_currentPartnerId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading requests: $e');
      }
      _requests = [];
    } finally {
      _isLoadingRequests = false;
      notifyListeners();
    }
  }

  /// Get requests by status
  List<Map<String, dynamic>> getRequestsByStatus(String status) {
    return _requests.where((req) => req['status'] == status).toList();
  }

  Future<bool> addRequest(Map<String, dynamic> requestData) async {
    try {
      final requestId = await _firebaseService.addRequest(requestData);
      if (requestId != null) {
        await loadRequests(); // Reload list
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding request: $e');
      }
      return false;
    }
  }

  Future<bool> updateRequestStatus(String requestId, String newStatus) async {
    try {
      final success = await _firebaseService.updateRequestStatus(requestId, newStatus);
      if (success) {
        await loadRequests(); // Reload list
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating request status: $e');
      }
      return false;
    }
  }

  // ===== QUOTES =====

  Future<void> loadQuotes() async {
    _isLoadingQuotes = true;
    notifyListeners();

    try {
      _quotes = await _firebaseService.getQuotesByPartner(_currentPartnerId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading quotes: $e');
      }
      _quotes = [];
    } finally {
      _isLoadingQuotes = false;
      notifyListeners();
    }
  }

  Future<bool> addQuote(Map<String, dynamic> quoteData) async {
    try {
      final quoteId = await _firebaseService.addQuote(quoteData);
      if (quoteId != null) {
        await loadQuotes(); // Reload list
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding quote: $e');
      }
      return false;
    }
  }

  // ===== ORDERS =====

  Future<void> loadOrders() async {
    _isLoadingOrders = true;
    notifyListeners();

    try {
      _orders = await _firebaseService.getOrdersByPartner(_currentPartnerId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading orders: $e');
      }
      _orders = [];
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  /// Get orders by status
  List<Map<String, dynamic>> getOrdersByStatus(String status) {
    return _orders.where((order) => order['status'] == status).toList();
  }

  Future<bool> addOrder(Map<String, dynamic> orderData) async {
    try {
      final orderId = await _firebaseService.addOrder(orderData);
      if (orderId != null) {
        await loadOrders(); // Reload list
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding order: $e');
      }
      return false;
    }
  }

  // ===== USERS =====

  Future<void> loadUsers() async {
    _isLoadingUsers = true;
    notifyListeners();

    try {
      _users = await _firebaseService.getUsersByPartner(_currentPartnerId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading users: $e');
      }
      _users = [];
    } finally {
      _isLoadingUsers = false;
      notifyListeners();
    }
  }

  // ===== STATISTICS =====

  /// Get request statistics
  Map<String, int> getRequestStatistics() {
    return {
      'total': _requests.length,
      'new': _requests.where((r) => r['status'] == 'new').length,
      'sent': _requests.where((r) => r['status'] == 'sent').length,
      'thinking': _requests.where((r) => r['status'] == 'thinking').length,
      'accepted': _requests.where((r) => r['status'] == 'accepted').length,
      'rejected': _requests.where((r) => r['status'] == 'rejected').length,
    };
  }

  /// Get order statistics
  Map<String, int> getOrderStatistics() {
    return {
      'total': _orders.length,
      'pending': _orders.where((o) => o['status'] == 'pending').length,
      'in_progress': _orders.where((o) => o['status'] == 'in_progress').length,
      'completed': _orders.where((o) => o['status'] == 'completed').length,
      'cancelled': _orders.where((o) => o['status'] == 'cancelled').length,
    };
  }

  /// Get total revenue from completed orders
  double getTotalRevenue() {
    return _orders
        .where((order) => order['status'] == 'completed')
        .fold(0.0, (sum, order) {
      final amount = order['total_amount'];
      if (amount is num) {
        return sum + amount.toDouble();
      }
      return sum;
    });
  }
}
