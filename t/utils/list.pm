package t::utils::list;
use strict;
use App::Queue::Message;

use base 'Exporter';

our @EXPORT = qw/msg fromlist tolist/;

sub msg {
    my ($id, $next) = @_;
    App::Queue::Message->new( data => { id => $id }, next => $next );
}

sub fromlist {
    my @list = @_;
    return unless @list;
    return msg( (shift @list), fromlist(@list) );
}

sub tolist {
    my $msg = shift;
    my @acc;
    while($msg){
        push @acc, $msg->data->{id};
        $msg = $msg->next;
    }
    return @acc;
}


1;
