# translate.pl for Irssi

Skrypt `translate.pl` jest dodatkiem do klienta IRC Irssi, umożliwiającym tłumaczenie wiadomości przychodzących i wychodzących na wybranych kanałach IRC.

## Funkcje

- Tłumaczenie wiadomości przychodzących na wybrane języki per kanał.
- Tłumaczenie wiadomości wychodzących na wybrane języki per kanał.
- Możliwość włączania/wyłączania wyświetlania oryginalnego tekstu wysyłanych wiadomości.
- Obsługa Google Translate API.

## Wymagania

- Klient IRC: Irssi
- Klucz API Google Translate

## Instalacja

1. Pobierz skrypt `translate.pl` i umieść go w katalogu skryptów Irssi (zwykle `~/.irssi/scripts/`).
2. Załaduj skrypt w Irssi za pomocą komendy:

	- /script load translate.pl


## Konfiguracja

1. **Ustaw Klucz API Google Translate**:

	- /set translate_api_key TwójKluczAPI


2. **Dodaj Regułę Tłumaczenia dla Wiadomości Przychodzących**:

- /translate addin #nazwa_kanału/lub_nick język_źródłowy język_docelowy

	Przykład:

- /translate addin #example it pl
- /translate addin nickname it pl


3. **Dodaj Regułę Tłumaczenia dla Wiadomości Wychodzących**:

- /translate addout #nazwa_kanału/lub_nick język_źródłowy język_docelowy

	Przykład:

- /translate addout #example pl it
- /translate addout nickname pl it


4. **Włącz/Wyłącz Wyświetlanie Oryginalnego Tekstu Wysyłanych Wiadomości**:

	- Włącz:
	  ```
	  /set translate_print_original on
	  ```
	- Wyłącz:
	  ```
	  /set translate_print_original off
	  ```

5. **Zapisz Konfigurację**:

	- /save


## Użycie
- Komedna /tr kod_języka tekst do szybkiego tłumaczenia na dany język
- Aby wyświetlić listę aktualnych reguł tłumaczenia:
	- /translate list

- Aby usunąć regułę tłumaczenia:
	- /translate remove #nazwa_kanału/lub_nick
