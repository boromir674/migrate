#!/bin/bash

binary=$1
git_url=$2
go_root_dir=$3
aliases_file=$4
the_alias=$5

if [ -z $GOPATH ]; then
    export GOPATH=$go_root_dir && echo "Set environment variable 'GOPATH' as $go_root_dir"
fi

echo "Go getting $git_url"
go get -v $git_url >/dev/null 2>&1

regex="github.com/(.*)"
if [[ $git_url =~ $regex ]]; then
    path="${BASH_REMATCH[1]}"
fi

dir_here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $GOPATH/src/github.com/$path
make >/dev/null
if [ $? -eq 0 ]; then
    make install > /dev/null
    if [ $? -eq 0 ]; then
        $dir_here/write-alias.sh $the_alias $go_root_dir/bin/$binary $aliases_file
    else
        cd - >/dev/null
        exit 1
    fi
else
    cd - >/dev/null
    exit 1
fi
cd - >/dev/null
