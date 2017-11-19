#!/bin/bash

binary=$1
git_url=$2
go_root_dir=$3
aliases_file=$4
the_alias=$5

if [ -z $GOPATH ]; then
    export GOPATH=$go_root_dir && echo "Set environment variable 'GOPATH' as $go_root_dir"
fi

which go >/dev/null
if [ $? -ne 0 ]; then
    apt-get install golang git > /dev/null && echo "Installed 'go' program"
fi

regex="https?://(.*).git"

if [[ $git_url =~ $regex ]]; then
    repo="${BASH_REMATCH[1]}";
    go get $repo >/dev/null
    if [ $? -eq 0 ]; then
        echo "Go got repo '$repo' in GOPATH"
        ./write-alias.sh $the_alias $go_root_dir/bin/$binary $aliases_file
    else
        echo "Go failed to get '$repo'"
        exit 1
    fi
else
    echo "'$git_url' doesn't match" >&2
    exit 1
fi





