/***************************************************************************
 * 
 * Copyright (c) 2014 Baidu.com, Inc. All Rights Reserved
 * 
 **************************************************************************/
 
 
 
/**
 * @file my_swap.cpp
 * @author yaokun(com@baidu.com)
 * @date 2014/09/28 11:30:48
 * @brief 
 *  
 **/


#include <iostream>

using namespace std;

void my_swap_pointer(char *a, char *b){
    //cout << *a << endl;
    //cout << *b << endl;
    *a = (*a) ^ (*b);
    //cout << "step 1" ;
    *b = (*b) ^ (*a);
    //cout << "step 2" ;
    *a = (*a) ^ (*b);
    //cout << "step 3" ;
}

void my_swap(char *str, unsigned int p1, unsigned int p2){
    str[p1] ^= str[p2];
    str[p2] ^= str[p1];
    str[p1] ^= str[p2];
}

void reverse(char *str){
    unsigned int len = strlen(str);
    
    for(unsigned int i=0; i < len/2; i++){
        //cout <<*(str+len-i-1) <<endl;
        my_swap(str, i, len-1-i);
    }
}


int main(){
    
    char a = 'A';
    char b = 'B';
    
    char *test = "qwerasdf";
    my_swap(test, 0, 4);
    //reverse(test);

    /*
    while(test != NULL && *test != '\0'){
        cout << "test"  << endl;
        test++;
    }
    cout << endl <<test;
    */
    return 0;
}





















/* vim: set expandtab ts=4 sw=4 sts=4 tw=100: */
