/// Auftrag-Model - Wenn eine Offerte angenommen wird
class Order {
  final String id;
  final String quoteId;
  final String requestId;
  
  // Kundendaten
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  
  // Objektdaten
  final String address;
  final String propertyType;
  final double rooms;
  final String? floor;
  final double? squareMeters;
  
  // Auftragsdaten
  final DateTime cleaningDate;
  final DateTime? handoverDate;
  final double price;
  final List<String> services;
  final List<String> additionalServices;
  
  // Status
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;
  
  // Team-Zuweisung
  final String? assignedTeam;
  final int? estimatedHours;

  Order({
    required this.id,
    required this.quoteId,
    required this.requestId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.address,
    required this.propertyType,
    required this.rooms,
    this.floor,
    this.squareMeters,
    required this.cleaningDate,
    this.handoverDate,
    required this.price,
    required this.services,
    this.additionalServices = const [],
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.notes,
    this.assignedTeam,
    this.estimatedHours,
  });

  /// Tage bis zur Reinigung
  int get daysUntilCleaning {
    final now = DateTime.now();
    return cleaningDate.difference(now).inDays;
  }
  
  /// Ist der Auftrag überfällig?
  bool get isOverdue {
    return status != OrderStatus.completed && 
           cleaningDate.isBefore(DateTime.now());
  }
  
  /// Ist der Auftrag heute?
  bool get isToday {
    final now = DateTime.now();
    return cleaningDate.year == now.year &&
           cleaningDate.month == now.month &&
           cleaningDate.day == now.day;
  }
  
  /// Ist der Auftrag diese Woche?
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return cleaningDate.isAfter(weekStart) && cleaningDate.isBefore(weekEnd);
  }

  Order copyWith({
    String? id,
    String? quoteId,
    String? requestId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? address,
    String? propertyType,
    double? rooms,
    String? floor,
    double? squareMeters,
    DateTime? cleaningDate,
    DateTime? handoverDate,
    double? price,
    List<String>? services,
    List<String>? additionalServices,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? notes,
    String? assignedTeam,
    int? estimatedHours,
  }) {
    return Order(
      id: id ?? this.id,
      quoteId: quoteId ?? this.quoteId,
      requestId: requestId ?? this.requestId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      address: address ?? this.address,
      propertyType: propertyType ?? this.propertyType,
      rooms: rooms ?? this.rooms,
      floor: floor ?? this.floor,
      squareMeters: squareMeters ?? this.squareMeters,
      cleaningDate: cleaningDate ?? this.cleaningDate,
      handoverDate: handoverDate ?? this.handoverDate,
      price: price ?? this.price,
      services: services ?? this.services,
      additionalServices: additionalServices ?? this.additionalServices,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      estimatedHours: estimatedHours ?? this.estimatedHours,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quote_id': quoteId,
      'request_id': requestId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'address': address,
      'property_type': propertyType,
      'rooms': rooms,
      'floor': floor,
      'square_meters': squareMeters,
      'cleaning_date': cleaningDate.toIso8601String(),
      'handover_date': handoverDate?.toIso8601String(),
      'price': price,
      'services': services,
      'additional_services': additionalServices,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
      'assigned_team': assignedTeam,
      'estimated_hours': estimatedHours,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      quoteId: json['quote_id'] as String,
      requestId: json['request_id'] as String,
      customerName: json['customer_name'] as String,
      customerEmail: json['customer_email'] as String,
      customerPhone: json['customer_phone'] as String,
      address: json['address'] as String,
      propertyType: json['property_type'] as String,
      rooms: (json['rooms'] as num).toDouble(),
      floor: json['floor'] as String?,
      squareMeters: (json['square_meters'] as num?)?.toDouble(),
      cleaningDate: DateTime.parse(json['cleaning_date'] as String),
      handoverDate: json['handover_date'] != null 
          ? DateTime.parse(json['handover_date'] as String) 
          : null,
      price: (json['price'] as num).toDouble(),
      services: List<String>.from(json['services'] as List),
      additionalServices: json['additional_services'] != null 
          ? List<String>.from(json['additional_services'] as List)
          : [],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      notes: json['notes'] as String?,
      assignedTeam: json['assigned_team'] as String?,
      estimatedHours: json['estimated_hours'] as int?,
    );
  }
}

/// Auftragsstatus
enum OrderStatus {
  pending,      // Auftrag erstellt, noch nicht begonnen
  confirmed,    // Vom Team bestätigt
  inProgress,   // Reinigung läuft
  completed,    // Abgeschlossen
  cancelled,    // Storniert
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Ausstehend';
      case OrderStatus.confirmed:
        return 'Bestätigt';
      case OrderStatus.inProgress:
        return 'In Arbeit';
      case OrderStatus.completed:
        return 'Erledigt';
      case OrderStatus.cancelled:
        return 'Storniert';
    }
  }
  
  String get emoji {
    switch (this) {
      case OrderStatus.pending:
        return '📋';
      case OrderStatus.confirmed:
        return '✅';
      case OrderStatus.inProgress:
        return '🧹';
      case OrderStatus.completed:
        return '🎉';
      case OrderStatus.cancelled:
        return '❌';
    }
  }
}
