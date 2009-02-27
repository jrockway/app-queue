package App::Queue::Message;
use Moose;

has 'data' => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1,
);

has 'next' => (
    is        => 'rw',
    isa       => 'Undef|App::Queue::Message',
    clearer   => 'unlink',
);

1;

