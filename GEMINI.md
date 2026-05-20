# SkyAudit - System Rules & Context

## 1. TECH STACK & ARCHITECTURE
- **Framework:** Flutter (Desktop & WEB App target).
- **Web Constraint:** NEVER use 'dart:io' directly (causes Web crash). Use 'package:universal_io' or cross-platform plugins.
- **Navigation:** GoRouter (Declarative routing, strongly typed paths).
- **State Management:** Riverpod (Use Riverpod Generator `@riverpod`, AsyncNotifier, AutoDispose).
- **Database:** Isar DB (`package:isar`).
- **UI:** Material 3. Clean, professional style optimized for TIM corporate welfare platforms.
- **Code Standards:** Clean Architecture (Presentation, Domain, Data layers). Strict separation of UI and Business Logic.

## 2. UI/UX & RESPONSIVENESS REQUIREMENTS
- **Responsiveness:** Every widget MUST use adaptive layouts (`LayoutBuilder`, `MediaQuery` boundaries, or `Responsive` grid layout). 
- **Lists & Tables:** 
  - Mandatory Pagination: Default to exactly 50 items per page.
  - Performance: Use `ListView.builder` or `SliverList` for large recordsets.
  - UI State: Persistent quick-filters header, highly accessible.
- **Design Pattern:** Enterprise dashboard, precise alignments, clean padding. Standard Material 3 implementation.

## 3. DATABASE (ISAR) PROTOCOL
- **Local DB Management Section:** Every new Isar Collection MUST explicitly implement:
  1. A clear UI trigger inside "GESTIONE DATABASE LOCALE" settings to wipe/reset that specific collection.
  2. A corresponding Riverpod Provider to broadcast state updates and force UI re-renders upon deletion or modification.

## 4. TXT PARSING LOGIC & CHARACTER INDEXING
- **Source:** *.TXT Fixed-Width Contable File.
- **Row Filtering:** Skip index 0 (Header) and index `list.length - 1` (Footer). Parse middle records only.
- **Extraction Schema (1-Based Substrings):**
  - CID: [2-9] | Numero Trasferta: [10-19] | Progressivo Giustificativo: [20-22]
  - Società: [23-26] | Tipo Dipendente: [27-28] | Giustificativo di Spesa: [29-32] | Numero Bolla: [33-44]
  - Data Spesa: [45-52] -> Format to DD/MM/YYYY
  - Località Trasferta: [53-111] -> Apply `.trim()`
  - Data Inizio: [112-119] -> Format to DD/MM/YYYY | Ora Inizio: [120-125] -> Format to HH:MM:SS
  - Data Fine: [126-133] -> Format to DD/MM/YYYY | Ora Fine: [134-139] -> Format to HH:MM:SS
  - Tipo Attività: [140]
  - Importo: [141-160] -> Clean padding zeros, parse to double.
  - Valuta: [161-163] (e.g., EUR)
  - Segno: [166]
- **Business Logic Rules:**
  - If char[166] == "R" -> Multiply Importo by -1. Else -> Positive.
  - UI Formatting: Format numbers using localized Italian syntax (`,` comma decimal separator) and append the Currency string (e.g., -59,48 EUR).

## 5. DICTIONARIES & DECODING (ISAR DEPENDENT)
- **Architecture:** Fetch decoding entries dynamically from Isar DB Collections in the Settings -> "Dizionari" view.
- **Parsing Invalidation:** Every coded string field parsed from the TXT file MUST match its Isar dictionary description.

### Static Seeding Data:
#### Giustificativi Spesa:
- ALP1: Alloggio prepagato | SSP1: Visti consolari - pre. Autom. | TAP1: Aereo - prepagato Automatico
- TGP1: Traghetto - prepagato Autom. | TNP1: Noleggio auto prep. Autom. | TTP1: Treno - prepagato Automatico
#### Tipo Dipendente:
- QD: Quadro | IM: Impiegato | RS: Risorsa Strategica | DR: Dirigente
#### Società:
- C120: TIM S.p.A. | C140: Noovle S.p.A | A710: TI Trust Technol. S.r.L. | A640: TI Sparkle S.p.A. | A200: Olivetti S.p.A. | A150: Telecontact Center S.p.A