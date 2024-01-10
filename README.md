# translate.pl for Irssi

The `translate.pl` script is an add-on for the Irssi IRC client, enabling the translation of incoming and outgoing messages on specific IRC channels.

## Features

- Translation of incoming messages into selected languages per channel.
- Translation of outgoing messages into selected languages per channel.
- Ability to enable/disable displaying the original text of sent messages.
- Support for Google Translate API.

## Requirements

- IRC Client: Irssi
- Google Translate API Key

## Installation

1. Download the `translate.pl` script and place it in the Irssi scripts directory (usually `~/.irssi/scripts/`).
2. Load the script in Irssi using the command:

   - /script load translate.pl


## Configuration

1. **Set Google Translate API Key**:

   - /set translate_api_key YourAPIKey


2. **Add Translation Rule for Incoming Messages**:

- /translate addin #channel_name/or_nick source_language target_language

   Example:

- /translate addin #example it pl
- /translate addin nickname it pl


3. **Add Translation Rule for Outgoing Messages**:

- /translate addout #channel_name/or_nick source_language target_language

   Example:

- /translate addout #example pl it
- /translate addout nickname pl it


4. **Enable/Disable Displaying Original Text of Sent Messages**:

   - Enable:
     ```
     /set translate_print_original on
     ```
   - Disable:
     ```
     /set translate_print_original off
     ```

5. **Save Configuration**:

   - /save


## Usage

- To display the list of current translation rules:
   - /translate list

- To remove a translation rule:
   - /translate remove #channel_name/or_nick
