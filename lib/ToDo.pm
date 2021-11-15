package ToDo;
use Dancer2;

our $VERSION = '0.1';

use Data::Dumper;
use API::Process;

my $api_obj  = API::Process->new();

get '/' => sub {
    template 'index' => { 'title' => 'ToDo' };
};

#prefix for the api
prefix '/api/v1';

    #to get data
    get '/todo' => sub {
        debug( 'GET /todo called' );
        header('Content-Type' => 'application/json');
        return to_json $api_obj->get_todo_list(params->{limit} // 10);
    };

    # to post data
    post '/todo' => sub {
        debug( 'POST /todo called' );
        my $data = from_json(request->body);
        header('Content-Type' => 'application/json');
        my $result = $api_obj->create_todo_list($data->{description});
        delete $result->{id};
        return to_json $result;
    };

    # to post data
    put '/todo/:refrence_id' => sub {
        debug( 'PUT /todo called ref id ', params->{refrence_id} );
        header('Content-Type' => 'application/json');
        return to_json $api_obj->update_todo_item(params->{refrence_id});
    };

    # to post data
    del '/todo/:refrence_id' => sub {
        debug( 'DELETE /todo called ref id ', params->{refrence_id} );
        header('Content-Type' => 'application/json');
        return to_json $api_obj->delete_todo_item(params->{refrence_id});
    };

true;
