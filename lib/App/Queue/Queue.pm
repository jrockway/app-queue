package App::Queue::Queue;
use Moose;

use App::Queue::Message;

has front => (
    is  => 'rw',
    isa => 'Undef|App::Queue::Message',
);

has rear => (
    is      => 'rw',
    isa     => 'Undef|App::Queue::Message',
    clearer => 'clear_rear',
);

sub put {
    my ($self, $msg) = @_;
    my $rear = $self->rear;
    $msg->next($rear);
    $self->rear($msg);
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

sub take {
    my ($self) = @_;
    my $msg = $self->_take1;
    return $msg if $msg;

    $self->front(_lreverse($self->rear));
    $self->clear_rear;
    return $self->_take1; # finally returns undef if rear was empty
}

1;
