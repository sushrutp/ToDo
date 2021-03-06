use strict;
use warnings;

BEGIN{
    use FindBin qw($Bin); 
    use lib "$Bin/../lib";
    $ENV{TODO_DB_FILE_ENV} = $ENV{DANCER_ENVIRONMENT}  = 'test'
};

use ToDo;
use Test::More tests => 2;
use Plack::Test;
use HTTP::Request::Common;
use Ref::Util qw<is_coderef>;

my $app = ToDo->to_app;
ok( is_coderef($app), 'Got app' );

my $test = Plack::Test->create($app);
my $res  = $test->request( GET '/' );

ok( $res->is_success, '[GET /] successful' );
