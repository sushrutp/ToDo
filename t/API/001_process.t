BEGIN{
    use FindBin qw($Bin); 
    use lib "$Bin/../lib";
    $ENV{TODO_DB_FILE_ENV} = $ENV{DANCER_ENVIRONMENT}  = 'test'
};

require_ok( 'API::Process' );

use Test::More;
#load schema
my $db_object = DB->new();
my $db_con    = $db_object->get_db_con();

$db_object->load_schema();
clean_data_and_test();

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#

foreach my $i (1..20) {
    my $result = API::Process->new->create_todo_list( 'test_note_from_unit_test' . '_' . $_ );
    like  ($result->{id}, qr/\d+/, "id geenrated $result->{id}");
    like  ($result->{reference_id}, qr/ref-\w+/, "Reference id generated $result->{reference_id}");

    my $update_res = API::Process->new->update_todo_item($result->{reference_id});
    is($update_res->{result}, 1, "Update status is success");

    my $get_list = API::Process->new->get_todo_list;
    is(scalar @{$get_list}, 1, "$i item in list with count 1");

    my $delete = API::Process->new->delete_todo_item($result->{reference_id});
    my $get_list_after_delete = API::Process->new->get_todo_list;
    is(scalar @{$get_list_after_delete}, 0, "item deleted from list count 0");
}

clean_data_and_test();
done_testing();
###########################
# helper methods
###########################

sub clean_data_and_test {
    my $sql = qq/ DELETE FROM todo_list /;
    $db_con->do($sql);
    $sql = qq/ SELECT count(id) as count FROM todo_list /;
    my $result_from_db = $db_con->selectall_arrayref($sql, {'Slice' => {}});
    is(0, $result_from_db->[0]->{count}, 'Cleaned data');
}