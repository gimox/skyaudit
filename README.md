# SkyAudit (Travel Check)

**SkyAudit** è un applicativo desktop e web aziendale di livello enterprise, sviluppato in **Flutter**, progettato per automatizzare, verificare e riconciliare i flussi contabili legati al sistema travel e trasferte aziendali.

Il software permette di centralizzare diversi flussi di input (flussi di fatturazione agenzia, estratti conto bancari, estratti di carte di credito aziendali AMEX, tracciati contabili SAP e anagrafiche dipendenti) per costruire un modello di dati unificato ed eseguire controlli automatici di quadratura, scarti e mappatura geografica.

## 🌊 Gestione dello Stato con Riverpod

L'architettura dello stato e della logica di business di SkyAudit è interamente basata su **Riverpod**, garantendo reattività, disaccoppiamento dall'interfaccia utente (UI) e facilità di test. Di seguito sono elencate le tipologie e le responsabilità dei vari provider implementati nel sistema:

### 1. Autenticazione e Sessioni (`StateNotifierProvider`)
* **`authProvider`**: Gestisce lo stato globale di login (`AuthState`) interfacciandosi con il flusso OAuth2 di Microsoft Entra ID. Rilascia e memorizza in modo sicuro i token per le chiamate REST verso SharePoint e gestisce lo stato di connessione utente.
* **`userAvatarProvider`**: Estrae asincronamente la foto del profilo dell'utente loggato da Microsoft Graph e la fornisce all'interfaccia (es. nell'header del menu).

### 2. Database Isar e Operazioni CRUD (`NotifierProvider`)
Ciascun tracciato o risorsa possiede un `NotifierProvider` dedicato che gestisce le operazioni di lettura asincrona, filtraggio in memoria e scrittura sul database locale Isar:
* **`tracciatoContabileProvider`**: Carica, filtra e aggiorna le righe della fatturazione agenzia (TXT).
* **`tracciatoSapProvider`**: Gestisce le scritture contabili SAP.
* **`estrattoContoProvider`**: Gestisce i dati degli estratti conto centralizzati.
* **`estrattoAmexProvider`**: Fornisce l'accesso alle transazioni delle carte American Express individuali.
* **`anagraficaProvider`**: Amministra il database delle risorse umane, garantendo la logica di sostituzione pulita all'import di un nuovo file.
* **`scartiEcSapProvider`**: Mantiene in memoria le discrepanze identificate dai controlli contabili di quadratura.
* **`logHistoryProvider`**: Gestisce lo storico e l'audit trail di ogni singola importazione manuale o sincronizzazione cloud.
* **`dictionaryProvider`**: Gestisce lo stato e la manutenzione dei dizionari di decodifica (Società, Tipo Dipendente, Giustificativi).

### 3. Statistiche Calcolate e Derivate (`Provider` di sola lettura)
I calcoli statistici e analitici pesanti non vengono rieseguiti ad ogni render dei widget, ma vengono memorizzati nella cache di Riverpod tramite provider che dipendono da altri provider (computed state):
* **`dashboardStatsProvider`**: Calcola i KPI generali (spese, medie, totali).
* **`dashboardFilteredRecordsProvider`**: Applica filtri temporali e di struttura sui tracciati nel DB.
* **`dashboardTopCidByAmountProvider`** / **`dashboardTopCidByTripsProvider`**: Calcola le graduatorie di spesa e frequenza (Top-20 dipendenti).
* **`dashboardAmountByTypeProvider`** / **`dashboardAvgCostByTypeProvider`**: Calcola le medie e somme aggregate per qualifica del personale.

---

## 📂 Struttura del Progetto (Feature-First)

Il codebase segue una struttura pulita orientata alle funzionalità (*features*), separando l'architettura logica e di stato (*Riverpod*) dalla rappresentazione visuale:

```text
lib/
├── core/
│   ├── config/             # Configurazione globale, costanti ed endpoint SSO
│   ├── db/                 # Provider e inizializzazione del database locale Isar
│   ├── navigation/         # Gestione percorsi applicativi via GoRouter
│   └── theme/              # Design System Material 3, colori aziendali (SkyTheme)
├── features/
│   ├── anagrafica/         # Gestione e ricerca dei record dipendenti
│   ├── analysis/           # Liste e tabelle analitiche (Contabile, AMEX, SAP, Estratti, Scarti)
│   ├── auth/               # Integrazione login Azure SSO con Microsoft Entra ID
│   ├── controls/           # Modulo di riconciliazione e quadratura "Controlli Trasferte"
│   ├── dashboard/          # Cruscotto KPI e grafici statistici interattivi (fl_chart)
│   ├── home/               # Layout di base, menu laterale (SkySideBar) e topbar (SkyTopBar)
│   ├── log_history/        # Log cronologico delle operazioni di caricamento e sincronizzazione
│   ├── settings/           # Gestione dizionari decodifica e manutenzione database Isar
│   ├── splash/             # Schermata di caricamento iniziale
│   ├── sync_file/          # Console di sincronizzazione cloud automatica con SharePoint
│   ├── travel_history/     # Visualizzazione cartografica "Dove Viaggi"
│   └── upload/             # Modulo di caricamento manuale di file locali (TXT e Excel)
└── shared/
    └── widgets/            # Elementi dell'interfaccia riutilizzabili (es. sfondi animati)
```

---

## 🚀 Panoramica delle Sezioni e dei Moduli

### 1. Dashboard Analitica
Cruscotto di controllo direzionale che aggrega in tempo reale le informazioni presenti nel database locale Isar:
* **Metriche Principali (KPI)**: Visualizzazione immediata di Spese Totali, Numero Trasferte, Costi Medi e Record totali.
* **Statistiche Grafiche**: Grafici a torta e a barre (sviluppati con `fl_chart`) che mostrano la ripartizione dei costi per *Tipo Dipendente*, andamento mensile e la classifica dei primi 20 dipendenti per volume di spesa (Top-20 CID).

### 2. Tracciato Contabile (Fatturato UVET)
Visualizzazione tabellare ad alte prestazioni dei record importati dal file posizionale dell'agenzia di viaggio (UVET):
* **Caratteristiche**: Tabella responsiva, paginata a 50 elementi di default.
* **Filtri**: Ricerca rapida per CID, Numero Bolla o Trasferta, con opzioni di ordinamento su colonne multiple ed esportazione dei dati filtrati in formato Microsoft Excel.

### 3. Estratti Conto (Bancari UVET)
Modulo dedicato all'analisi degli estratti conto bancari (importati da file Excel):
* Consente il tracciamento dei pagamenti emessi a favore dell'agenzia viaggi, visualizzando informazioni di tesoreria, fatture e addebiti correlati.

### 4. Estratti Carte AMEX
Visualizzazione ed elaborazione dei flussi delle carte di credito aziendali American Express:
* Mappa in dettaglio le transazioni individuali dei dipendenti, consentendo di confrontare le spese caricate su carta di credito con le trasferte autorizzate.

### 5. Tracciato SAP
Modulo di importazione delle registrazioni contabili esportate da SAP:
* Rappresenta le scritture di costo effettive registrate a libro giornale, essenziali per la quadratura finale del "liquidato" rispetto al "fatturato".

### 6. Scarti Tracciato
Pannello per l'identificazione immediata delle anomalie di quadratura (discrepanze):
* Calcola ed elenca in automatico i record orfani o con differenze di importo significnative tra l'estratto conto della carta, la fatturazione dell'agenzia viaggi e le registrazioni su SAP.

### 7. Controlli Trasferte (Riconciliazione)
Il cuore logico contabile dell'applicativo. Aggrega i dati per **Numero Trasferta** o per **CID** ed evidenzia anomalie tramite specifici flag colorati:
* **Verifiche di Congruenza**: Discrepanza importi, corrispondenza dei codici società e tipo dipendente, assenza di record SAP o di estratti conto corrispondenti.
* **Ricerca Dipendente**: Sistema avanzato di autocompletamento in tempo reale basato su Nome, Cognome, CID o Codice Fiscale.
* **Visualizzazione a Busta**: Sezione a espansione con dettagli affiancati di tutte le voci associate (Contabile, SAP, AMEX, Estratto Conto) con evidenza dei singoli scostamenti.

### 8. Dove Viaggi (Mappatura Geografica)
Modulo cartografico interattivo per la tracciabilità delle trasferte:
* Mappa le località di trasferta convertendole in coordinate geografiche.
* Visualizza marker interattivi con caricamento dinamico di tile basato su **CartoDB Voyager** ad alte prestazioni.
* Filtro integrato per dipendente con pannello di ricerca ad autocompletamento.

### 9. Anagrafica Dipendenti
Database centralizzato delle risorse umane (CIDs, Codici Fiscali, Nomi, Società e Qualifiche):
* Utilizzato come dizionario autoritativo per validare il "Tipo Dipendente" e associare le generalità ai CIDs presenti nei tracciati.

### 10. Caricamento File (Upload Manuale)
Interfaccia drag-and-drop ed esplora risorse per caricare localmente i file:
* **Parser TXT Posizionale**: Legge i file contabili posizionali estraendo i campi in base a specifici offset (vedi sezione *Regole di Parsing*).
* **Parser Excel (AMEX, SAP, Estratti)**: Legge e mappa le colonne dei fogli di calcolo Excel nel database relazionale Isar.

### 11. Sincronizzazione Cloud (SharePoint)
Console per l'importazione automatica di file direttamente da cartelle remote SharePoint tramite Microsoft Graph API:
* **Autenticazione**: Richiede il login aziendale Microsoft Entra ID (SSO) tramite flusso protetto di redirect OAuth2. Se l'utente non è loggato, mostra un pannello informativo centrato (`ACCEDI PER SINCRONIZZARE`) inibendo le altre funzioni.
* **Sincronizzazione Delta (Tracciati Contabili, AMEX, SAP, ecc.)**: Verifica la data di modifica del file su SharePoint e scarica/elabora solo i file effettivamente nuovi o modificati.
* **Sostituzione Totale (Anagrafica)**: Per l'anagrafica, seleziona esclusivamente il file più recente nella cartella SharePoint. Se non è mai stato importato, svuota completamente la tabella locale del DB ed effettua un caricamento pulito da zero (nessun delta row-by-row).
* **Console di monitoraggio**: Visualizzazione opzionale (nascosta di default) dei log di avanzamento dettagliati del parser e dei record importati.

### 12. Log History & Impostazioni Dizionari
* **Log History**: Visualizza lo storico degli import (Nome File, Data Operazione, Record Inseriti, Stato) a fini di audit trail.
* **Gestione Database**: Permette la formattazione mirata e separata delle singole tabelle di Isar.
* **Dizionari**: Pannello per gestire i codici di decodifica (Giustificativi di spesa, Qualifica dipendente, Codici Società) salvati su DB e usati dinamicamente per tradurre i codici criptici dei tracciati in descrizioni testuali chiare.

---

## 📊 Regole di Business e Schemi di Mappatura dei File

L'applicativo supporta il parsing e la decodifica di diversi tipi di file (TXT posizionale ed Excel) inseriti nel database locale Isar.

### 1. Tracciato Contabile Posizionale (TXT)
Durante il parsing, il sistema salta la prima riga (Header) e l'ultima riga (Footer) di controllo. Per le righe centrali si applica la seguente mappatura basata su indici di caratteri (1-based indexing):

| Campo | Caratteri (Offset) | Logica / Trasformazione |
| :--- | :--- | :--- |
| **CID** | 2 - 9 | Identificativo dipendente. |
| **Numero Trasferta** | 10 - 19 | Codice univoco trasferta. |
| **Progressivo Giustificativo** | 20 - 22 | Numero progressivo spesa. |
| **Società** | 23 - 26 | Codice societario decodificato tramite Dizionario Società (es: `C120` -> `Società di riferimento`). |
| **Tipo Dipendente** | 27 - 28 | Livello decodificato tramite Dizionario Tipo Dipendente (es: `QD` -> `Quadro`). |
| **Giustificativo di Spesa** | 29 - 32 | Codice spesa decodificato tramite Dizionario Giustificativi (es: `TAP1` -> `Aereo - prepagato Automatico`). |
| **Numero Bolla** | 33 - 44 | Codice bolla/fattura. |
| **Data Spesa** | 45 - 52 | Stringa `YYYYMMDD` -> Convertita in data italiana `DD/MM/YYYY`. |
| **Località Trasferta** | 53 - 111 | Stringa con rimozione del padding di spazi (Trim). |
| **Data Inizio** | 112 - 119 | Stringa `YYYYMMDD` -> Convertita in data italiana `DD/MM/YYYY`. |
| **Ora Inizio** | 120 - 125 | Stringa `HHMMSS` -> Formattata come `HH:MM:SS`. |
| **Data Fine** | 126 - 133 | Stringa `YYYYMMDD` -> Convertita in data italiana `DD/MM/YYYY`. |
| **Ora Fine** | 134 - 139 | Stringa `HHMMSS` -> Formattata come `HH:MM:SS`. |
| **Tipo Attività** | 140 | Carattere singolo indicatore attività. |
| **Importo** | 141 - 160 | Pulito dagli zeri iniziali e convertito in numero decimale (es: `000000000059.4800000` -> `59.48`). |
| **Valuta** | 161 - 163 | Codice valuta (es. `EUR`). |
| **Segno** | 166 | Se contiene `'R'`, l'importo è trattato come **negativo** (Storno/Rimborso). Altrimenti è positivo. |

### 2. Tracciato SAP (Excel)
Il tracciato delle scritture contabili SAP viene mappato colonna per colonna in base all'indice (0-based):
* **0 (Colonna A)**: CID (Codice Identificativo Dipendente)
* **1 (Colonna B)**: Nome Dipendente
* **2 (Colonna C)**: Codice Società
* **3 (Colonna D)**: Descrizione Società
* **4 (Colonna E)**: Tipo Dipendente
* **5 (Colonna F)**: Classe Retributiva
* **6 (Colonna G)**: Numero Trasferta
* **7 (Colonna H)**: Progressivo Giustificativo
* **8 (Colonna I)**: Codice Tipo Spesa
* **9 (Colonna J)**: Descrizione Tipo Spesa
* **10 (Colonna K)**: Importo (Normalizzato rimuovendo spazi e convertendo la virgola come separatore decimale)
* **11 (Colonna L)**: Valuta
* **12 (Colonna M)**: Data registrazione
* **13 (Colonna N)**: RiTr (Riferimento Trasferta)
* **14 (Colonna O)**: Codice Richiesta
* **15 (Colonna P)**: Calc
* **16 (Colonna Q)**: Codice Stato
* **17 (Colonna R)**: FI
* **18 (Colonna S)**: Codice Trasferimento FI
* **19 (Colonna T)**: Colonna T tecnica

### 3. Estratto Conto (Fattura Carte Centralizzate Agenzia - Excel)
Gli estratti conto bancari presentano un tracciato esteso a 55 colonne (indici 0-54):
* **0 - 4**: Numero Estratto Conto, Numero Bolla (normalizzato in `bolla`), Data Bolla, Data Competenza, Codice Cliente.
* **5 - 9**: Ragione Sociale, Tipo Transazione, Tipo Servizio, Descrizione Servizio, Itinerario.
* **10 - 14**: Fornitore, Codice Viaggio, Numero Passeggeri (Pax), Numero Biglietto (Tkt), Nome Passeggero.
* **15 - 19**: Metodo Pagamento Servizio, Metodo Pagamento Fee, Importo Servizio, Tasse, Fee.
* **20 - 24**: Codice Iva, Iva Servizio, Iva Tasse, Iva Fee, Totale Servizio.
* **25 - 29**: Totale Tasse, Totale Servizio Generale, Totale Fee, Data In, Data Out.
* **30 - 34**: Località Partenza, Località Arrivo, Codice Trattamento, Codice Sistemazione, Richiedente.
* **35 - 39**: CID, Centro di Costo, Numero Trasferta, Campo Statistico 4, Riga CRM.
* **40 - 44**: SAP/No-SAP, Campo Statistico 7, Campo Statistico 8, Campo Statistico 9, Campo Statistico 10.
* **45 - 49**: Numero CC Servizio, Numero CC Fee, Numero Documento Servizio, Numero Documento Fee, Numero Notti.
* **50 - 54**: Segue Fattura Servizi, Servizio Da Pagare, Merchant Fee, Descrizione Spedire A, Righe Pratiche.

### 4. Estratto AMEX (Excel)
Il file di estratto conto American Express contiene 64 colonne (A-BL) utilizzate per riconciliare i pagamenti individuali con le trasferte contabili:
* **Mappature di Riconciliazione Chiave**:
  * **CID**: Estratto dal campo **Rif 1** (Colonna AC / indice 28).
  * **Numero Trasferta**: Estratto dal campo **Rif 3** (Colonna AE / indice 30).
  * **Bolla**: Estratto dal campo **Rif 5** (Colonna AG / indice 32) e memorizzato sia come `bollaOriginale` sia in forma normalizzata come `bolla` per permettere la corrispondenza esatta.
* **Mappature Principali**:
  * **Colonna R**: Importo Lordo.
  * **Colonna F**: Data Transazione.
  * **Colonna BD**: Nome Fornitore / Esercizio.
  * **Colonna N**: Nome Viaggiatore.

### 5. Anagrafica Dipendenti (Excel)
Il file HR contiene 66 colonne (A-BN / indici 0-65) utilizzate per caricare l'intero database del personale:
* **0 (Colonna A)**: CID (Codice Identificativo Dipendente)
* **1 (Colonna B)**: Nominativo completo
* **2 (Colonna C)**: Codice Fiscale (campo con indice univoco nel DB locale)
* **3 - 7**: Sesso, Data Nascita, Luogo Nascita, Data Assunzione, Data Assunzione Gruppo.
* **8 - 14**: Tipo Scuola, Formazione, Livello, Tipo Dipendente, Grado Occupazione, Grado Solidarietà, Contratto Solidarietà.
* **15 - 16**: Società, Società Contabile.
* **17 - 31**: Struttura delle Unità Organizzative (da UO3 a UO9 e relative descrizioni).
* **32 - 34**: CID, Nominativo e Mail del Responsabile UO.
* **35 - 41**: Paese, Regione, Provincia, Sede (Provincia, Indirizzo, CAP, Comune).
* **42 - 45**: Tipo Contratto, Part-Time/Full-Time, Mansione, Posizione.
* **46 - 50**: Classificazione Sistema Professionale (Famiglia, Area, Ambito, Job, Status).
* **51 - 54**: Campi Utente tecnici (COD, RU, KA, RUBU).
* **55 (Colonna BD)**: Indirizzo E-mail.
* **56 - 61**: CID, Nominativo e Mail del Key Account e del Gestore Risorse.
* **62 - 65**: Indicatore Under 35, Responsabile (SI/NO), Tipologia Responsabile, Matricola Aziendale UID.

---

## ⚙️ Configurazione, Compilazione e Avvio Rapido

### 1. Configurazione Autenticazione (Microsoft Entra ID)
Per motivi di sicurezza, i parametri di autenticazione non sono tracciati nel repository git.
Prima di avviare il progetto, è necessario creare il file `auth_config.dart` a partire dal file di esempio fornito:

```bash
cp lib/core/config/auth_config.sample.dart lib/core/config/auth_config.dart
```

Dopodiché, apri `lib/core/config/auth_config.dart` ed inserisci i valori reali per il tuo Tenant ID, Client ID e URL di redirect della web-app.

### 2. Avvio del Progetto
Questo software supporta nativamente la build per OS Desktop e in forma di Web App.

Per testare e sviluppare il codice localmente:
```bash
flutter clean
flutter pub get

# Inizializza il database locale Isar (se apporti modifiche ai modelli o per il primo avvio)
flutter pub run build_runner build --delete-conflicting-outputs

flutter run -d macos # o -d windows / chrome
```
