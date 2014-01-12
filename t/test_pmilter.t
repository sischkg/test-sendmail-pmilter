# -*- coding: utf-8; mode: cperl-mode -*-

use strict;
use Test::More;
use Sendmail::PMilter qw(:all);
use Test::Sendmail::PMilter;


my %cbs;
for my $cb (qw(close connect helo abort envfrom envrcpt header eoh eom)) {
    $cbs{$cb} = sub {
        my $ctx = shift;
        SMFIS_CONTINUE;
    };
}

$cbs{envfrom} = sub {
    my $ctx = shift;
    my ( $mail_from ) = @_;
    if ( $mail_from eq 'spammer@example.com' ) {
        return SMFIS_REJECT;
    }
    return SMFIS_CONTINUE;
};

$cbs{envrcpt} = sub {
    my $ctx = shift;
    my ( $rcpt ) = @_;
    if ( $rcpt eq 'test1@example.com' ) {
        return SMFIS_REJECT;
    }
    return SMFIS_CONTINUE;
};

{
    my $milter = new Test::Sendmail::PMilter(
					     rcpt_to => [
							 'test0@example.com',
							 'test1@example.com',
							 'test2@example.com',
							],
					     headers => [
							 'From: sender@example.com',
							 'To: rcpt@example.com',
							 'Subeject: test',
							],
					     body    => "test\n",
					    );
    $milter->register( 'test', \%cbs );

    $milter->expect_connect_response( SMFIS_CONTINUE );
    $milter->expect_helo_response( SMFIS_CONTINUE );
    $milter->expect_envfrom_response( SMFIS_CONTINUE );
    $milter->expect_envrcpt_response( SMFIS_CONTINUE, 0 );
    $milter->expect_envrcpt_response( SMFIS_REJECT, 1 );
    $milter->expect_envrcpt_response( SMFIS_CONTINUE, 2 );
    $milter->expect_header_response( SMFIS_CONTINUE, 0 );
    $milter->expect_header_response( SMFIS_CONTINUE, 1 );
    $milter->expect_header_response( SMFIS_CONTINUE, 2 );
    $milter->expect_eoh_response( SMFIS_CONTINUE );
    $milter->expect_eom_response( SMFIS_CONTINUE );
}

{
    my $milter = new Test::Sendmail::PMilter(
					     rcpt_to => [
							 'test1@example.com',
							],
					     headers => [
							 'From: sender@example.com',
							 'To: rcpt@example.com',
							 'Subeject: test',
							],
					     body    => "test\n",
					    );
    $milter->register( 'test', \%cbs );
    $milter->expect_result( Test::Sendmail::PMilter::ACCEPT );
}


{
    my $milter = new Test::Sendmail::PMilter(
					     mail_from => 'spammer@example.com',
					     rcpt_to => [
							 'test1@example.com',
							],
					     headers => [
							 'From: sender@example.com',
							 'To: rcpt@example.com',
							 'Subeject: test',
							],
					     body    => "test\n",
					    );
    $milter->register( 'test', \%cbs );
    $milter->expect_result( Test::Sendmail::PMilter::REJECT );
}


done_testing();

