#!/bin/sh
find . -name "issue.info" | xargs rm -rf
#cooder的upload文件地址.
cooder_path=~/netdisk/git/cloud/baidu/tool/dev/upload.py
echo "y\nhello cooder" | python $cooder_path
read myissue < issue.info
read commitmsg
svn ci -m "ISSUE=$myissue $commitmsg"
rm -rf ISSUE_ID
rm -rf issue.info
