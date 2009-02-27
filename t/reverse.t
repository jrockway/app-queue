use strict;
use warnings;
use Test::More tests => 8;

use App::Queue::Message;
use App::Queue::Queue;
use t::utils::list;

BEGIN { *rev = *App::Queue::Queue::_lreverse }

for my $list ([], [1], [1,2], [1,2,3]){
    my $msg = fromlist(@$list);
    is_deeply [tolist $msg], $list, 'list ok';
    is_deeply [tolist(rev($msg))], [reverse @$list], 'list reverses ok';
}
