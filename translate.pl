use strict;
use warnings;
use Irssi;
use Irssi::TextUI;
use LWP::UserAgent;
use JSON;

our $VERSION = '1.0';
our %IRSSI = (
    authors     => 'Jerzy (kofany) Dabrowski',
    name        => 'translate.pl',
    description => 'Translates incoming and outgoing messages on a per client basis. Based on script by Vlastimil Ovčáčík',
    license     => 'The MIT License',
    url         => 'https://github.com/kofany/irssi_translate'
);

Irssi::settings_add_str('translate', 'translate_list_in', '{}');
Irssi::settings_add_str('translate', 'translate_list_out', '{}');
Irssi::settings_add_str('translate', 'translate_api_key', '');
Irssi::settings_add_int('translate', 'translate_scrollback_lines', 3);
Irssi::settings_add_bool('translate', 'translate_print_original', 0); # 0 oznacza 'off' jako wartość domyślną

my %translate_list_in = %{ decode_json(Irssi::settings_get_str('translate_list_in')) };
my %translate_list_out = %{ decode_json(Irssi::settings_get_str('translate_list_out')) };

Irssi::command_bind('translate', \&on_translate);
Irssi::command_bind('translate addin', \&on_translate_addin);
Irssi::command_bind('translate addout', \&on_translate_addout);
Irssi::command_bind('translate list', \&on_translate_list);
Irssi::command_bind('translate remove', \&on_translate_remove);
Irssi::command_bind('translate save', \&on_translate_save);
Irssi::command_bind('translate reload', \&on_translate_reload);
Irssi::command_bind('tr', 'on_tr_command');

Irssi::signal_add('message public', \&on_message);
Irssi::signal_add('message private', \&on_message);
Irssi::signal_add('send text', \&on_send_text);

sub detect_language {
    my ($text) = @_;
    return unless $text;

    my $ua = LWP::UserAgent->new;
    my $api_key = Irssi::settings_get_str('translate_api_key');
    return unless $api_key;

    my $response = $ua->post("https://translation.googleapis.com/language/translate/v2/detect", {
        key => $api_key,
        q => $text
    });

    if ($response->is_success) {
        my $content = decode_json($response->decoded_content);
        my $detected_language = $content->{data}->{detections}->[0]->[0]->{language};
        return $detected_language;
    } else {
        Irssi::print("Language detection error: " . $response->status_line);
        return;
    }
}

sub on_tr_command {
    my ($data, $server, $item) = @_;
    my ($target_lang, $text_to_translate) = $data =~ /^(\S+)\s+(.*)$/;

    if (!$target_lang || !$text_to_translate) {
        Irssi::print("Usage: /tr target_language text_to_translate", MSGLEVEL_CLIENTCRAP);
        return;
    }

    my $source_lang = detect_language($text_to_translate);
    if (!$source_lang) {
        Irssi::print("Could not detect source language.", MSGLEVEL_CLIENTCRAP);
        return;
    }

    my $translation = translate($text_to_translate, $source_lang, $target_lang);
    if ($translation) {
        # Wysyłanie przetłumaczonego tekstu do aktywnego okna czatu
        if ($item && ($item->{type} eq "CHANNEL" || $item->{type} eq "QUERY")) {
            # Wysyłanie na kanał lub w prywatnej rozmowie
            $server->command("msg " . $item->{name} . " " . $translation);
        } else {
            Irssi::print("Translation error: Not in a channel or query window.", MSGLEVEL_CLIENTCRAP);
        }
    } else {
        Irssi::print("Translation error or no translation available.", MSGLEVEL_CLIENTCRAP);
    }
}

sub on_translate {
    my ($data, $server, $item) = @_;
    my ($arg1) = split(' ', $data);
    if ($arg1) {
        Irssi::command_runsub('translate', $data, $server, $item);
    } else {
        on_translate_list();
    }
}

sub on_translate_addin {
    my ($data, $server, $item) = @_;
    my ($channel, $source_lang, $target_lang) = split(' ', $data);
    $translate_list_in{$channel} = {
        'source_lang' => $source_lang,
        'target_lang' => $target_lang
    };
    Irssi::settings_set_str('translate_list_in', encode_json(\%translate_list_in));
}

sub on_translate_addout {
    my ($data, $server, $item) = @_;
    my ($channel, $source_lang, $target_lang) = split(' ', $data);
    $translate_list_out{$channel} = {
        'source_lang' => $source_lang,
        'target_lang' => $target_lang
    };
    Irssi::settings_set_str('translate_list_out', encode_json(\%translate_list_out));
}

sub on_translate_list {
    my $width = 25;
    Irssi::print("%WChannel%-${width}s In Lang%-${width}s Out Lang%n", MSGLEVEL_CLIENTCRAP);
    foreach my $channel (keys %translate_list_in) {
        my $in_langs = $translate_list_in{$channel};
        my $out_langs = $translate_list_out{$channel} // {'source_lang' => 'n/a', 'target_lang' => 'n/a'};
        Irssi::print(sprintf("%-${width}s%-${width}s%-${width}s",
            $channel,
            $in_langs->{'source_lang'} . "->" . $in_langs->{'target_lang'},
            $out_langs->{'source_lang'} . "->" . $out_langs->{'target_lang'}
        ), MSGLEVEL_CLIENTCRAP);
    }
}

sub on_translate_remove {
    my ($data, $server, $item) = @_;
    delete $translate_list_in{$data};
    delete $translate_list_out{$data};
    Irssi::settings_set_str('translate_list_in', encode_json(\%translate_list_in));
    Irssi::settings_set_str('translate_list_out', encode_json(\%translate_list_out));
}

sub on_translate_save {
    Irssi::settings_set_str('translate_list_in', encode_json(\%translate_list_in));
    Irssi::settings_set_str('translate_list_out', encode_json(\%translate_list_out));
}

sub on_translate_reload {
    %translate_list_in = %{ decode_json(Irssi::settings_get_str('translate_list_in')) };
    %translate_list_out = %{ decode_json(Irssi::settings_get_str('translate_list_out')) };
}

sub on_message {
    my ($server, $msg, $nick, $address, $target) = @_;
    my $chatnet = $server->{chatnet};

    my $is_private = $target eq $server->{nick};
    my $translate_key = $is_private ? $nick : $target;

    if (exists $translate_list_in{$translate_key}) {
        my $langs = $translate_list_in{$translate_key};
        my $detected_lang = detect_language($msg);

        my $char_count = length($msg);
        my $contains_spaces = $msg =~ /\s/;
        my $is_alphanumeric = $msg =~ /^[a-zA-Z0-9]+$/;

        my $should_translate = 0;
        if ($contains_spaces) {
            $should_translate = $char_count >= 6;
        } elsif ($is_alphanumeric) {
            $should_translate = $char_count >= 4;
        }

        if ($should_translate && $detected_lang ne $langs->{target_lang}) {
            my $translation = translate($msg, $detected_lang, $langs->{target_lang});
            if ($translation) {
                my $translated_text = $translation . " (from $detected_lang)";
                # Dodaj oryginalny tekst, jeśli wiadomość ma mniej niż 8 znaków
                if ($char_count < 8) {
                    $translated_text .= " (original: $msg)";
                }
                Irssi::signal_continue($server, $translated_text, $nick, $address, $target);
            }
        }
    }
}

sub on_send_text {
    my ($line, $server, $item) = @_;
    return unless $item;

    my $target = $item->{name};
    if (exists $translate_list_out{$target}) {
        my $langs = $translate_list_out{$target};
        my $translation = translate($line, $langs->{source_lang}, $langs->{target_lang});
        if ($translation) {
            if (Irssi::settings_get_bool('translate_print_original')) {
                # Wyświetl oryginalny tekst w aktywnym oknie, jeśli ustawienie jest włączone
                Irssi::active_win()->print("%Moriginal text %Y>>%n $line", MSGLEVEL_CLIENTCRAP);
            }
            # Kontynuuj z przetłumaczonym tekstem
            Irssi::signal_continue($translation, $server, $item);
        }
    }
}


sub translate {
    my ($text, $from, $to) = @_;
    return $text unless $text && $from && $to;

    my $ua = LWP::UserAgent->new;
    my $api_key = Irssi::settings_get_str('translate_api_key');
    return $text unless $api_key;

    my $response = $ua->post("https://translation.googleapis.com/language/translate/v2", {
        key => $api_key,
        q => $text,
        target => $to,
        source => $from,
        format => "text"
    });

    if ($response->is_success) {
        my $content = decode_json($response->decoded_content);
        return $content->{data}->{translations}->[0]->{translatedText};
    } else {
        Irssi::print("Translation error: " . $response->status_line);
        return $text;
    }
}

1;
