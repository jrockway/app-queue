#!/usr/bin/env perl

use strict;
use warnings;
use feature ':5.10';

use FindBin qw($Bin);
use lib "$Bin/../lib";

use EV;
use App::Queue::Client;
my $c = App::Queue::Client->new_with_options;

while( my $line = <> ){
    chomp $line;
    my $put_ok = $c->put( { line => $line } );
    $put_ok->recv;
    say 'ok';
}
