/// Modell für eine Reinigungsanfrage von der Website
class CleaningRequest {
  final String id;
  final String customerName;
  final String phoneNumber;
  final String email;
  final String address;
  final double roomCount; // 3.5 Zimmer etc.
  final String objectType; // Wohnung, Haus, etc.
  final String areaRange; // 130-150 m²
  final DateTime cleaningDate;
  final DateTime? inspectionDate; // Abnahmetermin
  final DirtLevel dirtLevel;
  final List<AdditionalService> additionalServices;
  final bool wantsInspection;
  final String preferredContact; // email, whatsapp, pdf
  final DateTime createdAt;
  final RequestStatus status;
  final String? notes;

  CleaningRequest({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.roomCount,
    required this.objectType,
    required this.areaRange,
    required this.cleaningDate,
    this.inspectionDate,
    required this.dirtLevel,
    required this.additionalServices,
    required this.wantsInspection,
    required this.preferredContact,
    required this.createdAt,
    required this.status,
    this.notes,
  });

  factory CleaningRequest.fromJson(Map<String, dynamic> json) {
    return CleaningRequest(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      roomCount: (json['room_count'] as num).toDouble(),
      objectType: json['object_type'] as String,
      areaRange: json['area_range'] as String,
      cleaningDate: DateTime.parse(json['cleaning_date'] as String),
      inspectionDate: json['inspection_date'] != null
          ? DateTime.parse(json['inspection_date'] as String)
          : null,
      dirtLevel: DirtLevel.fromJson(json['dirt_level'] as Map<String, dynamic>),
      additionalServices: (json['additional_services'] as List<dynamic>?)
              ?.map((e) => AdditionalService.fromString(e as String))
              .toList() ??
          [],
      wantsInspection: json['wants_inspection'] as bool? ?? false,
      preferredContact: json['preferred_contact'] as String? ?? 'email',
      createdAt: DateTime.parse(json['created_at'] as String),
      status: RequestStatus.fromString(json['status'] as String? ?? 'new'),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'room_count': roomCount,
      'object_type': objectType,
      'area_range': areaRange,
      'cleaning_date': cleaningDate.toIso8601String(),
      'inspection_date': inspectionDate?.toIso8601String(),
      'dirt_level': dirtLevel.toJson(),
      'additional_services':
          additionalServices.map((e) => e.name).toList(),
      'wants_inspection': wantsInspection,
      'preferred_contact': preferredContact,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'notes': notes,
    };
  }

  CleaningRequest copyWith({
    String? id,
    String? customerName,
    String? phoneNumber,
    String? email,
    String? address,
    double? roomCount,
    String? objectType,
    String? areaRange,
    DateTime? cleaningDate,
    DateTime? inspectionDate,
    DirtLevel? dirtLevel,
    List<AdditionalService>? additionalServices,
    bool? wantsInspection,
    String? preferredContact,
    DateTime? createdAt,
    RequestStatus? status,
    String? notes,
  }) {
    return CleaningRequest(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      roomCount: roomCount ?? this.roomCount,
      objectType: objectType ?? this.objectType,
      areaRange: areaRange ?? this.areaRange,
      cleaningDate: cleaningDate ?? this.cleaningDate,
      inspectionDate: inspectionDate ?? this.inspectionDate,
      dirtLevel: dirtLevel ?? this.dirtLevel,
      additionalServices: additionalServices ?? this.additionalServices,
      wantsInspection: wantsInspection ?? this.wantsInspection,
      preferredContact: preferredContact ?? this.preferredContact,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  /// Berechnet einen Richtpreis basierend auf den Parametern
  /// Ergebnis = Grundpreis (Zimmer + Flaeche + Verschmutzung) + Zusatzleistungen
  double calculateSuggestedPrice() {
    // Basispreis nach Zimmerzahl
    double basePrice = roomCount * 80;
    
    // Flaechenzuschlag basierend auf Durchschnittsflaeche
    final areaParts = areaRange.replaceAll(' m²', '').replaceAll('m²', '').split('-');
    if (areaParts.length == 2) {
      final minArea = double.tryParse(areaParts[0].trim()) ?? 80;
      final maxArea = double.tryParse(areaParts[1].trim()) ?? 120;
      final avgArea = (minArea + maxArea) / 2;
      // Zuschlag fuer Flaechen ueber 120 m²: CHF 2.00 pro zusaetzlichem m²
      if (avgArea > 120) {
        basePrice += (avgArea - 120) * 2.0;
      }
    }
    
    // Verschmutzungsgrad-Zuschlag
    basePrice += dirtLevel.calculateSurcharge();
    
    // Zusatzleistungen
    for (final service in additionalServices) {
      basePrice += service.price;
    }
    
    return basePrice;
  }
  
  /// Berechnet den reinen Grundpreis OHNE Zusatzleistungen
  double calculateBasePrice() {
    return calculateSuggestedPrice() - additionalServicesTotal;
  }
  
  /// Summe aller Zusatzleistungen
  double get additionalServicesTotal {
    return additionalServices.fold(0.0, (sum, s) => sum + s.price);
  }
}

/// Verschmutzungsgrad für verschiedene Bereiche
class DirtLevel {
  final String kitchen; // leicht, mittel, stark
  final String kitchenAppliances;
  final String bathroom;
  final String limescale;
  final String windows;
  final String blinds;
  final String floors;

  DirtLevel({
    required this.kitchen,
    required this.kitchenAppliances,
    required this.bathroom,
    required this.limescale,
    required this.windows,
    required this.blinds,
    required this.floors,
  });

  factory DirtLevel.fromJson(Map<String, dynamic> json) {
    return DirtLevel(
      kitchen: json['kitchen'] as String? ?? 'leicht',
      kitchenAppliances: json['kitchen_appliances'] as String? ?? 'leicht',
      bathroom: json['bathroom'] as String? ?? 'leicht',
      limescale: json['limescale'] as String? ?? 'leicht',
      windows: json['windows'] as String? ?? 'leicht',
      blinds: json['blinds'] as String? ?? 'leicht',
      floors: json['floors'] as String? ?? 'leicht',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kitchen': kitchen,
      'kitchen_appliances': kitchenAppliances,
      'bathroom': bathroom,
      'limescale': limescale,
      'windows': windows,
      'blinds': blinds,
      'floors': floors,
    };
  }

  /// Berechnet Zuschlag basierend auf Verschmutzung
  double calculateSurcharge() {
    double surcharge = 0;
    
    int levelToMultiplier(String level) {
      switch (level) {
        case 'mittel': return 1;
        case 'stark': return 2;
        default: return 0;
      }
    }
    
    surcharge += levelToMultiplier(kitchen) * 15;
    surcharge += levelToMultiplier(kitchenAppliances) * 20;
    surcharge += levelToMultiplier(bathroom) * 25;
    surcharge += levelToMultiplier(limescale) * 30;
    surcharge += levelToMultiplier(windows) * 10;
    surcharge += levelToMultiplier(blinds) * 15;
    surcharge += levelToMultiplier(floors) * 20;
    
    return surcharge;
  }

  /// Gibt den durchschnittlichen Verschmutzungsgrad zurück
  String getOverallLevel() {
    final levels = [kitchen, kitchenAppliances, bathroom, limescale, windows, blinds, floors];
    int score = 0;
    for (final level in levels) {
      switch (level) {
        case 'leicht': score += 1;
        case 'mittel': score += 2;
        case 'stark': score += 3;
      }
    }
    final avg = score / levels.length;
    if (avg < 1.5) return 'Leicht';
    if (avg < 2.5) return 'Mittel';
    return 'Stark';
  }
}

/// Zusatzleistungen
/// WICHTIG: Preise muessen mit TemplateSettings.additionalServices uebereinstimmen!
enum AdditionalService {
  waschturm('Waschturm (Waschmaschine & Tumbler)', 50),
  balkon('Balkon/Terrasse (Außenbereich)', 80),
  keller('Keller/Estrich (Lagerräume)', 100),
  garage('Garage/Hobbyraum (Nebenräume)', 120),
  teppich('Teppichreinigung (Professionell)', 150),
  parkett('Parkettpflege (Spezialpflege)', 100),
  hochdruck('Hochdruckreinigung (Außenflächen)', 180),
  bohrlocher('Bohrlöcher zugipsen (Verspachteln)', 80),
  sonstiges('Sonstiges', 0);

  final String label;
  final double price;

  const AdditionalService(this.label, this.price);

  static AdditionalService fromString(String value) {
    return AdditionalService.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => AdditionalService.sonstiges,
    );
  }
}

/// Status einer Anfrage
enum RequestStatus {
  newRequest('new', 'Neu', 0xFF4CAF50),
  quoteSent('quote_sent', 'Offerte gesendet', 0xFF2196F3),
  viewed('viewed', 'Angeschaut', 0xFFFF9800),
  accepted('accepted', 'Angenommen', 0xFF4CAF50),
  rejected('rejected', 'Abgelehnt', 0xFFF44336),
  thinking('thinking', 'Überdenkt', 0xFF9C27B0),
  expired('expired', 'Abgelaufen', 0xFF9E9E9E);

  final String name;
  final String label;
  final int color;

  const RequestStatus(this.name, this.label, this.color);

  static RequestStatus fromString(String value) {
    return RequestStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RequestStatus.newRequest,
    );
  }
}
