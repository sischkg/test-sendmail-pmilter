package Test::Sendmail::PMilter;

use Test::More;
use Moose;
use Moose::Util::TypeConstraints;
use Readonly;
use Sendmail::PMilter q(:all);
use Test::Sendmail::PMilter::Context;
use Test::Sendmail::PMilter::MacroGenerator;

class_type 'Test::Sendmail::PMilter::MacroGenerator';

=head1 NAME

Test::Sendmail::PMilter - The great new Test::Sendmail::PMilter!

=head1 VERSION

Version 0.0.1

=cut

our $VERSION = '0.0.1';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Test::More;
    use Sendmail::PMilter;
    use Test::Sendmail::PMilter;
    use Test::Sendmail::PMilter::MacroGenerator;

    my $macro = new Test::Sendmail::PMilter::MacroGenerator;
    my $milter = new Test::Sendmail::PMilter(
        client_address => '192.168.0.1',
        client_name    => 'client.example.com',
        authen         => 'test-id',
        mail_from      => 'sender@example.com',
        rcpt_to        => [
                            'recipient@example.com',
                            'recipient@example.com',
                            'recipient@example.com',
                          ],
        headers        => [
                            'From: from@example.com',
                            'To: to@example.com',
                            'Subject: test',
                          ],
        body           => "test",
        queue_id       => 'EEE191C1EC1',
        macro          => $macro,
    );

    $milter->setconn( 'local:/var/run/milter.sock' );
    my %callback_of = (
        connect => \&_callback_connect,
        envfrom => \&_callback_envfrom,
        envrcpt => \&_callback_envrcpt,
        eom     => \&_callback_eom,
        abort   => \&_callback_abort,
        close   => \&_callback_close,
    );
    $milter->register( 'smtp-filter', \callback_of, SMFI_CURR_ACTS );

    $milter->expect_connect_response( SMFIS_CONTINUE );
    $milter->expect_helo_response( SMFIS_CONTINUE );
    $milter->expect_envfrom_response( SMFIS_CONTINUE );

    $milter->expect_envrcpt( SMDIS_CONTINUE, 0 );
    $milter->expect_envrcpt( SMFIS_REJECT,   1 );
    $milter->expect_envrcpt( SMFIS_CONTINUE, 2 );

    $milter->expect_header( SMFIS_CONTINUE );
    $milter->expect_header( SMFIS_CONTINUE );
    $milter->expect_header( SMFIS_CONTINUE );

    $milter->expect_eom( SMFIS_CONTINUE );

    $milter->expect_abort( SMFIS_CONTINUE );
    $milter->expect_quit( SMFIS_CONTINUE );

or

    my $macro = new Test::Sendmail::PMilter::MacroGenerator;
    my $milter = new Test::Sendmail::PMilter(
        client_address => '192.168.0.1',
        client_name    => 'client.example.com',
        authen         => 'test-id',
        mail_from      => 'sender@example.com',
        rcpt_to        => [
                            'recipient@example.com',
                            'recipient@example.com',
                            'recipient@example.com',
                          ],
        headers        => [
                            'From: from@example.com',
                            'To: to@example.com',
                            'Subject: test',
                          ],
        body           => "test",
        queue_id       => 'EEE191C1EC1',
        macro          => $macro,
    );

    $milter->setconn( 'local:/var/run/milter.sock' );
    my %callback_of = (
        connect => \&_callback_connect,
        envfrom => \&_callback_envfrom,
        envrcpt => \&_callback_envrcpt,
        eom     => \&_callback_eom,
        abort   => \&_callback_abort,
        close   => \&_callback_close,
    );
    $milter->register( 'smtp-filter', \callback_of, SMFI_CURR_ACTS );

    $milter->expect_result( Test::Sendamil::PMilter::OK );

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=cut

Readonly::Scalar my $DEFAULT_CLIENT_ADDRESS => '127.0.0.1';
Readonly::Scalar my $DEFAULT_HELO           => 'example.com';
Readonly::Scalar my $DEFAULT_MAIL_FROM      => 'sender@example.com';
Readonly::Array  my @DEFAULT_RCPT_TO        => ( 'rcpt01@example.com' );
Readonly::Array  my @DEFAULT_HEADERS        => (
    'From: from@example.com',
    'To: to@example.net',
    'Subject: test',
);
Readonly::Scalar my $DEFAULT_BODY           => "test\r\n";
Readonly::Scalar my $DEFAULT_QUEUE_ID       => 'qidAABBCCDD';

use constant ACCEPT     => 'ACCEPT';
use constant REJECT     => 'REJECT';
use constant TEMPFAIL   => 'TEMPFAIL';
use constant DISCARD    => 'DISCARD';
use constant QUARANTINE => 'QUARANTINE';

has 'callback_of'    => ( isa => 'HashRef',       is => 'rw', default => sub { {} } );

has 'client_address' => ( isa => 'Str',           is => 'ro', default => $DEFAULT_CLIENT_ADDRESS );
has 'client_name'    => ( isa => 'Maybe[Str]',    is => 'ro', default => q{} );
has 'helo'           => ( isa => 'Str',           is => 'ro', default => $DEFAULT_HELO );
has 'auth_authen'    => ( isa => 'Maybe[Str]',    is => 'ro', default => undef );
has 'mail_from'      => ( isa => 'Str',           is => 'ro', default => $DEFAULT_MAIL_FROM );
has 'rcpt_to'        => ( isa => 'ArrayRef[Str]', is => 'ro', default => sub { \@DEFAULT_RCPT_TO } );
has 'headers'        => ( isa => 'ArrayRef[Str]', is => 'ro', default => sub { \@DEFAULT_HEADERS } );
has 'body'           => ( isa => 'Str',           is => 'ro', default => $DEFAULT_BODY ); 
has 'queue_id'       => ( isa => 'Str',           is => 'ro', default => $DEFAULT_QUEUE_ID );

has 'private_data'   => ( isa => 'Any',           is => 'rw', default  => undef );
has 'macro_generator' => ( isa => 'Test::Sendmail::PMilter::MacroGenerator',
                           is  => 'rw',
                           default => sub { new Test::Sendmail::PMilter::MacroGenerator } );

=head2 new

=cut new

=over 4

=item * client_address

=item * client_name

=item * helo

=item * auth_authen

=item * mail_from

=item * rcpt_to

=item * headers

=item * body

=item * queue_id

=item * macro_generator

=back

=head2 register

=cut

sub register {
    my $this = shift;
    my ( $dummy1, $callback_of, $dummy2 ) = @_;

    $this->callback_of( $callback_of );
}

=head2 function2

=cut

sub setconn {
}


sub main {
    my $this = shift;
}


sub headers_count {
    return $#{ $_[0]->headers } + 1;
}

sub recipients_count {
    return $#{ $_[0]->rcpt_to } + 1;
}

sub _expect_response {
    my $this = shift;
    my ( $args ) = @_;
    my $expected = $args->{expected};
    my $callback = $args->{callback};
    my $arg      = $args->{arg};
    my $message  = $args->{message};

    ok( exists( $this->callback_of->{$callback} ), "connect $callback must be defined" );

    my $context = new Test::Sendmail::PMilter::Context();
    $context->private_data( $this->private_data );
    $context->macro( $this->macro_generator->$callback( $this ) );

    my $response = $this->callback_of->{$callback}( $context, $arg );
    $this->private_data( $context->private_data );

    is( $response, $expected, $message );
}

sub expect_connect_response {
    my $this = shift;
    my ( $expected, $message ) = @_;

    my $client = $this->client_name ? $this->client_name : $this->client_address;
    $this->_expect_response( { expected => $expected,
                               callback => 'connect',
                               arg      => $client,
                               message  => $message } );
}


sub expect_helo_response {
    my $this = shift;
    my ( $expected, $message ) = @_;
    $this->_expect_response( { expected => $expected,
                               callback => 'helo',
                               arg      => $this->helo,
                               message  => $message } );
}


sub expect_envfrom_response {
    my $this = shift;
    my ( $expected, $message ) = @_;
    $this->_expect_response( { expected => $expected,
                               callback => 'envfrom',
                               arg      => $this->mail_from,
                               message  => $message } );
}

sub expect_envrcpt_response {
    my $this = shift;
    my ( $expected, $index, $message ) = @_;

    if ( $index < 0 || $index >= @{ $this->rcpt_to } ){
        die sprintf( "invalid recipient index %d, must be 0 <= index < %d\n", $index, $this->recipients_count );
    }

    my $rcpt          = $this->rcpt_to->[$index];
    my $msg_with_rcpt = sprintf( "recipient: %s(index: %d); %s", $rcpt, $index, $message ? $message : q{} );
    $this->_expect_response( { expected => $expected,
                               callback => 'envrcpt',
                               arg      => $rcpt,
                               message  => $msg_with_rcpt } );
}

sub expect_header_response {
    my $this = shift;
    my ( $expected, $index, $message ) = @_;

    if ( $index < 0 || $index >= @{ $this->headers } ){
        die sprintf( "invalid header index %d, must be 0 <= index < %d\n", $index, $this->headers_count );
    }

    my $header          = $this->headers->[$index];
    my $msg_with_header = sprintf( "header: %s(index: %d); %s", $header, $index, $message ? $message : q{} );
    $this->_expect_response( { expected => $expected,
                               callback => 'header',
                               arg      => $header,
                               message  => $msg_with_header } );
}


sub expect_eoh_response {
    my $this = shift;
    my ( $expected, $message ) = @_;
    $this->_expect_response( { expected => $expected,
                               callback => 'eoh',
                               message  => $message } );
}

sub expect_eom_response {
    my $this = shift;
    my ( $expected, $message ) = @_;
    $this->_expect_response( { expected => $expected,
                               callback => 'eom',
                               message  => $message } );
}


sub _check_response {
    my $this = shift;
    my ( $callback, $arg ) = @_;

    if ( $this->callback_of->{$callback} ) {
	my $context = new Test::Sendmail::PMilter::Context();
	$context->private_data( $this->private_data );
	$context->macro( $this->macro_generator->$callback( $this ) );

	my $response = $this->callback_of->{$callback}( $context, $arg );
	$this->private_data( $context->private_data );
	return $response;
    }
    else {
	return SMFIS_CONTINUE;
    }
}

sub expect_result {
    my $this = shift;
    my ( $expected, $message ) = @_;

    my $all_recipients_result = 0;
    my @recpient_results;
    my $headers_result       = 0;
    my $response_of_message  = ACCEPT;

    my $response = $this->_check_response( 'connect', $this->client_address );
    if ( $response == SMFIS_REJECT  )  { $response_of_message = REJECT;   goto PROCESS_END; }
    if ( $response == SMFIS_TEMPFAIL ) { $response_of_message = TEMPFAIL; goto PROCESS_END; }
    if ( $response == SMFIS_DISCARD )  { $response_of_message = REJECT;   goto PROCESS_END; }

    $response = $this->_check_response( 'helo', $this->helo );
    if ( $response == SMFIS_REJECT  )  { $response_of_message = REJECT;   goto PROCESS_END; }
    if ( $response == SMFIS_TEMPFAIL ) { $response_of_message = TEMPFAIL; goto PROCESS_END; }
    if ( $response == SMFIS_DISCARD )  { $response_of_message = REJECT;   goto PROCESS_END; }

    $response = $this->_check_response( 'envfrom', $this->mail_from );
    if ( $response == SMFIS_REJECT  )  { $response_of_message = REJECT;   goto PROCESS_END; }
    if ( $response == SMFIS_TEMPFAIL ) { $response_of_message = TEMPFAIL; goto PROCESS_END; }
    if ( $response == SMFIS_DISCARD )  { $response_of_message = REJECT;   goto PROCESS_END; }

    foreach my $rcpt_to ( @{ $this->rcpt_to } ) {
	$response = $this->_check_response( 'envrcpt', $rcpt_to );
	if ( $response == SMFIS_CONTINUE || $response == SMFIS_ACCEPT ) {
	    $all_recipients_result = 1;
	}
	my $result = 0;
	if ( $response == SMFIS_REJECT  )  { $response_of_message = REJECT; }
	if ( $response == SMFIS_TEMPFAIL ) { $response_of_message = TEMPFAIL; }
	if ( $response == SMFIS_DISCARD )  { $response_of_message = REJECT; }
    }

    foreach my $header ( @{ $this->headers } ) {
	$response = $this->_check_response( 'header', $header );
	if ( $response == SMFIS_REJECT  )  { $response_of_message = REJECT;   goto PROCESS_END; }
	if ( $response == SMFIS_TEMPFAIL ) { $response_of_message = TEMPFAIL; goto PROCESS_END; }
	if ( $response == SMFIS_DISCARD )  { $response_of_message = REJECT;   goto PROCESS_END; }
    }

    $response = $this->_check_response( 'eoh' );
    if ( $response == SMFIS_REJECT  )  { $response_of_message = REJECT;   goto PROCESS_END; }
    if ( $response == SMFIS_TEMPFAIL ) { $response_of_message = TEMPFAIL; goto PROCESS_END; }
    if ( $response == SMFIS_DISCARD )  { $response_of_message = REJECT;   goto PROCESS_END; }

    $response = $this->_check_response( 'eom', $this->body );
    if ( $response == SMFIS_REJECT  )  { $response_of_message = REJECT;   goto PROCESS_END; }
    if ( $response == SMFIS_TEMPFAIL ) { $response_of_message = TEMPFAIL; goto PROCESS_END; }
    if ( $response == SMFIS_DISCARD )  { $response_of_message = REJECT;   goto PROCESS_END; }

    $response_of_message = ACCEPT;
  PROCESS_END:
    is( $response_of_message, $expected, $message );
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 AUTHOR

Toshifumi Sakaguchi, C<< <sischkg at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-test-sendmail-pmilter at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-Sendmail-PMilter>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Test::Sendmail::PMilter


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-Sendmail-PMilter>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Test-Sendmail-PMilter>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Test-Sendmail-PMilter>

=item * Search CPAN

L<http://search.cpan.org/dist/Test-Sendmail-PMilter/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Toshifumi Sakaguchi.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;
