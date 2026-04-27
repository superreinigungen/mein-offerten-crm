import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_provider.dart';
import '../models/cleaning_request.dart';
import '../models/quote.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';

/// Neue Version des CreateQuoteScreen mit Positions-System
class CreateQuoteScreen extends StatefulWidget {
  final CleaningRequest request;
  final Quote? existingQuote;

  const CreateQuoteScreen({
    super.key,
    required this.request,
    this.existingQuote,
  });

  @override
  State<CreateQuoteScreen> createState() => _CreateQuoteScreenState();
}

class _CreateQuoteScreenState extends State<CreateQuoteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SettingsService _settingsService = SettingsService();
  final _uuid = const Uuid();

  // Loaded Settings
  CompanySettings? _companySettings;
  TemplateSettings? _templateSettings;

  // Quote Data
  List<QuotePosition> _positions = [];
  List<String> _conditions = [];
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _basePriceController = TextEditingController();
  double _basePrice = 0.0; // Grundpreis (Reinigung ohne Extras)
  
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSettingsAndInitialize();
  }

  Future<void> _loadSettingsAndInitialize() async {
    final company = await _settingsService.getCompanySettings();
    final template = await _settingsService.getTemplateSettings();
    final email = await _settingsService.getEmailSettings();

    setState(() {
      _companySettings = company;
      _templateSettings = template;

      // Wenn existierende Offerte: Lade deren Daten
      if (widget.existingQuote != null) {
        _positions = List.from(widget.existingQuote!.positions);
        _conditions = List.from(widget.existingQuote!.conditions);
        _messageController.text = widget.existingQuote!.customMessage ?? '';
        // Grundpreis = Gesamtpreis minus Zusatzleistungen
        final additionalTotal = widget.existingQuote!.positions
            .where((p) => p.isAdditional)
            .fold(0.0, (sum, p) => sum + p.totalPrice);
        _basePrice = widget.existingQuote!.price - additionalTotal;
        _basePriceController.text = _basePrice.toStringAsFixed(2);
      } else {
        // Neue Offerte: Standard-Leistungen automatisch hinzufuegen
        _initializeStandardPositions(template);
        _conditions = List.from(template.conditions);
        _messageController.text = email.introText;
        
        // WICHTIG: Grundpreis = Richtpreis OHNE Zusatzleistungen
        // calculateBasePrice() liefert den reinen Reinigungspreis
        _basePrice = widget.request.calculateBasePrice();
        _basePriceController.text = _basePrice.toStringAsFixed(2);
        
        // Zusatzleistungen aus der Anfrage als separate Positionen hinzufuegen
        _prefillAdditionalServicesFromRequest();
      }

      _isLoading = false;
    });
  }

  void _initializeStandardPositions(TemplateSettings template) {
    // Standard-Leistungen automatisch als Positionen hinzufügen
    for (final service in template.standardServices) {
      _positions.add(QuotePosition(
        id: _uuid.v4(),
        name: service,
        description: null,
        unitPrice: 0.0, // Bei Standard-Leistungen kein Einzelpreis
        quantity: 1,
        isAdditional: false,
      ));
    }
  }

  /// Fuellt Zusatzleistungen aus der Anfrage als Offerten-Positionen vor
  void _prefillAdditionalServicesFromRequest() {
    for (final service in widget.request.additionalServices) {
      _positions.add(QuotePosition(
        id: _uuid.v4(),
        name: service.label,
        description: null,
        unitPrice: service.price,
        quantity: 1,
        isAdditional: true,
      ));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _basePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingQuote != null;
    final isAlreadySent = widget.existingQuote?.sentAt != null;

    // Wenn bereits gesendet: Read-Only Ansicht
    if (isAlreadySent) {
      return _buildSentQuoteView();
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(isEditing ? 'Offerte bearbeiten' : 'Offerte erstellen'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Offerte bearbeiten' : 'Offerte erstellen'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Als Entwurf speichern',
            onPressed: _saveDraft,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Positionen'),
            Tab(icon: Icon(Icons.preview), text: 'Vorschau'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPositionsTab(),
          _buildPreviewTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildPositionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomerInfoCard(),
          const SizedBox(height: 20),
          _buildBasePriceSection(),
          const SizedBox(height: 20),
          _buildStandardServicesSection(),
          const SizedBox(height: 20),
          _buildAdditionalServicesSection(),
          const SizedBox(height: 20),
          _buildConditionsSection(),
          const SizedBox(height: 20),
          _buildMessageSection(),
          const SizedBox(height: 80), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    final request = widget.request;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.person, color: AppTheme.primaryDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.customerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        request.address,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Objekt', request.objectType),
            _buildInfoRow('Zimmer', '${request.roomCount}'),
            _buildInfoRow('Fläche', request.areaRange),
            _buildInfoRow('Reinigungstermin', Formatters.date(request.cleaningDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStandardServicesSection() {
    final standardPositions = _positions.where((p) => !p.isAdditional).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cleaning_services, color: AppTheme.primaryDark),
                SizedBox(width: 8),
                Text(
                  'Standard-Leistungen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Diese Leistungen sind im Grundpreis enthalten',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...standardPositions.map((position) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(position.name)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalServicesSection() {
    final additionalPositions = _positions.where((p) => p.isAdditional).toList();
    final availableServices = _templateSettings?.additionalServices ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.add_circle, color: AppTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'Zusatzleistungen',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _showAddAdditionalServiceDialog(availableServices),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Hinzufügen'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Optional wählbare Zusatzleistungen mit individuellen Preisen',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (additionalPositions.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Keine Zusatzleistungen hinzugefügt',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...additionalPositions.map((position) => _buildAdditionalServiceTile(position)),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalServiceTile(QuotePosition position) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.blue[50],
      child: ListTile(
        leading: const Icon(Icons.handyman, color: AppTheme.primary),
        title: Text(position.name),
        subtitle: Text('Menge: ${position.quantity}x'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CHF ${position.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editAdditionalService(position),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _removeAdditionalService(position),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description, color: AppTheme.primaryDark),
                SizedBox(width: 8),
                Text(
                  'Konditionen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Allgemeine Geschäftsbedingungen aus den Einstellungen',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            ..._conditions.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key + 1}.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entry.value)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.message, color: AppTheme.primaryDark),
                SizedBox(width: 8),
                Text(
                  'Persönliche Nachricht',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Optional: Individuelle Nachricht an den Kunden',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Z.B. Vielen Dank für Ihre Anfrage...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPreviewHeader(),
                  const Divider(height: 32),
                  _buildPreviewCustomerInfo(),
                  const Divider(height: 32),
                  _buildPreviewPositions(),
                  const Divider(height: 32),
                  _buildPreviewTotal(),
                  const Divider(height: 32),
                  _buildPreviewConditions(),
                  const Divider(height: 32),
                  _buildPreviewFooter(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildPreviewHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _companySettings?.name ?? 'SuperReinigungen.ch',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'OFFERTE',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Datum: ${Formatters.date(DateTime.now())}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          'Gültig bis: ${Formatters.date(DateTime.now().add(Duration(days: _templateSettings?.validityDays ?? 7)))}',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPreviewCustomerInfo() {
    final request = widget.request;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'KUNDE',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(request.customerName),
        Text(request.address),
        const SizedBox(height: 16),
        const Text(
          'OBJEKT',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text('${request.objectType}, ${request.roomCount} Zimmer'),
        Text('Fläche: ${request.areaRange}'),
        Text('Reinigungstermin: ${Formatters.date(request.cleaningDate)}'),
      ],
    );
  }

  Widget _buildPreviewPositions() {
    final standardPositions = _positions.where((p) => !p.isAdditional).toList();
    final additionalPositions = _positions.where((p) => p.isAdditional).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LEISTUNGEN',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...standardPositions.map((p) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              const Text('• '),
              Expanded(child: Text(p.name)),
            ],
          ),
        )),
        if (additionalPositions.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'ZUSATZLEISTUNGEN',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...additionalPositions.map((p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('${p.name} (${p.quantity}x)')),
                Text(
                  'CHF ${p.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildPreviewTotal() {
    final total = _calculateTotalPrice();
    final additionalTotal = _positions
        .where((p) => p.isAdditional)
        .fold(0.0, (sum, position) => sum + position.totalPrice);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aufschluesselung
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Grundpreis (Reinigung)', style: TextStyle(fontSize: 14)),
            Text('CHF ${_basePrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
        if (additionalTotal > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Zusatzleistungen', style: TextStyle(fontSize: 14)),
              Text('CHF ${additionalTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
        const SizedBox(height: 12),
        // Gesamtpreis Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryDark.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'GESAMTPREIS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'CHF ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'KONDITIONEN',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ..._conditions.asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            '${entry.key + 1}. ${entry.value}',
            style: const TextStyle(fontSize: 13),
          ),
        )),
        const SizedBox(height: 8),
        Text(
          'Zahlungsbedingungen: ${_templateSettings?.paymentTerms ?? 'Gemäss Vereinbarung'}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPreviewFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'KONTAKT',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(_companySettings?.name ?? 'SuperReinigungen.ch'),
        Text(_companySettings?.hotline ?? '+41 44 544 20 04'),
        Text(_companySettings?.email ?? 'info@superreinigungen.ch'),
        Text(_companySettings?.website ?? 'www.superreinigungen.ch'),
        const SizedBox(height: 16),
        Text(
          _companySettings?.ownerName ?? 'Petrit Xhaferi',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          _companySettings?.ownerTitle ?? 'Geschäftsführer',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final total = _calculateTotalPrice();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  total > _basePrice
                      ? 'Grundpreis CHF ${_basePrice.toStringAsFixed(0)} + Extras'
                      : 'Gesamtpreis',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Text(
                  'CHF ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isSending ? null : _sendQuote,
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(_isSending ? 'Wird gesendet...' : 'Offerte senden'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentQuoteView() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Offerte Details'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Offerte wurde bereits gesendet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Gesendet am: ${Formatters.date(widget.existingQuote!.sentAt!)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Zurück'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === GRUNDPREIS SECTION ===
  Widget _buildBasePriceSection() {
    final suggestedPrice = widget.request.calculateSuggestedPrice();
    final pureBasePrice = widget.request.calculateBasePrice();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate, color: AppTheme.primaryDark),
                const SizedBox(width: 8),
                const Text(
                  'Grundpreis (Reinigung)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Richtpreis gesamt: CHF ${suggestedPrice.toStringAsFixed(2)} | Reinigung: CHF ${pureBasePrice.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _basePriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Grundpreis (CHF)',
                border: const OutlineInputBorder(),
                prefixText: 'CHF ',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh, color: AppTheme.primary),
                  tooltip: 'Richtpreis uebernehmen',
                  onPressed: () {
                    setState(() {
                      _basePrice = pureBasePrice;
                      _basePriceController.text = pureBasePrice.toStringAsFixed(2);
                    });
                  },
                ),
                helperText: 'Du kannst den Preis manuell anpassen',
              ),
              onChanged: (value) {
                setState(() {
                  _basePrice = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods

  double _calculateTotalPrice() {
    // Grundpreis + alle Zusatzleistungen
    final additionalTotal = _positions
        .where((p) => p.isAdditional)
        .fold(0.0, (sum, position) => sum + position.totalPrice);
    return _basePrice + additionalTotal;
  }

  void _showAddAdditionalServiceDialog(List<AdditionalServiceTemplate> availableServices) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zusatzleistung hinzufügen'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableServices.length,
            itemBuilder: (context, index) {
              final service = availableServices[index];
              // Check if already added
              final alreadyAdded = _positions.any((p) => p.name == service.name && p.isAdditional);
              
              return ListTile(
                leading: const Icon(Icons.handyman, color: AppTheme.primary),
                title: Text(service.name),
                subtitle: Text('Standard: CHF ${service.defaultPrice.toStringAsFixed(2)}'),
                trailing: alreadyAdded
                    ? const Icon(Icons.check_circle, color: AppTheme.success)
                    : null,
                onTap: alreadyAdded
                    ? null
                    : () {
                        Navigator.pop(context);
                        _addAdditionalService(service);
                      },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    );
  }

  void _addAdditionalService(AdditionalServiceTemplate service) {
    final priceController = TextEditingController(text: service.defaultPrice.toStringAsFixed(2));
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Preis pro Einheit (CHF)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Menge',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text) ?? service.defaultPrice;
              final quantity = int.tryParse(quantityController.text) ?? 1;
              
              setState(() {
                _positions.add(QuotePosition(
                  id: _uuid.v4(),
                  name: service.name,
                  description: null,
                  unitPrice: price,
                  quantity: quantity,
                  isAdditional: true,
                ));
              });
              
              Navigator.pop(context);
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }

  void _editAdditionalService(QuotePosition position) {
    final priceController = TextEditingController(text: position.unitPrice.toStringAsFixed(2));
    final quantityController = TextEditingController(text: position.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(position.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Preis pro Einheit (CHF)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Menge',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text) ?? position.unitPrice;
              final quantity = int.tryParse(quantityController.text) ?? position.quantity;
              
              setState(() {
                final index = _positions.indexWhere((p) => p.id == position.id);
                if (index != -1) {
                  _positions[index] = position.copyWith(
                    unitPrice: price,
                    quantity: quantity,
                  );
                }
              });
              
              Navigator.pop(context);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _removeAdditionalService(QuotePosition position) {
    setState(() {
      _positions.removeWhere((p) => p.id == position.id);
    });
  }

  Future<void> _saveDraft() async {
    final total = _calculateTotalPrice();
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    try {
      await provider.createQuoteV2(
        requestId: widget.request.id,
        price: total,
        suggestedPrice: widget.request.calculateSuggestedPrice(),
        customMessage: _messageController.text.isEmpty ? null : _messageController.text,
        positions: _positions,
        conditions: _conditions,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entwurf gespeichert'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Speichern: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendQuote() async {
    // Berechne Gesamtpreis (Grundpreis + Zusatzleistungen)
    double total = _calculateTotalPrice();
    
    // Validierung: Preis muss > 0 sein
    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte Grundpreis eingeben (muss > 0 sein)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      // Create quote with new position system
      final quote = await provider.createQuoteV2(
        requestId: widget.request.id,
        price: total,
        suggestedPrice: widget.request.calculateSuggestedPrice(),
        customMessage: _messageController.text.isEmpty ? null : _messageController.text,
        positions: _positions,
        conditions: _conditions,
      );

      if (quote != null) {
        // Send the quote
        final success = await provider.sendQuote(quote);
        
        if (success && mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('✓ Offerte erfolgreich gesendet!'),
                ],
              ),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Senden: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }
}
