/***************************************************************************
 * 
 * Copyright (c) 2015 Baidu.com, Inc. All Rights Reserved
 * 
 **************************************************************************/
 

/**
 * @file redis-read.c
 * @author yaokun(com@baidu.com)
 * @date 2015/11/08 03:42:53
 * @brief 
 *  
 **/

#include "redis-read.h"

static int default_msg_handler(const char* msg) {
    printf("your msg is %s\n", msg);
    return 0;
}

static int (*msg_function_pointer)(const char* msg) = default_msg_handler;

int main(int argc, char** argv) {
    if (argc > 1) {
        msg_function_pointer(argv[1]);
    } else {
        msg_function_pointer("no input command!");
    }
    return 0;
}
















/* vim: set expandtab ts=4 sw=4 sts=4 tw=100: */
