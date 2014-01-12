use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Test::Sendamil::PMilter',
    AUTHOR              => q{Toshifumi Sakaguchi <sischkg@gmail.com>},
    VERSION_FROM        => 'lib/Test/Sendmail/PMilter.pm',
    ABSTRACT_FROM       => 'lib/Test/Sendmail/PMilter.pm',
    PREREQ_PM => {
        'Test::More'         => 0,
        'Readonly'           => 0,
        'Moose'              => 0,
        'Sendmail::PMilter'  => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Test::Sendmail::PMilter-*' },
);
