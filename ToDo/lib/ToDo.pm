package ToDo;
use Dancer2;

our $VERSION = '0.1';


#prefix for the api
# prefix '/api/v1';
use API::Process;

my $api_obj  = API::Process->new();

get '/' => sub {
    template 'index' => { 'title' => 'ToDo' };
};

#to get data
get '/api/v1/todo' => sub {
    header('Content-Type' => 'application/json');
    return to_json $api_obj->get_todo_list(params->{limit} // 10);
};

# to post data
post '/api/v1/todo' => sub {
    if ( not session('logged_in') ) {
        send_error("Not logged in", 401);
    }
 
    my $sql = 'insert into entries (title, text) values (?, ?)';
    my $sth = database->prepare($sql);
    $sth->execute(
        body_parameters->get('title'),
        body_parameters->get('text')
    );
 
    set_flash('New entry posted!');
    redirect '/';
};


true;
