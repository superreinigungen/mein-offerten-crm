import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

/// Service für lokale Einstellungen (shared_preferences)
/// Speichert: Company, Template, Email, Design Settings
class SettingsService {
  static const String _keyCompany = 'company_settings';
  static const String _keyTemplate = 'template_settings';
  static const String _keyEmail = 'email_settings';
  static const String _keyDesign = 'design_settings';

  // Singleton Pattern
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SharedPreferences? _prefs;

  /// Initialisiert den Service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Stellt sicher dass SharedPreferences initialisiert ist
  Future<SharedPreferences> get _sharedPreferences async {
    if (_prefs == null) {
      await initialize();
    }
    return _prefs!;
  }

  // ============================================================
  // COMPANY SETTINGS
  // ============================================================

  /// Lädt Company Settings (oder gibt Defaults zurück)
  Future<CompanySettings> getCompanySettings() async {
    final prefs = await _sharedPreferences;
    final jsonString = prefs.getString(_keyCompany);
    
    if (jsonString == null) {
      // Erste Nutzung - gebe Defaults zurück
      return CompanySettings.defaultSettings();
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return CompanySettings.fromJson(json);
    } catch (e) {
      // Fehler beim Parsen - gebe Defaults zurück
      return CompanySettings.defaultSettings();
    }
  }

  /// Speichert Company Settings
  Future<bool> saveCompanySettings(CompanySettings settings) async {
    try {
      final prefs = await _sharedPreferences;
      final jsonString = jsonEncode(settings.toJson());
      return await prefs.setString(_keyCompany, jsonString);
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // TEMPLATE SETTINGS
  // ============================================================

  /// Lädt Template Settings (oder gibt Defaults zurück)
  Future<TemplateSettings> getTemplateSettings() async {
    final prefs = await _sharedPreferences;
    final jsonString = prefs.getString(_keyTemplate);
    
    if (jsonString == null) {
      return TemplateSettings.defaultSettings();
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return TemplateSettings.fromJson(json);
    } catch (e) {
      return TemplateSettings.defaultSettings();
    }
  }

  /// Speichert Template Settings
  Future<bool> saveTemplateSettings(TemplateSettings settings) async {
    try {
      final prefs = await _sharedPreferences;
      final jsonString = jsonEncode(settings.toJson());
      return await prefs.setString(_keyTemplate, jsonString);
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // EMAIL SETTINGS
  // ============================================================

  /// Lädt Email Settings (oder gibt Defaults zurück)
  Future<EmailSettings> getEmailSettings() async {
    final prefs = await _sharedPreferences;
    final jsonString = prefs.getString(_keyEmail);
    
    if (jsonString == null) {
      return EmailSettings.defaultSettings();
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return EmailSettings.fromJson(json);
    } catch (e) {
      return EmailSettings.defaultSettings();
    }
  }

  /// Speichert Email Settings
  Future<bool> saveEmailSettings(EmailSettings settings) async {
    try {
      final prefs = await _sharedPreferences;
      final jsonString = jsonEncode(settings.toJson());
      return await prefs.setString(_keyEmail, jsonString);
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // DESIGN SETTINGS
  // ============================================================

  /// Lädt Design Settings (oder gibt Defaults zurück)
  Future<DesignSettings> getDesignSettings() async {
    final prefs = await _sharedPreferences;
    final jsonString = prefs.getString(_keyDesign);
    
    if (jsonString == null) {
      return DesignSettings.defaultSettings();
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return DesignSettings.fromJson(json);
    } catch (e) {
      return DesignSettings.defaultSettings();
    }
  }

  /// Speichert Design Settings
  Future<bool> saveDesignSettings(DesignSettings settings) async {
    try {
      final prefs = await _sharedPreferences;
      final jsonString = jsonEncode(settings.toJson());
      return await prefs.setString(_keyDesign, jsonString);
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Lädt alle Einstellungen auf einmal
  Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'company': await getCompanySettings(),
      'template': await getTemplateSettings(),
      'email': await getEmailSettings(),
      'design': await getDesignSettings(),
    };
  }

  /// Reset auf Standardeinstellungen
  Future<bool> resetToDefaults() async {
    try {
      await saveCompanySettings(CompanySettings.defaultSettings());
      await saveTemplateSettings(TemplateSettings.defaultSettings());
      await saveEmailSettings(EmailSettings.defaultSettings());
      await saveDesignSettings(DesignSettings.defaultSettings());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Löscht alle gespeicherten Einstellungen
  Future<bool> clearAllSettings() async {
    try {
      final prefs = await _sharedPreferences;
      await prefs.remove(_keyCompany);
      await prefs.remove(_keyTemplate);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyDesign);
      return true;
    } catch (e) {
      return false;
    }
  }
}
