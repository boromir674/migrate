#!/bin/bash

### BUG: renders/inserts '\n' in places of '\' found (i.e. alias ltr=\'\ls -tr')

me=`basename "$0"`
dir_here="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
target_file_name=selected_aliases

if [ "$#" -ne 2 ]; then
    echo "Example usage: $me ~/.bash_aliases /media/$USER/a-disk/-a-path/ \"usefull optional must\""
    exit 1
fi

aliases_source=$1 # the file to search for defined aliases
selected_aliases=$2 # comma separated flags indicating which aliases groups to extract
aliases_target=$dir_here/resources/$target_file_name # the file to write the extracted aliases to

if [ -f $aliases_target ]; then rm $aliases_target; fi
touch $aliases_target
aliases_data=`cat $aliases_source`
read -a alias_types <<< $selected_aliases

prev_lines=0
for alias_type in "${alias_types[@]}"; do
    shopt -s nocasematch
    regex="#{5} ?$alias_type ?#{5}(.*)#{5} ?$alias_type ?#{5}"
    if [[ $aliases_data =~ $regex ]]; then
        aliases_block="\n##### $alias_type #####${BASH_REMATCH[1]}# $alias_type #####\n"
        printf "$aliases_block" >> $aliases_target
        lines=`grep -E "^alias " $aliases_target | wc -l`
        echo "Loaded $((lines-prev_lines)) '$alias_type' alias entries in 'resources/$target_file_name' from '$aliases_source'"
        prev_lines=$lines
    else
        echo "Did not find '$alias_type' alias header entries in '$aliases_source'"
    fi
done
