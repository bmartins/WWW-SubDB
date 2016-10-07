package WWW::SubDB;

use 5.006;
use strict;
use warnings;
use Mouse;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Request::Common;
use Digest::MD5 qw(md5_hex);
use Params::Validate qw(:all);


has '_endpoint' => (
    isa => 'Str',
    is  =>'ro',
	lazy_build => 1,
);

has 'error' => (
    isa => 'Maybe[Str]',
    is  => 'rw',
    default => undef,
);

has '_user_agent' => (
	isa => 'Str',
	is => 'ro',
	default => 'SubDB/1.0 (WWW::SubDB/0.1;)'
);

has 'http_status' => (
    isa => 'Maybe[Str]',
    is  =>'rw',
    default => undef,
);

has 'debug' => (
	isa => 'Int',
	is => 'rw',
	default => 0
);


sub _build__endpoint {
	my($self) = @_;
	return 'http://sandbox.thesubdb.com/' if ($self->debug);
	return 'http://api.thesubdb.com/';
}





=head1 NAME

WWW::SubDB - The great new WWW::SubDB!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use WWW::SubDB;

    my $foo = WWW::SubDB->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut



=head2 function2

=cut

sub languages {
	my ($self) = @_;
	my $request = HTTP::Request->new('GET', $self->_endpoint .'?action=languages');
	return $self->_do_request($request);
}

sub search {
	my ($self, $file, $versions) = @_;
	shift @_;
	validate_pos(@_, { type => SCALAR }, { type => SCALAR , optional => 1 });
	$versions ||= 0;

	return undef if (!$self->_valid_file($file));

	my $file_hash = $self->_file_hash($file);
	my $url = $self->_endpoint . '?action=search&hash=' . $file_hash;
	if ( $versions ) {
		$url .='&versions';
	}
	my $request = HTTP::Request->new('GET', $url );
	return $self->_do_request($request);
}

sub download {
	my ($self, $file, @langs) = @_;
	shift @_;
	validate_pos(@_, { type => SCALAR }, { type => SCALAR } );
	my $lang = join(',', @langs);
	return undef if (!$self->_valid_file($file));
	my $file_hash = $self->_file_hash($file);
	my $url = $self->_endpoint . '?action=download&hash=' . $file_hash .'&language=' . $lang;
	my $request = HTTP::Request->new('GET', $url );
	return $self->_do_request($request);

}

sub upload {
	my ($self, $file, $subtitle_file) = @_;

	return undef if (!$self->_valid_file);
	my $file_hash = $self->_file_hash($file);
	my $request = POST  $self->_endpoint .'?action=upload', Content_Type => 'form-data', Content => [ hash => $file_hash, file => [$subtitle_file, 'subtitle.srt', 'Content-type' => 'application/octet-stream'] ] ;
	return $self->_do_request($request);
}


sub _valid_file {
	my ($self, $file) = @_;
	if (!-e $file) {
		$self->_file_error( $file . ' not found');
		return 0;
	}
	if (!open(my $fh, "<", $file)) {
		$self->_file_error($file .' ' . $!);
		return 0;
	}
	return 1;
}

sub _file_error {
	my ($self, $error) =@_;
	$self->http_status('400');
	$self->error($error);
	return 1;
}




sub _file_hash {
	my ($self, $f) = @_;

    my @stat = stat ($f);
    my $f_size = $stat[7];
    my $nbytes = 64*1024;

    my $data;
    my $r;
    open(my $fh , "<", $f);
    read($fh, $r, $nbytes);
    $data .=$r;
    seek($fh,$f_size-$nbytes, 0);
    read($fh, $r, $nbytes );
    $data .= $r;
    close($fh);

    return md5_hex($data);

}

sub _do_request {
	my ($self, $request) = @_;
	$self->http_status('');
	$self->error(undef);

	$request->header('User-Agent' => $self->_user_agent);

	my $ua = LWP::UserAgent->new();
	my $response = $ua->request($request);
	$self->http_status($response->code);
	if ($response->is_success) {
		return $response->decoded_content;
	} else {
		$self->error($response->status_line);
		return undef;
	}
}


=head1 AUTHOR

Bruno Martins, C<< <=bscmartins at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-subdb at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-SubDB>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::SubDB


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-SubDB>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-SubDB>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-SubDB>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-SubDB/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2015 Bruno Martins.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of WWW::SubDB
