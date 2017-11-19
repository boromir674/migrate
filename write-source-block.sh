#!/bin/bash

me=`basename "$0"`

if [ "$#" -ne 2 ]; then
    echo "Example usage: $me \"~/.bash_functions\" ~/.bashrc"
    exit 1
fi

file_to_source=$1
target_file=$2

echo in1: $file_to_source
echo in2: $target_file

file_data=`cat $(echo $target_file)`

regex=". $file_to_source"
echo regex: $regex

if [[ $file_data =~ $regex ]]; then
    match="${BASH_REMATCH[1]}";
    echo "It seems that file '$file_to_source' is already loaded/sourced from '$target_file'"
else
    echo >> $target_file
    echo "if [ -f $file_to_source ]; then" >> $target_file
    echo "    . $file_to_source" >> $target_file
    echo "fi" >> $target_file
    echo "Injected code in '$target_file' to load/source '$file_to_source'"
fi
