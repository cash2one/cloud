/***************************************************************************
 * 
 * Copyright (c) 2014 Baidu.com, Inc. All Rights Reserved
 * 
 **************************************************************************/
 
 
/**
 * @file loopQueue.cpp
 * @author yaokun(com@baidu.com)
 * @date 2014/09/23 17:18:29
 * @brief 
 *  
 **/

#include <iostream>
using namespace std;

class LoopQueue{
    public:
        LoopQueue(int m): max_size(m){
            size = 0;
            arr = new int[max_size];
        }

        void insert(int val){
            if(full() == true){
                cout << "now is full" << endl;
                return ;
            }
            arr[tail] = val;
            size++;
            tail++;
            tail = tail%max_size;
        }
        
        int getFront(){
           if(empty())
               return -1;
            return arr[front];
        }

        int pop(){
            if(empty())
                return -1;
            front++;
            front = front%max_size;
            size--;
            return 0;
        }

        inline bool full(){
            return size == max_size;
        }

        inline bool empty(){
            return size == 0;
        }

    private:
        int *arr;
        unsigned int size;
        const unsigned int max_size;
        unsigned int front;
        unsigned int tail;
};

int main(){
    LoopQueue q(3);
    q.insert(1);
    q.insert(2);

    q.pop();
    q.pop();
    q.insert(3);
    q.pop();
    q.insert(4);
    q.pop();
    cout << q.getFront() << endl;
    return 0;
}









/* vim: set expandtab ts=4 sw=4 sts=4 tw=100: */
