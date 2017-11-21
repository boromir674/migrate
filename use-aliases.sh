#!/bin/bash

me=`basename "$0"`
dir_here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
selected_aliases=selected_aliases

if [ "$#" -ne 2 ]; then
    echo "Example usage: $me \"usefull optional must\" ~/.bash_aliases"
    exit 1
fi

selected_aliases_types=$1 # comma separated flags indicating which aliases groups to extract
aliases_target=$2 # the file to write the extracted aliases to

aliases_data=`cat $dir_here/resources/$selected_aliases`
read -a alias_types <<< $selected_aliases_types

echo
echo $aliases_data
echo
echo $selected_aliases
echo $dir_here

for alias_type in "${alias_types[@]}"; do
    shopt -s nocasematch
    regex="#{5} ?$alias_type ?#{5}(.*)#{5} ?$alias_type ?#{5}"
    if [[ $aliases_data =~ $regex ]]; then
        aliases_block="${BASH_REMATCH[1]}"
        lines=`echo $aliases_block | wc -l`
        printf "$aliases_block" >> $aliases_target
        echo "Unloaded/appended $(lines) '$alias_type' alias entries to '$aliases_target' from '$selected_aliases'"
    else
        echo "Did not find '$alias_type' alias header entries in '$selected_aliases'"
    fi
done
