# translate.pl per Irssi

Lo script `translate.pl` è un add-on per il client IRC Irssi, che permette di tradurre i messaggi in entrata e in uscita su specifici canali IRC.

## Funzionalità

- Traduzione dei messaggi in entrata in lingue selezionate per canale.
- Traduzione dei messaggi in uscita in lingue selezionate per canale.
- Possibilità di abilitare/disabilitare la visualizzazione del testo originale dei messaggi inviati.
- Supporto per l'API di Google Translate.

## Requisiti

- Client IRC: Irssi
- Chiave API Google Translate

## Installazione

1. Scarica lo script `translate.pl` e collocalo nella cartella degli script di Irssi (solitamente `~/.irssi/scripts/`).
2. Carica lo script in Irssi usando il comando:

	- /script load translate.pl


## Configurazione

1. **Imposta la Chiave API di Google Translate**:

	- /set translate_api_key TuaChiaveAPI


2. **Aggiungi una Regola di Traduzione per i Messaggi in Entrata**:

- /translate addin #nome_canale/o_nick lingua_origine lingua_destinazione

	Esempio:

- /translate addin #example it pl
- /translate addin nickname it pl


3. **Aggiungi una Regola di Traduzione per i Messaggi in Uscita**:

- /translate addout #nome_canale/o_nick lingua_origine lingua_destinazione

	Esempio:

- /translate addout #example pl it
- /translate addout nickname pl it


4. **Abilita/Disabilita la Visualizzazione del Testo Originale dei Messaggi Inviati**:

	- Abilita:
	  ```
	  /set translate_print_original on
	  ```
	- Disabilita:
	  ```
	  /set translate_print_original off
	  ```

5. **Salva la Configurazione**:

	- /save


## Utilizzo

- Per visualizzare l'elenco delle attuali regole di traduzione:
	- /translate list

- Per rimuovere una regola di traduzione:
	- /translate remove #nome_canale/o_nick
