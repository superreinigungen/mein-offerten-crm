import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import '../models/cleaning_request.dart';
import '../models/quote.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';
import '../utils/formatters.dart';
import '../services/quote_html_service.dart';
import '../widgets/status_badge.dart';
import 'create_quote_screen.dart';

/// Detail-Ansicht einer Anfrage mit manueller Status-Steuerung
class RequestDetailScreen extends StatefulWidget {
  final CleaningRequest request;
  final Quote? quote;

  const RequestDetailScreen({
    super.key,
    required this.request,
    this.quote,
  });

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        // Aktuelle Daten aus Provider holen (für Live-Updates)
        final currentRequest = provider.requests.firstWhere(
          (r) => r.id == widget.request.id,
          orElse: () => widget.request,
        );
        final currentQuote = provider.getQuoteForRequest(widget.request.id);
        
        // Logik fuer Button-Anzeige
        final bool hasQuote = currentQuote != null;
        final bool isQuoteSent = currentQuote?.sentAt != null;
        final bool isAccepted = currentRequest.status == RequestStatus.accepted || 
                               currentQuote?.status == QuoteStatus.accepted;
        final bool isRejected = currentRequest.status == RequestStatus.rejected ||
                               currentQuote?.status == QuoteStatus.rejected;
        final bool isThinking = currentQuote?.status == QuoteStatus.thinking ||
                               currentRequest.status == RequestStatus.thinking;
        final bool isFinal = isAccepted || isRejected;

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: Text(currentRequest.customerName),
            backgroundColor: AppTheme.primaryDark,
            actions: [
              // Status-Änderung Button (nur wenn Offerte gesendet und nicht final)
              if (hasQuote && isQuoteSent && !isFinal)
                IconButton(
                  icon: const Icon(Icons.edit_note),
                  tooltip: 'Status manuell ändern',
                  onPressed: () => _showStatusChangeDialog(context, provider, currentRequest, currentQuote),
                ),
              IconButton(
                icon: const Icon(Icons.phone_outlined),
                onPressed: () => _copyToClipboard(context, currentRequest.phoneNumber, 'Telefonnummer'),
              ),
              IconButton(
                icon: const Icon(Icons.email_outlined),
                onPressed: () => _copyToClipboard(context, currentRequest.email, 'E-Mail'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                Row(
                  children: [
                    StatusBadge.forRequestStatus(currentRequest.status),
                    if (currentQuote?.isHotLead ?? false) ...[
                      const SizedBox(width: 8),
                      const HotLeadBadge(),
                    ],
                  ],
                ),
                
                const SizedBox(height: 20),

                // INFO-BOX: Status-Erklaerung
                if (isQuoteSent) _buildStatusInfoBox(isAccepted, isRejected, isThinking),

                // MANUELLE STATUS-ÄNDERUNG CARD (wenn Offerte gesendet und nicht final)
                if (hasQuote && isQuoteSent && !isFinal) ...[
                  _buildManualStatusCard(context, provider, currentRequest, currentQuote!),
                  const SizedBox(height: 16),
                ],

                // Kontaktdaten
                _buildSectionCard(
                  title: 'Kontaktdaten',
                  icon: Icons.person_outline,
                  children: [
                    _buildDetailRow('Telefon', Formatters.phoneNumber(currentRequest.phoneNumber)),
                    _buildDetailRow('E-Mail', currentRequest.email),
                    _buildDetailRow('Adresse', currentRequest.address),
                  ],
                ),

                const SizedBox(height: 16),

                // Objekt-Informationen
                _buildSectionCard(
                  title: 'Objekt-Informationen',
                  icon: Icons.home_outlined,
                  children: [
                    _buildDetailRow('Zimmer', Formatters.roomCount(currentRequest.roomCount)),
                    _buildDetailRow('Typ', currentRequest.objectType),
                    _buildDetailRow('Fläche', currentRequest.areaRange),
                    _buildDetailRow('Reinigungstermin', Formatters.date(currentRequest.cleaningDate)),
                    if (currentRequest.inspectionDate != null)
                      _buildDetailRow('Abnahmetermin', Formatters.date(currentRequest.inspectionDate!)),
                  ],
                ),

                const SizedBox(height: 16),

                // Verschmutzungsgrad
                _buildSectionCard(
                  title: 'Verschmutzungsgrad',
                  icon: Icons.cleaning_services_outlined,
                  children: [
                    _buildDirtRow('Küche allgemein', currentRequest.dirtLevel.kitchen),
                    _buildDirtRow('Küchengeräte', currentRequest.dirtLevel.kitchenAppliances),
                    _buildDirtRow('Bad allgemein', currentRequest.dirtLevel.bathroom),
                    _buildDirtRow('Kalkrückstände', currentRequest.dirtLevel.limescale),
                    _buildDirtRow('Fenster/Rahmen', currentRequest.dirtLevel.windows),
                    _buildDirtRow('Stören/Rollläden', currentRequest.dirtLevel.blinds),
                    _buildDirtRow('Böden allgemein', currentRequest.dirtLevel.floors),
                  ],
                ),

                // Zusatzleistungen
                if (currentRequest.additionalServices.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Zusatzleistungen',
                    icon: Icons.add_circle_outline,
                    children: currentRequest.additionalServices.map((service) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppTheme.success, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(service.label, style: const TextStyle(fontSize: 14))),
                            Text('+ ${Formatters.price(service.price)}', 
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Tracking (wenn Offerte existiert und gesendet)
                if (hasQuote && isQuoteSent) ...[
                  const SizedBox(height: 16),
                  _buildTrackingCard(currentQuote!),
                ],

                // Offerten-Info (wenn gesendet)
                if (hasQuote && isQuoteSent) ...[
                  const SizedBox(height: 16),
                  _buildQuoteInfoCard(context, currentQuote!),
                ],

                // Preisvorschlag (nur wenn noch keine Offerte)
                if (!hasQuote) ...[
                  const SizedBox(height: 16),
                  _buildPriceCard(currentRequest),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
          
          // Bottom Action Bar - LOGIK-BASIERT
          bottomNavigationBar: Container(
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
            child: SafeArea(
              child: _buildActionButtons(context, provider, currentRequest, currentQuote, hasQuote, isQuoteSent, isAccepted, isRejected, isThinking, isFinal),
            ),
          ),
        );
      },
    );
  }

  // ============================================
  // MANUELLE STATUS-ÄNDERUNG CARD
  // ============================================
  Widget _buildManualStatusCard(BuildContext context, AppProvider provider, CleaningRequest request, Quote quote) {
    return Card(
      color: AppTheme.primaryDark.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings, color: AppTheme.primaryDark, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Manuelle Status-Steuerung',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primaryDark),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Nach Telefonat mit ${request.customerName.split(' ').first} kannst du den Status hier manuell ändern:',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                // ANNEHMEN
                Expanded(
                  child: _statusButton(
                    icon: Icons.check_circle,
                    label: 'Annehmen',
                    color: AppTheme.success,
                    onPressed: () => _acceptQuote(context, provider, request),
                  ),
                ),
                const SizedBox(width: 8),
                // ÜBERLEGT
                Expanded(
                  child: _statusButton(
                    icon: Icons.hourglass_empty,
                    label: 'Überlegt',
                    color: AppTheme.warning,
                    onPressed: () => _markAsThinking(context, provider, request),
                  ),
                ),
                const SizedBox(width: 8),
                // ABLEHNEN
                Expanded(
                  child: _statusButton(
                    icon: Icons.cancel,
                    label: 'Ablehnen',
                    color: AppTheme.error,
                    onPressed: () => _rejectQuote(context, provider, request),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Test-Button: Ansicht simulieren
            OutlinedButton.icon(
              onPressed: () => _simulateView(context, provider, request),
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text('🧪 Ansicht simulieren (Test)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ============================================
  // STATUS-ÄNDERUNG AKTIONEN
  // ============================================
  
  void _acceptQuote(BuildContext context, AppProvider provider, CleaningRequest request) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.success),
            SizedBox(width: 12),
            Text('Offerte annehmen?'),
          ],
        ),
        content: Text('Möchtest du die Offerte für ${request.customerName} als ANGENOMMEN markieren?\n\nEin neuer Auftrag wird automatisch erstellt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.acceptQuoteManually(request.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Offerte angenommen! Auftrag wurde erstellt.'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Ja, annehmen'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
          ),
        ],
      ),
    );
  }

  void _rejectQuote(BuildContext context, AppProvider provider, CleaningRequest request) {
    String? selectedReason;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cancel, color: AppTheme.error),
              SizedBox(width: 12),
              Text('Offerte ablehnen?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Möchtest du die Offerte für ${request.customerName} als ABGELEHNT markieren?'),
              const SizedBox(height: 16),
              const Text('Ablehnungsgrund (optional):', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedReason,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Grund auswählen...'),
                items: const [
                  DropdownMenuItem(value: 'price_high', child: Text('Preis zu hoch')),
                  DropdownMenuItem(value: 'wrong_date', child: Text('Termin passt nicht')),
                  DropdownMenuItem(value: 'comparing', child: Text('Vergleicht andere Anbieter')),
                  DropdownMenuItem(value: 'other', child: Text('Sonstiger Grund')),
                ],
                onChanged: (value) => setDialogState(() => selectedReason = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                provider.rejectQuoteManually(request.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Offerte wurde abgelehnt'),
                    backgroundColor: AppTheme.error,
                  ),
                );
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Ablehnen'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            ),
          ],
        ),
      ),
    );
  }

  void _markAsThinking(BuildContext context, AppProvider provider, CleaningRequest request) {
    provider.markQuoteAsThinking(request.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🤔 Status: Kunde überlegt noch'),
        backgroundColor: AppTheme.warning,
      ),
    );
  }

  void _simulateView(BuildContext context, AppProvider provider, CleaningRequest request) {
    provider.markQuoteAsViewed(request.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('👀 Ansicht simuliert! (Tracking +1)'),
        backgroundColor: AppTheme.info,
      ),
    );
  }

  // Status-Änderung Dialog (aus AppBar)
  void _showStatusChangeDialog(BuildContext context, AppProvider provider, CleaningRequest request, Quote? quote) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status manuell ändern',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ändere den Status für ${request.customerName}',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            
            _statusListTile(
              icon: Icons.check_circle,
              title: '✅ Offerte annehmen',
              subtitle: 'Auftrag wird automatisch erstellt',
              color: AppTheme.success,
              onTap: () {
                Navigator.pop(ctx);
                _acceptQuote(context, provider, request);
              },
            ),
            _statusListTile(
              icon: Icons.hourglass_empty,
              title: '🤔 Kunde überlegt noch',
              subtitle: 'Zur Nachverfolgung markieren',
              color: AppTheme.warning,
              onTap: () {
                Navigator.pop(ctx);
                _markAsThinking(context, provider, request);
              },
            ),
            _statusListTile(
              icon: Icons.cancel,
              title: '❌ Offerte ablehnen',
              subtitle: 'Mit optionalem Ablehnungsgrund',
              color: AppTheme.error,
              onTap: () {
                Navigator.pop(ctx);
                _rejectQuote(context, provider, request);
              },
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            
            _statusListTile(
              icon: Icons.visibility,
              title: '🧪 Ansicht simulieren (Test)',
              subtitle: 'Fügt eine Tracking-Ansicht hinzu',
              color: AppTheme.info,
              onTap: () {
                Navigator.pop(ctx);
                _simulateView(context, provider, request);
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _statusListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // STATUS-INFO BOX
  Widget _buildStatusInfoBox(bool isAccepted, bool isRejected, bool isThinking) {
    Color bgColor;
    Color borderColor;
    IconData icon;
    String title;
    String message;

    if (isAccepted) {
      bgColor = AppTheme.success.withValues(alpha: 0.1);
      borderColor = AppTheme.success;
      icon = Icons.check_circle;
      title = '✅ Offerte angenommen!';
      message = 'Der Kunde hat die Offerte akzeptiert. Ein Auftrag wurde erstellt.';
    } else if (isRejected) {
      bgColor = AppTheme.error.withValues(alpha: 0.1);
      borderColor = AppTheme.error;
      icon = Icons.cancel;
      title = '❌ Offerte abgelehnt';
      message = 'Der Kunde hat die Offerte leider abgelehnt.';
    } else if (isThinking) {
      bgColor = AppTheme.warning.withValues(alpha: 0.1);
      borderColor = AppTheme.warning;
      icon = Icons.hourglass_empty;
      title = '🤔 Kunde überlegt noch';
      message = 'Der Kunde hat "Ich überlege noch" gewählt. Nachfassen empfohlen!';
    } else {
      bgColor = AppTheme.info.withValues(alpha: 0.1);
      borderColor = AppTheme.info;
      icon = Icons.send;
      title = '📤 Offerte gesendet';
      message = 'Warte auf Kundenreaktion. Tracking zeigt Aktivität.';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: borderColor, fontSize: 15)),
                const SizedBox(height: 4),
                Text(message, style: TextStyle(fontSize: 13, color: borderColor.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ACTION BUTTONS - BASIEREND AUF STATUS
  Widget _buildActionButtons(BuildContext context, AppProvider provider, CleaningRequest request, Quote? quote,
                             bool hasQuote, bool isQuoteSent, bool isAccepted, bool isRejected, bool isThinking, bool isFinal) {
    
    // FALL 1: Angenommen - Zeige "Zum Auftrag" Button
    if (isAccepted) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showQuotePreview(context, request, quote),
              icon: const Icon(Icons.description),
              label: const Text('Offerte'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                // Schließe Detail-Screen
                Navigator.pop(context);
                
                // Wechsle zum Aufträge-Tab (Index 2)
                DefaultTabController.of(context).animateTo(2);
                
                // Zeige Bestätigung
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('✓ Zum Auftrag gewechselt'),
                      ],
                    ),
                    backgroundColor: AppTheme.success,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.work),
              label: const Text('Auftrag ansehen'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            ),
          ),
        ],
      );
    }

    // FALL 2: Abgelehnt - Zeige nur Anzeigen + Archivieren
    if (isRejected) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showQuotePreview(context, request, quote),
              icon: const Icon(Icons.description),
              label: const Text('Offerte anzeigen'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.archive),
              label: const Text('Archivieren'),
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.textSecondary),
            ),
          ),
        ],
      );
    }

    // FALL 3: Ueberlegt - Zeige Anzeigen + Nachfassen
    if (isThinking) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showQuotePreview(context, request, quote),
              icon: const Icon(Icons.description),
              label: const Text('Offerte anzeigen'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _copyToClipboard(context, request.phoneNumber, 'Telefonnummer'),
              icon: const Icon(Icons.phone),
              label: const Text('Jetzt nachfassen'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
            ),
          ),
        ],
      );
    }

    // FALL 4: Offerte gesendet, warte auf Antwort
    if (hasQuote && isQuoteSent) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _copyToClipboard(context, request.phoneNumber, 'Telefonnummer'),
              icon: const Icon(Icons.phone),
              label: const Text('Anrufen'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _showQuotePreview(context, request, quote),
              icon: const Icon(Icons.visibility),
              label: const Text('Gesendete Offerte'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.info),
            ),
          ),
        ],
      );
    }

    // FALL 5: Offerte erstellt aber noch nicht gesendet (Draft)
    if (hasQuote && !isQuoteSent) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _copyToClipboard(context, request.phoneNumber, 'Telefonnummer'),
              icon: const Icon(Icons.phone),
              label: const Text('Anrufen'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateQuoteScreen(
                      request: request,
                      existingQuote: quote,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Offerte senden'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            ),
          ),
        ],
      );
    }

    // FALL 6: Keine Offerte - Neu erstellen
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _copyToClipboard(context, request.phoneNumber, 'Telefonnummer'),
            icon: const Icon(Icons.phone),
            label: const Text('Anrufen'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateQuoteScreen(
                    request: request,
                    existingQuote: null,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Offerte erstellen'),
          ),
        ),
      ],
    );
  }

  // OFFERTE VORSCHAU OEFFNEN
  void _showQuotePreview(BuildContext context, CleaningRequest request, Quote? quote) async {
    if (quote == null) return;
    
    // Zeige Loading-Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Offerte wird generiert...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    try {
      // Generiere HTML mit neuem Service
      final htmlService = QuoteHtmlService();
      final htmlContent = await htmlService.generateQuoteHtml(request, quote);
      
      // Schließe Loading-Dialog
      if (context.mounted) Navigator.pop(context);
      
      // Öffne in neuem Tab
      final blob = html.Blob([htmlContent], 'text/html');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📄 Offerte in neuem Tab geöffnet'),
            backgroundColor: AppTheme.info,
          ),
        );
      }
    } catch (e) {
      // Schließe Loading-Dialog bei Fehler
      if (context.mounted) Navigator.pop(context);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Generieren der Offerte: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // OFFERTEN-INFO CARD
  Widget _buildQuoteInfoCard(BuildContext context, Quote quote) {
    final daysLeft = quote.validUntil.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysLeft <= 2 && daysLeft >= 0;
    final isExpired = daysLeft < 0;

    return Card(
      color: isExpired ? AppTheme.error.withValues(alpha: 0.1) : 
             isExpiringSoon ? AppTheme.warning.withValues(alpha: 0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: isExpired ? AppTheme.error : AppTheme.primaryDark, size: 20),
                const SizedBox(width: 8),
                const Text('Offerten-Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Preis', Formatters.price(quote.price)),
            _buildDetailRow('Gesendet am', Formatters.dateTime(quote.sentAt!)),
            _buildDetailRow(
              'Gültig bis', 
              '${Formatters.date(quote.validUntil)} ${isExpired ? "(ABGELAUFEN)" : isExpiringSoon ? "(bald!)" : ""}',
            ),
            if (quote.customMessage != null && quote.customMessage!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.message, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        quote.customMessage!,
                        style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirtRow(String label, String level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ),
          DirtLevelBadge(level: level),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(Quote quote) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.visibility_outlined, color: AppTheme.info, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Tracking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                StatusBadge.forQuoteStatus(quote.status, isSmall: true),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTrackingStat(Icons.visibility, '${quote.viewCount}', 'Ansichten', AppTheme.info),
                _buildTrackingStat(Icons.timer_outlined, Formatters.duration(quote.totalViewDuration), 'Gesamtzeit', AppTheme.warning),
              ],
            ),
            if (quote.viewCount > 0) ...[
              const Divider(height: 24),
              Text(
                quote.viewCount >= 3 
                  ? '🔥 Hohe Aktivität! Kunde ist sehr interessiert.'
                  : quote.viewCount >= 1
                    ? '👀 Kunde hat die Offerte angesehen.'
                    : '',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textHint)),
      ],
    );
  }

  Widget _buildPriceCard(CleaningRequest request) {
    final suggestedPrice = request.calculateSuggestedPrice();
    
    return Card(
      color: AppTheme.primaryDark.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calculate_outlined, color: AppTheme.primaryDark),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Berechneter Richtpreis', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Text(
                  Formatters.price(suggestedPrice),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label kopiert'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ALTE HTML-GENERIERUNG ENTFERNT - Nutzt jetzt QuoteHtmlService!
}
