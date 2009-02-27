package App::Queue::Queue;
use Moose::Role;

requires 'put';
requires 'take';

1;
