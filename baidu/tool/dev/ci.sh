#!/bin/sh
#cooder的upload文件地址.
cooder_path=~/Documents/upload.py
echo "y\nhello cooder" | python $cooder_path | grep visit | awk -F/ '{print $4}' > ISSUE_ID
read myissue < ISSUE_ID
svn ci -m "ISSUE=$myissue"
rm -rf ISSUE_ID
rm -rf issue.info
