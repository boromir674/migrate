use strict;
use warnings;
use Env;
use Data::Dumper;
use feature 'say';
use YAML::XS 'LoadFile';
use APT;

########## CONSTANTS ##########
my $soft_n_libs_dir = "/home/$ENV{USER}/soft-n-libs";
my $deb_download_dir = $soft_n_libs_dir;
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

# my $apt = APT->new(
#     aptget => '/usr/bin/sudo $apt_get_path -s', # sudo and no-act
#     aptcache => '/usr/bin/sudo $apt_cache_path', # sudo
#     );

# print Dumper($config); # print dict sructure

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
    `which $program >/dev/null`;
    if ($? == 0) {
        print "Program $program is already installed\n";
    }
    else {
        bring_deb($program, $url, $deb_download_dir);
    }
}

###### process repos ######

for (keys %{$config->{repos}}) {
    my $key_tag = $_;
    my @specs = @{ $config->{repos}->{$_} };
    git_clone($key_tag, $specs[0], $specs[1]);
}

sub m_install {
    my $binary = shift;
    my $repo = shift;
    my $alias = shift;
    $ENV{'GOPATH'} = '$go_root_dir' && print "exported GOPATH variable as $go_root_dir/\n";
    get_install("golang-go git");
    print $repo, "\n";
    if ($repo =~ /https?:\/+(.+)\.git/) {
        print "$1\n";
        `go get blah` && print "got repo '$1' in GOPATH\n";
    }

 #   `alias $alias='$go_root_dir/bin/$binary\n'` && print "aliased $go_root_dir/bin/$binary as $alias\n";
#     write_alias($alias, "$go_root_dir/bin/$binary");
}

###### process repo4compile ######
print "\n";
for (keys %{$config->{repos4compile}}) {
    my $binary = $_;
    my @specs = @{ $config->{repos4compile}->{$_} };
    m_install($binary, $specs[0], $specs[1]);
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
    `wget -O ./$dir/$name.deb $url >> /dev/null 2>&1`;
    if ( $? == 0 ) {
        print "Downloaded debian package $url as $name.deb in $dir\n";
    }
    else {
        print "Failed to download debian package $url as $name.deb\n";
        push @failed, "$name: $url";
    }
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



sub write_alias {
    my $alias = shift;
    my $binary_path = shift;
    open(my $fh, '>>', '~/.bash_aliases') or die "Failed to open ~/.bash_aliases";
    say $fh "alias $alias='$binary_path'" && print "aliased $binary_path as $alias\n";
    close $fh;
}

if (@failed) {
    print "\nFailed: ", join(', ', @failed), "\n";
}

print "\nMigration complete\n";

