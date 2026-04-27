import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cleaning_request.dart';
import '../models/quote.dart';

/// Service für E-Mail Versand
class EmailService {
  static EmailService? _instance;
  
  // Supabase Edge Function URL für E-Mail Versand
  String? _edgeFunctionUrl;
  String? _anonKey;

  EmailService._();

  static EmailService get instance {
    _instance ??= EmailService._();
    return _instance!;
  }

  void configure({
    required String edgeFunctionUrl,
    required String anonKey,
  }) {
    _edgeFunctionUrl = edgeFunctionUrl;
    _anonKey = anonKey;
  }

  /// Sendet die Offerte per E-Mail an den Kunden
  Future<bool> sendQuoteEmail({
    required CleaningRequest request,
    required Quote quote,
  }) async {
    if (_edgeFunctionUrl == null || _anonKey == null) {
      throw Exception('EmailService nicht konfiguriert');
    }

    final quoteLink = quote.getQuoteLink();
    
    final emailBody = _buildQuoteEmailHtml(
      customerName: request.customerName,
      address: request.address,
      cleaningDate: request.cleaningDate,
      price: quote.price,
      quoteLink: quoteLink,
      validUntil: quote.validUntil,
      customMessage: quote.customMessage,
    );

    try {
      final response = await http.post(
        Uri.parse('$_edgeFunctionUrl/send-email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_anonKey',
        },
        body: jsonEncode({
          'to': request.email,
          'subject': 'Ihre Offerte für die Umzugsreinigung - Super Reinigungen',
          'html': emailBody,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Baut den HTML-Inhalt der E-Mail
  String _buildQuoteEmailHtml({
    required String customerName,
    required String address,
    required DateTime cleaningDate,
    required double price,
    required String quoteLink,
    required DateTime validUntil,
    String? customMessage,
  }) {
    final formattedDate = '${cleaningDate.day}.${cleaningDate.month}.${cleaningDate.year}';
    final formattedValidUntil = '${validUntil.day}.${validUntil.month}.${validUntil.year}';
    final formattedPrice = price.toStringAsFixed(2);

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; background-color: #f5f5f5;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f5f5f5; padding: 20px 0;">
    <tr>
      <td align="center">
        <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
          <!-- Header -->
          <tr>
            <td style="background: linear-gradient(135deg, #1a237e 0%, #0d47a1 100%); padding: 30px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 600;">Super Reinigungen</h1>
              <p style="color: #90caf9; margin: 10px 0 0; font-size: 16px;">Ihre Offerte ist bereit</p>
            </td>
          </tr>
          
          <!-- Content -->
          <tr>
            <td style="padding: 40px 30px;">
              <p style="font-size: 18px; color: #333; margin: 0 0 20px;">
                Guten Tag <strong>$customerName</strong>,
              </p>
              
              <p style="font-size: 16px; color: #555; line-height: 1.6; margin: 0 0 25px;">
                Vielen Dank für Ihre Anfrage. Wir haben Ihre Offerte für die Umzugsreinigung erstellt.
              </p>

              ${customMessage != null ? '''
              <div style="background-color: #e3f2fd; border-left: 4px solid #1976d2; padding: 15px; margin: 0 0 25px; border-radius: 0 8px 8px 0;">
                <p style="margin: 0; color: #1565c0; font-size: 14px;">$customMessage</p>
              </div>
              ''' : ''}

              <!-- Details Box -->
              <div style="background-color: #fafafa; border-radius: 8px; padding: 25px; margin: 0 0 25px;">
                <h3 style="color: #1a237e; margin: 0 0 15px; font-size: 18px;">Ihre Reinigung</h3>
                <table width="100%" cellpadding="8" cellspacing="0">
                  <tr>
                    <td style="color: #666; font-size: 14px;">📍 Adresse:</td>
                    <td style="color: #333; font-size: 14px; font-weight: 500;">$address</td>
                  </tr>
                  <tr>
                    <td style="color: #666; font-size: 14px;">📅 Reinigungstermin:</td>
                    <td style="color: #333; font-size: 14px; font-weight: 500;">$formattedDate</td>
                  </tr>
                </table>
              </div>

              <!-- Price Box -->
              <div style="background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%); border-radius: 8px; padding: 25px; text-align: center; margin: 0 0 25px;">
                <p style="color: #2e7d32; font-size: 14px; margin: 0 0 5px; text-transform: uppercase; letter-spacing: 1px;">Ihr Preis</p>
                <p style="color: #1b5e20; font-size: 42px; font-weight: 700; margin: 0;">CHF $formattedPrice</p>
                <p style="color: #388e3c; font-size: 12px; margin: 10px 0 0;">Inkl. MwSt. • Keine versteckten Kosten</p>
              </div>

              <!-- CTA Button -->
              <div style="text-align: center; margin: 30px 0;">
                <a href="$quoteLink" style="display: inline-block; background: linear-gradient(135deg, #1a237e 0%, #0d47a1 100%); color: #ffffff; text-decoration: none; padding: 16px 40px; border-radius: 8px; font-size: 16px; font-weight: 600; box-shadow: 0 4px 12px rgba(26,35,126,0.3);">
                  Offerte ansehen & entscheiden
                </a>
              </div>

              <p style="font-size: 13px; color: #888; text-align: center; margin: 20px 0 0;">
                Diese Offerte ist gültig bis: <strong>$formattedValidUntil</strong>
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background-color: #fafafa; padding: 25px 30px; border-top: 1px solid #eee;">
              <p style="font-size: 14px; color: #666; margin: 0 0 10px; text-align: center;">
                Fragen? Rufen Sie uns an oder schreiben Sie uns.
              </p>
              <p style="font-size: 14px; color: #1a237e; margin: 0; text-align: center; font-weight: 500;">
                📞 +41 XX XXX XX XX • ✉️ info@shiny-cleaning.ch
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';
  }

  /// Generiert einen Link zum Kopieren für WhatsApp (falls später benötigt)
  String generateWhatsAppLink({
    required String phoneNumber,
    required String customerName,
    required String quoteLink,
  }) {
    // Schweizer Nummern formatieren
    String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '41${formattedPhone.substring(1)}';
    }

    final message = Uri.encodeComponent(
      'Guten Tag $customerName,\n\n'
      'Ihre Offerte für die Umzugsreinigung ist bereit.\n\n'
      '👉 $quoteLink\n\n'
      'Bei Fragen stehen wir Ihnen gerne zur Verfügung.\n\n'
      'Freundliche Grüsse\n'
      'Super Reinigungen'
    );

    return 'https://wa.me/$formattedPhone?text=$message';
  }
}
