#!/bin/bash

### BUG: renders/inserts '\n' in places of '\' found (i.e. alias ltr=\'\ls -tr')

me=`basename "$0"`

if [ "$#" -ne 3 ]; then
    echo "Example usage: $me ~/.bash_aliases /media$USER/a-disk/-a-path/ \"usefull optional must\""
    exit 1
fi

aliases_source=$1 # the file to search for defined aliases
aliases_target=$2 # the file to write the extracted aliases to
selected_aliases=$3 # comma separated flags indicating which aliases groups to extract

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
        echo "Loaded $((lines-prev_lines)) '$alias_type' alias entries in '$aliases_target' from '$aliases_source'"
        prev_lines=$lines
    else
        echo "Did not find '$alias_types' alias entries in '$aliases_source'"
    fi
done
