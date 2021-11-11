package API::Process;

use Moose;
use namespace::autoclean;

use English qw($EVAL_ERROR -no_match_vars);
use utf8;
use Carp qw(croak);
use DB;

#remove later
use Data::Dumper;

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
has 'db_con' => (
    is      => 'ro',
    isa     => 'DBI::db',
    default => sub { DB->new->get_db_con() },
    lazy    => 1,
);

sub get_todo_list {
    my ( $self, $params ) = @_;

    my $sql = q/ SELECT reference_id, description, status, created_at, updated_at FROM todo_list /;

    my $sth = $self->db_con->prepare($sql);

    $sth->execute;

    return {
        data => $sth->fetchall_hashref('reference_id'),
    };
}

1;