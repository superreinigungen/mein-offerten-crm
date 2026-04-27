/// Modell für eine Offerte
class Quote {
  final String id;
  final String requestId;
  final double price;
  final double suggestedPrice;
  final String? customMessage;
  final DateTime validUntil;
  final DateTime createdAt;
  final DateTime? sentAt;
  final QuoteStatus status;
  final List<QuoteView> views;
  final String? customerFeedback;
  final String? rejectionReason;
  
  // NEU: Positions-System
  final List<QuotePosition> positions;
  final List<String> conditions;

  Quote({
    required this.id,
    required this.requestId,
    required this.price,
    required this.suggestedPrice,
    this.customMessage,
    required this.validUntil,
    required this.createdAt,
    this.sentAt,
    required this.status,
    this.views = const [],
    this.customerFeedback,
    this.rejectionReason,
    this.positions = const [],
    this.conditions = const [],
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      price: (json['price'] as num).toDouble(),
      suggestedPrice: (json['suggested_price'] as num).toDouble(),
      customMessage: json['custom_message'] as String?,
      validUntil: DateTime.parse(json['valid_until'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      status: QuoteStatus.fromString(json['status'] as String? ?? 'draft'),
      views: (json['views'] as List<dynamic>?)
              ?.map((e) => QuoteView.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      customerFeedback: json['customer_feedback'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      positions: (json['positions'] as List<dynamic>?)
              ?.map((e) => QuotePosition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'price': price,
      'suggested_price': suggestedPrice,
      'custom_message': customMessage,
      'valid_until': validUntil.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
      'status': status.name,
      'views': views.map((e) => e.toJson()).toList(),
      'customer_feedback': customerFeedback,
      'rejection_reason': rejectionReason,
      'positions': positions.map((e) => e.toJson()).toList(),
      'conditions': conditions,
    };
  }

  Quote copyWith({
    String? id,
    String? requestId,
    double? price,
    double? suggestedPrice,
    String? customMessage,
    DateTime? validUntil,
    DateTime? createdAt,
    DateTime? sentAt,
    QuoteStatus? status,
    List<QuoteView>? views,
    String? customerFeedback,
    String? rejectionReason,
    List<QuotePosition>? positions,
    List<String>? conditions,
  }) {
    return Quote(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      price: price ?? this.price,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      customMessage: customMessage ?? this.customMessage,
      validUntil: validUntil ?? this.validUntil,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
      status: status ?? this.status,
      views: views ?? this.views,
      customerFeedback: customerFeedback ?? this.customerFeedback,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      positions: positions ?? this.positions,
      conditions: conditions ?? this.conditions,
    );
  }

  /// Generiert den Offerten-Link für den Kunden
  String getQuoteLink() {
    return 'https://superreinigungen.shiny-cleaning.ch/offerte/$id';
  }

  /// Prüft ob die Offerte abgelaufen ist
  bool get isExpired => DateTime.now().isAfter(validUntil);

  /// Berechnet wie oft die Offerte angeschaut wurde
  int get viewCount => views.length;

  /// Gibt die letzte Ansicht zurück
  QuoteView? get lastView => views.isNotEmpty ? views.last : null;

  /// Prüft ob es ein "Hot Lead" ist (3+ Ansichten)
  bool get isHotLead => viewCount >= 3;

  /// Berechnet die Gesamtzeit die der Kunde auf der Offerte verbracht hat
  Duration get totalViewDuration {
    return views.fold(
      Duration.zero,
      (total, view) => total + view.duration,
    );
  }
}

/// Tracking einer Offerten-Ansicht
class QuoteView {
  final String id;
  final DateTime viewedAt;
  final Duration duration;
  final String? device;
  final String? browser;
  final String? location;

  QuoteView({
    required this.id,
    required this.viewedAt,
    required this.duration,
    this.device,
    this.browser,
    this.location,
  });

  factory QuoteView.fromJson(Map<String, dynamic> json) {
    return QuoteView(
      id: json['id'] as String,
      viewedAt: DateTime.parse(json['viewed_at'] as String),
      duration: Duration(seconds: json['duration_seconds'] as int? ?? 0),
      device: json['device'] as String?,
      browser: json['browser'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'viewed_at': viewedAt.toIso8601String(),
      'duration_seconds': duration.inSeconds,
      'device': device,
      'browser': browser,
      'location': location,
    };
  }
}

/// Modell für eine Offerten-Position (Leistung/Zusatzleistung)
class QuotePosition {
  final String id;
  final String name;
  final String? description;
  final double unitPrice;
  final int quantity;
  final bool isAdditional; // true = Zusatzleistung, false = Standard
  
  QuotePosition({
    required this.id,
    required this.name,
    this.description,
    required this.unitPrice,
    required this.quantity,
    required this.isAdditional,
  });
  
  /// Berechnet den Gesamtpreis dieser Position
  double get totalPrice => unitPrice * quantity;
  
  factory QuotePosition.fromJson(Map<String, dynamic> json) {
    return QuotePosition(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      isAdditional: json['is_additional'] as bool,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unit_price': unitPrice,
      'quantity': quantity,
      'is_additional': isAdditional,
    };
  }
  
  QuotePosition copyWith({
    String? id,
    String? name,
    String? description,
    double? unitPrice,
    int? quantity,
    bool? isAdditional,
  }) {
    return QuotePosition(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      isAdditional: isAdditional ?? this.isAdditional,
    );
  }
}

/// Status einer Offerte
enum QuoteStatus {
  draft('draft', 'Entwurf', 0xFF9E9E9E),
  sent('sent', 'Gesendet', 0xFF2196F3),
  viewed('viewed', 'Angeschaut', 0xFFFF9800),
  accepted('accepted', 'Angenommen', 0xFF4CAF50),
  rejected('rejected', 'Abgelehnt', 0xFFF44336),
  thinking('thinking', 'Überdenkt', 0xFF9C27B0),
  expired('expired', 'Abgelaufen', 0xFF9E9E9E);

  final String name;
  final String label;
  final int color;

  const QuoteStatus(this.name, this.label, this.color);

  static QuoteStatus fromString(String value) {
    return QuoteStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => QuoteStatus.draft,
    );
  }
}

/// Ablehnungsgrund-Optionen
enum RejectionReason {
  priceHigh('price_high', 'Preis zu hoch'),
  wrongDate('wrong_date', 'Termin passt nicht'),
  comparing('comparing', 'Vergleiche noch andere Anbieter'),
  needInfo('need_info', 'Brauche mehr Infos'),
  other('other', 'Sonstiger Grund');

  final String name;
  final String label;

  const RejectionReason(this.name, this.label);

  static RejectionReason fromString(String value) {
    return RejectionReason.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RejectionReason.other,
    );
  }
}
