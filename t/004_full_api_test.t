use strict;
use warnings;

BEGIN{
    use FindBin qw($Bin); 
    use lib "$Bin/../lib";
    $ENV{TODO_DB_FILE_ENV} = $ENV{DANCER_ENVIRONMENT}  = 'test'
};

use ToDo;
use Test::More;
use Plack::Test;
use HTTP::Request::Common qw(GET POST PUT DELETE);
use Ref::Util qw<is_coderef>;
use DB;
use JSON;
use Data::Dumper;

#load schema
my $db_object = DB->new();
my $db_con    = $db_object->get_db_con();

$db_object->load_schema();
clean_data_and_test();

my $app = ToDo->to_app;
ok(is_coderef($app), 'Got app');

my $test = Plack::Test->create($app);

#---------------------------------------#
#---------------------------------------#
#get api
{
    my $res               = $test->request(GET '/');
    my $get_todo_list_api = $test->request(GET '/api/v1/todo');
    ok($res->is_success,               '[GET /api/v1/todo] successful');
    ok($get_todo_list_api->is_success, '[GET /api/v1/todo] successful');
}

#---------------------------------------#
#---------------------------------------#
# post api
{
    my $res_post_todo =
      $test->request(POST '/api/v1/todo', content => encode_json({'description' => "test_todo_from_unit_test"}));
    ok($res_post_todo->is_success,             '[POST /api/v1/todo] successful');
    ok($res_post_todo->content =~ /ref-(\w+)/, 'test_todo_from_unit_test is in the list ' . $res_post_todo->content);

    my $response_hash = decode_json($res_post_todo->content);

    my $sql =
qq/ SELECT id, reference_id , description, status FROM todo_list  where reference_id = '$response_hash->{reference_id}' /;

    my $result_from_db = $db_con->selectall_arrayref($sql, {'Slice' => {}});
    ok(scalar(@$result_from_db), '[POST /api/v1/todo] successful and result found in db');

    $result_from_db = $result_from_db->[0];

    is(
        $response_hash->{reference_id},
        $result_from_db->{reference_id},
        "Reference id in db matched to the received from api $result_from_db->{reference_id}"
    );

    is(
        "test_todo_from_unit_test",
        $result_from_db->{description},
        "description in db matched to the sent from api test_todo_from_unit_test"
    );

    is(0, $result_from_db->{status},
        "status in db matched to the sent from api test_todo_from_unit_test $result_from_db->{status} (not completed)");

    clean_data_and_test();
}

#---------------------------------------#
#---------------------------------------#
# put api
{
    my $res_put_todo =
      $test->request(POST '/api/v1/todo', content => encode_json({'description' => "test_todo_from_unit_test"}));
    ok($res_put_todo->is_success,             '[POST /api/v1/todo] successful');
    ok($res_put_todo->content =~ /ref-(\w+)/, 'test_todo_from_unit_test is in the list ' . $res_put_todo->content);

    my $response_hash = decode_json($res_put_todo->content);

    my $sql =
qq/ SELECT id, reference_id , description, status FROM todo_list  where reference_id = '$response_hash->{reference_id}' /;

    my $result_from_db = $db_con->selectall_arrayref($sql, {'Slice' => {}});
    ok(scalar(@$result_from_db), '[POST /api/v1/todo] successful and result found in db');

    $result_from_db = $result_from_db->[0];

    is(
        $response_hash->{reference_id},
        $result_from_db->{reference_id},
        "Reference id in db matched to the received from api $result_from_db->{reference_id}"
    );

    is(
        "test_todo_from_unit_test",
        $result_from_db->{description},
        "description in db matched to the sent from api test_todo_from_unit_test"
    );

    is(0, $result_from_db->{status},
        "status in db matched to the sent from api test_todo_from_unit_test $result_from_db->{status} (not completed)");

    my $res_put_todo_update = $test->request(PUT '/api/v1/todo/' . $result_from_db->{reference_id});
    ok($res_put_todo_update->is_success, '[PUT /api/v1/todo] successful');

    my $update_res_hash = decode_json $res_put_todo_update->content;
    ok($update_res_hash->{result} == 1,
        "$result_from_db->{reference_id} id updated as completed result from api " . $res_put_todo_update->content);

    $sql =
qq/ SELECT id, reference_id , description, status FROM todo_list  where reference_id = '$result_from_db->{reference_id}' /;

    my $result_from_db_after_api = $db_con->selectall_arrayref($sql, {'Slice' => {}});
    ok(scalar(@$result_from_db_after_api), '[PUT /api/v1/todo] successful and result found in db');

    $result_from_db_after_api = $result_from_db_after_api->[0];

    is(
        $response_hash->{reference_id},
        $result_from_db_after_api->{reference_id},
        "Reference id in db matched to the received from api $result_from_db_after_api->{reference_id}"
    );

    is(
        "test_todo_from_unit_test",
        $result_from_db_after_api->{description},
        "description in db matched to the sent from api test_todo_from_unit_test"
    );

    is(
        1,
        $result_from_db_after_api->{status},
        "status in db matched to the sent from api test_todo_from_unit_test $result_from_db->{status} (completed)"
    );

    clean_data_and_test();

}

#---------------------------------------#
#---------------------------------------#
# delete api
{
    my $res_put_todo =
      $test->request(POST '/api/v1/todo', content => encode_json({'description' => "test_todo_from_unit_test"}));
    ok($res_put_todo->is_success,             '[POST /api/v1/todo] successful');
    ok($res_put_todo->content =~ /ref-(\w+)/, 'test_todo_from_unit_test is in the list ' . $res_put_todo->content);

    my $response_hash = decode_json($res_put_todo->content);

    my $sql =
qq/ SELECT id, reference_id , description, status FROM todo_list  where reference_id = '$response_hash->{reference_id}' /;

    my $result_from_db = $db_con->selectall_arrayref($sql, {'Slice' => {}});
    ok(scalar(@$result_from_db), '[POST /api/v1/todo] successful and result found in db');

    $result_from_db = $result_from_db->[0];

    is(
        $response_hash->{reference_id},
        $result_from_db->{reference_id},
        "Reference id in db matched to the received from api $result_from_db->{reference_id}"
    );

    is(
        "test_todo_from_unit_test",
        $result_from_db->{description},
        "description in db matched to the sent from api test_todo_from_unit_test"
    );

    is(0, $result_from_db->{status},
        "status in db matched to the sent from api test_todo_from_unit_test $result_from_db->{status} (not completed)");

    my $res_put_todo_update = $test->request(PUT '/api/v1/todo/' . $result_from_db->{reference_id});
    ok($res_put_todo_update->is_success, '[PUT /api/v1/todo] successful');

    my $update_res_hash = decode_json $res_put_todo_update->content;
    ok($update_res_hash->{result} == 1,
        "$result_from_db->{reference_id} id updated as completed result from api " . $res_put_todo_update->content);

    $sql =
qq/ SELECT id, reference_id , description, status FROM todo_list  where reference_id = '$result_from_db->{reference_id}' /;

    my $result_from_db_after_api = $db_con->selectall_arrayref($sql, {'Slice' => {}});
    $result_from_db_after_api = $result_from_db_after_api->[0];

    is(
        $response_hash->{reference_id},
        $result_from_db_after_api->{reference_id},
        "Reference id in db matched to the received from api $result_from_db_after_api->{reference_id}"
    );

    is(
        "test_todo_from_unit_test",
        $result_from_db_after_api->{description},
        "description in db matched to the sent from api test_todo_from_unit_test"
    );

    is(
        1,
        $result_from_db_after_api->{status},
        "status in db matched to the sent from api test_todo_from_unit_test $result_from_db->{status} (completed)"
    );

    my $res_del_todo_update = $test->request(DELETE '/api/v1/todo/' . $result_from_db->{reference_id});
    ok($res_del_todo_update->is_success, '[DELETE /api/v1/todo] successful');

    my $update_del_hash = decode_json $res_del_todo_update->content;
    ok($update_del_hash->{result} == 1,
        "$result_from_db->{reference_id} id deleted  result from api " . $res_del_todo_update->content);

    $sql =
qq/ SELECT id, reference_id , description, status FROM todo_list  where reference_id = '$result_from_db->{reference_id}' /;

    my $result_from_db_after_api_del = $db_con->selectall_arrayref($sql, {'Slice' => {}});
    ok(!scalar(@$result_from_db_after_api_del), '[DELETE /api/v1/todo] successful and result not found in db');

    $sql = qq/ SELECT count(id) as count FROM todo_list /;
    $result_from_db = $db_con->selectall_arrayref($sql, {'Slice' => {}});
    is(0, $result_from_db->[0]->{count}, 'Cleaned data via api confirmed');

    clean_data_and_test();
}

#---------------------------------------#
#---------------------------------------#
# get api
{

    my $created_data = {
        'sent_from_api' => [],
        'from_db'       => []
    };
    my $generated_ref_ids_hash;
    my $total_records = 0;
    for my $i (1 .. 10) {
        my $res_put_todo =
          $test->request(POST '/api/v1/todo', content => encode_json({'description' => "test_todo_from_unit_test_$i"}));
        ok($res_put_todo->is_success,             '[POST /api/v1/todo] successful');
        ok($res_put_todo->content =~ /ref-(\w+)/, 'test_todo_from_unit_test is in the list ' . $res_put_todo->content);
        my $response_hash = decode_json($res_put_todo->content);

        push(@{$created_data->{sent_from_api}}, $response_hash);

        $generated_ref_ids_hash->{$response_hash->{reference_id}} = 1;

        my $sql =qq/ SELECT id, reference_id , description, status FROM todo_list
                    where reference_id = '$response_hash->{reference_id}' /;
        my $result_from_db = $db_con->selectall_arrayref($sql, {'Slice' => {}});

        push(@{$created_data->{from_db}}, $result_from_db->[0]);
        ok(scalar(@$result_from_db), '[POST /api/v1/todo] successful and result found in db');
        $total_records++;
    }

    is(
        scalar @{$created_data->{sent_from_api}},
        scalar @{$created_data->{from_db}},
        'Number of created data matched for db and api'
    );
    is(scalar @{$created_data->{from_db}},       10, 'Number of created data matched for db');
    is(scalar @{$created_data->{sent_from_api}}, 10, 'Number of created data matched api');

    my $count_update_to_completed = 0;
    foreach my $data (@{$created_data->{sent_from_api}}) {

        #only update first 5 to completed
        last if ($count_update_to_completed == 5);
        my $res_put_todo_update = $test->request(PUT '/api/v1/todo/' . $data->{reference_id});
        ok($res_put_todo_update->is_success, '[PUT /api/v1/todo] successful');
        $generated_ref_ids_hash->{$data->{reference_id}} = 0;
        $count_update_to_completed++;
    }
    is($count_update_to_completed, 5, 'Number of updated data matched');

    my $sql = qq/ SELECT count(id) as count FROM todo_list  where status = 1 /;

    my $count_completed = $db_con->selectall_arrayref($sql, {'Slice' => {}});
    $count_completed = $count_completed->[0];

    is($count_completed->{count},
        $count_update_to_completed,
        "Correct number of data updated in db $count_update_to_completed when sent from api");

    my $count_delete = 0;
    foreach my $data (@{$created_data->{sent_from_api}}) {

        #only delete first 3 to completed
        last if ($count_delete == 3);
        my $res_put_todo_update = $test->request(DELETE '/api/v1/todo/' . $data->{reference_id});
        ok($res_put_todo_update->is_success, '[DELETE /api/v1/todo] successful');
        delete $generated_ref_ids_hash->{$data->{reference_id}};
        $count_delete++;
    }

    is($count_delete, 3, 'Number of delete data matched');

    $sql = qq/ SELECT count(id) as count FROM todo_list/;
    my $new_count = $db_con->selectall_arrayref($sql, {'Slice' => {}});
    $new_count = $new_count->[0];

    is($new_count->{count}, 7, "Correct number of data deleted in db $new_count->{count} when sent from api");

    my $res               = $test->request(GET '/');
    my $get_todo_list_api = $test->request(GET '/api/v1/todo');
    ok($res->is_success,               '[GET /api/v1/todo] successful');
    ok($get_todo_list_api->is_success, '[GET /api/v1/todo] successful');

    my $response_hash_get = decode_json($get_todo_list_api->content);

    is(scalar(@$response_hash_get), 7, "Correct number of data from get api");

    my $count_completed_from_api     = 0;
    my $count_non_completed_from_api = 0;
    my @reference_ids_completed_from_api;
    my @reference_ids_not_completed_from_api;

    foreach my $data (@$response_hash_get) {
        next unless defined $data;
        if ($data->{status} eq 'completed') {
            $count_completed_from_api++;
            push(@reference_ids_completed_from_api, $data->{id});
        }
        else {
            $count_non_completed_from_api++;
            push(@reference_ids_not_completed_from_api, $data->{id});
        }
    }

    is($count_completed_from_api, 2, "Correct number of completed data from api $count_completed_from_api");

    is($count_non_completed_from_api, 5, "Correct number of non completed data from api $count_non_completed_from_api");

    my (@reference_id_completed, @non_completed_reference_id);

    foreach (keys %$generated_ref_ids_hash) {
        if ($generated_ref_ids_hash->{$_} == 1) {
            push(@non_completed_reference_id, $_);
        }
        else {
            push(@reference_id_completed, $_);
        }
    }

    is_deeply(
        [sort @reference_id_completed],
        [sort @reference_ids_completed_from_api],
        "Correct completed data from api Deep Data structure compared"
    );
    is_deeply(
        [sort @non_completed_reference_id],
        [sort @reference_ids_not_completed_from_api],
        "Correct non completed data from api Deep Data structure compared"
    );

    clean_data_and_test();
}

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
