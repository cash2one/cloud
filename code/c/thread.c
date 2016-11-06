/***************************************************************************
 * 
 * Copyright (c) 2016 Baidu.com, Inc. All Rights Reserved
 * 
 **************************************************************************/

/**
 * @file thread.c
 * @author yaokun(com@baidu.com)
 * @date 2016/06/23 01:11:05
 * @brief 
 *  
 **/

int total_count = 100;

void* test123(void * arg) {
    printf("arg : [%s]\n", arg);
    printf("total_count [%d]\n", total_count);
    while(total_count > 0) {
        printf("Cur total Count %d\n", total_count--);
    }
    return 0;
}

#include <pthread.h>

int main() {
    pthread_t tid1;
    pthread_t tid2;
    char* str1 = "thread1";
    pthread_create(&tid1, NULL, &test123, str1);
    char* str2 = "thread2";
    pthread_create(&tid2, NULL, &test123, str2);
    pthread_join(tid1, NULL);
    pthread_join(tid2, NULL);
    return 0;
}



















/* vim: set expandtab ts=4 sw=4 sts=4 tw=100: */
