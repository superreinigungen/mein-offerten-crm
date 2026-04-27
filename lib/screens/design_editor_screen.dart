import 'package:flutter/material.dart';
import '../utils/theme.dart';

class DesignEditorScreen extends StatefulWidget {
  const DesignEditorScreen({super.key});

  @override
  State<DesignEditorScreen> createState() => _DesignEditorScreenState();
}

class _DesignEditorScreenState extends State<DesignEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasChanges = false;
  
  // === FARBEN ===
  Color _primaryColor = const Color(0xFF1A237E);
  Color _secondaryColor = const Color(0xFF0D47A1);
  Color _accentColor = const Color(0xFF64B5F6);
  Color _acceptButtonColor = const Color(0xFF4CAF50);
  Color _rejectButtonColor = const Color(0xFFF44336);
  Color _thinkingButtonColor = const Color(0xFFFF9800);
  Color _priceBoxColor = const Color(0xFF4CAF50);
  
  // === HEADER ===
  final _companyNameController = TextEditingController(text: 'SuperReinigungen.ch');
  final _companyNameHighlightController = TextEditingController(text: 'Reinigungen');
  final _hotlineController = TextEditingController(text: '+41 44 544 20 04');
  final _emailController = TextEditingController(text: 'info@superreinigungen.ch');
  final _websiteController = TextEditingController(text: 'www.superreinigungen.ch');
  String? _logoUrl;
  bool _showLogo = false;
  
  // === FOOTER ===
  final _addressController = TextEditingController(text: 'Badenerstrasse 562, CH-8048 Zürich');
  final _ownerNameController = TextEditingController(text: 'Petrit Xhaferi');
  final _ownerTitleController = TextEditingController(text: 'Geschäftsführer / Ihr Ansprechpartner');
  final _footerTaglineController = TextEditingController(text: 'Reinigungen aller Art');
  
  // === BUTTONS ===
  final _acceptButtonTextController = TextEditingController(text: 'Offerte annehmen');
  final _rejectButtonTextController = TextEditingController(text: 'Offerte ablehnen');
  final _thinkingButtonTextController = TextEditingController(text: 'Ich überlege noch');
  final _actionTitleController = TextEditingController(text: 'Wie möchten Sie fortfahren?');
  
  // Preset Farben
  final List<Color> _presetColors = [
    const Color(0xFF1A237E), // Navy Blue
    const Color(0xFF0D47A1), // Blue
    const Color(0xFF1565C0), // Light Blue
    const Color(0xFF00695C), // Teal
    const Color(0xFF2E7D32), // Green
    const Color(0xFF558B2F), // Light Green
    const Color(0xFF6A1B9A), // Purple
    const Color(0xFFC62828), // Red
    const Color(0xFFAD1457), // Pink
    const Color(0xFFEF6C00), // Orange
    const Color(0xFF4E342E), // Brown
    const Color(0xFF37474F), // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _companyNameController.dispose();
    _companyNameHighlightController.dispose();
    _hotlineController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _ownerNameController.dispose();
    _ownerTitleController.dispose();
    _footerTaglineController.dispose();
    _acceptButtonTextController.dispose();
    _rejectButtonTextController.dispose();
    _thinkingButtonTextController.dispose();
    _actionTitleController.dispose();
    super.dispose();
  }
  
  void _markChanged() {
    setState(() => _hasChanges = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Offerten-Design'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          if (_hasChanges)
            TextButton.icon(
              onPressed: _saveDesign,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Speichern', style: TextStyle(color: Colors.white)),
            ),
          IconButton(
            icon: const Icon(Icons.preview),
            tooltip: 'Live-Vorschau',
            onPressed: _showLivePreview,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.palette), text: 'Farben'),
            Tab(icon: Icon(Icons.view_headline), text: 'Header'),
            Tab(icon: Icon(Icons.smart_button), text: 'Buttons'),
            Tab(icon: Icon(Icons.view_agenda), text: 'Footer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildColorsTab(),
          _buildHeaderTab(),
          _buildButtonsTab(),
          _buildFooterTab(),
        ],
      ),
    );
  }
  
  // === FARBEN TAB ===
  Widget _buildColorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Hauptfarben', Icons.palette),
          const SizedBox(height: 16),
          
          _buildColorPicker(
            label: 'Primärfarbe (Header)',
            color: _primaryColor,
            onColorChanged: (c) => setState(() { _primaryColor = c; _markChanged(); }),
          ),
          
          _buildColorPicker(
            label: 'Sekundärfarbe (Gradient)',
            color: _secondaryColor,
            onColorChanged: (c) => setState(() { _secondaryColor = c; _markChanged(); }),
          ),
          
          _buildColorPicker(
            label: 'Akzentfarbe (Highlights)',
            color: _accentColor,
            onColorChanged: (c) => setState(() { _accentColor = c; _markChanged(); }),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Preis-Box', Icons.attach_money),
          const SizedBox(height: 16),
          
          _buildColorPicker(
            label: 'Preis-Box Farbe',
            color: _priceBoxColor,
            onColorChanged: (c) => setState(() { _priceBoxColor = c; _markChanged(); }),
          ),
          
          // Vorschau Header
          const SizedBox(height: 24),
          _buildSectionHeader('Vorschau', Icons.visibility),
          const SizedBox(height: 16),
          _buildHeaderPreview(),
        ],
      ),
    );
  }
  
  // === HEADER TAB ===
  Widget _buildHeaderTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Logo', Icons.image),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Logo anzeigen'),
            subtitle: const Text('Zeigt ein Logo neben dem Firmennamen'),
            value: _showLogo,
            onChanged: (v) => setState(() { _showLogo = v; _markChanged(); }),
          ),
          
          if (_showLogo) ...[
            const SizedBox(height: 8),
            // Logo Vorschau
            if (_logoUrl != null && _logoUrl!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _logoUrl!,
                        height: 60,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 60,
                            width: 60,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('Logo-Vorschau', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Logo URL',
                hintText: 'https://example.com/logo.png',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) { setState(() { _logoUrl = v; }); _markChanged(); },
            ),
            const SizedBox(height: 12),
            // Hinweis für Upload
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tipp: Lade dein Logo auf einen Bildhosting-Dienst hoch und füge die URL hier ein.',
                      style: TextStyle(fontSize: 12, color: AppTheme.info),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          _buildSectionHeader('Firmenname', Icons.business),
          const SizedBox(height: 16),
          
          TextField(
            controller: _companyNameController,
            decoration: InputDecoration(
              labelText: 'Firmenname (Teil 1)',
              hintText: 'Super',
              prefixIcon: const Icon(Icons.store),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _companyNameHighlightController,
            decoration: InputDecoration(
              labelText: 'Firmenname (Highlight-Teil)',
              hintText: 'Reinigungen',
              helperText: 'Dieser Teil wird farbig hervorgehoben',
              prefixIcon: const Icon(Icons.highlight),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _markChanged(),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Kontaktdaten', Icons.contact_phone),
          const SizedBox(height: 16),
          
          TextField(
            controller: _hotlineController,
            decoration: InputDecoration(
              labelText: 'Hotline',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'E-Mail',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _websiteController,
            decoration: InputDecoration(
              labelText: 'Website',
              prefixIcon: const Icon(Icons.language),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _markChanged(),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Vorschau', Icons.visibility),
          const SizedBox(height: 16),
          _buildHeaderPreview(),
        ],
      ),
    );
  }
  
  // === BUTTONS TAB ===
  Widget _buildButtonsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Action-Bereich Titel', Icons.title),
          const SizedBox(height: 16),
          
          TextField(
            controller: _actionTitleController,
            decoration: InputDecoration(
              labelText: 'Überschrift',
              prefixIcon: const Icon(Icons.text_fields),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _markChanged(),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Annehmen-Button', Icons.check_circle),
          const SizedBox(height: 16),
          
          TextField(
            controller: _acceptButtonTextController,
            decoration: InputDecoration(
              labelText: 'Button-Text',
              prefixIcon: const Icon(Icons.text_fields),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),
          
          _buildColorPicker(
            label: 'Button-Farbe',
            color: _acceptButtonColor,
            onColorChanged: (c) => setState(() { _acceptButtonColor = c; _markChanged(); }),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Überlegen-Button', Icons.schedule),
          const SizedBox(height: 16),
          
          TextField(
            controller: _thinkingButtonTextController,
            decoration: InputDecoration(
              labelText: 'Button-Text',
              prefixIcon: const Icon(Icons.text_fields),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),
          
          _buildColorPicker(
            label: 'Button-Farbe',
            color: _thinkingButtonColor,
            onColorChanged: (c) => setState(() { _thinkingButtonColor = c; _markChanged(); }),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Ablehnen-Button', Icons.cancel),
          const SizedBox(height: 16),
          
          TextField(
            controller: _rejectButtonTextController,
            decoration: InputDecoration(
              labelText: 'Button-Text',
              prefixIcon: const Icon(Icons.text_fields),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),
          
          _buildColorPicker(
            label: 'Button-Farbe',
            color: _rejectButtonColor,
            onColorChanged: (c) => setState(() { _rejectButtonColor = c; _markChanged(); }),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Vorschau', Icons.visibility),
          const SizedBox(height: 16),
          _buildButtonsPreview(),
        ],
      ),
    );
  }
  
  // === FOOTER TAB ===
  Widget _buildFooterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Adresse', Icons.location_on),
          const SizedBox(height: 16),
          
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Firmenadresse',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _footerTaglineController,
            decoration: InputDecoration(
              labelText: 'Slogan / Tagline',
              hintText: 'z.B. "Reinigungen aller Art"',
              prefixIcon: const Icon(Icons.format_quote),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _markChanged(),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Unterschrift', Icons.draw),
          const SizedBox(height: 16),
          
          TextField(
            controller: _ownerNameController,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),
          
          TextField(
            controller: _ownerTitleController,
            decoration: InputDecoration(
              labelText: 'Titel / Position',
              prefixIcon: const Icon(Icons.work),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _markChanged(),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Vorschau', Icons.visibility),
          const SizedBox(height: 16),
          _buildFooterPreview(),
        ],
      ),
    );
  }
  
  // === HELPER WIDGETS ===
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryDark.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryDark, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDark,
          ),
        ),
      ],
    );
  }
  
  Widget _buildColorPicker({
    required String label,
    required Color color,
    required Function(Color) onColorChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text(
                        '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetColors.map((c) => GestureDetector(
                onTap: () => onColorChanged(c),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: c == color ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: c == color ? [
                      BoxShadow(
                        color: c.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ] : null,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeaderPreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryColor, _secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (_showLogo && _logoUrl != null && _logoUrl!.isNotEmpty)
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: _companyNameController.text.replaceAll(_companyNameHighlightController.text, ''),
                        style: const TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: _companyNameHighlightController.text,
                        style: TextStyle(color: _accentColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Hotline: ${_hotlineController.text}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  _emailController.text,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildButtonsPreview() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            _actionTitleController.text,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _buildPreviewButton(_acceptButtonTextController.text, _acceptButtonColor, Icons.check),
              _buildPreviewButton(_thinkingButtonTextController.text, _thinkingButtonColor, Icons.schedule),
              _buildPreviewButton(_rejectButtonTextController.text, _rejectButtonColor, Icons.close),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreviewButton(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
  
  Widget _buildFooterPreview() {
    return Container(
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '${_companyNameController.text} - ${_footerTaglineController.text}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            _addressController.text,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
            ),
            child: Column(
              children: [
                Text(
                  'Freundliche Grüsse, ${_ownerNameController.text}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                Text(
                  _ownerTitleController.text,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _saveDesign() {
    // TODO: Save to provider/storage
    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Design gespeichert!'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _showLivePreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Live-Vorschau', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildFullPreview(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFullPreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          _buildHeaderPreview(),
          
          // Content Preview
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Guten Tag Max,', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Vielen Dank für Ihre Anfrage...', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 20),
                
                // Price Box Preview
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _priceBoxColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _priceBoxColor),
                  ),
                  child: Column(
                    children: [
                      Text('Ihr Pauschalpreis', style: TextStyle(color: _priceBoxColor, fontSize: 12)),
                      Text('CHF 650.00', style: TextStyle(color: _priceBoxColor.withValues(alpha: 0.8), fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Buttons
          _buildButtonsPreview(),
          
          // Footer
          _buildFooterPreview(),
        ],
      ),
    );
  }
}
