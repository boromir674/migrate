use strict;
use warnings;
use Env;
use LWP::Simple;
use Data::Dumper;
use feature 'say';
use YAML::XS 'LoadFile';
use APT;

########## CONSTANTS ##########
my $soft_n_libs_dir = "/home/$ENV{USER}/soft-n-libs";
my $download_dir = $soft_n_libs_dir;
my $go_root_dir = "$soft_n_libs_dir/go";
my $bashrc = "/home/$ENV{USER}/del_bashrc";
my $bash_aliases = "/home/$ENV{USER}/del_bash_aliases";
my $bash_functions = "/home/$ENV{USER}/del_bash_functions";
my $gitconfig = "/home/$ENV{USER}/del_gitconfig";
###############################

my $config = LoadFile('config.cfg');
# my $apt_get_path = `which apt-get`;
# my $apt_cache_path = `which apt-cache`;

my @failed = ();

# print Dumper($config); # print dict sructure

print "Begin migration\n\n";

###### process programs ######

for (keys %{$config->{programs}}) {
    my $key = $_;
    my $value = $config->{programs}->{$_};
    if ($value == 1) {
        get_install($key);
    }
}

###### process repository dependent programs  ######

for (keys %{$config->{reprograms}}) {
    my $program = $_;
    my $repo = $config->{reprograms}->{$_};
    add_repo($program, $repo);
    get_install($program);
}

###### process web elements ######

for (keys %{$config->{webelements}}) {
    my $program = $_;
    my $url = $config->{webelements}->{$_};
    `which program1 >/dev/null`;
    if ($? == 0) {
        print "Program $program is already installed\n";
    }
    else {
        system("./download-deb.sh $program $url $download_dir");
        my $exit_val = $? >> 8;
        if ($exit_val == 0) {
            print "Program $program ready to install\n";
        }
        else {
            print "Failed downloading for program $program\n";
            push @failed, $program;
        }
    }
}

###### process repos ######

for (keys %{$config->{repos}}) {
    my $key_tag = $_;
    my @specs = @{ $config->{repos}->{$_} };
    git_clone($key_tag, $specs[0], $specs[1]);
}

###### process gorepos ######

for (keys %{$config->{gorepos}}) {
    my $binary = $_;
    my @specs = @{ $config->{gorepos}->{$_} };
    system("./goalias.sh $binary $specs[0] $go_root_dir $bash_aliases $specs[1]");
    my $exit_val = $? >> 8;
    if ($exit_val == 0) {
        print "Installed $binary\n";
    }
    else {
        print "Failed to install $binary\n";
        push @failed, $binary;
    }
}

###### process gomkmkinstalias ######

for (keys %{$config->{gomkmkinstalias}}) {
    my $binary = $_;
    my @specs = @{ $config->{gomkmkinstalias}->{$_} };
    system("./gomkmkinstalias.sh $binary $specs[0] $go_root_dir $bash_aliases $specs[1]");
    my $exit_val = $? >> 8;
    if ($exit_val != 0) {
        print "Failed to install $binary\n";
        push @failed, $binary; 
    }
}

########## SUBS ##########

sub get_install {
    my $program = shift;
    `which $program >/dev/null`;
    if ($? == 0) {
        print "Program $program is already installed\n";
    }
    else {
        `sudo apt-get install $program >/dev/null 2>&1`;
        if ($? == 0) {
            print "Installed $program\n";
        }
        else {
            print "Failed to install $program\n";
            push @failed, $program;
        }
    }
}

sub bring_deb {
    my $name = shift;
    my $url = shift;
    my $dir = shift;
    if (-d $dir) {

    }
    elsif (-e $dir) {
        print "Requested to download .deb package in directory '$dir', but there is already a file with the same name\n";
        push @failed, "$name: $url";
        exit
    }
    else {
        `mkdir $dir`;
    }
    # my $cmd = "wget -O $dir/$name.deb $url";
    # print "$cmd\n";
    my $data = get("$url");
    print "Retrieved " . length($data) . " bytes of data.\n";
    my $exit_value  = $? >> 8;
    print "\nexit code: $exit_value\n";
    #    open(my $out, '>:raw', '$dir/$name.deb') or die "Unable to open: $!";
    print "name: $name\n";
    print "url: $url\n";
    print "dir: $dir\n";

#    system("touch $dir/$name.deb");
    open my $fh, ">:raw", "$dir/$name.deb" or die "file: $dir/$name.deb , failed $!";
#    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    print $fh pack($data);
    if ( $exit_value == 1 ) {
        print "Saved debian package $url as $name.deb in $dir/\n";
    }
    else {
        print "Failed to download debian package $url as $name.deb in $dir/\n";
        push @failed, "$name: $url";
    }
    close($fh);

}

sub add_repo {
    my $program = shift;
    my $repo = shift;
    my $pre = '';
    my @words = split(/:/, $repo);
    if ($words[0] ne "ppa") {
        print "Warning: usually expecting ppa as prefix with ':' as the separator. Instead '$words[0]' was parsed as the prefix\n";
    }
    `grep -q "^deb .*$words[1]" /etc/apt/sources.list /etc/apt/sources.list.d/*`;
    if ($? == 0) {
        print "Repository '$repo' for program '$program' is already added.\n";
    }
    else {
        `add-apt-repository $repo >/dev/null 2>&1`;
         if ( $? == 0 ) {
             print "Failed to add repository $repo for program $program\n";
             push @failed, "$program: $repo";
         }
        else {
            print "updating...\n";
            `apt-get update >dev/null 2>&1`;
            print "Added repository $repo for program '$program'\n";
       }
    }
}

sub git_clone {
    my $key_tag = shift;
    my $repo = shift;
    my $dir = shift;
    print "Cloning $repo for $key_tag in $dir\n";
    `git clone $repo $dir >/dev/null 2>&1`;
    if ($? == 0) {
        print "Cloned repo $repo for $key_tag in $dir\n";
    }
    else {
        print "Failed to clone repo $repo for $key_tag in $dir\n";
        push @failed, "$key_tag: $repo";
    }
}

if (@failed) {
    print "\nFailed: ", join(', ', @failed), "\n";
}

print "\nMigration complete\n\n";
