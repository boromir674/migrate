#!/bin/bash

name=$1
url=$2
dir=$3
if [ ! -d "$dir" ]; then
    mkdir ./$dir
fi
echo "Downloading.."
wget -O $dir/$name.deb $url > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo Downloaded debian package $url as $name.deb "in" $dir
    xdg-open $dir/$name.deb > /dev/null 2>&1 &
else
    echo Failed to download debian package $url as $name.deb
    exit 1
fi
