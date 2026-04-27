import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/settings.dart';
import '../services/settings_service.dart';

class TemplateEditorScreen extends StatefulWidget {
  const TemplateEditorScreen({super.key});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SettingsService _settingsService = SettingsService();
  
  // Loaded Settings (for logo path reference)
  DesignSettings? _designSettings;
  
  // Company Info Controllers
  final _companyNameController = TextEditingController();
  final _hotlineController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerTitleController = TextEditingController();
  
  // Quote Settings Controllers
  final _validDaysController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  
  // Email Settings Controllers
  final _emailSubjectController = TextEditingController();
  final _introTextController = TextEditingController();
  
  // Design Controllers
  final _primaryColorController = TextEditingController();
  final _accentColorController = TextEditingController();
  
  // Lists (loaded from settings)
  List<String> _standardServices = [];
  List<AdditionalServiceTemplate> _additionalServices = [];
  List<String> _conditions = [];
  
  bool _hasChanges = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // 6 tabs now (added Design)
    _loadCurrentSettings();
  }
  
  Future<void> _loadCurrentSettings() async {
    // Load all settings from SettingsService
    final company = await _settingsService.getCompanySettings();
    final template = await _settingsService.getTemplateSettings();
    final email = await _settingsService.getEmailSettings();
    final design = await _settingsService.getDesignSettings();
    
    setState(() {
      _designSettings = design;
      
      // Populate controllers
      _companyNameController.text = company.name;
      _hotlineController.text = company.hotline;
      _emailController.text = company.email;
      _websiteController.text = company.website;
      _addressController.text = company.address;
      _ownerNameController.text = company.ownerName;
      _ownerTitleController.text = company.ownerTitle;
      
      _validDaysController.text = template.validityDays.toString();
      _paymentTermsController.text = template.paymentTerms;
      
      _emailSubjectController.text = email.subject;
      _introTextController.text = email.introText;
      
      _primaryColorController.text = design.primaryColor;
      _accentColorController.text = design.accentColor;
      
      // Populate lists
      _standardServices = List.from(template.standardServices);
      _additionalServices = List.from(template.additionalServices);
      _conditions = List.from(template.conditions);
    });
  }
  
  void _markAsChanged() {
    setState(() {
      _hasChanges = true;
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _companyNameController.dispose();
    _hotlineController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _ownerNameController.dispose();
    _ownerTitleController.dispose();
    _validDaysController.dispose();
    _paymentTermsController.dispose();
    _emailSubjectController.dispose();
    _introTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Offerten-Vorlage bearbeiten'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_hasChanges)
            TextButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Speichern', style: TextStyle(color: Colors.white)),
            ),
          IconButton(
            icon: const Icon(Icons.preview),
            tooltip: 'Vorschau',
            onPressed: _showPreview,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Firma'),
            Tab(text: 'Leistungen'),
            Tab(text: 'Zusatz'),
            Tab(text: 'Konditionen'),
            Tab(text: 'E-Mail'),
            Tab(text: 'Design'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompanyTab(),
          _buildServicesTab(),
          _buildAdditionalServicesTab(),
          _buildConditionsTab(),
          _buildEmailTab(),
          _buildDesignTab(),
        ],
      ),
    );
  }
  
  Widget _buildCompanyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Firmen-Informationen', Icons.business),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _companyNameController,
            label: 'Firmenname',
            icon: Icons.store,
          ),
          _buildTextField(
            controller: _hotlineController,
            label: 'Hotline',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          _buildTextField(
            controller: _emailController,
            label: 'E-Mail',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          _buildTextField(
            controller: _websiteController,
            label: 'Website',
            icon: Icons.language,
          ),
          _buildTextField(
            controller: _addressController,
            label: 'Adresse',
            icon: Icons.location_on,
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Absender / Unterschrift', Icons.person),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _ownerNameController,
            label: 'Name',
            icon: Icons.badge,
          ),
          _buildTextField(
            controller: _ownerTitleController,
            label: 'Titel / Position',
            icon: Icons.work,
          ),
        ],
      ),
    );
  }
  
  Widget _buildServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Standard-Leistungen', Icons.cleaning_services),
          const Text(
            'Diese Leistungen werden standardmässig in jeder Offerte aufgeführt.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _standardServices.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _standardServices.removeAt(oldIndex);
                _standardServices.insert(newIndex, item);
                _markAsChanged();
              });
            },
            itemBuilder: (context, index) {
              return Card(
                key: ValueKey(_standardServices[index]),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.drag_handle, color: Colors.grey),
                  title: Text(_standardServices[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _editService(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _deleteService(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _addService,
            icon: const Icon(Icons.add),
            label: const Text('Leistung hinzufügen'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAdditionalServicesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Zusatzleistungen & Preise', Icons.add_circle),
          const Text(
            'Definiere die Zusatzleistungen und ihre Standardpreise.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _additionalServices.length,
            itemBuilder: (context, index) {
              final service = _additionalServices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.handyman, color: AppTheme.primaryDark, size: 20),
                  ),
                  title: Text(service.name),
                  subtitle: Text('Standard: CHF ${service.defaultPrice.toStringAsFixed(0)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _editAdditionalService(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _deleteAdditionalService(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _addAdditionalService,
            icon: const Icon(Icons.add),
            label: const Text('Zusatzleistung hinzufügen'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildConditionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Offerten-Einstellungen', Icons.settings),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _validDaysController,
            label: 'Gültigkeitsdauer (Tage)',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
          ),
          _buildTextField(
            controller: _paymentTermsController,
            label: 'Zahlungsbedingungen',
            icon: Icons.payment,
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Konditionen', Icons.rule),
          const Text(
            'Diese Konditionen werden unter dem Preis angezeigt.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _conditions.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _conditions.removeAt(oldIndex);
                _conditions.insert(newIndex, item);
                _markAsChanged();
              });
            },
            itemBuilder: (context, index) {
              return Card(
                key: ValueKey(_conditions[index]),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.drag_handle, color: Colors.grey),
                  title: Text(
                    _conditions[index],
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _editCondition(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () => _deleteCondition(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _addCondition,
            icon: const Icon(Icons.add),
            label: const Text('Kondition hinzufügen'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('E-Mail Einstellungen', Icons.email),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailSubjectController,
            label: 'E-Mail Betreff',
            icon: Icons.subject,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _introTextController,
            label: 'Einleitungstext',
            icon: Icons.text_snippet,
            maxLines: 4,
            hint: 'Dieser Text wird dem Kunden als Begrüssung angezeigt...',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Vorschau', Icons.visibility),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Betreff: ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Expanded(
                        child: Text(
                          _emailSubjectController.text,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Guten Tag [Kundenname],',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  _introTextController.text,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: AppTheme.primaryDark),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Link zur Offerte wird hier eingefügt...',
                          style: TextStyle(color: AppTheme.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Freundliche Grüsse,\n${_ownerNameController.text}\n${_companyNameController.text}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
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
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: (_) => _markAsChanged(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
  
  void _editService(int index) {
    final controller = TextEditingController(text: _standardServices[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leistung bearbeiten'),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Leistungsbeschreibung',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _standardServices[index] = controller.text;
                _markAsChanged();
              });
              Navigator.pop(context);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
  
  void _deleteService(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leistung löschen?'),
        content: Text('Möchten Sie "${_standardServices[index]}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _standardServices.removeAt(index);
                _markAsChanged();
              });
              Navigator.pop(context);
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
  
  void _addService() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neue Leistung'),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Leistungsbeschreibung',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _standardServices.add(controller.text);
                  _markAsChanged();
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }
  
  void _editAdditionalService(int index) {
    final service = _additionalServices[index];
    final nameController = TextEditingController(text: service.name);
    final priceController = TextEditingController(text: service.defaultPrice.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zusatzleistung bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Standardpreis (CHF)',
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
              setState(() {
                _additionalServices[index] = AdditionalServiceTemplate(
                  name: nameController.text,
                  code: nameController.text.toLowerCase().replaceAll(' ', '_'),
                  defaultPrice: double.tryParse(priceController.text) ?? 0.0,
                );
                _markAsChanged();
              });
              Navigator.pop(context);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
  
  void _deleteAdditionalService(int index) {
    setState(() {
      _additionalServices.removeAt(index);
      _markAsChanged();
    });
  }
  
  void _addAdditionalService() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neue Zusatzleistung'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Standardpreis (CHF)',
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
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _additionalServices.add(AdditionalServiceTemplate(
                    name: nameController.text,
                    code: nameController.text.toLowerCase().replaceAll(' ', '_'),
                    defaultPrice: double.tryParse(priceController.text) ?? 0.0,
                  ));
                  _markAsChanged();
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }
  
  void _editCondition(int index) {
    final controller = TextEditingController(text: _conditions[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kondition bearbeiten'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Kondition',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _conditions[index] = controller.text;
                _markAsChanged();
              });
              Navigator.pop(context);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
  
  void _deleteCondition(int index) {
    setState(() {
      _conditions.removeAt(index);
      _markAsChanged();
    });
  }
  
  void _addCondition() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neue Kondition'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Kondition',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _conditions.add(controller.text);
                  _markAsChanged();
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveSettings() async {
    try {
      // Create settings objects
      final company = CompanySettings(
        name: _companyNameController.text,
        hotline: _hotlineController.text,
        email: _emailController.text,
        website: _websiteController.text,
        address: _addressController.text,
        ownerName: _ownerNameController.text,
        ownerTitle: _ownerTitleController.text,
      );
      
      final template = TemplateSettings(
        validityDays: int.tryParse(_validDaysController.text) ?? 7,
        paymentTerms: _paymentTermsController.text,
        standardServices: _standardServices,
        additionalServices: _additionalServices,
        conditions: _conditions,
      );
      
      final email = EmailSettings(
        subject: _emailSubjectController.text,
        introText: _introTextController.text,
      );
      
      final design = DesignSettings(
        primaryColor: _primaryColorController.text,
        accentColor: _accentColorController.text,
        logoPath: _designSettings?.logoPath ?? 'assets/images/sr_logo.png',
      );
      
      // Save to SettingsService
      await _settingsService.saveCompanySettings(company);
      await _settingsService.saveTemplateSettings(template);
      await _settingsService.saveEmailSettings(email);
      await _settingsService.saveDesignSettings(design);
      
      setState(() {
        _hasChanges = false;
        _designSettings = design;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('✓ Einstellungen erfolgreich gespeichert!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
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
  
  void _showPreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Offerten-Vorschau',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildQuotePreview(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuotePreview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1a237e), Color(0xFF0d47a1)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _companyNameController.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Hotline: ${_hotlineController.text}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      _emailController.text,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Guten Tag Max Mustermann,',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  _introTextController.text,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                
                // Services
                const Text(
                  'Leistungsumfang:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._standardServices.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
                
                const SizedBox(height: 20),
                
                // Price Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Column(
                    children: [
                      Text('Ihr Pauschalpreis', style: TextStyle(color: Colors.green)),
                      Text(
                        'CHF 450.00',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Inkl. MwSt. • Keine versteckten Kosten',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Conditions
                const Text('Konditionen:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._conditions.map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(c, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1a237e),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Column(
              children: [
                Text(
                  'Freundliche Grüsse, ${_ownerNameController.text}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  _ownerTitleController.text,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDesignTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Offerten-Design', Icons.palette),
          const Text(
            'Passe die Farben für deine Offerten an.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _primaryColorController,
            label: 'Primärfarbe (Hex)',
            icon: Icons.color_lens,
            hint: '#1a237e',
          ),
          _buildTextField(
            controller: _accentColorController,
            label: 'Akzentfarbe (Hex)',
            icon: Icons.color_lens_outlined,
            hint: '#0d47a1',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Vorschau', Icons.visibility),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _parseColor(_primaryColorController.text) ?? const Color(0xFF1a237e),
                  _parseColor(_accentColorController.text) ?? const Color(0xFF0d47a1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'SuperReinigungen.ch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Beispiel-Header mit deinen Farben',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '💡 Tipp: Verwende Hex-Farbcodes wie #1a237e oder #0d47a1',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  Color? _parseColor(String hex) {
    if (hex.isEmpty) return null;
    try {
      final hexCode = hex.replaceAll('#', '');
      if (hexCode.length == 6) {
        return Color(int.parse('FF$hexCode', radix: 16));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
