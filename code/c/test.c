/***************************************************************************
 * 
 * Copyright (c) 2016 Baidu.com, Inc. All Rights Reserved
 * 
 **************************************************************************/
 
 
 
/**
 * @file test.c
 * @author yaokun(com@baidu.com)
 * @date 2016/01/03 21:05:39
 * @brief 
 *  
 **/

#include <stdio.h>
#include <unistd.h>
 #include <fcntl.h>
#include <sched.h>

int main (int argc, char** argv) {
    __sync_bool_compare_and_swap();
    int f = open("test.c", O_RDONLY);
    char buf[4096];
    read(f, buf, 4096);
    printf("%s", buf);
    return 0;
}





















/* vim: set expandtab ts=4 sw=4 sts=4 tw=100: */
