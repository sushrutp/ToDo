use strict;
use warnings;

BEGIN{
    use FindBin qw($Bin); 
    use lib "$Bin/../lib";
    $ENV{TODO_DB_FILE_ENV} = $ENV{DANCER_ENVIRONMENT}  = 'test'
};

use Test::More tests => 1;
use_ok 'ToDo';
