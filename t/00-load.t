#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Test::Sendmail::PMilter' ) || print "Bail out!\n";
}

diag( "Testing Test::Sendmail::PMilter $Test::Sendmail::PMilter::VERSION, Perl $], $^X" );
