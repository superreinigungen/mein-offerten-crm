// Firebase Service Layer for CLEVO Pro
// Provides centralized access to Firestore collections with type safety

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get partners => _firestore.collection('partners');
  CollectionReference get customers => _firestore.collection('customers');
  CollectionReference get requests => _firestore.collection('requests');
  CollectionReference get quotes => _firestore.collection('quotes');
  CollectionReference get orders => _firestore.collection('orders');
  CollectionReference get users => _firestore.collection('users');

  // ===== PARTNERS =====
  
  /// Get all partners (for multi-tenant setup)
  Future<List<Map<String, dynamic>>> getAllPartners() async {
    try {
      final snapshot = await partners.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching partners: $e');
      }
      return [];
    }
  }

  /// Get partner by ID
  Future<Map<String, dynamic>?> getPartnerById(String partnerId) async {
    try {
      final doc = await partners.doc(partnerId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching partner: $e');
      }
      return null;
    }
  }

  // ===== CUSTOMERS =====
  
  /// Get customers for a specific partner
  Future<List<Map<String, dynamic>>> getCustomersByPartner(String partnerId) async {
    try {
      final snapshot = await customers
          .where('partner_id', isEqualTo: partnerId)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching customers: $e');
      }
      return [];
    }
  }

  /// Add new customer
  Future<String?> addCustomer(Map<String, dynamic> customerData) async {
    try {
      final docRef = await customers.add(customerData);
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding customer: $e');
      }
      return null;
    }
  }

  // ===== REQUESTS =====
  
  /// Get requests for a specific partner
  Future<List<Map<String, dynamic>>> getRequestsByPartner(String partnerId) async {
    try {
      final snapshot = await requests
          .where('partner_id', isEqualTo: partnerId)
          .get();
      
      final requestsList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort in memory by created_at (descending)
      requestsList.sort((a, b) {
        final aTime = a['created_at'] as Timestamp?;
        final bTime = b['created_at'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      return requestsList;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching requests: $e');
      }
      return [];
    }
  }

  /// Get requests by status
  Future<List<Map<String, dynamic>>> getRequestsByStatus(
    String partnerId,
    String status,
  ) async {
    try {
      final snapshot = await requests
          .where('partner_id', isEqualTo: partnerId)
          .where('status', isEqualTo: status)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching requests by status: $e');
      }
      return [];
    }
  }

  /// Add new request
  Future<String?> addRequest(Map<String, dynamic> requestData) async {
    try {
      final docRef = await requests.add(requestData);
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding request: $e');
      }
      return null;
    }
  }

  /// Update request status
  Future<bool> updateRequestStatus(String requestId, String newStatus) async {
    try {
      await requests.doc(requestId).update({
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating request status: $e');
      }
      return false;
    }
  }

  // ===== QUOTES =====
  
  /// Get quotes for a specific partner
  Future<List<Map<String, dynamic>>> getQuotesByPartner(String partnerId) async {
    try {
      final snapshot = await quotes
          .where('partner_id', isEqualTo: partnerId)
          .get();
      
      final quotesList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort in memory
      quotesList.sort((a, b) {
        final aTime = a['created_at'] as Timestamp?;
        final bTime = b['created_at'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      return quotesList;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching quotes: $e');
      }
      return [];
    }
  }

  /// Add new quote
  Future<String?> addQuote(Map<String, dynamic> quoteData) async {
    try {
      final docRef = await quotes.add(quoteData);
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding quote: $e');
      }
      return null;
    }
  }

  // ===== ORDERS =====
  
  /// Get orders for a specific partner
  Future<List<Map<String, dynamic>>> getOrdersByPartner(String partnerId) async {
    try {
      final snapshot = await orders
          .where('partner_id', isEqualTo: partnerId)
          .get();
      
      final ordersList = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort in memory
      ordersList.sort((a, b) {
        final aTime = a['created_at'] as Timestamp?;
        final bTime = b['created_at'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      return ordersList;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching orders: $e');
      }
      return [];
    }
  }

  /// Get orders by status
  Future<List<Map<String, dynamic>>> getOrdersByStatus(
    String partnerId,
    String status,
  ) async {
    try {
      final snapshot = await orders
          .where('partner_id', isEqualTo: partnerId)
          .where('status', isEqualTo: status)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching orders by status: $e');
      }
      return [];
    }
  }

  /// Add new order
  Future<String?> addOrder(Map<String, dynamic> orderData) async {
    try {
      final docRef = await orders.add(orderData);
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error adding order: $e');
      }
      return null;
    }
  }

  // ===== USERS =====
  
  /// Get users for a specific partner
  Future<List<Map<String, dynamic>>> getUsersByPartner(String partnerId) async {
    try {
      final snapshot = await users
          .where('partner_id', isEqualTo: partnerId)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching users: $e');
      }
      return [];
    }
  }

  /// Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final snapshot = await users
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        data['id'] = snapshot.docs.first.id;
        return data;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching user by email: $e');
      }
      return null;
    }
  }

  // ===== REALTIME LISTENERS =====
  
  /// Listen to requests in real-time
  Stream<List<Map<String, dynamic>>> streamRequestsByPartner(String partnerId) {
    return requests
        .where('partner_id', isEqualTo: partnerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Listen to orders in real-time
  Stream<List<Map<String, dynamic>>> streamOrdersByPartner(String partnerId) {
    return orders
        .where('partner_id', isEqualTo: partnerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
