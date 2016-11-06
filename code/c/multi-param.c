/***************************************************************************
 * 
 * Copyright (c) 2015 Baidu.com, Inc. All Rights Reserved
 * 
 **************************************************************************/
 
 
 
/**
 * @file multi-param.c
 * @author yaokun(com@baidu.com)
 * @date 2015/11/16 00:21:54
 * @brief 
 *  
 **/

#include <stdio.h>
#include <stdarg.h>

int my_printf(const char* tpl, ...) {
    va_list v;
    va_start(v, tpl);
    while(*tpl != '\0') {
        printf("char : %c, pointer : %p\n", *tpl, tpl);
        tpl++;
    }

    printf("reading param list!\n");
    int i =0;
    for(i=0; i<20000000000000; i++) {
        char* cp = (char*)malloc(sizeof(char));
        *cp = 'a';
        printf("current is %d, here is %c, p is %p\n", i, *cp, cp);
        cp++;
    }

    /*
    int i=1;
    while(1) {
        i++;
        cp = va_arg(v, char*);
        printf("%d is %s", i++, cp);
    }
    va_end(v);
    free(cp);
    */
}

int main(int argc, char** argv) {
    my_printf("Asdasd", "asd", "asda");
    return 0;
}

/* vim: set expandtab ts=4 sw=4 sts=4 tw=100: */
