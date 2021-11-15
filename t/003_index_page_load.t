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
use HTTP::Request::Common;
use Ref::Util qw<is_coderef>;
use DB;

#load schema
my $db_object = DB->new();
$db_object->load_schema();

my $app = ToDo->to_app;
ok( is_coderef($app), 'Got app' );

my $test = Plack::Test->create($app);
my $res  = $test->request( GET '/' );
my $get_todo_list_api  = $test->request( GET '/api/v1/todo' );

ok( $res->is_success, '[GET /] successful' );
ok( $get_todo_list_api->is_success, '[GET /api/v1/todo] successful');

done_testing();