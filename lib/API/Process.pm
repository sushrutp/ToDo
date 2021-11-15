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
=pod
    db connections object
=cut
has 'db_con' => (
    is      => 'ro',
    isa     => 'DBI::db',
    default => sub { DB->new->get_db_con() },
    lazy    => 1,
);
#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
=pod
    utils_obj has object of utils class
=cut
has 'utils_obj' => (
    is      => 'ro',
    isa     => 'Utils',
    default => sub { Utils->new },
    lazy    => 1,
);

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
=pod

=header get_todo_list

    get_todo_list()

    Returns a list of all todo items.

    Returns:
        ArrayRef of Hashes  -  List of all todo items.

    Exceptions:
        None.

    Example:    $todo_list = $obj->get_todo_list();

=cut
sub get_todo_list {
    my ( $self ) = @_;

    $self->utils_obj->print_log("getting todo list",'info');

    my $sql = q/ SELECT reference_id as id, description, case when status == 1 then 'completed' else '' end as status FROM todo_list /;

    my $result = $self->db_con->selectall_arrayref($sql, { 'Slice' => {} });

    if (defined $result && scalar @$result) {
        $self->utils_obj->print_log("Fetched data for rows => ". scalar @$result,'info');
    } else {
        $self->utils_obj->print_log("No data found",'info');
    }

    return $result;
}
#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
=pod

=header B<create_todo_list>

    Method: create_todo_list
    Description:
        This method is used to add a new todo list item.
    Params:
            description - Description of the todo list item.
    Returns:
        $result - Hash reference containing the following keys:
            id - Id of the newly added todo list item.
            reference_id - reference Id of the newly added todo list item.

    example:
        $result = $obj->create_todo_list('new todo list item');
=cut

sub create_todo_list {
    my ( $self, $description ) = @_;

    return {id => undef, reference_id => undef} unless defined $description;

    my $length = 7;

    my $reference_id = lc('REF-'. $self->utils_obj->generate_unique_name($length));

    $self->utils_obj->print_log("creating the todo note text: '$description' and reference_id generated: '$reference_id'",'info');


    my $sql = q/ INSERT INTO todo_list (description, reference_id) VALUES (?,?)  /;

    my $sth = $self->db_con->prepare($sql);

    $sth->execute( $description, $reference_id );

    my $id = $self->db_con->last_insert_id();

    if (defined $id) {
        $self->utils_obj->print_log("data created successful table id => ". $id,'info');
    } else {
        $self->utils_obj->print_log("unable to create todo item for reference id ". $reference_id,'error');
    }

    return {id => $self->db_con->last_insert_id(), reference_id => $reference_id};
}
#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
=pod

=header B<update_todo_item>

    update_todo_item( $self, $reference_id )

    returns:
        {
            result => $res # 1 or 0
        }

    params: 
        $reference_id (string)

    example:   $obj->update_todo_item('REF-123456789');

=cut

sub update_todo_item {
    my ($self, $reference_id) = @_;

    return [undef] unless defined $reference_id;

    $self->utils_obj->print_log("updating status of reference_id '$reference_id' to competed ",'info');

    return {result => 0} unless defined $reference_id;

    my $sql = q/ UPDATE todo_list SET status = 1 WHERE reference_id = lower(?) /;

    my $res= $self->db_con->do($sql, {}, $reference_id);

    if (defined $res) {
        $self->utils_obj->print_log("data updated successful reference_id => ". $reference_id,'info');
    } else {
        $self->utils_obj->print_log("unable to update todo item for reference id ". $reference_id,'error');
    }

    return {result => $res};

}
#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
=pod

=header <delete_todo_item>

    delete_todo_item($reference_id)

    delete todo item by reference id

    returns:
        {
            result => $res # 1 or 0
        }

    params: 
        $reference_id (string)

    example:   $obj->delete_todo_item('REF-123456789');

=cut

sub delete_todo_item {
    my ($self, $reference_id) = @_;

    return {result => 0} unless defined $reference_id;

    $self->utils_obj->print_log("deleting todo item for reference_id '$reference_id' ",'info');

    return unless defined $reference_id;

    my $sql = q/ DELETE FROM todo_list WHERE reference_id = lower(?) /;

    my $res =  $self->db_con->do($sql, {}, $reference_id);

    if (defined $res) {
        $self->utils_obj->print_log("data deleted successful reference_id => ". $reference_id,'info');
    } else {
        $self->utils_obj->print_log("unable to delete todo item for reference id ". $reference_id,'error');
    }

    return {result => $res};

}

1;