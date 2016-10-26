# NAME

WWW::SubDB - Interface to thesubdb.com API

# VERSION

Version 0.01

# SYNOPSIS

This module is an interface to [http://thesubdb.com](http://thesubdb.com) API. It allows to search and download subtitles based on movie file hashes.

    use WWW::SubDB;

    my $subdb = WWW::SubDB->new();
    ...

# SUBROUTINES/METHODS

## new

    my $subdb = WWW::SubDB->new()

    my $subdb = WWW::SubDB->new( debug => 1 )

Initializes the object, with debug = 1, the sandbox SubDB API will be used

## languages

    my $lang = $subdb->languages()

Returns the list of languages supported by SubDB. The result is a string with languages separated by (,). Ex: en,es,fr,it,nl,pl,pt,ro,sv,tr

## search

    my $file = 'movie.mp4'

    my $result = $subdb->languages($file [,$versions])

Returns a list of available subtitle languages for a given file. if $versions is set to 1, returns the number of available versions for each language. If there are no subtitles available, it will return undef.

## download

    my $file = 'movie.mp4';
    my $langs = 'en,pt';
    my $subtitle = $subdb->download($file, $langs);

Return the subtitle for a given movie. It will return the first language found according to $langs. Will return undef if not found.

## upload

    my $file = 'movie.mp4';
    my $subtitle = 'movie.srt';

    my $uploaded = $subdb->upload($file, $subtitle);

Will upload the subtitle file for the the given movie file.

## http\_status

    $subdb->http_status()

Will show the last HTTP status code

## error

    $subdb->error() 

Will show the last HTTP status line in case there was an error 

# AUTHOR

Bruno Martins, `<=bscmartins at gmail.com>` 

[https://twitter.com/b\_martins](https://twitter.com/b_martins)

[https://github.com/bmartins](https://github.com/bmartins)

# BUGS

Please report any bugs or feature requests at  [https://github.com/bmartins/WWW-SubDB](https://github.com/bmartins/WWW-SubDB)

# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::SubDB

# LICENSE AND COPYRIGHT

Copyright 2016 Bruno Martins.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.
