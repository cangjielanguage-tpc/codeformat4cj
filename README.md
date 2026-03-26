<div align="center">
<h1>codeformat4cj</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v1.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/build-pass-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v1.0.5-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>


## 介绍

codeformat4cj是一个对代码进行格式化的库,目前仅支持C和C++,OC/OC++,js/ts，java,python语言


### 特性

本项目为自研项目

- 🚀 支持C和C++代码格式化
- 🚀 支持OC/OC++，js/ts，java，python代码的格式化


### 源码目录

```shell
├── README.md                                 #整体介绍
├── CHANGELOG.md                              #更新说明
├── LICENSE                                   #license说明
├── doc                                       #文档目录
│   └── feature_api.md                        #API接口文档
├── src                                       #仓颉源码目录 
└── cjpm.toml                                 #项目的配置文件 

```

### 接口说明

主要类和函数接口说明详见 [API](./doc/feature_api.md)


## 使用说明

### 编译构建

描述具体的编译过程：

```shell
    1.先通过命令把代码下载下来,
      git clone -b develop https://gitcode.com/Cangjie-TPC/codeformat4cj.git
    2.进入项目目录
      执行cjpm build即可编译通过      
```

### 功能示例
 
功能示例描述: 将一段C++代码格式化

示例代码如下：
```cangjie

    var codeRaw = """
    #include<stdio.h>
    #include<stdlib.h>
    struct Node{int data;struct Node*next;};struct Node*createNode(int data){struct Node*node=(struct Node*)malloc(sizeof(struct Node));node->data=data;node->next=NULL;return node;}void insert(struct Node**head,int data){struct Node*newNode=createNode(data);if(*head==NULL){*head=newNode;return;}struct Node*temp=*head;while(temp->next!=NULL){temp=temp->next;}temp->next=newNode;}void printList(struct Node*head){struct Node*temp=head;while(temp!=NULL){printf("%d ",temp->data);temp=temp->next;}printf("\\n");}void freeList(struct Node*head){struct Node*temp;while(head!=NULL){temp=head;head=head->next;free(temp);}}int main(){struct Node*head=NULL;int arr[]={7,3,9,1,4,6,2,8,5};int n=sizeof(arr)/sizeof(arr[0]);for(int i=0;i<n;i++){insert(&head,arr[i]);}printf("链表元素:");printList(head);int sum=0;for(int i=0;i<n;i++){sum+=arr[i];}printf("数组总和:%d\\n",sum);freeList(head);return 0;}
    """

    let output = codeFormat("cpp",codeRaw,FormatConfig())
    println(output)


```shell

输出结果如下：

```cangjie

#include<stdio.h>
#include<stdlib.h>
struct Node{
    int data;
    struct Node*next;
};
struct Node*createNode(int data){
    struct Node*node=(struct Node*)malloc(sizeof(struct Node));
    node->data=data;
    node->next=NULL;
    return node;
}
void insert(struct Node**head,int data){
    struct Node*newNode=createNode(data);
    if(*head==NULL){
        *head=newNode;
        return;
    }
    struct Node*temp=*head;
    while(temp->next!=NULL){
        temp=temp->next;
    }
    temp->next=newNode;
}
void printList(struct Node*head){
    struct Node*temp=head;
    while(temp!=NULL){
        printf("%d ",temp->data);
        temp=temp->next;
    }
    printf("\n");
}
void freeList(struct Node*head){
    struct Node*temp;
    while(head!=NULL){
        temp=head;
        head=head->next;
        free(temp);
    }
}
int main(){
    struct Node*head=NULL;
    int arr[]={7,3,9,1,4,6,2,8,5};
    int n=sizeof(arr)/sizeof(arr[0]);
    for(int i=0;i<n;i++){
        insert(&head,arr[i]);
    }
    printf("链表元素:");
    printList(head);
    int sum=0;
    for(int i=0;i<n;i++){
        sum+=arr[i];
    }
    printf("数组总和:%d\n",sum);
    freeList(head);
    return 0;
}

```


## 约束与限制

Cangjie Compiler: 请使用最新的lts版本1.0.5

## 开源协议

本项目基于 [Apache License 2.0](./LICENSE) ，请自由的享受和参与开源。

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。