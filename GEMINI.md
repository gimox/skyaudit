# CRITICAL TOKEN-SAVING INSTRUCTIONS
- Always be extremely concise. Restrict all chat answers to the core code fix.
- NEVER generate final walkthroughs, summaries, or explanations unless explicitly requested.
- DO NOT launch autonomous sub-agents to scan the workspace without asking for my confirmation first.
- Stop execution immediately after writing the required code block.
- non mostrare il codice della modifica effettuata in chat (anche se richiesto). Fai solo una breve sintesi del task completato.



# SkyAudit - System Rules & Context

## 1. TECH STACK & ARCHITECTURE
- **Framework:** Flutter (Desktop macOS/Windows/Linux & WEB App target).
- **Web & Desktop Constraints:**
  - NEVER use `dart:io` directly in web-exposed files (causes Web crash). Use `package:universal_io` or cross-platform plugins.
  - Check platform conditionally (`kIsWeb`, `Platform.isWindows`, etc.).
  - Desktop window configuration: `window_manager` with frameless/custom title bar (`TitleBarStyle.hidden`), minimum size 1000x700, default size 1280x800.
- **Navigation:** GoRouter (Declarative routing, strongly typed paths, route providers in `lib/core/navigation`).
- **State Management:** Riverpod (`@riverpod` code generation / `flutter_riverpod`, `AsyncNotifier`, `AutoDispose`).
- **Database:** Isar Database (`package:isar`, `isar_flutter_libs`). Singleton instance injected via `isarProvider`.
- **UI:** Material 3. Enterprise audit dashboard, clean, professional style optimized for TIM corporate welfare platforms.
- **Code Standards:** Clean Architecture (Presentation, Domain/Services, Data layers). Strict separation of UI and Business Logic.

## 2. UI/UX & RESPONSIVENESS REQUIREMENTS
- **Responsiveness:** Every widget MUST use adaptive layouts (`LayoutBuilder`, `MediaQuery` boundaries, or `Responsive` grid layout).
- **Lists & Tables:**
  - Mandatory Pagination: Default to exactly 50 items per page.
  - Performance: Use `ListView.builder` or `SliverList` for large recordsets; avoid building unrendered rows.
  - UI State: Persistent quick-filters header, search inputs with debouncing, accessible status chips.
- **Design Pattern:** Enterprise audit dashboard, precise alignments, clear visual hierarchy, clean padding (TIM/Sky brand guidelines).

## 3. DATABASE (ISAR) PROTOCOL & PERFORMANCE OPTIMIZATION
- **Registered Collections (10 Collections):**
  1. `TracciatoContabile` (Uvet Fixed-Width TXT records)
  2. `TracciatoSap` (SAP expense records)
  3. `TrasferteSap` (SAP travel orders & mission records)
  4. `EstrattoConto` (Credit card & banking statements)
  5. `EstrattoAmex` (American Express statements)
  6. `Anagrafica` (Employee directory, CIDs, tax codes, card numbers)
  7. `ScartiEcSap` (Reconciliation discrepancies & discarded rows)
  8. `LogHistory` (Audit trail of file imports, insertions, updates, and discards)
  9. `Dictionary` (Dynamic code-to-description lookups)
  10. `AppSettings` (Singleton settings: sync, proxy, Amex filters, SharePoint paths)
- **Local DB Management Section:** Every Isar Collection MUST explicitly implement:
  1. A clear UI trigger inside "GESTIONE DATABASE LOCALE" settings to wipe/reset that specific collection.
  2. A corresponding Riverpod Provider to broadcast state updates and force UI re-renders upon deletion or modification.
- **Async Database Operations:** NEVER use synchronous blocking database queries (e.g., `findAllSync()`) in Riverpod Notifier `build()` methods or screen loading. Always use asynchronous reads (`findAll()`) to guarantee zero main-thread UI freezing.
- **$O(1)$ Map Indexing:** NEVER perform nested linear searches (`.where()`) over collections inside UI `build()` or calculation loops. Always pre-index record relations into `Map<String, List<T>>` or `Map<String, T>` for $O(1)$ constant-time lookup.
- **Fast Sorting & Single-Pass Extraction:**
  1. Avoid `DateTime` object instantiations and regex `split()` calls inside `.sort()` comparators. Use positional comparison keys (e.g. `YYYYMMDD`).
  2. Combine metric extractions and unique filter option lists in a single `for` loop pass over collections rather than chaining multiple array methods.
- **Data Quality & Integrity:** All performance optimizations MUST guarantee 100% data fidelity, exact decimal calculations, and complete filter accuracy.

## 4. INGESTION & PARSING LOGIC

### 4.1. Tracciato Contabile (Fixed-Width TXT)
- **Source:** *.TXT Fixed-Width Contable File (Uvet).
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
  - Deduplication: When `AppSettings.discardIdenticalBolla` is true, prevent duplicate imports with identical Bolla/Progressivo.

### 4.2. Ingestion Altre Fonti (SAP, AMEX, Estratto Conto, Anagrafica)
- **Formati Supportati:** CSV, Excel (.xlsx/.xls), Fixed-width TXT.
- **Estratto AMEX:** Filtro righe per colonna configurabile (default: `Categ. transazione` == `Nuovi addebiti`).
- **Anagrafica Dipendenti:** Mappatura chiave primaria su CID (con padding zeri normalizzato a 8 cifre), Codice Fiscale, e Numero Carta di Credito associata.
- **Import Audit:** Ogni operazione di upload DEVE creare o aggiornare un record `LogHistory` contenente: `fileName`, `sourceType`, `date`, `totalRecords`, `insertedRecords`, `updatedRecords`, `discardedRecords`.

### 4.3. Sincronizzazione Remota (SharePoint / Cloud)
- **Architettura Sync:** Servizio di sincronizzazione configurabile via `AppSettings` (`sharepointSiteName`, percorsi cartelle dedicati per ciascuna tipologia file).
- **Opzioni di Sincronizzazione:**
  - `alignWithRemote`: Controllo se sovrascrivere o unire dati remoti.
  - `syncOnStartup`: Esecuzione automatica del controllo file all'avvio.
  - `clearBeforeSync`: Flag monouso per pulizia preventiva del database prima della re-ingestione massiva.

## 5. AUDIT, RICONCILIAZIONE & REGOLE DI CONTROLLO
- **Obiettivo:** Incrocio automatizzato tra Tracciato Contabile (Uvet), Dati SAP (Trasferte e Tracciato), Estratto Conto Bancario ed Estratto AMEX.
- **Livelli di Riconciliazione:**
  1. **Match Esatto (1:1):** Corrispondenza per CID/Dipendente, Data Spesa, e Importo esatto (entro tolleranza centesimi).
  2. **Match Bolla / Documento:** Corrispondenza tramite Numero Bolla / Transazione e Codice Fornitore/Giustificativo.
  3. **Scarti & Anomalie (`ScartiEcSap`):** Tracciamento automatico di spese presenti in contabilità ma prive di riscontro SAP/AMEX o viceversa, con causale specifica dell'anomalia.

## 6. DIZIONARI & DECODIFICA (ISAR DEPENDENT)
- **Architettura:** Fetch dinamico delle tabelle di decodifica dalla collezione Isar `Dictionary` (gestita e modificabile dalla vista Impostazioni -> "Dizionari").
- **Validazione Parsing:** Ciascun codice stringa estratto deve trovare corrispondenza nella rispettiva categoria dizionario.

### Static Seeding Data:
#### Giustificativi Spesa:
- ALP1: Alloggio prepagato | SSP1: Visti consolari - pre. Autom. | TAP1: Aereo - prepagato Automatico
- TGP1: Traghetto - prepagato Autom. | TNP1: Noleggio auto prep. Autom. | TTP1: Treno - prepagato Automatico
#### Tipo Dipendente:
- QD: Quadro | IM: Impiegato | RS: Risorsa Strategica | DR: Dirigente
#### Società:
- C120: TIM S.p.A. | C140: Noovle S.p.A | A710: TI Trust Technol. S.r.L. | A640: TI Sparkle S.p.A. | A200: Olivetti S.p.A. | A150: Telecontact Center S.p.A.

## 7. NETWORK & CORPORATE PROXY PROTOCOL
- **Proxy Corporate TIM:** Supporto integrato in `ProxyService` con override globale di `HttpOverrides`.
- **Configurazioni Supportate:** Auto-detect proxy di sistema, configurazione manuale PAC/Host:Port, credenziali proxy opzionali e flag `bypassSslVerification` per certificati interni aziendali.
- **Aggiornamenti Applicativi:** Gestione release desktop tramite `appUpdaterInstance` compatibile con le restrizioni di rete aziendali.