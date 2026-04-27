# CLEVO Pro - CRM & Offerten-Management

Reinigungsunternehmen CRM-App fuer SuperReinigungen.ch
Entwickelt fuer Petrit Xhaferi, Geschaeftsfuehrer

---

## Inhaltsverzeichnis

1. [App-Uebersicht](#app-uebersicht)
2. [Architektur & Dateistruktur](#architektur--dateistruktur)
3. [Screens & Navigation](#screens--navigation)
4. [Datenmodelle](#datenmodelle)
5. [Kompletter App-Flow](#kompletter-app-flow)
6. [Preisberechnung](#preisberechnung)
7. [Offerten-System](#offerten-system)
8. [Status-Logik](#status-logik)
9. [Einstellungen & Templates](#einstellungen--templates)
10. [Changelog & Fixes](#changelog--fixes)

---

## App-Uebersicht

CLEVO Pro ist ein mobiles CRM fuer Reinigungsunternehmen mit folgenden Kernfunktionen:

- **Anfragen verwalten** - Kundenanfragen einsehen, bearbeiten, priorisieren
- **Offerten erstellen** - Automatische Preisberechnung, Positionen-System, HTML-Offerten
- **Auftraege tracken** - Angenommene Offerten werden automatisch zu Auftraegen
- **Tracking** - Wie oft hat der Kunde die Offerte angeschaut (Hot Lead Detection)
- **Statistiken** - Conversion Rate, Umsatz, Hot Leads
- **Template-System** - Offerten-Vorlagen, Konditionen, Design anpassbar

**Tech Stack:**
- Flutter 3.35.4 / Dart 3.9.2
- State Management: Provider (ChangeNotifier)
- Lokale Speicherung: shared_preferences
- Demo-Modus: Alle Daten sind lokal, kein Backend noetig

---

## Architektur & Dateistruktur

```
lib/
|-- main.dart                          # App Entry Point, MainScreen mit BottomNav
|
|-- models/
|   |-- cleaning_request.dart          # Anfrage-Model (Kunde, Objekt, Verschmutzung)
|   |-- quote.dart                     # Offerte-Model (Positionen, Preis, Status, Tracking)
|   |-- order.dart                     # Auftrag-Model (nach Annahme einer Offerte)
|   |-- settings.dart                  # Settings-Models (Company, Template, Email, Design)
|   |-- statistics.dart                # Statistik-Model
|
|-- providers/
|   |-- app_provider.dart              # Haupt-Provider (State, Demo-Daten, CRUD-Operationen)
|   |-- cleaning_request_provider.dart # (Legacy, nicht aktiv im Demo-Mode)
|   |-- firebase_provider.dart         # (Firebase, nicht aktiv im Demo-Mode)
|
|-- screens/
|   |-- dashboard_screen.dart          # Dashboard mit Quick-Stats + neue Anfragen
|   |-- requests_screen.dart           # Anfragen-Liste mit 5 Status-Tabs
|   |-- request_detail_screen.dart     # Anfrage-Detail + Status-Steuerung + Tracking
|   |-- create_quote_screen.dart       # Offerte erstellen/bearbeiten (Positions-System)
|   |-- orders_screen.dart             # Auftraege-Liste mit 4 Status-Tabs
|   |-- statistics_screen.dart         # Statistik-Dashboard
|   |-- template_editor_screen.dart    # Offerten-Vorlage bearbeiten
|   |-- design_editor_screen.dart      # Offerten-Design (Farben, Logo)
|
|-- services/
|   |-- settings_service.dart          # SharedPreferences Speicherung (Singleton)
|   |-- quote_html_service.dart        # HTML-Generierung fuer Offerten-Vorschau
|   |-- email_service.dart             # E-Mail Versand (Platzhalter)
|   |-- firebase_service.dart          # Firebase Service (nicht aktiv im Demo-Mode)
|
|-- widgets/
|   |-- request_card.dart              # Anfrage-Karte (Listenansicht)
|   |-- stat_card.dart                 # Statistik-Karte
|   |-- status_badge.dart              # Status-Badges + HotLead-Badge + DirtLevel-Badge
|
|-- utils/
|   |-- theme.dart                     # AppTheme (Farben, Styles, Material Design 3)
|   |-- formatters.dart                # Formatter (Preis CHF, Datum, Telefon, Dauer)
```

---

## Screens & Navigation

### Bottom Navigation (4 Tabs)
```
[Dashboard] [Anfragen] [Auftraege] [Statistik]
     0           1           2           3
```

### Screen-Hierarchie
```
MainScreen (BottomNav mit IndexedStack)
  |
  |-- DashboardScreen (Tab 0)
  |     |-- Gradient-Header mit Quick-Stats
  |     |     |-- Neue Anfragen (Zahl)
  |     |     |-- Hot Leads (Zahl, hervorgehoben wenn > 0)
  |     |     +-- Angenommen (Zahl)
  |     |-- Settings-Buttons -> TemplateEditorScreen / DesignEditorScreen
  |     +-- Neue Anfragen Liste (neueste zuerst)
  |           +-- RequestCard -> RequestDetailScreen
  |
  |-- RequestsScreen (Tab 1)
  |     |-- Tab "Neu"        -> Anfragen mit Status newRequest
  |     |-- Tab "Gesendet"   -> quoteSent + viewed
  |     |-- Tab "Ueberlegt"  -> thinking
  |     |-- Tab "Angenommen" -> accepted
  |     +-- Tab "Abgelehnt"  -> rejected
  |           +-- RequestCard -> RequestDetailScreen
  |                 |-- Kontaktdaten, Objekt, Verschmutzungsgrad
  |                 |-- Zusatzleistungen (aus Anfrage)
  |                 |-- Tracking-Card (wenn Offerte gesendet)
  |                 |-- Offerten-Details (wenn gesendet)
  |                 |-- Richtpreis (wenn keine Offerte)
  |                 |-- Manuelle Status-Steuerung (Annehmen/Ueberlegt/Ablehnen)
  |                 +-- Bottom-Buttons (je nach Status)
  |                       +-- "Offerte erstellen" -> CreateQuoteScreen
  |                             |-- Tab "Positionen" (Grundpreis, Standard, Zusatz, Konditionen)
  |                             +-- Tab "Vorschau" (wie Kunde es sieht)
  |
  |-- OrdersScreen (Tab 2)
  |     |-- Tab "Anstehend"  -> pending
  |     |-- Tab "Heute"      -> heutige Auftraege
  |     |-- Tab "Erledigt"   -> completed
  |     +-- Tab "Storniert"  -> cancelled
  |           +-- OrderCard (Kundeninfo, Preis, Termin, Team, Aktionen)
  |
  +-- StatisticsScreen (Tab 3)
        |-- Gesamtanfragen, Offerten, Conversion-Rate
        +-- Umsatz, Durchschnittlicher Offertenwert
```

---

## Datenmodelle

### CleaningRequest (Anfrage)
| Feld                | Typ                  | Beispiel                                  |
|---------------------|----------------------|-------------------------------------------|
| id                  | String               | "1"                                       |
| customerName        | String               | "Thomas Weber"                            |
| phoneNumber         | String               | "+41 79 123 45 67"                        |
| email               | String               | "thomas.weber@email.ch"                   |
| address             | String               | "Winterthurerstrasse 55, 8006 Zuerich"    |
| roomCount           | double               | 4.5                                       |
| objectType          | String               | "Wohnung" oder "Haus"                     |
| areaRange           | String               | "100-130 m2"                              |
| cleaningDate        | DateTime             | Reinigungstermin                          |
| inspectionDate      | DateTime?            | Abnahmetermin (optional)                  |
| dirtLevel           | DirtLevel            | 7 Kategorien (leicht/mittel/stark)        |
| additionalServices  | List<AdditionalService> | [balkon, waschturm]                    |
| status              | RequestStatus        | newRequest/quoteSent/thinking/accepted/rejected |

### DirtLevel (Verschmutzungsgrad - 7 Bereiche)
| Bereich          | Moegliche Werte          | Zuschlag mittel | Zuschlag stark |
|------------------|--------------------------|-----------------|----------------|
| kitchen          | leicht / mittel / stark  | CHF 15          | CHF 30         |
| kitchenAppliances| leicht / mittel / stark  | CHF 20          | CHF 40         |
| bathroom         | leicht / mittel / stark  | CHF 25          | CHF 50         |
| limescale        | leicht / mittel / stark  | CHF 30          | CHF 60         |
| windows          | leicht / mittel / stark  | CHF 10          | CHF 20         |
| blinds           | leicht / mittel / stark  | CHF 15          | CHF 30         |
| floors           | leicht / mittel / stark  | CHF 20          | CHF 40         |

### AdditionalService (Enum - synchronisiert mit TemplateSettings)
| Code       | Bezeichnung                           | Preis (CHF) |
|------------|---------------------------------------|-------------|
| waschturm  | Waschturm (Waschmaschine & Tumbler)   | 50          |
| balkon     | Balkon/Terrasse (Aussenbereich)       | 80          |
| keller     | Keller/Estrich (Lagerraeume)          | 100         |
| garage     | Garage/Hobbyraum (Nebenraeume)        | 120         |
| teppich    | Teppichreinigung (Professionell)      | 150         |
| parkett    | Parkettpflege (Spezialpflege)         | 100         |
| hochdruck  | Hochdruckreinigung (Aussenflaechen)   | 180         |
| bohrlocher | Bohrloecher zugipsen (Verspachteln)   | 80          |

**WICHTIG:** Die Preise im `AdditionalService` Enum muessen IMMER mit den
`defaultPrice` Werten in `TemplateSettings.additionalServices` uebereinstimmen!
Sonst entstehen Preisdifferenzen zwischen Richtpreis und Offerten-Positionen.

### Quote (Offerte)
| Feld            | Typ                | Beschreibung                              |
|-----------------|--------------------|-------------------------------------------|
| id              | String             | Eindeutige ID                             |
| requestId       | String             | Verknuepfung zur Anfrage                  |
| price           | double             | Endpreis (Grundpreis + Zusatzleistungen)  |
| suggestedPrice  | double             | Berechneter Richtpreis (zur Referenz)     |
| positions       | List<QuotePosition>| Standard + Zusatzleistungen               |
| conditions      | List<String>       | AGB-Konditionen                           |
| views           | List<QuoteView>    | Tracking: wann + wie lange angeschaut     |
| sentAt          | DateTime?          | null = Draft, Datum = gesendet            |
| status          | QuoteStatus        | draft/sent/viewed/accepted/rejected/thinking |

### QuotePosition (Offerten-Position)
| Feld         | Typ    | Beschreibung                              |
|--------------|--------|-------------------------------------------|
| name         | String | "Kueche inkl. Geraete..."                 |
| unitPrice    | double | 0.0 fuer Standard, > 0 fuer Zusatz        |
| quantity     | int    | Menge (meist 1)                           |
| isAdditional | bool   | false = im Grundpreis, true = Extrapreis  |
| totalPrice   | double | (getter) unitPrice * quantity              |

### Order (Auftrag - wird bei Annahme einer Offerte erstellt)
| Feld               | Typ          | Beschreibung                       |
|--------------------|--------------|------------------------------------|
| id                 | String       | Automatisch generiert              |
| requestId/quoteId  | String       | Verknuepfung                       |
| customerName       | String       | Kopie der Kundendaten              |
| address            | String       | Reinigungsadresse                  |
| cleaningDate       | DateTime     | Termin                             |
| price              | double       | Vereinbarter Preis aus Offerte     |
| services           | List<String> | Leistungsbeschreibung              |
| additionalServices | List<String> | Zusatzleistungen (Label-Strings)   |
| status             | OrderStatus  | pending/confirmed/inProgress/completed/cancelled |
| assignedTeam       | String?      | Team-Zuweisung                     |
| estimatedHours     | int?         | Geschaetzte Stunden                |

---

## Kompletter App-Flow

### Flow 1: Neue Anfrage -> Offerte erstellen -> Senden

```
1. ANFRAGE KOMMT REIN (Status: newRequest)
   - Dashboard zeigt neue Anfrage in "Neue Anfragen" Liste
   - Anfragen-Tab "Neu" zeigt Anzahl im Badge

2. ANFRAGE OEFFNEN (tap -> RequestDetailScreen)
   - Kontaktdaten (Telefon, E-Mail, Adresse)
   - Objekt-Informationen (Zimmer, Typ, Flaeche, Termin)
   - Verschmutzungsgrad (7 Bereiche mit farbigen Badges)
   - Zusatzleistungen mit Preisen (z.B. "Balkon + CHF 80.00")
   - Berechneter Richtpreis-Card (z.B. "CHF 520.00")
   - Buttons: [Anrufen] [+ Offerte erstellen]

3. OFFERTE ERSTELLEN (Button -> CreateQuoteScreen)
   Tab "Positionen":
     a) Kundeninfo-Card (Name, Adresse, Objekt-Daten)
     b) Grundpreis-Section:
        - Zeigt berechneten Richtpreis gesamt + reinen Reinigungspreis
        - Textfeld mit vorausgefuelltem Grundpreis (editierbar)
        - Refresh-Button zum Zuruecksetzen auf Richtpreis
     c) Standard-Leistungen (automatisch aus Template):
        - 6 Checkmark-Items (Endreinigung, Kueche, Bad, Raeume, etc.)
        - Kein Einzelpreis - im Grundpreis enthalten
     d) Zusatzleistungen:
        - Automatisch vorausgefuellt aus Anfrage-Extras
        - Manuell weitere hinzufuegen aus Template-Liste
        - Jede mit eigenem Preis + Menge (editierbar + loeschbar)
     e) Konditionen (aus Template, 4 AGB-Punkte)
     f) Persoenliche Nachricht (Freitext)

   Tab "Vorschau":
     - Komplette Offerte wie der Kunde sie sehen wuerde
     - Header (Firma), Kunde, Leistungen, Zusatz, Preis-Box, Konditionen, Footer

   Footer-Bar: Gesamtpreis (Grundpreis + Extras) + [Offerte senden]

4. OFFERTE SENDEN
   - Validierung: Gesamtpreis muss > 0 sein
   - createQuoteV2() erstellt Quote mit allen Positionen
   - sendQuote() setzt sentAt + aendert Status
   - Request-Status: newRequest -> quoteSent
   - Zurueck zum RequestDetailScreen

5. NACH DEM SENDEN (RequestDetailScreen aendert Ansicht)
   - Status-Banner "Offerte gesendet" (blau)
   - Tracking-Card: Anzahl Ansichten + Gesamtdauer
   - Offerten-Details: Preis, Gesendet am, Gueltig bis
   - Manuelle Status-Steuerung (3 Buttons + Ansicht simulieren)
   - Buttons: [Anrufen] [Gesendete Offerte]
```

### Flow 2: Offerte angenommen -> Auftrag erstellt

```
1. ANNEHMEN (Button in RequestDetailScreen)
   - Bestaetigung-Dialog: "Offerte fuer [Name] als ANGENOMMEN markieren?"
   - acceptQuoteManually() wird aufgerufen

2. WAS PASSIERT INTERN:
   - Request-Status -> accepted
   - Quote-Status -> accepted
   - Neuer Order wird automatisch erstellt mit:
     * Kundendaten aus Request
     * Preis aus Quote (oder Richtpreis als Fallback)
     * Zusatzleistungen als Labels
     * Status: pending

3. AUFTRAG SICHTBAR:
   - OrdersScreen -> Tab "Anstehend"
   - OrderCard zeigt: Status-Badge, Termin, Preis, Adresse, Team
   - Buttons: [Offerte anzeigen] [Anrufen] [Erledigt]

4. AUFTRAG ABSCHLIESSEN:
   - Button "Erledigt" -> OrderStatus.completed
   - Statistiken werden automatisch aktualisiert
```

### Flow 3: Offerte abgelehnt

```
1. ABLEHNEN (Button in RequestDetailScreen)
   - Dialog mit optionalem Ablehnungsgrund:
     * Preis zu hoch
     * Termin passt nicht
     * Vergleiche andere Anbieter
     * Sonstiger Grund

2. WAS PASSIERT INTERN:
   - Request-Status -> rejected
   - Quote-Status -> rejected

3. SICHTBAR IN:
   - Anfragen Tab "Abgelehnt"
   - Statistiken (Rejection Rate)
```

### Flow 4: Kunde ueberlegt noch

```
1. UEBERLEGT (Button in RequestDetailScreen)
   - Request-Status -> thinking
   - Quote-Status -> thinking

2. SICHTBAR IN:
   - Anfragen Tab "Ueberlegt"
   - Dashboard als "Hot Lead" (wenn 3+ Ansichten)

3. VON HIER AUS:
   - Buttons: [Offerte anzeigen] [Jetzt nachfassen (Anrufen)]
   - Kann immer noch angenommen oder abgelehnt werden
```

---

## Preisberechnung

### Richtpreis-Formel (calculateSuggestedPrice)

```
RICHTPREIS = GRUNDPREIS + FLAECHENZUSCHLAG + VERSCHMUTZUNG + ZUSATZLEISTUNGEN

GRUNDPREIS:
  = Zimmeranzahl x CHF 80
  Beispiel: 4.5 Zimmer = CHF 360.00

FLAECHENZUSCHLAG (nur wenn Durchschnitt > 120 m2):
  avgArea = (untere + obere Grenze) / 2
  Zuschlag = (avgArea - 120) x CHF 2.00 pro m2
  Beispiel: "100-130 m2" -> avg = 115 -> KEIN Zuschlag
  Beispiel: "150-180 m2" -> avg = 165 -> (165-120) x 2 = CHF 90.00

VERSCHMUTZUNGSZUSCHLAG (je Bereich):
  leicht = 0, mittel = 1x Faktor, stark = 2x Faktor
  Kueche (15), Geraete (20), Bad (25), Kalk (30),
  Fenster (10), Storen (15), Boeden (20)
  Beispiel Thomas Weber (alle mittel ausser Geraete/Kalk/Fenster/Storen):
  Kueche 15 + Geraete 0 + Bad 25 + Kalk 0 + Fenster 0 + Storen 0 + Boeden 20 = CHF 60

ZUSATZLEISTUNGEN:
  Balkon = CHF 80, Waschturm = CHF 50, etc.
  Beispiel Thomas Weber: Balkon = CHF 80

ERGEBNIS Thomas Weber:
  360 + 0 + 60 + 80 = CHF 500.00
```

### Wie der Preis in die Offerte kommt

```
calculateSuggestedPrice()    = CHF 500.00  (Richtpreis GESAMT)
calculateBasePrice()         = CHF 420.00  (Richtpreis OHNE Extras)
additionalServicesTotal      = CHF  80.00  (Extras aus der Anfrage)

CreateQuoteScreen:
  _basePrice                 = CHF 420.00  (vorausgefuellt, editierbar)
  Zusatzleistung "Balkon"    = CHF  80.00  (als Position vorausgefuellt)
  _calculateTotalPrice()     = CHF 500.00  (Grundpreis + alle Zusatz-Positionen)
```

**WICHTIG:** Der Grundpreis ist immer der Richtpreis MINUS die Zusatzleistungen
aus der Anfrage. Die Zusatzleistungen kommen separat als eigene Positionen dazu.
So kann Petrit den Grundpreis manuell anpassen UND die Extras einzeln aendern.

---

## Offerten-System

### Positions-System (QuotePosition)

Jede Offerte besteht aus:
- **Standard-Positionen** (isAdditional = false):
  Aus TemplateSettings geladen, kein Einzelpreis (unitPrice = 0).
  Sind im Grundpreis enthalten und werden als Checkliste angezeigt.

- **Zusatzleistung-Positionen** (isAdditional = true):
  Haben einen Einzelpreis und Menge. Werden aus der Anfrage vorausgefuellt
  und koennen manuell hinzugefuegt/bearbeitet/geloescht werden.

### Gesamtpreis-Berechnung in der Offerte

```
Gesamtpreis = _basePrice + SUM(zusatz.unitPrice * zusatz.quantity)
```

### HTML-Offerte (QuoteHtmlService)

Wenn "Gesendete Offerte anzeigen" geklickt wird:
1. `QuoteHtmlService.generateQuoteHtml()` generiert vollstaendiges HTML
2. HTML wird als Blob erstellt und in neuem Browser-Tab geoeffnet
3. Inhalte:
   - Status-Banner (farbig je nach Status: blau/gruen/rot/orange)
   - Firmen-Header mit Logo und Kontakt
   - Offerten-Meta (Datum, Gueltigkeit, Kunde, Termin)
   - Objekt-Informationen (Adresse, Typ, Zimmer, Flaeche)
   - Standard-Leistungen als Checkliste
   - Zusatzleistungen mit Preisen (Tabelle)
   - Persoenliche Nachricht (optional)
   - Preis-Box (gross, gruen, zentriert)
   - Konditionen
   - Footer mit Kontaktdaten und Unterschrift

### Draft-Handling

- `createQuoteV2()` prueft ob bereits ein Draft fuer diese Anfrage existiert
- Wenn ja: aktualisiert den bestehenden Draft (kein Duplikat)
- Wenn nein: erstellt einen neuen Draft
- Draft wird erst zur "echten" Offerte wenn `sendQuote()` aufgerufen wird
- `sentAt` ist der Indikator: null = Draft, Datum = gesendet

---

## Status-Logik

### Request-Status Flow
```
newRequest ----[Offerte senden]---------> quoteSent
quoteSent  ----[Kunde schaut an]--------> viewed     (via Tracking)
quoteSent  ----[Manuell "Ueberlegt"]----> thinking
quoteSent  ----[Manuell "Annehmen"]-----> accepted   --> Order wird erstellt
quoteSent  ----[Manuell "Ablehnen"]-----> rejected
thinking   ----[Manuell "Annehmen"]-----> accepted   --> Order wird erstellt
thinking   ----[Manuell "Ablehnen"]-----> rejected
```

### Quote-Status Flow (synchron mit Request)
```
draft    ----[sendQuote()]----------> sent
sent     ----[markQuoteAsViewed()]-> viewed    (+ QuoteView hinzugefuegt)
sent     ----[markQuoteAsThinking]-> thinking
viewed   ----[acceptManually()]----> accepted
thinking ----[acceptManually()]----> accepted
*        ----[rejectManually()]----> rejected
```

**WICHTIG:** Seit dem letzten Fix werden Request-Status UND Quote-Status
IMMER synchron aktualisiert. Vorher konnte es Inkonsistenzen geben wo
der Request "accepted" war aber die Quote noch "sent".

### Order-Status Flow
```
pending ----[bestaetigen]----> confirmed
confirmed --[starten]--------> inProgress
inProgress -[erledigt]-------> completed
*          -[stornieren]-----> cancelled
```

### Button-Logik in RequestDetailScreen
| Situation            | Linker Button      | Rechter Button         |
|----------------------|--------------------|------------------------|
| Keine Offerte        | Anrufen            | + Offerte erstellen    |
| Offerte (Draft)      | Anrufen            | Offerte senden         |
| Offerte gesendet     | Anrufen            | Gesendete Offerte      |
| Kunde ueberlegt      | Offerte anzeigen   | Jetzt nachfassen       |
| Offerte angenommen   | Offerte anzeigen   | Auftrag ansehen        |
| Offerte abgelehnt    | Offerte anzeigen   | Archivieren            |

### Tracking-System (QuoteView)

Jede "Ansicht" wird als QuoteView gespeichert:
- viewedAt: Wann angeschaut
- duration: Wie lange (Sekunden)
- device: Desktop/Mobile
- browser: Chrome/Safari/etc.

Hot Lead = 3 oder mehr Ansichten (isHotLead = true)

---

## Einstellungen & Templates

### Speicherung
Alle Einstellungen werden lokal via **shared_preferences** gespeichert.
Service: `SettingsService` (Singleton Pattern mit lazy initialization)

### CompanySettings - Firmendaten
| Feld       | Default                                       |
|------------|-----------------------------------------------|
| name       | SuperReinigungen.ch                            |
| hotline    | +41 44 544 20 04                               |
| email      | info@superreinigungen.ch                       |
| website    | www.superreinigungen.ch                        |
| address    | Badenerstrasse 562, CH-8048 Zuerich            |
| ownerName  | Petrit Xhaferi                                 |
| ownerTitle | Geschaeftsfuehrer / Ihr Ansprechpartner         |

### TemplateSettings - Offerten-Vorlage
**Standard-Leistungen** (im Grundpreis enthalten):
1. Komplette Endreinigung der Wohnung mit Abnahmegarantie
2. Kueche inkl. Geraete (Backofen, Kuehlschrank, Geschirrspueler)
3. Badezimmer/WC inkl. Entkalkung
4. Alle Raeume inkl. Boeden, Fenster, Rahmen
5. Tueren, Schraenke, Steckdosen, Lichtschalter
6. Balkon/Terrasse (falls vorhanden)

**Zusatzleistungen-Templates** (Default-Preise):
| Leistung          | Code       | Preis CHF |
|-------------------|------------|-----------|
| Waschturm         | waschturm  | 50        |
| Balkon/Terrasse   | balkon     | 80        |
| Keller/Estrich    | keller     | 100       |
| Garage/Hobbyraum  | garage     | 120       |
| Teppichreinigung  | teppich    | 150       |
| Parkettpflege     | parkett    | 100       |
| Hochdruckreinigung| hochdruck  | 180       |
| Bohrloecher       | bohrlocher | 80        |

**Konditionen** (AGB, 4 Punkte):
1. Der Preis versteht sich als Pauschalpreis, inkl. MwSt.
2. Bezahlung innert 7 Tagen oder bar bei Abgabe.
3. Kostenlose Nachreinigung bei berechtigten Beanstandungen.
4. Wohnung muss am Reinigungstag leer und besenrein sein.

### EmailSettings
- Betreff: "Ihre Offerte fuer die Umzugsreinigung - SuperReinigungen.ch"
- Intro-Text: "Vielen Dank fuer Ihre Anfrage..."

### DesignSettings
- Primary Color: #1a237e (dunkelblau)
- Accent Color: #0d47a1 (blau)
- Logo: assets/images/sr_logo.png

### Bearbeiten
- Dashboard -> Zahnrad-Icon -> TemplateEditorScreen
- Dashboard -> Palette-Icon -> DesignEditorScreen

---

## Changelog & Fixes

### Version 1.1.0 (Aktuell)

**FIX: Preise zwischen AdditionalService Enum und TemplateSettings synchronisiert**
Problem: `AdditionalService.balkon` hatte CHF 35, aber `TemplateSettings` hatte CHF 80.
Der Richtpreis wurde mit Enum-Preisen berechnet, aber die Offerte nutzte Template-Preise.
Loesung: Enum-Preise an Template-Preise angeglichen (beide Quellen identisch).

**FIX: Grundpreis wird korrekt in die Offerte uebertragen**
Problem: Auf dem "Offerte erstellen" Screen war der Gesamtpreis CHF 0.00.
Ursache: `calculateBasePrice()` fehlte - der Richtpreis minus Extras wurde falsch berechnet.
Loesung: Neue Methode `calculateBasePrice()` und `additionalServicesTotal` auf dem
CleaningRequest-Model. CreateQuoteScreen nutzt diese jetzt korrekt.

**FIX: Zusatzleistungen werden automatisch aus der Anfrage uebernommen**
Problem: Extras wie "Balkon + CHF 80" wurden zwar im Detail angezeigt, aber nicht
in die Offerte uebertragen.
Loesung: `_prefillAdditionalServicesFromRequest()` fuellt automatisch alle Extras
aus der Anfrage als QuotePositions ein.

**FIX: Demo-Quotes haben jetzt Positionen**
Problem: Die vordefinierten Demo-Offerten (Maria Mueller, Lisa Brunner) hatten keine
`positions` Liste. Die HTML-Vorschau und Bearbeitung zeigte daher leere Inhalte.
Loesung: Alle Demo-Quotes mit vollstaendigen Positionen + Konditionen erstellt.

**FIX: createQuoteV2 ersetzt bestehende Drafts statt Duplikate zu erstellen**
Problem: Jedes Mal wenn man speicherte, wurde eine NEUE Quote hinzugefuegt.
Loesung: `createQuoteV2()` prueft jetzt ob ein Draft fuer die Anfrage existiert
und aktualisiert diesen statt einen neuen zu erstellen.

**FIX: Request- und Quote-Status werden synchron aktualisiert**
Problem: `rejectQuoteManually()` und `markQuoteAsThinking()` aktualisierten nur
den Request-Status, nicht den Quote-Status. Fuehrte zu Inkonsistenzen.
Loesung: Alle Status-Aenderungsmethoden aktualisieren jetzt BEIDE Objekte.

**FIX: markQuoteAsViewed fuegt jetzt QuoteView-Tracking hinzu**
Problem: "Ansicht simulieren" aenderte den Status aber fuegte kein QuoteView-Objekt
hinzu. Tracking-Zaehler blieb bei 0.
Loesung: Erstellt jetzt ein neues QuoteView-Objekt mit Timestamp und Dauer.

**FIX: Flaechenzuschlag-Berechnung korrigiert**
Problem: Der Zuschlag pro zusaetzlichem m2 ueber 120 m2 war nur CHF 0.50 (zu niedrig).
Loesung: Auf CHF 2.00 pro m2 angehoben fuer realistischere Preise.

**VERBESSERUNG: Demo-Daten realistischer**
- Andreas Fischer (Haus, 5.5 Zi, 150-180 m2): Offerte mit Keller + Garage, Status thinking, 3 Views (Hot Lead)
- Maria Mueller: Offerte mit 2 Views, Status viewed
- Lisa Brunner: Auftrag mit Team A zugewiesen, 4 Stunden geschaetzt

---

## Demo-Daten Uebersicht

| Kunde            | Status     | Zimmer | Objekt   | Extras             | Richtpreis |
|------------------|------------|--------|----------|--------------------|------------|
| Thomas Weber     | Neu        | 4.5    | Wohnung  | Balkon             | ~500       |
| Maria Mueller    | Gesendet   | 3.5    | Wohnung  | -                  | ~450       |
| Andreas Fischer  | Ueberlegt  | 5.5    | Haus     | Keller, Garage     | ~780       |
| Sandra Keller    | Neu        | 3.0    | Wohnung  | -                  | ~300       |
| Peter Huber      | Neu        | 4.0    | Wohnung  | Waschturm          | ~430       |
| Lisa Brunner     | Angenommen | 2.5    | Wohnung  | -                  | ~280       |
| Marco Bianchi    | Abgelehnt  | 3.5    | Wohnung  | -                  | ~340       |

---

## Entwicklung

### Lokale Entwicklung starten
```bash
cd /home/user/flutter_app
flutter pub get
flutter build web --release
python3 -m http.server 5060 --directory build/web --bind 0.0.0.0
```

### Analyse
```bash
flutter analyze        # Syntax- und Code-Pruefung
dart format .          # Code-Formatierung
```

### APK bauen
```bash
flutter build apk --release
```
