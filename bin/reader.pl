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

while(1){
    my $wait = $c->take(1);
    my $data = $wait->recv;
    say Dump($data);
}
