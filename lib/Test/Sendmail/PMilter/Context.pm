
package Test::Sendmail::PMilter::Context::Reply;

use Moose;

has 'rcode'   => ( isa => 'Str',        is => 'ro', required => 1 );
has 'xcode'   => ( isa => 'Maybe[Str]', is => 'ro', default => undef );
has 'message' => ( isa => 'Maybe[Str]', is => 'ro', default => undef );

no Moose;
__PACKAGE__->meta->make_immutable;


package Test::Sendmail::PMilter::Context;

use Moose;
use Moose::Util::TypeConstraints;

class_type 'Test::Sendmail::PMilter::Context::Reply';

has 'macro'             => ( isa => 'HashRef', is => 'rw', default => sub { {} } );
has 'private_data'      => ( isa => 'Any',     is => 'rw', default => undef );
has 'reply'             => ( isa => 'Maybe[Test::Sendmail::PMilter::Context::Reply]',
			     is => 'rw',
			     default => undef );
has 'is_shutdown'       => ( isa => 'Bool', is => 'rw', default => 0 );
has 'added_header_of'   => ( isa => 'HashRef', is => 'rw', default => sub { {} } );
has 'deleted_header_of' => ( isa => 'HashRef', is => 'rw', default => sub { {} } );

sub getsymval {
    my $this = shift;
    return $this->macro()->{ $_[0] };
}

sub setpriv {
    my ( $this ) = @_;
    $this->private_data( $_[0] );
}

sub getpriv {
    my $this = shift;
    return $this->private_data();
}

sub setreply {
    my $this = shift;
    my ( $rcode, $xcode, $message ) = @_;

    my $reply = new Test::Sendmail::PMilter::Context::Reply( rocode  => $rcode,
							     xcode   => $xcode,
							     message => $message );
    $this->reply( $reply );
}

sub shutdown {
  my $this = shift;
  $this->is_shutdown( 1 );
}


sub addheader {
  my $this = shift;
  my ( $header, $value ) = @_;

  push( $this->added_header_of->{ $header }, $value );
}

sub chgheader {
  my $this = shift;
  my ( $header, $index, $value ) = @_;

}


=begin
$ctx->delrcpt(ADDRESS)

$ctx->progress()

$ctx->quarantine(REASON)


$ctx->replacebody(BUFFER)

$ctx->setsender(ADDRESS)

=cut

no Moose;
__PACKAGE__->meta->make_immutable;


1;

