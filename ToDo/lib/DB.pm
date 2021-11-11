package DB;

use Moose;
use namespace::autoclean;

use English qw($EVAL_ERROR -no_match_vars);
use Carp qw(croak);
use DBI;
use Utils;
#----------------------------------------------------------------------------------#
# custom module for all Utils                                                      #
#----------------------------------------------------------------------------------#
use vars qw( $CACHED_DBI );

use Memoize;
memoize( 'get_db_con', SCALAR_CACHE => 'MEMORY', LIST_CACHE => 'MEMORY' );

=pod
#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
=cut

has 'db_path' => (
    is            => 'ro',
    isa           => 'Str',
    default       => sub { Utils->new->get_db_file_path },
    lazy          => 1,
    documentation => 'This variable will have db file path as per the environment',
);

=pod
#----------------------------------------------------------------------------------#
# create the connection using the DBIX connector return cached connection .
# if requested again before returning the cache conn make sure its live connection.
#----------------------------------------------------------------------------------#
=cut

sub get_db_con {
    my ($self) = @_;

    if ( defined $CACHED_DBI && $CACHED_DBI->ping ) {

        # return live connection
        return $CACHED_DBI;
    }

    my $dbfile = $self->db_path;

    eval {
        # Create a connection.
        my $dbi = DBI->connect("dbi:SQLite:dbname=$dbfile",$ENV{DB_USERNAME} // "" ,$ENV{DB_PASSWORD} // "");
        #test
        $dbi->ping;
        $CACHED_DBI = $dbi;
        1;
    } or do {
        croak ": Error occured while connecting to db using dbi $EVAL_ERROR :";
    };

    return $CACHED_DBI;


}


sub connect_db {
    my $dbh = DBI->connect("dbi:SQLite:dbname=".setting('database'))
        or die $DBI::errstr;
 
    return $dbh;
}

sub init_db {
    my $db     = connect_db();
    my $schema = read_text('./schema.sql');
    $db->do($schema)
        or die $db->errstr;
}

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#

__PACKAGE__->meta->make_immutable;

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#

1;
