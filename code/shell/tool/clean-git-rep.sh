#!/bin/bash

# find exe file
find code -not -name "*.*" -type f > clearlist
echo "*tags" >> clearlist
echo "*.log" >> clearlist
echo "*.out" >> clearlist
echo "*.*~" >> clearlist
echo "*.vimrc" >> clearlist
echo "recv_file.tar.gz" >> clearlist

while read line
do
    #git filter-branch -f --prune-empty -d /dev/shm/scratch --index-filter "git rm --cached -f --ignore-unmatch $line" --tag-name-filter cat -- --all
    echo "Processing $line"
    git filter-branch -f --prune-empty --index-filter "git rm --cached -f --ignore-unmatch $line" --tag-name-filter cat -- --all
done < clearlist
