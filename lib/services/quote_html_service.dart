import '../models/cleaning_request.dart';
import '../models/quote.dart';
import '../models/settings.dart';
import 'settings_service.dart';

/// Service für die Generierung von Offerten-HTML
class QuoteHtmlService {
  final SettingsService _settingsService = SettingsService();

  /// Generiert vollständiges HTML für eine Offerte mit allen Settings
  Future<String> generateQuoteHtml(CleaningRequest request, Quote quote) async {
    // Lade aktuelle Einstellungen
    final company = await _settingsService.getCompanySettings();
    final template = await _settingsService.getTemplateSettings();
    final design = await _settingsService.getDesignSettings();

    final createdDate = quote.sentAt ?? DateTime.now();
    final validUntilDate = quote.validUntil;
    final price = quote.price;
    final customMessage = quote.customMessage ?? '';
    
    // Status-Banner basierend auf Quote-Status
    String statusBanner = '';
    if (quote.status == QuoteStatus.accepted) {
      statusBanner = '<div style="background:#4caf50;color:white;text-align:center;padding:12px;font-weight:600;">✅ ANGENOMMEN</div>';
    } else if (quote.status == QuoteStatus.rejected) {
      statusBanner = '<div style="background:#f44336;color:white;text-align:center;padding:12px;font-weight:600;">❌ ABGELEHNT</div>';
    } else if (quote.status == QuoteStatus.thinking) {
      statusBanner = '<div style="background:#ff9800;color:white;text-align:center;padding:12px;font-weight:600;">🤔 KUNDE ÜBERLEGT</div>';
    } else {
      statusBanner = '<div style="background:#2196f3;color:white;text-align:center;padding:12px;font-weight:600;">📤 OFFERTE</div>';
    }

    // Positionen aufteilen
    final standardPositions = quote.positions.where((p) => !p.isAdditional).toList();
    final additionalPositions = quote.positions.where((p) => p.isAdditional).toList();

    // Wenn Quote keine Positionen hat, nehme Template-Daten als Fallback
    final displayStandardServices = standardPositions.isNotEmpty
        ? standardPositions.map((p) => p.name).toList()
        : template.standardServices;

    // Zusatzleistungen HTML
    String additionalServicesHtml = '';
    if (additionalPositions.isNotEmpty) {
      additionalServicesHtml = '''
        <div class="section">
          <h3 class="section-title">Zusatzleistungen</h3>
          <table class="additional-services-table">
            ${additionalPositions.map((p) => '''
              <tr>
                <td class="service-name">${p.name}${p.quantity > 1 ? ' (${p.quantity}x)' : ''}</td>
                <td class="service-price">CHF ${p.totalPrice.toStringAsFixed(2)}</td>
              </tr>
            ''').join('')}
          </table>
        </div>
      ''';
    }

    // Konditionen HTML
    String conditionsHtml = '';
    final displayConditions = quote.conditions.isNotEmpty ? quote.conditions : template.conditions;
    if (displayConditions.isNotEmpty) {
      conditionsHtml = '''
        <div class="section">
          <h3 class="section-title">Konditionen</h3>
          <ol class="conditions-list">
            ${displayConditions.map((c) => '<li>$c</li>').join('')}
          </ol>
          <p style="margin-top:12px;font-weight:500;">Zahlungsbedingungen: ${template.paymentTerms}</p>
        </div>
      ''';
    }

    return '''
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Offerte - ${request.customerName}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Arial, sans-serif; background: #f5f5f5; color: #333; line-height: 1.6; }
        .container { max-width: 800px; margin: 0 auto; background: white; box-shadow: 0 0 20px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, ${design.primaryColor}, ${design.accentColor}); color: white; padding: 30px 40px; }
        .header-top { display: flex; justify-content: space-between; align-items: flex-start; }
        .logo { font-size: 28px; font-weight: 700; }
        .contact-info { text-align: right; font-size: 13px; opacity: 0.9; }
        .contact-info a { color: white; text-decoration: none; }
        .offerte-header { background: #e3f2fd; padding: 25px 40px; border-bottom: 3px solid ${design.primaryColor}; }
        .offerte-header h1 { color: ${design.primaryColor}; font-size: 22px; margin-bottom: 15px; }
        .offerte-meta { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
        .meta-item { display: flex; flex-direction: column; }
        .meta-label { font-size: 11px; color: #666; text-transform: uppercase; }
        .meta-value { font-size: 15px; font-weight: 600; color: ${design.primaryColor}; }
        .content { padding: 30px 40px; }
        .greeting { font-size: 17px; margin-bottom: 15px; }
        .section { margin-bottom: 25px; }
        .section-title { font-size: 15px; font-weight: 600; color: ${design.primaryColor}; margin-bottom: 12px; padding-bottom: 8px; border-bottom: 2px solid #e0e0e0; }
        .details-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
        .detail-row { display: flex; padding: 8px 12px; background: #fafafa; border-radius: 6px; }
        .detail-label { width: 120px; color: #666; font-size: 13px; }
        .detail-value { font-weight: 500; color: #333; font-size: 13px; }
        .services-list { list-style: none; }
        .services-list li { padding: 8px 12px; background: #fafafa; margin-bottom: 6px; border-radius: 6px; }
        .services-list li::before { content: '✓ '; color: #4caf50; font-weight: bold; }
        .additional-services-table { width: 100%; border-collapse: collapse; }
        .additional-services-table tr { border-bottom: 1px solid #e0e0e0; }
        .additional-services-table td { padding: 10px 12px; }
        .service-name { color: #333; font-size: 14px; }
        .service-price { text-align: right; font-weight: 600; color: ${design.primaryColor}; font-size: 14px; }
        .conditions-list { padding-left: 20px; }
        .conditions-list li { margin-bottom: 8px; color: #555; font-size: 13px; }
        .custom-message { background: #e3f2fd; border-left: 4px solid ${design.primaryColor}; padding: 15px; margin: 20px 0; border-radius: 0 8px 8px 0; font-style: italic; }
        .price-box { background: linear-gradient(135deg, #e8f5e9, #c8e6c9); border-radius: 12px; padding: 25px; text-align: center; margin: 25px 0; border: 2px solid #4caf50; }
        .price-label { font-size: 13px; color: #2e7d32; text-transform: uppercase; }
        .price-amount { font-size: 42px; font-weight: 700; color: #1b5e20; }
        .price-info { font-size: 12px; color: #388e3c; margin-top: 8px; }
        .footer { background: ${design.primaryColor}; color: white; padding: 25px 40px; }
        .footer-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px; }
        .footer-section h4 { font-size: 14px; margin-bottom: 8px; opacity: 0.9; }
        .footer-section p { font-size: 13px; margin: 4px 0; }
        .footer-section a { color: #90caf9; text-decoration: none; }
        .signature { margin-top: 20px; padding-top: 15px; border-top: 1px solid rgba(255,255,255,0.2); text-align: center; }
        @media (max-width: 600px) { 
          .header, .content, .footer { padding: 20px; } 
          .offerte-meta, .details-grid, .footer-grid { grid-template-columns: 1fr; } 
          .price-amount { font-size: 32px; } 
        }
    </style>
</head>
<body>
    $statusBanner
    <div class="container">
        <header class="header">
            <div class="header-top">
                <div class="logo">${company.name}</div>
                <div class="contact-info">
                    <div>${company.hotline}</div>
                    <div><a href="mailto:${company.email}">${company.email}</a></div>
                </div>
            </div>
        </header>
        <div class="offerte-header">
            <h1>Offerte für Umzugsreinigung</h1>
            <div class="offerte-meta">
                <div class="meta-item"><span class="meta-label">Erstellt am</span><span class="meta-value">${_formatDate(createdDate)}</span></div>
                <div class="meta-item"><span class="meta-label">Gültig bis</span><span class="meta-value">${_formatDate(validUntilDate)}</span></div>
                <div class="meta-item"><span class="meta-label">Kunde</span><span class="meta-value">${request.customerName}</span></div>
                <div class="meta-item"><span class="meta-label">Reinigungstermin</span><span class="meta-value">${_formatDate(request.cleaningDate)}</span></div>
            </div>
        </div>
        <main class="content">
            <p class="greeting">Guten Tag <strong>${request.customerName.split(' ').first}</strong>,</p>
            <p style="color:#555;margin-bottom:25px;">Vielen Dank für Ihre Anfrage. Hier ist unser Angebot:</p>
            <div class="section">
                <h3 class="section-title">Objekt-Informationen</h3>
                <div class="details-grid">
                    <div class="detail-row"><span class="detail-label">Adresse</span><span class="detail-value">${request.address}</span></div>
                    <div class="detail-row"><span class="detail-label">Objekttyp</span><span class="detail-value">${request.objectType}</span></div>
                    <div class="detail-row"><span class="detail-label">Zimmer</span><span class="detail-value">${request.roomCount}</span></div>
                    <div class="detail-row"><span class="detail-label">Fläche</span><span class="detail-value">${request.areaRange}</span></div>
                </div>
            </div>
            <div class="section">
                <h3 class="section-title">Leistungsumfang</h3>
                <ul class="services-list">
                    ${displayStandardServices.map((s) => '<li>$s</li>').join('')}
                </ul>
            </div>
            $additionalServicesHtml
            ${customMessage.isNotEmpty ? '<div class="custom-message"><strong>Persönliche Nachricht:</strong><br>$customMessage</div>' : ''}
            <div class="price-box">
                <div class="price-label">Pauschalpreis</div>
                <div class="price-amount">CHF ${price.toStringAsFixed(2)}</div>
                <div class="price-info">Inkl. MwSt. • Mit Abnahmegarantie</div>
            </div>
            $conditionsHtml
        </main>
        <footer class="footer">
            <div class="footer-grid">
                <div class="footer-section">
                    <h4>Kontakt</h4>
                    <p>${company.name}</p>
                    <p><a href="tel:${company.hotline.replaceAll(' ', '')}">${company.hotline}</a></p>
                    <p><a href="mailto:${company.email}">${company.email}</a></p>
                    <p><a href="https://${company.website}" target="_blank">${company.website}</a></p>
                </div>
                <div class="footer-section">
                    <h4>Adresse</h4>
                    <p>${company.address}</p>
                </div>
            </div>
            <div class="signature">
                <div style="font-size:16px;font-weight:600;">Freundliche Grüsse, ${company.ownerName}</div>
                <div style="font-size:12px;opacity:0.8;">${company.ownerTitle}</div>
            </div>
        </footer>
    </div>
</body>
</html>
''';
  }

  String _formatDate(DateTime date) {
    const months = ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 
                    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];
    return '${date.day}. ${months[date.month - 1]} ${date.year}';
  }
}
