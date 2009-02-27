package App::Queue::MemoryQueue;
use Moose;
use MooseX::AttributeHelpers;

use App::Queue::Message;

with 'App::Queue::Queue';

has front => (
    is  => 'rw',
    isa => 'Undef|App::Queue::Message',
);

has rear => (
    is      => 'rw',
    isa     => 'Undef|App::Queue::Message',
    clearer => 'clear_rear',
);

has waiters => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'ArrayRef', # todo, real queue
    default   => sub { [] },
    required  => 1,
    provides  => {
        push  => 'add_waiter',
        shift => 'get_waiter',
    },
);

sub put {
    my ($self, $msg) = @_;
    my $rear = $self->rear;
    my $waiter = $self->get_waiter;
    if($waiter){
        $waiter->($msg);
        return;
    }
    $msg->next($rear);
    $self->rear($msg);
    return;
}

sub _take1 {
    my ($self) = @_;
    my $msg = $self->front;
    if($msg){
        my $next = $msg->next;
        $self->front($next);
        $msg->unlink;
        return $msg;
    }
    return;
}

sub _lreverse {
    my ($node) = @_;
    my $next;
    while($node){
        my $tmp = $node->next;
        $node->next($next);
        $next = $node;
        $node = $tmp;
    }

    return $next;
}

# if passed a callback, we call it when a value is ready (return
# value of this function is undefined)
# otherwise returns value if available, otherwise returns undef (when
# no values are available)
sub take {
    my ($self, $cb) = @_;

    # if other things are waiting for input, immediately delay this
    # call
    if (scalar @{$self->waiters}){
        $self->add_waiter($cb);
        return;
    }

    my $msg = $self->_take1;
    $cb->($msg) if $cb && $msg;
    return $msg if $msg;

    $self->front(_lreverse($self->rear));
    $self->clear_rear;

    my $retry = $self->_take1;
    $cb->($retry) if $cb && $retry;
    return $retry if $retry;

    $self->add_waiter($cb) if($cb);
    return;
}

1;
