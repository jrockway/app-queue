#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';

use FindBin qw($Bin);
use lib "$Bin/../lib";

use EV;
use AnyEvent;
use App::Queue::Server;

my $s = App::Queue::Server->new_with_options;
$s->run;

my $t = AnyEvent->timer( after => 0, interval => 5, cb => sub {
    my $clients = $s->client_count;
    say "$clients client(s) connected";
});

EV::loop;
