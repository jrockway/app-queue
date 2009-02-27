use strict;
use warnings;
use Test::More tests => 9;

use App::Queue::MemoryQueue;
use t::utils::list;

my $q = App::Queue::MemoryQueue->new;

$q->put(msg($_)) for (1..10);

is_deeply [tolist($q->rear)], [reverse 1..10], 'rear has data';
is_deeply [tolist($q->front)], [], 'nothing in the front';

is $q->take->data->{id}, 1, 'got first element';
is_deeply [tolist($q->front)], [2..10], 'front now has the data';
is_deeply [tolist($q->rear)], [], 'rear is empty';

is $q->take->data->{id}, 2, 'still works';

$q->put(msg($_)) for (11..20);

is_deeply [tolist($q->front)], [3..10], 'front now has the data';
is_deeply [tolist($q->rear)], [reverse 11..20], 'rear has new data';

my @rest;
while(my $next = $q->take){
    push @rest, $next->data->{id};
}

is_deeply \@rest, [3..20], 'got the rest';
