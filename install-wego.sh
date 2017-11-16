#!/bin/bash

binary=$1
git_url=$2
go_root_dir=$3
aliases_file=$4
the_alias=$5

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

regex="https?://(.*).git"


if [[ $git_url =~ $regex ]]; then
    repo="${BASH_REMATCH[1]}";
    go get $repo >/dev/null
    if [ $? -eq 0 ]; then
        echo "Go got repo '$repo' in GOPATH";
        echo "alias $the_alias='$go_root_dir/bin/$binary'" >> $aliases_file && echo "Wrote alias in $aliases_file"
        echo "Please source yourself and use as '$the_alias'"
    else
        echo "Go failed to get '$repo'"
    fi
else
    echo "'$git_url' doesn't match" >&2
fi





