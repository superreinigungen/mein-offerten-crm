// Settings-Modelle für die App-Konfiguration
// Diese werden lokal gespeichert (shared_preferences)

/// Firmen-Einstellungen
class CompanySettings {
  final String name;
  final String hotline;
  final String email;
  final String website;
  final String address;
  final String ownerName;
  final String ownerTitle;

  CompanySettings({
    required this.name,
    required this.hotline,
    required this.email,
    required this.website,
    required this.address,
    required this.ownerName,
    required this.ownerTitle,
  });

  // Default-Werte aus aktuellem Template-Editor
  factory CompanySettings.defaultSettings() {
    return CompanySettings(
      name: 'SuperReinigungen.ch',
      hotline: '+41 44 544 20 04',
      email: 'info@superreinigungen.ch',
      website: 'www.superreinigungen.ch',
      address: 'Badenerstrasse 562, CH-8048 Zürich',
      ownerName: 'Petrit Xhaferi',
      ownerTitle: 'Geschäftsführer / Ihr Ansprechpartner',
    );
  }

  factory CompanySettings.fromJson(Map<String, dynamic> json) {
    return CompanySettings(
      name: json['name'] as String,
      hotline: json['hotline'] as String,
      email: json['email'] as String,
      website: json['website'] as String,
      address: json['address'] as String,
      ownerName: json['owner_name'] as String,
      ownerTitle: json['owner_title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hotline': hotline,
      'email': email,
      'website': website,
      'address': address,
      'owner_name': ownerName,
      'owner_title': ownerTitle,
    };
  }

  CompanySettings copyWith({
    String? name,
    String? hotline,
    String? email,
    String? website,
    String? address,
    String? ownerName,
    String? ownerTitle,
  }) {
    return CompanySettings(
      name: name ?? this.name,
      hotline: hotline ?? this.hotline,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      ownerName: ownerName ?? this.ownerName,
      ownerTitle: ownerTitle ?? this.ownerTitle,
    );
  }
}

/// Template-Einstellungen (Leistungen, Zusatz, Konditionen)
class TemplateSettings {
  final int validityDays;
  final String paymentTerms;
  final List<String> standardServices;
  final List<AdditionalServiceTemplate> additionalServices;
  final List<String> conditions;

  TemplateSettings({
    required this.validityDays,
    required this.paymentTerms,
    required this.standardServices,
    required this.additionalServices,
    required this.conditions,
  });

  // Default-Werte aus aktuellem Template-Editor
  factory TemplateSettings.defaultSettings() {
    return TemplateSettings(
      validityDays: 7,
      paymentTerms: 'innert 7 Tagen oder bar bei Abgabe',
      standardServices: [
        'Komplette Endreinigung der Wohnung mit Abnahmegarantie',
        'Küche inkl. Geräte (Backofen, Kühlschrank, Geschirrspüler)',
        'Badezimmer/WC inkl. Entkalkung',
        'Alle Räume inkl. Böden, Fenster, Rahmen',
        'Türen, Schränke, Steckdosen, Lichtschalter',
        'Balkon/Terrasse (falls vorhanden)',
      ],
      additionalServices: [
        AdditionalServiceTemplate(
          name: 'Waschturm (Waschmaschine & Tumbler)',
          code: 'waschturm',
          defaultPrice: 50,
        ),
        AdditionalServiceTemplate(
          name: 'Balkon/Terrasse (Außenbereich)',
          code: 'balkon',
          defaultPrice: 80,
        ),
        AdditionalServiceTemplate(
          name: 'Keller/Estrich (Lagerräume)',
          code: 'keller',
          defaultPrice: 100,
        ),
        AdditionalServiceTemplate(
          name: 'Garage/Hobbyraum (Nebenräume)',
          code: 'garage',
          defaultPrice: 120,
        ),
        AdditionalServiceTemplate(
          name: 'Teppichreinigung (Professionell)',
          code: 'teppich',
          defaultPrice: 150,
        ),
        AdditionalServiceTemplate(
          name: 'Parkettpflege (Spezialpflege)',
          code: 'parkett',
          defaultPrice: 100,
        ),
        AdditionalServiceTemplate(
          name: 'Hochdruckreinigung (Außenflächen)',
          code: 'hochdruck',
          defaultPrice: 180,
        ),
        AdditionalServiceTemplate(
          name: 'Bohrlöcher zugipsen (Verspachteln)',
          code: 'bohrlocher',
          defaultPrice: 80,
        ),
      ],
      conditions: [
        'Der Preis versteht sich als Pauschalpreis, inkl. MwSt.',
        'Bezahlung erfolgt auf Rechnung, zahlbar innert 7 Tagen oder bar bei Abgabe.',
        'Kostenlose Nachreinigung bei berechtigten Beanstandungen (Abnahmegarantie).',
        'Die Wohnung muss am Reinigungstag leer und besenrein sein.',
      ],
    );
  }

  factory TemplateSettings.fromJson(Map<String, dynamic> json) {
    return TemplateSettings(
      validityDays: json['validity_days'] as int,
      paymentTerms: json['payment_terms'] as String,
      standardServices: (json['standard_services'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      additionalServices: (json['additional_services'] as List<dynamic>)
          .map((e) => AdditionalServiceTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
      conditions: (json['conditions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'validity_days': validityDays,
      'payment_terms': paymentTerms,
      'standard_services': standardServices,
      'additional_services': additionalServices.map((e) => e.toJson()).toList(),
      'conditions': conditions,
    };
  }

  TemplateSettings copyWith({
    int? validityDays,
    String? paymentTerms,
    List<String>? standardServices,
    List<AdditionalServiceTemplate>? additionalServices,
    List<String>? conditions,
  }) {
    return TemplateSettings(
      validityDays: validityDays ?? this.validityDays,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      standardServices: standardServices ?? this.standardServices,
      additionalServices: additionalServices ?? this.additionalServices,
      conditions: conditions ?? this.conditions,
    );
  }
}

/// Zusatzleistung-Template
class AdditionalServiceTemplate {
  final String name;
  final String code;
  final double defaultPrice;

  AdditionalServiceTemplate({
    required this.name,
    required this.code,
    required this.defaultPrice,
  });

  factory AdditionalServiceTemplate.fromJson(Map<String, dynamic> json) {
    return AdditionalServiceTemplate(
      name: json['name'] as String,
      code: json['code'] as String,
      defaultPrice: (json['default_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'default_price': defaultPrice,
    };
  }
}

/// E-Mail-Einstellungen
class EmailSettings {
  final String subject;
  final String introText;

  EmailSettings({
    required this.subject,
    required this.introText,
  });

  factory EmailSettings.defaultSettings() {
    return EmailSettings(
      subject: 'Ihre Offerte für die Umzugsreinigung - SuperReinigungen.ch',
      introText: 'Vielen Dank für Ihre Anfrage. Wir freuen uns, Ihnen folgendes Angebot für die Umzugsreinigung mit Abnahmegarantie unterbreiten zu können.',
    );
  }

  factory EmailSettings.fromJson(Map<String, dynamic> json) {
    return EmailSettings(
      subject: json['subject'] as String,
      introText: json['intro_text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'intro_text': introText,
    };
  }

  EmailSettings copyWith({
    String? subject,
    String? introText,
  }) {
    return EmailSettings(
      subject: subject ?? this.subject,
      introText: introText ?? this.introText,
    );
  }
}

/// Design-Einstellungen
class DesignSettings {
  final String primaryColor;
  final String accentColor;
  final String logoPath;

  DesignSettings({
    required this.primaryColor,
    required this.accentColor,
    required this.logoPath,
  });

  factory DesignSettings.defaultSettings() {
    return DesignSettings(
      primaryColor: '#1a237e',
      accentColor: '#0d47a1',
      logoPath: 'assets/images/sr_logo.png',
    );
  }

  factory DesignSettings.fromJson(Map<String, dynamic> json) {
    return DesignSettings(
      primaryColor: json['primary_color'] as String,
      accentColor: json['accent_color'] as String,
      logoPath: json['logo_path'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_color': primaryColor,
      'accent_color': accentColor,
      'logo_path': logoPath,
    };
  }

  DesignSettings copyWith({
    String? primaryColor,
    String? accentColor,
    String? logoPath,
  }) {
    return DesignSettings(
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      logoPath: logoPath ?? this.logoPath,
    );
  }
}
