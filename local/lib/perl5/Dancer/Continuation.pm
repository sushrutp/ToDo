package Dancer::Continuation;
our $AUTHORITY = 'cpan:SUKRIA';
# ABSTRACT: Continuation exception (internal exception) for Dancer
$Dancer::Continuation::VERSION = '1.3513';
use strict;
use warnings;
use Carp;

sub new {
    my $class = shift;
    bless { @_ }, $class;
}

sub throw { die shift }

sub rethrow { die shift }

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dancer::Continuation - Continuation exception (internal exception) for Dancer

=head1 VERSION

version 1.3513

=head1 AUTHOR

Dancer Core Developers

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Alexis Sukrieh.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
