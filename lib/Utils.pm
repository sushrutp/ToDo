package Utils;

use Moose;
use Carp qw(croak);
use namespace::autoclean;
use Config::Any;
use File::Spec;
use Path::Class;
use File::Basename qw(fileparse);
use File::Spec::Functions;
use English qw($EVAL_ERROR -no_match_vars);
use File::Path qw( make_path );
use utf8;
use POSIX qw(strftime);
use Dancer::Logger::Console;
use Data::Dumper;

has 'logger_obj' => (
    is      => 'ro',
    isa     => 'Dancer::Logger::Console',
    default => sub { Dancer::Logger::Console->new },
    lazy    => 1,
);
#----------------------------------------------------------------------------------#
# custom module                                       #
#----------------------------------------------------------------------------------#

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
sub get_db_file_path {
    my ($self) = @_;

    #get all config at once
    my $file             = file(__FILE__);
    my $project_root_dir = $file->dir->parent;
    my $db_dir         = File::Spec->catdir($project_root_dir, 'db');

    if ( !-d $db_dir ) {
        $self->print_log("No db file found in $db_dir",'error');
        $self->print_log("creating db file in $db_dir",'info');
        make_path $db_dir  or die "Failed to create path: $db_dir ";
    }

    opendir(DIR, $db_dir) or croak "$!";
    my @file_name;
    my $ext = 'db';
    my $app_env_db = $ENV{TODO_DB_FILE_ENV} // $ENV{DANCER_ENVIRONMENT} // 'development';
    $app_env_db .= '.db';

    while (my $file = readdir(DIR)) {
        next if ($file ne $app_env_db);
        my $loc = "$db_dir/$file";
        next unless (-f $loc);
        next if (defined $ext && $loc !~ /\.($ext)$/);
        push(@file_name, $loc);
    }

    if (scalar @file_name == 0) {
        my $db_file =File::Spec->catfile($db_dir, $app_env_db);
        if (! -f $db_file) {
            open(my $fh, '>', $db_file) or die "Could not open file '$db_file' $!";
            push(@file_name, $db_file);
        }
    } elsif (scalar @file_name > 0) {
        $self->print_log("using db file in $file_name[0]",'debug');
    }

    $self->print_log(Dumper \@file_name);
    return wantarray ? @file_name : $file_name[0];
}
#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
sub get_db_schema_file_path {
    my ($self, $dir, $ext) = @_;
    #get all config at once
    my $file             = file(__FILE__);
    my $project_root_dir = $file->dir->parent;
    my $db_dir         = File::Spec->catdir($project_root_dir, 'sql');

    return $self->get_files_to_process($db_dir, 'sql');
}
#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
sub get_files_to_process {
    my ($self, $dir, $ext) = @_;
    return unless ($dir);
    opendir(DIR, $dir) or croak "$!";
    my @file_name;
    while (my $file = readdir(DIR)) {
        my $loc = "$dir/$file";
        next unless (-f $loc);
        next if (defined $ext && $loc !~ /\.($ext)$/);
        push(@file_name, $loc);
    }
    return [@file_name];
}

#----------------------------------------------------------------------------------#
# get asset path
#----------------------------------------------------------------------------------#
sub generate_unique_name {
    my ($self, $length) = @_;

    my $rand =
      join('', map { ('a' .. 'z')[rand(26)] } 1 .. $length // 10);

    return $rand;
}

#----------------------------------------------------------------------------------#
# debug   => 1,
# info    => 2,
# warn    => 3,
# warning => 3,
# error   => 4,
#----------------------------------------------------------------------------------#
sub print_log {
    my ($self, $text, $type) = @_;

    $type = lc($type // 'info');

    $self->logger_obj->$type($text);

    return;
}

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
__PACKAGE__->meta->make_immutable;

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#

1;
__END__
