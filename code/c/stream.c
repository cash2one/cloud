/***************************************************************************
 * 
 * Copyright (c) 2015 Baidu.com, Inc. All Rights Reserved
 * 
 **************************************************************************/
 
 
 
/**
 * @file stream.c
 * @author yaokun(com@baidu.com)
 * @date 2015/12/13 15:43:01
 * @brief 
 *  
 **/


#include <unistd.h>

#define BUFSIZE 4096

int write_to_std() {
    int n = 0;
    char buf[BUFSIZE];

    while( (n = read(STDIN_FILENO, buf, BUFSIZE) ) > 0 ) {
        if (write(STDOUT_FILENO, buf, n) != n) {
            printf("write error!");
        }
    }
    return 0;
}

int main() {
    write_to_std();
    return 0;
}




















/* vim: set expandtab ts=4 sw=4 sts=4 tw=100: */
