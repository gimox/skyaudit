# SkyAudit (Travel Check)

**SkyAudit** è un applicativo aziendale avanzato, sviluppato in Flutter (Desktop/Web), progettato per automatizzare, verificare e snellire la rendicontazione contabile legata al sistema travel aziendale. 

L'obiettivo principale del software è l'importazione di file in formato testuale (TXT posizionale) per la costruzione di un recordset coerente e pulito, su cui applicare rigorosi controlli finanziari e analizzare statistiche di trasferta per centro di costo.

---

## 🚀 Funzionalità Principali

- **Importazione Intelligente (Upload):** Parsing ad alte prestazioni di file TXT basato su indici di stringa (1-based indexing) per estrapolare dinamicamente le voci contabili saltando intestazioni e finali di controllo.
- **Tracciato Contabile:** Visualizzazione tabellare ultra-veloce di tutti i flussi incamerati. Include filtri avanzati, controlli di ordinamento e funzionalità per l'esportazione verso formato Excel.
- **Controlli Trasferte:** Modulo di revisione per aggregare e analizzare spese multiple di una singola trasferta. L'interfaccia include multi-selezione dinamica, Zebra Striping e una visione compatta a pop-up simile al layout di una busta contabile.
- **Dashboard Analitica:** Pannello direzionale con indicatori numerici (KPI) e grafici (Line e Pie Charts via `fl_chart`) per monitorare spese, trasferte mensili, impatto per "Tipo Dipendente" e statistiche top-20 sui CID.
- **Database Administration:** Interfaccia nativa (nelle "Impostazioni") per la formattazione e lo svuotamento protetto della collection Isar locale.

---

## 🛠️ Stack Tecnologico e Scelte Architetturali

Il progetto applica le best practices più recenti dello sviluppo su framework Flutter, con netta separazione in *Features* verticali.

- **Framework:** Flutter (target macOS, Windows, Linux e Web).
- **State Management:** [Riverpod](https://riverpod.dev/) (fortemente tipizzato, separato dall'UI layer).
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router) per percorsi dichiarativi.
- **Local Database:** [Isar Database](https://isar.dev/) (NoSQL database ultra-veloce e performante su dataset estesi, scelto in base alla grande quantità di record elaborabili).
- **UI & Grafica:** Material 3 con forte personalizzazione su linee guida e colori aziendali stile TIM (SkyTheme).
- **Gestione Finestra (Desktop):** `window_manager` per barre del titolo native macOS/Windows e bordi dinamici.

---

## 📂 Struttura del Progetto (Layered / Feature-first)

```text
lib/
├── core/
│   ├── config/       # Costanti globali di app
│   ├── db/           # Inizializzazione provider database Isar
│   ├── navigation/   # GoRouter e routes
│   └── theme/        # Tema Material 3, colori TIM, stili custom
├── features/
│   ├── analysis/     # Tracciato contabile
│   ├── controls/     # Controlli Trasferte
│   ├── dashboard/    # Grafici e KPI
│   ├── home/         # Scaffold base e SideBar menu
│   ├── settings/     # Database wipe actions
│   └── upload/       # Importazione e parser modello
└── shared/
    └── widgets/      # Widget riutilizzabili (Es: SkyAnimatedBackground)
```

---

## 📊 Regole e Logica di Business

Ogni riga di dettaglio TXT viene scansionata secondo offset esatti:
* **CID:** 2-9
* **Trasferta/Giustificativo:** 10-19 e 20-22
* **Azienda:** Società (23-26), Tipo Dipendente (27-28)
* **Importi & Valuta:** 141-160 e 161-163 (I segni negativi sono letti dal carattere in pos. 166 indicato con 'R').
* **Date e Ore:** Conversione automatica in formati standard Europei/Italiani per data/ora di spesa e inizio/fine trasferta.

---

## ⚙️ Compilazione e Avvio Rapido

Questo software supporta nativamente la build per OS Desktop e in futuro anche in Web.

Per testare e sviluppare il codice localmente:
```bash
flutter clean
flutter pub get

# Opzionale: Se modifichi il modello `tracciato_contabile.dart`, rigenera il codice per Isar
flutter pub run build_runner build --delete-conflicting-outputs

flutter run -d macos
```
