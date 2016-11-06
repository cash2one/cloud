/***************************************************************************
 * 
 * Copyright (c) 2015 Baidu.com, Inc. All Rights Reserved
 * 
 **************************************************************************/
 
/**
 * @file test.c
 * @author yaokun(com@baidu.com)
 * @date 2015/11/07 16:38:49
 * @brief 
 *  
 **/


#include <stdio.h>
struct sdshdr {
    int len;
    int free;
    char buf[];
};


int main (int argc, char** argv) {
    printf("size : %d", sizeof(struct sdshdr));
    return 0;
}





















/* vim: set expandtab ts=4 sw=4 sts=4 tw=100: */
