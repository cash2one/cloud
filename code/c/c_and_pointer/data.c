/***************************************************************************
 * 
 * Copyright (c) 2016 Baidu.com, Inc. All Rights Reserved
 * 
 **************************************************************************/
 
 
 
/**
 * @file data.c
 * @author yaokun(com@baidu.com)
 * @date 2016/05/16 13:53:43
 * @brief 
 *  
 **/



#include <stdlib.h>


static int tmp_static_var = 123;

void test_static() {
    static int internal_static_var;
    internal_static_var++;
    printf("%d\t", internal_static_var);
}

int main(int argc, char** argv) {
    printf("%d\n", tmp_static_var);
    test_static();
    test_static();
    test_static();
    test_static();
    
    return 0;
}


















/* vim: set expandtab ts=4 sw=4 sts=4 tw=100: */
