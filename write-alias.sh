#!/bin/bash

the_alias=$1
cmd=$2
aliases_file=$3

echo "alias $the_alias='$cmd'" >> $aliases_file
if [ $? -eq 0 ]; then
    echo "Wrote alias in $aliases_file. Please source yourself and use as '$the_alias'"
else
    echo "Failed to alias '$cmd' as '$the_alias'"
    exit 1
fi
