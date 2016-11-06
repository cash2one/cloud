#!/bin/sh

ps -ef | grep php-fpm | grep -v grep | awk '{print $2}' | xargs kill -QUIT
/Users/syaokun219/cpp-ide/php-annotation/php-5.6.16/sapi/fpm/php-fpm
