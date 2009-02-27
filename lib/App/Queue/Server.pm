package App::Queue::Server;
use Moose;
use MooseX::AttributeHelpers;

use AnyEvent;
use AnyEvent::Socket;
use AnyEvent::Handle;
use App::Queue::Queue;
use App::Queue::MemoryQueue;

with 'MooseX::Getopt';

has 'port' => (
    is       => 'ro',
    isa      => 'Int',
    required => 1,
    default  => '1212',
);

has 'queue' => (
    traits   => ['NoGetopt'],
    is       => 'ro',
    does     => 'App::Queue::Queue',
    required => 1,
    default  => sub { App::Queue::MemoryQueue->new },
);

has 'client_count' => (
    metaclass => 'Counter',
    is        => 'ro',
    isa       => 'Int',
    provides  => {
        inc => 'add_client',
        dec => 'del_client',
    },
);

sub cmd_put {
    my ($self, $h, $msg) = @_;
    $self->queue->put( App::Queue::Message->new( data => $msg->{data} ));
    $h->push_write( json => { type => 'put' } );
}

sub cmd_take {
    my ($self, $h, $msg) = @_;

    if($msg->{block}){
        $self->queue->take( sub {
            my $data = shift;
            $h->push_write( json => { type => 'take', data => $data->data } );
        });
    }
    else {
        my $data = $self->queue->take;
        if($data){
            $h->push_write( json => { type => 'take', data => $data->data } );
        }
        else {
            $h->push_write( json => { type => 'take' } );
        }
    }
}

sub run {
    my ($self, @args) = @_;

    tcp_server undef, $self->port, sub {
        my ($fh, $host, $port) = @_;

        $self->add_client;
        my $err; $err = sub { $self->del_client; $err = sub {} };
        my $h = AnyEvent::Handle->new(
            fh       => $fh,
            on_eof   => $err,
            on_error => $err,
        );

        my $handler; $handler = sub {
            my ($h, $msg) = @_;
            my $method = 'cmd_'. $msg->{type};
            $self->$method($h, $msg);
            $h->push_read( json => $handler );
        };
        $h->push_read( json => $handler );
    };
}

1;
