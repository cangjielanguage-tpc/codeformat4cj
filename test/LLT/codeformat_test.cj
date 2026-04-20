/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

package codeformat.test

import codeformat.*
import std.fs.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let formatCAndCpp = FormatCAndCpp()
    formatCAndCpp.testformat1()
    formatCAndCpp.testformat2()
    formatCAndCpp.testformat3()
    formatCAndCpp.testformat4()
    formatCAndCpp.testformat5()
    return 0
}

@Test
class FormatCAndCpp {
    var codeRaw1 = #"
#include <stdio.h>
#include <stdlib.h>
int main() {
int a = 10;
int b = 20;
int sum = a + b;
printf("Sum: %d\\n", sum);
return 0;
}
"#

var codeRaw2 = #"
include<stdio.h>
int main(){int i,j;for(i=1;i<=3;i++){for(j=1;j<=3;j++){printf("%d %d\\n",i,j);}}return 0;}
"#

var codeRaw3 = #"
#include<iostream>
using namespace std;
class Test{
      private:
int x;
     public:
Test(int a){x=a;}
void show(){cout<<"Value: "<<x<<endl;}};
int main(){
Test t(42);
t.show();
int arr[5]={1,2,3,4,5};
for(int i=0;i<5;i++){
cout<<arr[i]<<" ";}
cout<<endl;return 0;}
"#


var codeRaw4 = #"
#include <iostream>
#include <vector>
using namespace std;class Node{public:int data;Node*next;Node(int val){data=val;next=nullptr;}};class LinkedList{private:Node*head;public:LinkedList(){head=nullptr;}void insert(int val){Node*newNode=new Node(val);if(!head){head=newNode;return;}Node*temp=head;while(temp->next){temp=temp->next;}temp->next=newNode;}void print(){Node*temp=head;while(temp){cout<<temp->data<<" ";temp=temp->next;}cout<<endl;}~LinkedList(){Node*temp;while(head){temp=head;head=head->next;delete temp;}}};int main(){LinkedList list;vector<int>nums={5,2,8,1,9};for(int num:nums){list.insert(num);}cout<<"链表内容:";list.print();int sum=0;for(int i=0;i<nums.size();i++){sum+=nums[i];}cout<<"数字总和:"<<sum<<endl;return 0;}
"#

var codeRaw5 = #"
#include<stdio.h>
#include<stdlib.h>
struct Node{int data;struct Node*next;};struct Node*createNode(int data){struct Node*node=(struct Node*)malloc(sizeof(struct Node));node->data=data;node->next=NULL;return node;}void insert(struct Node**head,int data){struct Node*newNode=createNode(data);if(*head==NULL){*head=newNode;return;}struct Node*temp=*head;while(temp->next!=NULL){temp=temp->next;}temp->next=newNode;}void printList(struct Node*head){struct Node*temp=head;while(temp!=NULL){printf("%d ",temp->data);temp=temp->next;}printf("\\n");}void freeList(struct Node*head){struct Node*temp;while(head!=NULL){temp=head;head=head->next;free(temp);}}int main(){struct Node*head=NULL;int arr[]={7,3,9,1,4,6,2,8,5};int n=sizeof(arr)/sizeof(arr[0]);for(int i=0;i<n;i++){insert(&head,arr[i]);}printf("链表元素:");printList(head);int sum=0;for(int i=0;i<n;i++){sum+=arr[i];}printf("数组总和:%d\\n",sum);freeList(head);return 0;}
"#

    @TestCase
    func testformat1() {
        let output1 = codeFormat("c", codeRaw1, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/tempFile1.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr1 = String.fromUtf8(allBytes)
        @Assert(output1,expectedStr1.replace("\r\n","\n"))
    }

    @TestCase
    func testformat2() {
        let output2 = codeFormat("c", codeRaw2, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/tempFile2.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr2 = String.fromUtf8(allBytes)
        @Assert(output2,expectedStr2.replace("\r\n","\n"))
    }

    @TestCase
    func testformat3() {
        let output3 = codeFormat("c", codeRaw3, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/tempFile3.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr3 = String.fromUtf8(allBytes)
        @Assert(output3,expectedStr3.replace("\r\n","\n"))
    }

    @TestCase
    func testformat4() {
        let output4 = codeFormat("c", codeRaw4, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/tempFile4.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr4 = String.fromUtf8(allBytes)
        @Assert(output4,expectedStr4.replace("\r\n","\n"))
    }

    @TestCase
    func testformat5() {
         let output5 = codeFormat("c", codeRaw5, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/tempFile5.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr5 = String.fromUtf8(allBytes)
        @Assert(output5,expectedStr5.replace("\r\n","\n"))
    }
}
