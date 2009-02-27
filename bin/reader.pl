#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';

use FindBin qw($Bin);
use lib "$Bin/../lib";

use DDS;
use EV;
use App::Queue::Client;

my $c = App::Queue::Client->new_with_options;
start_take();
EV::loop;

sub start_take {
    my $wait = $c->take;
    $wait->cb( sub {
        my ($cv) = @_;
        my $data = $cv->recv;
        if($data){
            say Dump($data);
            start_take();
        }
        else {
            my $t;
            $t = AnyEvent->timer( after => 1, cb => sub {
                start_take();
                undef $t;
            });
        }
    });
}
