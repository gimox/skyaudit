
## Tecnologica
applicativo desktop fatto in flutter, 

## SCOPO
deve permettere di verificare la parte contabile di un sistema travel aziendale.

il nome dell'applicazione è SkyAudit

L'operativà consiste nell'inserire diversi file e costruire un recordset coerente e pulito.

Una volta inserito saranno fatti diversi controlli in base al tipo di file e ai dati contenuti.

L'applicativo potrà essere compilato anche in forma di WEB app. QUESTO E' MOLTO IMPORTANTE QUINDI FAI ATTENZIONE A QUESTA COSA.

Deve essere fatta un'attenta analisi del codice in modo tale da rendere il codice il più pulito e leggibile possibile in ottica di futuro aggiornamento/manutenzione.

viene usato flutter applicata una best pratcice.

Strutture, directory e nome delle classi coerenti e pulite.

data la estrema complessità del sistema e la grande quantità di dati, il software deve essere estremamente performante.

utilizza 
- GoRouter per la gestione della navigazione.
- Riverpod per la gestione dello stato.
- material 3 per l'interfaccia.
- Isar per il database

## UX/UI
L'interfaccia deve essere moderna, pulita, user-friendly e accattivante, studiata appositamente per sistemi gestionali moderni.

Il tema deve essere personalizzabile con i colori aziendali in stile TIM

Gli assets sono nella cartella /assets del progetto

***IMPORTANTE*** LA UI deve essere esteticamente molto gradevole e accattivante. Deve essere studiata appositamente per sistemi gestionali moderni. 

Deve essere molto curata nei dettagli, pulita e professionale. 
DEVE ESSERE PERFETTAMENTE RESPONSIVE.

MOLTO IMPORTANTE. DEVE ESSERE PERFETTAMENTE RESPONSIVE. Ogni volta che aggiungi un componente deve rispondere perfettamente ai cambi di dimensione di interfaccia.
Implementa sempre i patter UI di material da manuale. 


## Liste e tabelle
sempre responsibe e sempre paginate di default a 50 items.
Ogni lista deve avere opzioni di filtro rapide e veloci. Devono essere ben visibili e facilmente accessibili.

## DB

l'applicativo fa uso di un database isar per la memorizzazione dei dati.
import 'package:isar/isar.dart';

le impostazioni contengono una sezione chiamata GESTIONE DATABASE LOCALE.
Ogni volta che aggiungerai una collection devi inserire al suo interno la voce per poterla cancellare.

Ogni volta che aggiungerai una collection devi inserire anche il provider relativo per aggiornare l'interfaccia grafica. 


## DECIFRARE I FILE 


### FILE TRACCIATO CONTABILE (*.TXT)

Esempio di record
1077017076000005296001A150IMTNP126018299420020260326CATANZARO                                                  2026032608300020260326173000C000000000059.4800000EUR   R#


#### 1. FILTRO RIGHE
- Ignora la prima riga del file (Header/Controllo).
- Ignora l'ultima riga del file (Footer/Controllo).
- Elabora esclusivamente i record centrali.

#### 2. SCHEMA DI ESTRAZIONE E TRASFORMAZIONE
Estrai i dati da ogni riga in base alle seguenti posizioni dei caratteri (1-based indexing):

- **CID**: caratteri 2-9
- **Numero Trasferta**: caratteri 10-19
- **Progressivo Giustificativo**: caratteri 20-22
- **Società**: caratteri 23-26
- **Tipo Dipendente**: caratteri 27-28
- **Giustificativo di Spesa**: caratteri 29-32
- **Numero Bolla**: caratteri 33-44
- **Data Spesa**: caratteri 45-52 → Converti in formato italiano DD/MM/YYYY
- **Località Trasferta**: caratteri 53-111 → Rimuovi tutti gli spazi vuoti di padding (Trim)
- **Data Inizio**: caratteri 112-119 → Converti in formato italiano DD/MM/YYYY
- **Ora Inizio**: caratteri 120-125 → Formatta come HH:MM:SS
- **Data Fine**: caratteri 126-133 → Converti in formato italiano DD/MM/YYYY
- **Ora Fine**: caratteri 134-139 → Formatta come HH:MM:SS
- **Tipo Attività**: carattere 140
- **Importo**: caratteri 141-160 → Pulisci dagli zeri iniziali/finali e converti in formato numerico decimale.
- **Valuta**: caratteri 161-163 (es: EUR)
- **Segno**: carattere 166. 

#### 3. LOGICA DI BUSINESS APPLICATA
- **Segno Negativo**: Se il carattere in posizione 166 è "R", l'Importo deve essere visualizzato con il segno meno (es. -59,48). Se la posizione 166 è vuota o contiene altri valori, l'importo è positivo.
- **Pulizia Valuta**: Mostra l'importo pulito affiancato dal codice valuta.



## DIZIONARI
in impostazioni ci sarà la sezione dizionari. 
qui dovra essere possibile inserire e modificare i diversi codici e descrizioni che saranno usati per la decodifica dei file.

Devi estrarre sempre i dizionari da isar e usarli per la decodifica dei file.

La logica di decodifica dei files deve essere la seguente:

ogni campo del file che usa un codice deve essere decodificato usando il dizionario corrispondente.

Ad esempio, il campo "Giustificativo di Spesa" usa un codice che deve essere decodificato usando il dizionario "Giustificativo di Spesa".


I dizionari sono sempre inseriti in un database e si possono aggiungere/modificare tramite la sezione "Dizionari" di impostazioni.

### DIZIONARIO GIUSTIFICATIVI SPESA
Il dizionario giustificativi spesa è un dizionario che contiene i codici dei giustificativi di spesa e le loro descrizioni. 

ALP1
Alloggio prepagato
SSP1
Visti consolari - pre. Autom.
TAP1
Aereo - prepagato Automatico
TGP1
Traghetto  - prepagato Autom.
TNP1
Noleggio auto prep. Autom.
TTP1
Treno  - prepagato  Automatico

### DIZIONARIO TIPO DIPENDENTE
 - QD: Quadro
 - IM: Impiegato
 - RS: Risorsa Strategica
 - DR: Dirigente


### Dizionario Società
 - C120: TIM S.p.A.
 - C140: Noovle S.p.A
 - A710: TI Trust Technol. S.r.L.
 - A640: TI Sparkle S.p.A.
 - A200: Olivetti S.p.A.
 - A150: Telecontact Center S.p.A

