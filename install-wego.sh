#!/bin/bash

binary=$1
git_url=$2
go_root_dir=$3
the_alias=$4

echo $git_url

if [ -z $GOPATH ]; then
    export GOPATH=$go_root_dir && echo "Set environment variable 'GOPATH' as $go_root_dir"
else
    export GOPATH=$GOPATH:$go_root_dir && echo "Appended $go_root_dir to the environment variable 'GOPATH'"
fi

which go >/dev/null
if [ $? -eq 0 ]; then
    echo Program go is already installed
else
    apt-get install golang git > /dev/null && echo "Installed 'go' program"
fi

# echo $git_url
# repo=${git_url:8:-4}
# echo $repo

regex="https?://(.*).git"
echo $regex

if [[ $git_url =~ $regex ]]; then
    repo="${BASH_REMATCH[1]}";
    echo $repo
    # repo=${repo/.git/}
    # echo $repo
else
    echo "$git_url doesn't match" >&2
fi

go get $repo && echo  "got repo '$repo' in GOPATH\n";

