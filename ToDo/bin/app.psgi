#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use ToDo;

ToDo->to_app;

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use ToDo;
use Plack::Builder;

builder {
    enable 'Deflater';
    ToDo->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to mount several applications on different path

use ToDo;
use ToDo_admin;

use Plack::Builder;

builder {
    mount '/'      => ToDo->to_app;
    mount '/admin'      => ToDo_admin->to_app;
}

=end comment

=cut

