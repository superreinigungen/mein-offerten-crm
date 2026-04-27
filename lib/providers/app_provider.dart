import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cleaning_request.dart';
import '../models/quote.dart';
import '../models/order.dart';
import '../models/statistics.dart';
import '../services/email_service.dart';

/// Haupt-Provider für die App (Demo Mode)
class AppProvider extends ChangeNotifier {
  final EmailService _emailService = EmailService.instance;

  // State
  List<CleaningRequest> _requests = [];
  List<Quote> _quotes = [];
  List<Order> _orders = [];
  Statistics _statistics = Statistics.empty();
  bool _isLoading = false;
  String? _error;
  CleaningRequest? _selectedRequest;
  Quote? _selectedQuote;

  // Demo mode flag
  final bool _isDemoMode = true;

  // Getters
  List<CleaningRequest> get requests => _requests;
  List<Quote> get quotes => _quotes;
  List<Order> get orders => _orders;
  Statistics get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  CleaningRequest? get selectedRequest => _selectedRequest;
  Quote? get selectedQuote => _selectedQuote;
  bool get isDemoMode => _isDemoMode;

  // Status-based getters
  List<CleaningRequest> get newRequests =>
      _requests.where((r) => r.status == RequestStatus.newRequest).toList();

  List<CleaningRequest> get trulyNewRequests =>
      _requests.where((r) => r.status == RequestStatus.newRequest).toList();

  List<CleaningRequest> get pendingQuoteRequests =>
      _requests.where((r) => r.status == RequestStatus.quoteSent).toList();

  List<CleaningRequest> get viewedRequests =>
      _requests.where((r) => r.status == RequestStatus.viewed).toList();

  List<CleaningRequest> get thinkingRequests =>
      _requests.where((r) => r.status == RequestStatus.thinking).toList();

  List<CleaningRequest> get acceptedRequests =>
      _requests.where((r) => r.status == RequestStatus.accepted).toList();

  List<CleaningRequest> get rejectedRequests =>
      _requests.where((r) => r.status == RequestStatus.rejected).toList();

  // Order getters
  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == OrderStatus.pending).toList();

  List<Order> get todaysOrders {
    final today = DateTime.now();
    return _orders.where((o) {
      return o.cleaningDate.year == today.year &&
          o.cleaningDate.month == today.month &&
          o.cleaningDate.day == today.day;
    }).toList();
  }

  List<Order> get completedOrders =>
      _orders.where((o) => o.status == OrderStatus.completed).toList();

  /// Initialisiert den Provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadDemoData();
      calculateStatistics();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lädt Demo-Daten
  Future<void> _loadDemoData() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final defaultDirtLevel = DirtLevel(
      kitchen: 'mittel',
      kitchenAppliances: 'leicht',
      bathroom: 'mittel',
      limescale: 'leicht',
      windows: 'leicht',
      blinds: 'leicht',
      floors: 'mittel',
    );

    _requests = [
      CleaningRequest(
        id: '1',
        customerName: 'Thomas Weber',
        phoneNumber: '+41 79 123 45 67',
        email: 'thomas.weber@email.ch',
        address: 'Winterthurerstrasse 55, 8006 Zürich',
        roomCount: 4.5,
        objectType: 'Wohnung',
        areaRange: '100-130 m²',
        cleaningDate: DateTime.now().add(const Duration(days: 7)),
        dirtLevel: defaultDirtLevel,
        additionalServices: [AdditionalService.balkon],
        wantsInspection: true,
        preferredContact: 'email',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: RequestStatus.newRequest,
        notes: 'Endreinigung nach Umzug',
      ),
      CleaningRequest(
        id: '2',
        customerName: 'Maria Müller',
        phoneNumber: '+41 78 987 65 43',
        email: 'maria.mueller@email.ch',
        address: 'Bahnhofstrasse 12, 8001 Zürich',
        roomCount: 3.5,
        objectType: 'Wohnung',
        areaRange: '80-100 m²',
        cleaningDate: DateTime.now().add(const Duration(days: 3)),
        dirtLevel: defaultDirtLevel,
        additionalServices: [],
        wantsInspection: false,
        preferredContact: 'whatsapp',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: RequestStatus.quoteSent,
        notes: 'Wöchentliche Reinigung',
      ),
      CleaningRequest(
        id: '3',
        customerName: 'Andreas Fischer',
        phoneNumber: '+41 76 555 44 33',
        email: 'andreas.fischer@email.ch',
        address: 'Seestrasse 89, 8008 Zürich',
        roomCount: 5.5,
        objectType: 'Haus',
        areaRange: '150-180 m²',
        cleaningDate: DateTime.now().add(const Duration(days: 14)),
        dirtLevel: DirtLevel(
          kitchen: 'stark',
          kitchenAppliances: 'mittel',
          bathroom: 'stark',
          limescale: 'mittel',
          windows: 'mittel',
          blinds: 'leicht',
          floors: 'stark',
        ),
        additionalServices: [AdditionalService.keller, AdditionalService.garage],
        wantsInspection: true,
        preferredContact: 'email',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: RequestStatus.thinking,
        notes: 'Grundreinigung',
      ),
      CleaningRequest(
        id: '4',
        customerName: 'Sandra Keller',
        phoneNumber: '+41 79 222 33 44',
        email: 'sandra.keller@email.ch',
        address: 'Limmatstrasse 45, 8005 Zürich',
        roomCount: 3.0,
        objectType: 'Wohnung',
        areaRange: '70-90 m²',
        cleaningDate: DateTime.now().add(const Duration(days: 5)),
        dirtLevel: defaultDirtLevel,
        additionalServices: [],
        wantsInspection: false,
        preferredContact: 'email',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: RequestStatus.newRequest,
        notes: null,
      ),
      CleaningRequest(
        id: '5',
        customerName: 'Peter Huber',
        phoneNumber: '+41 78 444 55 66',
        email: 'peter.huber@email.ch',
        address: 'Hardstrasse 120, 8005 Zürich',
        roomCount: 4.0,
        objectType: 'Wohnung',
        areaRange: '90-110 m²',
        cleaningDate: DateTime.now().add(const Duration(days: 10)),
        dirtLevel: defaultDirtLevel,
        additionalServices: [AdditionalService.waschturm],
        wantsInspection: true,
        preferredContact: 'pdf',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: RequestStatus.newRequest,
        notes: 'Umzugsreinigung',
      ),
      CleaningRequest(
        id: '6',
        customerName: 'Lisa Brunner',
        phoneNumber: '+41 76 777 88 99',
        email: 'lisa.brunner@email.ch',
        address: 'Talstrasse 33, 8001 Zürich',
        roomCount: 2.5,
        objectType: 'Wohnung',
        areaRange: '50-70 m²',
        cleaningDate: DateTime.now().add(const Duration(days: 2)),
        dirtLevel: defaultDirtLevel,
        additionalServices: [],
        wantsInspection: false,
        preferredContact: 'email',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        status: RequestStatus.accepted,
        notes: null,
      ),
      CleaningRequest(
        id: '7',
        customerName: 'Marco Bianchi',
        phoneNumber: '+41 79 111 22 33',
        email: 'marco.bianchi@email.ch',
        address: 'Badenerstrasse 200, 8004 Zürich',
        roomCount: 3.5,
        objectType: 'Wohnung',
        areaRange: '80-100 m²',
        cleaningDate: DateTime.now().subtract(const Duration(days: 5)),
        dirtLevel: defaultDirtLevel,
        additionalServices: [],
        wantsInspection: false,
        preferredContact: 'email',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        status: RequestStatus.rejected,
        notes: 'Zu teuer',
      ),
    ];

    // Demo-Quotes MIT Positionen (wie sie das Positions-System erwartet)
    _quotes = [
      Quote(
        id: '1',
        requestId: '2',
        price: 450.0,
        suggestedPrice: 450.0,
        customMessage: 'Vielen Dank fuer Ihre Anfrage. Wir freuen uns, Ihnen folgendes Angebot unterbreiten zu koennen.',
        status: QuoteStatus.viewed,
        views: [
          QuoteView(id: 'v1', viewedAt: DateTime.now().subtract(const Duration(hours: 8)), duration: const Duration(minutes: 2, seconds: 30)),
          QuoteView(id: 'v2', viewedAt: DateTime.now().subtract(const Duration(hours: 3)), duration: const Duration(minutes: 1, seconds: 45)),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        sentAt: DateTime.now().subtract(const Duration(hours: 11)),
        validUntil: DateTime.now().add(const Duration(days: 14)),
        positions: [
          QuotePosition(id: 'std_1', name: 'Komplette Endreinigung der Wohnung mit Abnahmegarantie', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_2', name: 'Kueche inkl. Geraete (Backofen, Kuehlschrank, Geschirrspueler)', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_3', name: 'Badezimmer/WC inkl. Entkalkung', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_4', name: 'Alle Raeume inkl. Boeden, Fenster, Rahmen', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_5', name: 'Tueren, Schraenke, Steckdosen, Lichtschalter', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_6', name: 'Balkon/Terrasse (falls vorhanden)', unitPrice: 0, quantity: 1, isAdditional: false),
        ],
        conditions: [
          'Der Preis versteht sich als Pauschalpreis, inkl. MwSt.',
          'Bezahlung erfolgt auf Rechnung, zahlbar innert 7 Tagen oder bar bei Abgabe.',
          'Kostenlose Nachreinigung bei berechtigten Beanstandungen (Abnahmegarantie).',
          'Die Wohnung muss am Reinigungstag leer und besenrein sein.',
        ],
      ),
      Quote(
        id: '2',
        requestId: '6',
        price: 280.0,
        suggestedPrice: 280.0,
        customMessage: 'Freuen uns auf die Zusammenarbeit',
        status: QuoteStatus.accepted,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        sentAt: DateTime.now().subtract(const Duration(days: 2)),
        validUntil: DateTime.now().add(const Duration(days: 14)),
        positions: [
          QuotePosition(id: 'std_1', name: 'Komplette Endreinigung der Wohnung mit Abnahmegarantie', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_2', name: 'Kueche inkl. Geraete (Backofen, Kuehlschrank, Geschirrspueler)', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_3', name: 'Badezimmer/WC inkl. Entkalkung', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_4', name: 'Alle Raeume inkl. Boeden, Fenster, Rahmen', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_5', name: 'Tueren, Schraenke, Steckdosen, Lichtschalter', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_6', name: 'Balkon/Terrasse (falls vorhanden)', unitPrice: 0, quantity: 1, isAdditional: false),
        ],
        conditions: [
          'Der Preis versteht sich als Pauschalpreis, inkl. MwSt.',
          'Bezahlung erfolgt auf Rechnung, zahlbar innert 7 Tagen oder bar bei Abgabe.',
          'Kostenlose Nachreinigung bei berechtigten Beanstandungen (Abnahmegarantie).',
          'Die Wohnung muss am Reinigungstag leer und besenrein sein.',
        ],
      ),
      // Andreas Fischer - Offerte gesendet, Kunde ueberlegt
      Quote(
        id: '3',
        requestId: '3',
        price: 780.0,
        suggestedPrice: 780.0,
        customMessage: 'Gerne unterbreiten wir Ihnen unser Angebot fuer die Grundreinigung Ihres Hauses.',
        status: QuoteStatus.thinking,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        validUntil: DateTime.now().add(const Duration(days: 6)),
        views: [
          QuoteView(id: 'v3', viewedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)), duration: const Duration(minutes: 4, seconds: 10)),
          QuoteView(id: 'v4', viewedAt: DateTime.now().subtract(const Duration(hours: 12)), duration: const Duration(minutes: 3, seconds: 20)),
          QuoteView(id: 'v5', viewedAt: DateTime.now().subtract(const Duration(hours: 2)), duration: const Duration(minutes: 5, seconds: 0)),
        ],
        positions: [
          QuotePosition(id: 'std_1', name: 'Komplette Endreinigung der Wohnung mit Abnahmegarantie', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_2', name: 'Kueche inkl. Geraete (Backofen, Kuehlschrank, Geschirrspueler)', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_3', name: 'Badezimmer/WC inkl. Entkalkung', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_4', name: 'Alle Raeume inkl. Boeden, Fenster, Rahmen', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_5', name: 'Tueren, Schraenke, Steckdosen, Lichtschalter', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'std_6', name: 'Balkon/Terrasse (falls vorhanden)', unitPrice: 0, quantity: 1, isAdditional: false),
          QuotePosition(id: 'add_1', name: 'Keller/Estrich (Lagerraeume)', unitPrice: 100, quantity: 1, isAdditional: true),
          QuotePosition(id: 'add_2', name: 'Garage/Hobbyraum (Nebenraeume)', unitPrice: 120, quantity: 1, isAdditional: true),
        ],
        conditions: [
          'Der Preis versteht sich als Pauschalpreis, inkl. MwSt.',
          'Bezahlung erfolgt auf Rechnung, zahlbar innert 7 Tagen oder bar bei Abgabe.',
          'Kostenlose Nachreinigung bei berechtigten Beanstandungen (Abnahmegarantie).',
          'Die Wohnung muss am Reinigungstag leer und besenrein sein.',
        ],
      ),
    ];

    _orders = [
      Order(
        id: '1',
        requestId: '6',
        quoteId: '2',
        customerName: 'Lisa Brunner',
        customerEmail: 'lisa.brunner@email.ch',
        customerPhone: '+41 76 777 88 99',
        address: 'Talstrasse 33, 8001 Zürich',
        propertyType: 'Wohnung',
        rooms: 2.5,
        services: ['Endreinigung mit Abnahmegarantie'],
        cleaningDate: DateTime.now().add(const Duration(days: 2)),
        status: OrderStatus.pending,
        price: 280.0,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        assignedTeam: 'Team A',
        estimatedHours: 4,
      ),
    ];

    notifyListeners();
  }

  /// Wählt eine Anfrage aus
  void selectRequest(CleaningRequest? request) {
    _selectedRequest = request;
    if (request != null) {
      _selectedQuote = getQuoteForRequest(request.id);
    } else {
      _selectedQuote = null;
    }
    notifyListeners();
  }

  /// Erstellt eine Offerte
  Future<Quote?> createQuote({
    required String requestId,
    required double price,
    required double suggestedPrice,
    String? customMessage,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newQuote = Quote(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      requestId: requestId,
      price: price,
      suggestedPrice: suggestedPrice,
      customMessage: customMessage,
      status: QuoteStatus.draft,
      createdAt: DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 30)),
    );
    _quotes.add(newQuote);
    _selectedQuote = newQuote;
    notifyListeners();
    return newQuote;
  }

  /// Erstellt oder aktualisiert eine Offerte mit Positions-System (V2)
  /// Wenn bereits eine Offerte fuer diese Anfrage existiert (Draft), wird sie aktualisiert.
  Future<Quote?> createQuoteV2({
    required String requestId,
    required double price,
    required double suggestedPrice,
    String? customMessage,
    required List<QuotePosition> positions,
    required List<String> conditions,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Pruefen ob bereits ein Draft fuer diese Anfrage existiert
    final existingIndex = _quotes.indexWhere(
      (q) => q.requestId == requestId && q.sentAt == null,
    );
    
    final newQuote = Quote(
      id: existingIndex != -1 
          ? _quotes[existingIndex].id 
          : 'demo_${DateTime.now().millisecondsSinceEpoch}',
      requestId: requestId,
      price: price,
      suggestedPrice: suggestedPrice,
      customMessage: customMessage,
      status: QuoteStatus.draft,
      createdAt: existingIndex != -1 
          ? _quotes[existingIndex].createdAt 
          : DateTime.now(),
      validUntil: DateTime.now().add(const Duration(days: 30)),
      positions: positions,
      conditions: conditions,
    );
    
    if (existingIndex != -1) {
      // Aktualisiere bestehenden Draft
      _quotes[existingIndex] = newQuote;
    } else {
      _quotes.add(newQuote);
    }
    
    _selectedQuote = newQuote;
    notifyListeners();
    return newQuote;
  }

  /// Sendet die Offerte
  Future<bool> sendQuote(Quote quote) async {
    final request = _requests.firstWhere((r) => r.id == quote.requestId);

    await Future.delayed(const Duration(milliseconds: 500));
    final index = _quotes.indexWhere((q) => q.id == quote.id);
    if (index != -1) {
      _quotes[index] = quote.copyWith(
        status: QuoteStatus.sent,
        sentAt: DateTime.now(),  // WICHTIG: sentAt setzen!
      );
    }
    final reqIndex = _requests.indexWhere((r) => r.id == request.id);
    if (reqIndex != -1) {
      _requests[reqIndex] = request.copyWith(status: RequestStatus.quoteSent);
    }
    notifyListeners();
    return true;
  }

  /// Akzeptiert Offerte manuell und erstellt Auftrag
  Future<void> acceptQuoteManually(String requestId) async {
    final reqIndex = _requests.indexWhere((r) => r.id == requestId);
    if (reqIndex != -1) {
      final request = _requests[reqIndex];
      _requests[reqIndex] = request.copyWith(status: RequestStatus.accepted);
      
      // Quote-Status auch aktualisieren
      final quoteIndex = _quotes.indexWhere((q) => q.requestId == requestId);
      if (quoteIndex != -1) {
        _quotes[quoteIndex] = _quotes[quoteIndex].copyWith(status: QuoteStatus.accepted);
      }
      
      // AUFTRAG ERSTELLEN
      final quote = quoteIndex != -1 ? _quotes[quoteIndex] : null;
      final newOrder = Order(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        requestId: requestId,
        quoteId: quote?.id ?? '',
        customerName: request.customerName,
        customerEmail: request.email,
        customerPhone: request.phoneNumber,
        address: request.address,
        propertyType: request.objectType,
        rooms: request.roomCount,
        services: ['Endreinigung'],
        additionalServices: request.additionalServices.map((s) => s.label).toList(),
        cleaningDate: request.cleaningDate,
        handoverDate: request.inspectionDate,
        price: quote?.price ?? request.calculateSuggestedPrice(),
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );
      _orders.add(newOrder);
    }
    notifyListeners();
  }

  /// Lehnt Offerte ab - aktualisiert sowohl Request als auch Quote
  Future<void> rejectQuoteManually(String requestId) async {
    final reqIndex = _requests.indexWhere((r) => r.id == requestId);
    if (reqIndex != -1) {
      _requests[reqIndex] = _requests[reqIndex].copyWith(status: RequestStatus.rejected);
    }
    // Quote-Status synchronisieren
    final quoteIndex = _quotes.indexWhere((q) => q.requestId == requestId);
    if (quoteIndex != -1) {
      _quotes[quoteIndex] = _quotes[quoteIndex].copyWith(status: QuoteStatus.rejected);
    }
    notifyListeners();
  }

  /// Markiert als "Überlegt" - aktualisiert sowohl Request als auch Quote
  Future<void> markQuoteAsThinking(String requestId) async {
    final reqIndex = _requests.indexWhere((r) => r.id == requestId);
    if (reqIndex != -1) {
      _requests[reqIndex] = _requests[reqIndex].copyWith(status: RequestStatus.thinking);
    }
    // Quote-Status synchronisieren
    final quoteIndex = _quotes.indexWhere((q) => q.requestId == requestId);
    if (quoteIndex != -1) {
      _quotes[quoteIndex] = _quotes[quoteIndex].copyWith(status: QuoteStatus.thinking);
    }
    notifyListeners();
  }

  /// Markiert als "Angeschaut" - aktualisiert sowohl Request als auch Quote und fuegt Tracking hinzu
  Future<void> markQuoteAsViewed(String requestId) async {
    final reqIndex = _requests.indexWhere((r) => r.id == requestId);
    if (reqIndex != -1) {
      _requests[reqIndex] = _requests[reqIndex].copyWith(status: RequestStatus.viewed);
    }
    // Quote-Status und Tracking aktualisieren
    final quoteIndex = _quotes.indexWhere((q) => q.requestId == requestId);
    if (quoteIndex != -1) {
      final quote = _quotes[quoteIndex];
      final newView = QuoteView(
        id: 'view_${DateTime.now().millisecondsSinceEpoch}',
        viewedAt: DateTime.now(),
        duration: Duration(seconds: 30 + (DateTime.now().second * 3)),
        device: 'Desktop',
        browser: 'Chrome',
      );
      _quotes[quoteIndex] = quote.copyWith(
        status: QuoteStatus.viewed,
        views: [...quote.views, newView],
      );
    }
    notifyListeners();
  }

  /// Schließt Auftrag ab
  Future<void> completeOrder(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: OrderStatus.completed);
    }
    calculateStatistics();
    notifyListeners();
  }

  /// Berechnet Statistiken
  void calculateStatistics() {
    _statistics = Statistics(
      totalRequests: _requests.length,
      pendingRequests: _requests.where((r) => r.status == RequestStatus.newRequest).length,
      sentQuotes: _quotes.where((q) => q.status == QuoteStatus.sent).length,
      acceptedQuotes: _quotes.where((q) => q.status == QuoteStatus.accepted).length,
      thinkingQuotes: _requests.where((r) => r.status == RequestStatus.thinking).length,
      rejectedQuotes: _requests.where((r) => r.status == RequestStatus.rejected).length,
      hotLeads: _requests.where((r) => r.status == RequestStatus.thinking).length,
      totalRevenue: _orders
          .where((o) => o.status == OrderStatus.completed)
          .fold(0.0, (sum, o) => sum + o.price),
      conversionRate: _requests.isNotEmpty 
          ? (_requests.where((r) => r.status == RequestStatus.accepted).length / _requests.length * 100)
          : 0.0,
      averageQuoteValue: _quotes.isNotEmpty
          ? _quotes.fold(0.0, (sum, q) => sum + q.price) / _quotes.length
          : 0.0,
      dailyStats: [],
      rejectionReasons: {},
    );
  }

  /// Lädt Statistiken
  Future<void> loadStatistics() async {
    calculateStatistics();
    notifyListeners();
  }

  /// Holt die Offerte für eine Anfrage
  Quote? getQuoteForRequest(String requestId) {
    try {
      return _quotes.firstWhere((q) => q.requestId == requestId);
    } catch (_) {
      return null;
    }
  }
}
