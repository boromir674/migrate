#!/bin/bash

binary=$1
git_url=$2
go_root_dir=$3
aliases_file=$4
the_alias=$5

echo b $binary
echo g $git_url
echo go $go_root_dir

if [ -z $GOPATH ]; then
    export GOPATH=$go_root_dir && echo "Set environment variable 'GOPATH' as $go_root_dir"
fi

echo "go getting $git_url"
go get -v $git_url >/dev/null 2>&1

regex="github.com/(.*)"
if [[ $git_url =~ $regex ]]; then
    path="${BASH_REMATCH[1]}";
    echo path: $path
fi

dir_here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $GOPATH/src/github.com/$path
make >/dev/null
if [ $? -eq 0 ]; then
    make install > /dev/null
    if [ $? -eq 0 ]; then
        $dir_here/write-alias.sh $the_alias $go_root_dir/bin/$binary $aliases_file
    else
        exit 1
    fi
else
    exit 1
fi
cd -

