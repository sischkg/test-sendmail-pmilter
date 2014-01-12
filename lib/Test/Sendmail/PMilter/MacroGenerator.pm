package Test::Sendmail::PMilter::MacroGenerator;

use strict;
use warnings;
use Moose;
use Data::Dumper;

Readonly::Hash my %CONNECT_MACRO_OF => (
     'v'             => sub { "Test::Sendmail::PMilter $Test::Sendmail::PMilter::VERSION" },
     '_'             => sub { 'client.example.com[192.168.0.1]' },
     '{daemon_name}' => sub { 'server.example.com' },
     'j'             => sub { 'server.example.com' },
);

Readonly::Hash my %HELO_MACRO_OF => (
       '{tls_version}'  => sub {},
       '{cipher}'       => sub {},
       '{cipher_bits}'  => sub {},
       '{cert_subject}' => sub {},
       '{cert_issuer}'  => sub {},
);

Readonly::Hash my %ENVFROM_MACRO_OF => (
       '{auth_type}'    => sub {},
       '{auth_authen}'  => sub { $_[0]->auth_authen },
       '{auth_author}'  => sub {},
       '{mail_addr}'    => sub { $_[0]->mail_from },
       '{mail_host}'    => sub { _domain_part( $_[0]->mail_from ) },
       '{mail_mailer}'  => sub { 'smtp' },
);

Readonly::Hash my %ENVRCPT_MACRO_OF => (
       '{rcpt_addr}'    => sub { $_[0] },
       '{rcpt_host}'    => sub { _domain_part( $_[0] ) },
       '{rcpt_mailer}'  => sub { 'smtp' },
);

Readonly::Hash my %MESSAGE_MACRO_OF => (
       'i'    => sub { $_[0]->queue_id },
);

=begin

=head1 NAME

Test::Sendmail::PMilter::MacroGenerator - Macro Generator

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

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
    $milter->expect_mail_from_response( SMFIS_CONTINUE );

    $milter->expect_mail_rcpt_to( SMDIS_CONTINUE );
    $milter->expect_mail_rcpt_to( SMFIS_REJECT );
    $milter->expect_mail_rcpt_to( SMFIS_CONTINUE );

    $milter->expect_header( SMFIS_CONTINUE );
    $milter->expect_header( SMFIS_CONTINUE );
    $milter->expect_header( SMFIS_CONTINUE );

    $milter->expect_eom( SMFIS_CONTINUE );

    $milter->expect_abort( SMFIS_CONTINUE );
    $milter->expect_quit( SMFIS_CONTINUE );


=head1 SUBROUTINES/METHODS

=head2 _domain_part( $address )

return domain part of mail address.

=cut

sub _domain_part {
    return (split( '@', $_[0] ))[1];
}

sub _create_macro_value_of {
    my ( $obj, $macro_method_of ) = @_;

    my %macro_of;
    while ( my ( $name, $method ) = each( %{ $macro_method_of } ) ) {
        my $value = &$method( $obj );
        if ( defined( $value ) ) {
            $macro_of{ $name } = $value;
        }
    }
    return \%macro_of;
}


=begin

=head2 connect( $test_pmilter )

return hash reference of connect callback.

=cut

sub connect {
    my $this = shift;
    my ( $pmilter ) = @_;
    return _create_macro_value_of( $pmilter, \%CONNECT_MACRO_OF );
}


=begin

=head2 helo( $test_pmilter )

return hash reference of helo callback.

=cut

sub helo {
    my $this = shift;
    my ( $pmilter ) = @_;
    return _create_macro_value_of( $pmilter, \%HELO_MACRO_OF );
}


=begin

=head2 envfrom( $test_pmilter )

return hash reference of envfrom(Mail From:) callback.

=cut

sub envfrom {
    my $this = shift;
    my ( $pmilter ) = @_;
    return _create_macro_value_of( $pmilter, \%ENVFROM_MACRO_OF );
}


=begin

=head2 envrcpt( $test_pmilter, $rcpt )

return hash reference of envrcpt(RCPT To:) callback.

=cut

sub envrcpt {
    my $this = shift;
    my ( $rcpt ) = @_;
    return _create_macro_value_of( $rcpt, \%ENVRCPT_MACRO_OF );
}

=begin

=head2 header( $test_pmilter )

return hash reference of header callback.

=cut

sub header {
    my $this = shift;
    my ( $pmilter ) = @_;
    return _create_macro_value_of( $pmilter, \%MESSAGE_MACRO_OF );
}


=begin

=head2 eoh( $test_pmilter )

return hash reference of eoh callback.

=cut

sub eoh {
    my $this = shift;
    my ( $pmilter ) = @_;
    return _create_macro_value_of( $pmilter, \%MESSAGE_MACRO_OF );
}


=begin

=head2 eom( $test_pmilter )

return hash reference of eom callback.

=cut

sub eom {
    my $this = shift;
    my ( $pmilter ) = @_;
    return _create_macro_value_of( $pmilter, \%MESSAGE_MACRO_OF );
}


=begin

=head2 abort( $test_pmilter )

return hash reference of abort callback.

=cut

sub abort {
    my $this = shift;
    my ( $pmilter ) = @_;
    return _create_macro_value_of( $pmilter, \%MESSAGE_MACRO_OF );
}


=begin

=head2 close( $test_pmilter )

return hash reference of close callback.

=cut

sub close {
    my $this = shift;
    my ( $pmilter ) = @_;
    return _create_macro_value_of( $pmilter, \%MESSAGE_MACRO_OF );
}


no Moose;
__PACKAGE__->meta->make_immutable;

1;

