package App::Queue::Client;
use Moose;
use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;

with 'MooseX::Getopt';

has 'host' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'localhost',
);

has 'port' => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
    default  => '1212',
);

has 'connection' => (
    traits     => ['NoGetopt'],
    is         => 'ro',
    isa        => 'AnyEvent::Handle',
    lazy_build => 1,
);

sub _build_connection {
    my ($self) = @_;

    my $connected = AnyEvent->condvar;
    tcp_connect $self->host, $self->port, sub {
        my ($fh) = @_;
        $connected->send( AnyEvent::Handle->new( fh => $fh ) );
    };

    $connected->recv;
}

sub put {
    my ($self, $msg) = @_;
    my $fh = $self->connection;

    my $put_status = AnyEvent->condvar;
    $fh->push_read( json => sub {
        my ($h, $msg) = @_;
        $put_status->send(1);
    });

    $fh->push_write( json => { type => 'put', data => $msg } );
    return $put_status;
}

sub take {
    my ($self) = @_;
    my $fh = $self->connection;

    my $take = AnyEvent->condvar;
    $fh->push_read( json => sub {
        my ($h, $msg) = @_;
        my $data = $msg->{data};
        $take->send($data);
    });

    $fh->push_write( json => { type => 'take' } );

    return $take;
}

1;
