/***************************************************************************
 * 
 * Copyright (c) 2015 Baidu.com, Inc. All Rights Reserved
 * 
 **************************************************************************/
 
 
 
/**
 * @file array.c
 * @author yaokun(com@baidu.com)
 * @date 2015/11/12 00:19:50
 * @brief 
 *  
 **/


#include <stdio.h>

typedef struct ass_array_s {
    char* key;
    size_t value;
} ass_array_t;

int main (int argc, char** argv) {
    ass_array_t asd;
    asd.value = 123;

    printf("array value : %d", asd.value);
    return 0;
}
















/* vim: set expandtab ts=4 sw=4 sts=4 tw=100: */
