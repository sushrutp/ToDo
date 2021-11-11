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
use utf8;
use Log::Fast;
use Email::Valid;
use MIME::Base64;
use POSIX;
use String::Validator::Password;
use File::Compare;
use DateTime::Format::Strptime;

#crypt
use JSON::XS;

use Data::Dumper;

#----------------------------------------------------------------------------------#
# custom module                                       #
#----------------------------------------------------------------------------------#

sub enc_json {
    my ($self, $data) = @_;

    return JSON::XS->new->utf8->encode($data);
}

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#

sub dcd_json {
    my ($self, $data) = @_;

    return JSON::XS->new->utf8->allow_nonref->decode($data);
}

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
sub array_minus {
    my ($self, $arr1, $arr2) = @_;

    return unless (defined $arr1 && scalar @$arr1);
    return unless (defined $arr2 && scalar @$arr2);

    my %e = map { $_ => undef } @{$arr2};
    return [grep(!exists($e{$_}), @{$arr1})];
}

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
sub fetch_all_config {
    my ($self) = @_;

    if (defined $self->{cached_all_config}) {
        return $self->{cached_all_config};
    }

    #get all config at once
    my $file             = file(__FILE__);
    my $project_root_dir = $file->dir->parent->parent;
    my $conf_dir         = File::Spec->catdir($project_root_dir, 'conf');
    my @conf_files       = $self->get_files_to_process($conf_dir, 'yml');

    my $cfg = Config::Any->load_files({files => [@conf_files], flatten_to_hash => 1, use_ext => 1,});
    my $config;
    if (defined $cfg) {
        foreach (keys %{$cfg}) {
            my @file = fileparse($_, qr/\.[^.]*/mis);
            $config->{$file[0]} = $cfg->{$_};
        }
    }

    #keep debug for perf test
    my @stat = caller;
    $self->display("Config loaded for $stat[1] line $stat[2]", 'INFO');

    $self->{cached_all_config} = $config;
    return $self->{cached_all_config};
}

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
sub get_db_file_path {
    my ($self) = @_;

    #get all config at once
    my $file             = file(__FILE__);
    my $project_root_dir = $file->dir->parent;
    my $db_dir         = File::Spec->catdir($project_root_dir, 'db');

    opendir(DIR, $db_dir) or croak "$!";
    my @file_name;
    my $ext = 'db';
    my $app_env_db = $ENV{APP_ENV} // 'development';
    $app_env_db .= '.db';
    while (my $file = readdir(DIR)) {
        next if ($file ne $app_env_db);
        my $loc = "$db_dir/$file";
        next unless (-f $loc);
        next if (defined $ext && $loc !~ /\.($ext)$/);
        push(@file_name, $loc);
    }

    return wantarray ? @file_name : $file_name[0];
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
    return @file_name;
}

#----------------------------------------------------------------------------------#
# validate data keys needed
#----------------------------------------------------------------------------------#
sub validate {
    my ($self, $data, $keys) = @_;

    my $valid = 1;
    my $missing;
    foreach (@{$keys}) {
        if (defined $data->{$_} && ref($data->{$_}) eq 'ARRAY') {
            if (scalar @{$data->{$_}} < 1) {
                push(@$missing, $_);
                $valid = 0;
            }
        }
        if (not defined $data->{$_}) {
            push(@$missing, $_);
            $valid = 0;
        }
        if (defined $data->{$_} && $data->{$_} =~ /^\s*$/) {
            push(@$missing, $_);
            $valid = 0;
        }
    }

    return wantarray ? ($valid, $missing) : $valid;
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
#----------------------------------------------------------------------------------#
sub display {
    my ($self, $text, $type) = @_;

    $type = lc($type // 'info');

    my $time = strftime "%Y/%m/%d %H:%M:%S", localtime time;

    my $error_cat_map = {
        debug => '[debug]',
        warn  => '[warn]',
        error => '[error]',
        info  => '[info]',
        fatal => '[fatal]',
    };

    print STDERR $error_cat_map->{$type} . ' ' . $time . " : " . $text . "\n";

    #Exit with error message in case of any fatal
    croak if ($type eq 'fatal');

    return;
}

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#
__PACKAGE__->meta->make_immutable;

#----------------------------------------------------------------------------------#
#----------------------------------------------------------------------------------#

1;
__END__
