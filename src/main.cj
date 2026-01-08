package codeformat

import std.time.*


main():Int64 {


 var codeRaw1="""
(void)addConditionWithKey:(const std::string &)key strVal:(const std::string &)strVal modifyUpdateReqItem:(std::vector<unifiedPublish::UniPubMatch> &)modifyUpdateReqItem {   	unifiedPublish::UniPubMatch addcondition = new unifiedPublish::UniPubMatch();	addcondition->setkey(key);	addcondition->setvalue(strVal);		addcondition->setvaluetype(unifiedPublish::UniPubValueType::kString);		modifyUpdateReqItem.pushback(addcondition);}
"""

         
//差不多 反斜杠数量
    var codeRaw2 = #"
#include <stdio.h>
#include <stdlib.h>
#define BUFFER_SIZE 1024
#define VERSION "1.0"
#define MAX(a,b) ((a)>(b)?(a):(b))
#define DEBUG_PRINT(fmt, ...) 
if (DEBUG_ENABLED) {
fprintf(stderr, "[DEBUG] " fmt, ##__VA_ARGS__); 
}
#ifdef __linux__
#define PLATFORM "Linux"
#else
#define PLATFORM "Other"
#endif
#define SQUARE(x) ((x)*(x))
int main() {
int DEBUG_ENABLED = 1;
dEBUG_PRINT("Program starting on %s\\n\\t\\f\\r\\v\\\"\\\'\\0", PLATFORM);
int x = 10;
int y = 20;
int max_val = MAX(x, y);
printf("Max of %d and %d is %d\\n", x, y, max_val);
int buffer[BUFFER_SIZE];
DEBUG_PRINT("Buffer initialized, version %s\\n", VERSION);
#ifdef __linux__
printf("Running on Linux system\\n");
#endif
return 0;
}
"#


//差不多 空格
var codeRaw3 = """
for(int i=0;i<10;i++){x++;}
for(auto x:list){sum+=x;}
"""


    var codeRaw4 = """
#include <stdio.h>
#include <stdlib.h>
int main() {
int a = 10;
int b = 20;
int sum = a + b;
printf("Sum: %d\\n", sum);
return 0;
}
"""


var codeRaw5 = """
#include
using namespace std;
int main(){
int x=5;int y=10;cout<<"Product: "<<x*y<<endl;return 0;}
"""


var codeRaw6 = """
include<stdio.h>
int main(){int i,j;for(i=1;i<=3;i++){for(j=1;j<=3;j++){printf("%d %d\\n",i,j);}}return 0;}
"""


//差不多 反斜杠数量
    var codeRaw7 = #"
#include <stdio.h>
#include <stdlib.h>
#define BUFFER_SIZE 1024
#define VERSION "1.0"
#define MAX(a,b) ((a)>(b)?(a):(b))
#define DEBUG_PRINT(fmt, ...) 
if (DEBUG_ENABLED) { 
fprintf(stderr, "[DEBUG] " fmt, ##__VA_ARGS__); 
}
#ifdef __linux__
#define PLATFORM "Linux"
#else
#define PLATFORM "Other"
#endif
#define SQUARE(x) ((x)*(x))
int main() {
int DEBUG_ENABLED = 1;
DEBUG_PRINT("Program {starting} on %s\\n\\t\\f\\r\\v\\\"\\'\\0", PLATFORM);
int x = 10;
int y = 20;
int max_val = MAX(x, y);
printf("Max of %d and %d is %d\\n", x, y, max_val);
int buffer[BUFFER_SIZE];
for (int i = 0; i < 10; i++) {
buffer[i] = SQUARE(i);
}
DEBUG_PRINT("Buffer initialized, version %s\\n", VERSION);
#ifdef __linux__
printf("Running on Linux system\\n");
#endif
return 0;
}
"#

var codeRaw8 = """
#include    <stdio.h>
#include <string.h>
#define DEBUG 1
  #ifdef DEBUG
#define LOG_MSG "debug: value = %d\\n\\t\\"test escape\\""
#endif
int main() {
    char buf[100] = "init\\nvalue\\twith\\tescape\\\"";
    int sum = 0;
for(int i=0; i<10; i++){
sum += i;
    if (i % 2 == 0) {
printf(LOG_MSG, i);
char c = '\\n';
putchar(c);
}
}
  printf("sum = %d, buf = %s", sum, buf);
  return 0;
}

void calc(int a, int b) {
    int res = a + b;
    #ifdef DEBUG
    printf("res = %d\\n", res);
    #endif
}
"""

var codeRaw9 = """
#include 
#include
#include
#include
using namespace std;
class Student{
public:
string name;int id;double #gpa;
Student(string n,int i,double g):name(n),id(i),gpa(g){}
void display(){cout<<"Name: "<<name<<", ID: "<<id<<", GPA: "<<gpa<<endl;}
};
int main(){
vectorstudents;
students.push_back(Student("Alice",101,3.8));
students.push_back(Student("Bob",102,3.5));
students.push_back(Student("Charlie",103,3.9));
map<int,string>dept;
dept[101]="Computer Science";
dept[102]="Mathematics";
dept[103]="Physics";
for(int i=0;i<students.size();i++){
students[i].display();
cout<<"Department: "<<dept[students[i].id]<<endl;
}
double total=0;
for(int i=0;i<students.size();i++)total+=students[i].gpa;
cout<<"Average GPA: "<<total/students.size()<<endl;
return 0;
}
"""

var codeRaw10 = """
#include
#include
#include
using namespace std;
/* This program calculates Euclidean distances between points /
class Point{
public:
double x,y;
Point(double x0,double y0):x(x0),y(y0){} // constructor initializes coordinates
/ computes distance to another point /
double distanceTo(const Point& other){
return sqrt((x-other.x)(x-other.x)+(y-other.y)(y-other.y));
}
};
int main(){
// create a vector of points
vectorpoints;
points.push_back(Point(0.0,0.0)); // origin
points.push_back(Point(3.0,4.0)); / 3-4-5 triangle /
points.push_back(Point(1.0,1.0));
// calculate pairwise distances
for(int i=0;i<points.size();i++){
for(int j=i+1;j<points.size();j++){
double d=points[i].distanceTo(points[j]);
cout<<"Distance between point "<<i<<" and "<<j<<": "<<d<<endl;
}
}
/ output complete */
return 0;
"""

var codeRaw11 = """
  //这是单行注释你好啊7
#include <stdio.h>
#include <stdlib.h>
  #define BUFFER_SIZE 1024
#define VERSION "1.0"
#define MAX(a,b) ((a)>(b)?(a):(b))
    //这是单行注释你好啊
#define DEBUG_PRINT(fmt, ...) 
if (DEBUG_ENABLED) {
fprintf(stderr, "[DEBUG] " fmt, ##__VA_ARGS__); 
}  //这是单行注释你好啊5
#ifdef __linux__
#define PLATFORM "Linux"
#else
#define PLATFORM "Other"
#endif
#define SQUARE(x) ((x)*(x))
int main() {   //这是单行注释你好啊2 //这是单行注释你好啊5
 //这是单行注释你好啊3
int DEBUG_ENABLED = 1;  //这是单行注释你好啊4
dEBUG_PRINT("Program starting on %s\\n\\t\\f\\r\\v\\\"\\\'\\0", PLATFORM);
int x = 10;
int y = 20;
int max_val = MAX(x, y);
printf("Max of %d and %d is %d\\n", x, y, max_val);
int buffer[BUFFER_SIZE];
DEBUG_PRINT("Buffer initialized, version %s\\n", VERSION);
#ifdef __linux__
printf("Running on Linux system\\n");
#endif
return 0;
}
"""

var codeRaw12 = """
int main() {   
int DEBUG_ENABLED = 1;  //这是单行注释你好啊4
dEBUG_PRINT("Program", PLATFORM); /* HHSasdsadasd
这是多行注释
asdsadasd
这是多行注释*/ int x = 10;
int y = 20;
int max_val = MAX(x, y);
printf("Max of %d and %d is %d\\n", x, y, max_val);
int buffer[BUFFER_SIZE];
DEBUG_PRINT("Buffer initialized, version %s\\n", VERSION);
#ifdef __linux__
printf("Running on Linux system\\n");
#endif
return 0;
}
"""


var codeRaw13 = #"
/*
asdsadasd
这是多行注释
asdsadasd
这是多行注释*/
#include <stdio.h>
#include <stdlib.h>
  #define BUFFER_SIZE 1024
#define VERSION "1.0"
#define MAX(a,b) ((a)>(b)?(a):(b))  
/*asdsadasd
这是多行注释
asdsadasd
这是多行注释*/
#define DEBUG_PRINT(fmt, ...) 
if (DEBUG_ENABLED) {
/*
asdsadasd
这是多行注释
asdsadasd
这是多行注释*/  fprintf(stderr, "[DEBUG] " fmt, ##__VA_ARGS__); 
}  //这是单行注释你好啊5
#ifdef __linux__
#define PLATFORM "Linux" 
#else
#define PLATFORM "Other"
#endif
#define SQUARE(x) ((x)*(x))
int main() {   //这是单行注释你好啊2 //这是单行注释你好啊5 
 //这是单行注释你好啊3
int DEBUG_ENABLED = 1;  //这是单行注释你好啊4
dEBUG_PRINT("Program starting on", PLATFORM); /* asdsadasd
这是多行\n注释
asdsadasd
这是多行注释*/ 
int x = 10;
int y = 20;
int max_val = MAX(x, y);
printf("Max of %d and %d is %d\\n", x, y, max_val);
int buffer[BUFFER_SIZE];
DEBUG_PRINT("Buffer initialized, version %s\\n", VERSION);
#ifdef __linux__
printf("Running on Linux system\\n");
#endif
return 0;
}
"#


var codeRaw14 = """
#include <stdio.h>
int main(){int a=5,b=10,sum;sum=a+b;printf("The sum of %d and %d is %d\\n",a,b,sum);return 0;}
"""

var codeRaw15 = """
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
"""

var codeRaw16 = """
#include <iostream>
#include <vector>
using namespace std;class Node{public:int data;Node*next;Node(int val){data=val;next=nullptr;}};class LinkedList{private:Node*head;public:LinkedList(){head=nullptr;}void insert(int val){Node*newNode=new Node(val);if(!head){head=newNode;return;}Node*temp=head;while(temp->next){temp=temp->next;}temp->next=newNode;}void print(){Node*temp=head;while(temp){cout<<temp->data<<" ";temp=temp->next;}cout<<endl;}~LinkedList(){Node*temp;while(head){temp=head;head=head->next;delete temp;}}};int main(){LinkedList list;vector<int>nums={5,2,8,1,9};for(int num:nums){list.insert(num);}cout<<"链表内容:";list.print();int sum=0;for(int i=0;i<nums.size();i++){sum+=nums[i];}cout<<"数字总和:"<<sum<<endl;return 0;}
"""

var codeRaw17 = """
#include<stdio.h>
#include<stdlib.h>
struct Node{int data;struct Node*next;};struct Node*createNode(int data){struct Node*node=(struct Node*)malloc(sizeof(struct Node));node->data=data;node->next=NULL;return node;}void insert(struct Node**head,int data){struct Node*newNode=createNode(data);if(*head==NULL){*head=newNode;return;}struct Node*temp=*head;while(temp->next!=NULL){temp=temp->next;}temp->next=newNode;}void printList(struct Node*head){struct Node*temp=head;while(temp!=NULL){printf("%d ",temp->data);temp=temp->next;}printf("\\n");}void freeList(struct Node*head){struct Node*temp;while(head!=NULL){temp=head;head=head->next;free(temp);}}int main(){struct Node*head=NULL;int arr[]={7,3,9,1,4,6,2,8,5};int n=sizeof(arr)/sizeof(arr[0]);for(int i=0;i<n;i++){insert(&head,arr[i]);}printf("链表元素:");printList(head);int sum=0;for(int i=0;i<n;i++){sum+=arr[i];}printf("数组总和:%d\\n",sum);freeList(head);return 0;}
"""

var codeRaw18 = #"
/*
asdsadasd
这是多行注释
asdsadasd
这是多行注释*/
#include <stdio.h>
#include <stdlib.h>
  #define BUFFER_SIZE 1024
#define VERSION "1.0"
#define MAX(a,b) ((a)>(b)?(a):(b))  
/*asdsadasd
这是多行注释
asdsadasd
这是多行注释*/
#define DEBUG_PRINT(fmt, ...) 
if (DEBUG_ENABLED) {
/*
asdsadasd
这是多行注释
asdsadasd
这是多行注释*/  fprintf(stderr, "[DEBUG] " fmt, ##__VA_ARGS__); 
}  //这是单行注释你好啊5
#ifdef __linux__
#define PLATFORM "Linux" 
#else
#define PLATFORM "Other"
#endif
#define SQUARE(x) ((x)*(x))
int main() {   //这是单行注释你好啊2 //这是单行注释你好啊5 
 //这是单行注释你好啊3
int DEBUG_ENABLED = 1;  //这是单行注释你好啊4
dEBUG_PRINT("Program starting on %s\\n\\t\\f\\r\\v\"c\\\\0", PLATFORM); 
int x = 10;
int y = 20;
int max_val = MAX(x, y);
printf("Max of %d and %d is %d\\n", x, y, max_val);
int buffer[BUFFER_SIZE];
DEBUG_PRINT("Buffer initialized, version %s\\n", VERSION);
#ifdef __linux__
printf("Running on Linux system\\n");
#endif
return 0;
}
"#

var codeRaw19 = #"
#include <iostream>
#include <vector>
#include <string>
using namespace std;
class DataProcessor{public:
DataProcessor(){}
void process(vector<string>&items){
for(int i=0;i<items.size();i++){
string& item=items[i];
// Remove extra spaces
size_t pos=0;
while((pos=item.find("  ",pos))!=string::npos){
item.replace(pos,2," ");}
// Trim leading/trailing spaces
pos=item.find_first_not_of(" ");
if(pos!=string::npos){
item=item.substr(pos);}
pos=item.find_last_not_of(" ");
if(pos!=string::npos){
item=item.substr(0,pos+1);}}}
void print(const vector<string>&items)const{
for(const auto& item:items){
cout<<"["<<item<<"]"<<endl;}}};
int main(){
DataProcessor dp;
vector<string>data={"  hello   world  ","   c++  code  ","  no   format   "};
cout<<"Original:"<<endl;dp.print(data);
dp.process(data);
cout<<"Processed:"<<endl;dp.print(data);
return 0;}
"#


var codeRaw20 = #"
#include <iostream>
#include <string>
#include <cstring>
class Student {
private:
// 私有成员（封装性）
std::string m_name;
int m_age;
char* m_id; // 动态内存成员
public:
// 1. 默认构造函数
Student () : m_name ("Unknown"), m_age (0), m_id (nullptr) {
std::cout << "默认构造函数调用" << std::endl;
}
// 2. 带参数构造函数（初始化列表）
Student (std::string name, int age, const char* id)
: m_name (std::move (name)), m_age (age), m_id (nullptr) {
std::cout << "带参数构造函数调用" << std::endl;
if (id) {
m_id = new char [strlen (id) + 1];
strcpy (m_id, id);
}
}
// 3. 拷贝构造函数（深拷贝，避免浅拷贝问题）
Student (const Student& other) {
std::cout << "拷贝构造函数调用" << std::endl;
m_name = other.m_name;
m_age = other.m_age;
m_id = nullptr;
if (other.m_id) {
m_id = new char [strlen (other.m_id) + 1];
strcpy (m_id, other.m_id);
}
}
// 4. 赋值运算符重载（深拷贝）
Student& operator=(const Student& other) {
std::cout << "赋值运算符重载调用" << std::endl;
if (this == &other) { // 防止自赋值
return *this;
}
// 释放当前资源
delete [] m_id;
// 拷贝对方资源
m_name = other.m_name;
m_age = other.m_age;
m_id = nullptr;
if (other.m_id) {
m_id = new char [strlen (other.m_id) + 1];
strcpy (m_id, other.m_id);
}
return *this;
}
// 5. 析构函数（释放动态内存，防止内存泄漏）
~Student () {
std::cout << "析构函数调用，释放 ID 内存" << std::endl;
delete [] m_id;
m_id = nullptr;
}
// 公有接口：普通成员函数
void setInfo (std::string name, int age) {
m_name = std::move (name);
m_age = age;
}
// 公有接口：const 成员函数（不能修改成员变量）
void showInfo () const {
std::cout << "Name:" << m_name
<< ", Age:" << m_age
<<", ID:" << (m_id ? m_id : "None") << std::endl;
}
// 友元函数声明（突破封装，可访问私有成员）
friend std::ostream& operator<<(std::ostream& os, const Student& stu);
};
// 友元函数定义（全局函数）
std::ostream& operator<<(std::ostream& os, const Student& stu) {
os << "Friend Info:" << stu.m_name << "," << stu.m_age;
return os;
}
int main() {
Student stu1("Alice", 20, "20240001");
stu1.showInfo();
std::cout << stu1 << std::endl;
Student stu2 = stu1; // 调用拷贝构造
stu2.setInfo ("Bob", 21);
stu2.showInfo ();
Student stu3;
stu3 = stu2; // 调用赋值运算符重载
stu3.showInfo ();
return 0;
}
"#

var codeRaw21 = #"
#include <iostream>
#include <string>
// 基类（抽象类：包含纯虚函数）
class Animal {
protected:
std::string m_name;
int m_age;
public:
Animal(std::string name, int age) : m_name(std::move(name)), m_age(age) {}
// 虚析构函数：确保子类析构函数被正确调用
virtual ~Animal () {
std::cout << "Animal 析构函数调用" << std::endl;
}
// 纯虚函数：抽象接口，无实现，强制子类重写
virtual void makeSound () const = 0;
// 普通虚函数：有默认实现，子类可重写
virtual void showInfo () const {
std::cout << "Animal:" << m_name << ", Age:" << m_age << std::endl;
}
};
// 子类（公有继承）
class Dog : public Animal {
private:
std::string m_breed; // 子类独有成员
public:
Dog(std::string name, int age, std::string breed)
: Animal(std::move(name), age), m_breed(std::move(breed)) {}
~Dog () override { //override 关键字：明确重写父类虚函数
std::cout << "Dog 析构函数调用" << std::endl;
}
// 重写纯虚函数
void makeSound () const override {
std::cout << m_name << "says: Wang Wang!" << std::endl;
}
// 重写普通虚函数
void showInfo () const override {
std::cout << "Dog:" << m_name << ", Age:" << m_age
<< ", Breed:" << m_breed << std::endl;
}
};
// 另一个子类
class Cat : public Animal {
public:
Cat (std::string name, int age) : Animal (std::move (name), age) {}
~Cat () override {
std::cout << "Cat 析构函数调用" << std::endl;
}
void makeSound() const override {
std::cout << m_name << " says: Miao Miao!" << std::endl;
}
};
// 多态调用：接收基类指针 / 引用，实际调用子类实现
void animalBehavior (const Animal& animal) {
animal.showInfo ();
animal.makeSound ();
}
int main () {
// 抽象类不能实例化，只能创建子类对象
Dog dog ("Wang Cai", 3, "Golden Retriever");
Cat cat ("Mimi", 2);
// 多态表现：同一接口，不同行为
animalBehavior (dog);
animalBehavior (cat);
// 基类指针指向子类对象
Animal* animalPtr = new Dog ("Da Huang", 5, "Chinese Rural Dog");
animalPtr->showInfo ();
animalPtr->makeSound ();
delete animalPtr; // 调用 Dog 析构 + Animal 析构（虚析构的作用）
return 0;
}
"#

var codeRaw22 =#"
#include <iostream>
#include <string>
#include <vector>
// 1. 函数模板：通用数据类型的交换函数
template <typename T>
void swapValue(T& a, T& b) {
T temp = std::move(a);
a = std::move(b);
b = std::move(temp);
}
// 函数模板重载（不同参数个数）
template <typename T1, typename T2>
auto getMax (T1 a, T2 b) -> decltype (a > b ? a : b) {
return a > b ? a : b;
}
// 2. 类模板：通用栈容器
template <typename T, int DEFAULT_SIZE = 10> // 带默认模板参数
class MyStack {
private:
std::vector<T> m_data;
const int m_maxSize;
public:
MyStack() : m_maxSize(DEFAULT_SIZE) {
m_data.reserve(DEFAULT_SIZE);
}
MyStack(int maxSize) : m_maxSize(maxSize) {
m_data.reserve(maxSize);
}
// 入栈
bool push (const T& value) {
if (m_data.size () >= (size_t) m_maxSize) {
std::cout << "Stack is full" << std::endl;
return false;
}
m_data.push_back (value);
return true;
}
// 出栈
bool pop (T& value) {
if (m_data.empty ()) {
std::cout << "Stack is empty" << std::endl;
return false;
}
value = m_data.back ();
m_data.pop_back ();
return true;
}
// 查看栈顶
const T& top () const {
return m_data.back ();
}
bool isEmpty() const {
return m_data.empty();
}
};
// 3. 类模板特化：针对 std::string 类型的特殊处理
template <>
class MyStack<std::string, 10> {
private:
std::vectorstd::string m_data;
const int m_maxSize = 10;
public:
bool push (const std::string& value) {
if (m_data.size () >= (size_t) m_maxSize) {
std::cout << "String Stack is full" << std::endl;
return false;
}
// 特殊处理：去除字符串前后空格（特化的核心意义）
std::string trimmed = value;
size_t start = trimmed.find_first_not_of (" ");
size_t end = trimmed.find_last_not_of (" ");
if (start != std::string::npos) {
trimmed = trimmed.substr (start, end - start + 1);
} else {
trimmed = "";
}
m_data.push_back (trimmed);
return true;
}
bool pop(std::string& value) {
if (m_data.empty()) {
std::cout << "String Stack is empty" << std::endl;
return false;
}
value = m_data.back();
m_data.pop_back();
return true;
}
const std::string& top() const {
return m_data.back();
}
bool isEmpty() const {
return m_data.empty();
}
};
int main () {
// 函数模板使用
int a = 10, b = 20;
swapValue (a, b);
std::cout << "a:" << a << ", b:" << b << std::endl;
double c = 3.14, d = 6.28;
std::cout << "Max: " << getMax(c, d) << std::endl;
// 类模板使用（int 类型）
MyStack<int, 5> intStack;
for (int i = 1; i <= 6; ++i) {
intStack.push (i);
}
int val;
while (!intStack.isEmpty()) {
intStack.pop(val);
std::cout << "Pop: " << val << std::endl;
}
// 类模板特化使用（string 类型）
MyStackstd::string strStack;
strStack.push(" Hello World ");
strStack.push(" C++ Template ");
std::string strVal;
strStack.pop(strVal);
std::cout << "Pop String: [" << strVal << "]" << std::endl;
return 0;
}
"#  


var codeRaw23 =#"
#include <iostream>
#include <string>
#include <vector>
// 1. 函数模板：通用数据类型的交换函数
template <typename T>
void swapValue(T& a, T& b) {
T temp = std::move(a);
a = std::move(b);
b = std::move(temp);
}
// 函数模板重载（不同参数个数）
template <typename T1, typename T2>
auto getMax (T1 a, T2 b) -> decltype (a > b ? a : b) {
return a > b ? a : b;
}
// 2. 类模板：通用栈容器
template <typename T, int DEFAULT_SIZE = 10> /* 带默认模板参数
你还哦啊
哈哈哈*/
class MyStack {
private:
std::vector<T> m_data;
const int m_maxSize;
public:
MyStack() : m_maxSize(DEFAULT_SIZE) {
m_data.reserve(DEFAULT_SIZE);
}
MyStack(int maxSize) : m_maxSize(maxSize) {
m_data.reserve(maxSize);
}
"#

var codeRaw24 =#"
if (start != std::string::npos) {
trimmed = trimmed.substr (start, end - start + 1);
} else {  //这是注释
trimmed = "";
}
"#

var codeRaw25 =#"
if (start != std::string::npos) {
trimmed = trimmed.substr (start, end - start + 1);
} else if(start ==1) { //这是注释
   trimmed = "1";
}else if(start ==2) {
   trimmed = "2";
}else{
   trimmed = "3";
}
"#

var codeRaw26 =#"
#include <iostream>
#include <vector>
#include <map>
#include <set>
#include <string>
#include <algorithm>
#include <numeric>
#include <iterator>
int main () {
// 1. 顺序容器：vector
std::vector<int> vec = {3, 1, 4, 1, 5, 9, 2, 6};
std::cout << "Original vector:";
for (const auto& elem : vec) { // 范围 for 循环
std::cout << elem << " ";
}
std::cout << std::endl;
// 排序（STL 算法）
std::sort (vec.begin (), vec.end ());
std::cout << "Sorted vector:";
for (const auto& elem : vec) {
std::cout << elem << " ";
}
std::cout << std::endl;
// 去重（排序后去重）
auto uniqueIt = std::unique (vec.begin (), vec.end ());
vec.erase (uniqueIt, vec.end ());
std::cout << "Unique vector:";
for (const auto& elem : vec) {
std::cout << elem << " ";
}
std::cout << std::endl;
// 2. 关联容器：map（键值对）
std::map<std::string, int> scoreMap;
scoreMap ["Tom"] = 95;
scoreMap ["Jerry"] = 88;
scoreMap ["Alice"] = 99;
scoreMap.insert (std::make_pair ("Bob", 90)); // 插入方式
std::cout << "\nScore Map: " << std::endl;
for (const auto& pair : scoreMap) {
std::cout << pair.first << ": " << pair.second << std::endl;
}
// 查找 map 元素
std::string name = "Alice";
auto mapIt = scoreMap.find (name);
if (mapIt != scoreMap.end ()) {
std::cout << name << ":" << mapIt->second << std::endl;
}
// 3. 关联容器：set（自动去重、排序）
std::setstd::string strSet = {"apple", "banana", "orange", "apple", "grape"};
std::cout << "\nString Set: ";
for (const auto& str : strSet) {
std::cout << str << " ";
}
std::cout << std::endl;
// 4. STL 算法 + lambda 表达式
std::vector<int> nums = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
// 筛选偶数（copy_if）
std::vector<int> evenNums;
std::copy_if (nums.begin (), nums.end (), std::back_inserter (evenNums),
[](int num) { return num % 2 == 0; }); //lambda 表达式
std::cout << "\nEven numbers: ";
for (const auto& num : evenNums) {
std::cout << num << " ";
}
std::cout << std::endl;
// 累加（accumulate）
int sum = std::accumulate (nums.begin (), nums.end (), 0);
std::cout << "Sum of nums:" << sum << std::endl;
// 遍历并修改（for_each）
std::cout << "Double nums:";
std::for_each (nums.begin (), nums.end (),
[](int& num) { num *= 2; std::cout << num << " "; });
std::cout << std::endl;
// 5. 迭代器适配器：反向迭代器
std::cout << "Reverse vector:";
for (std::vector<int>::reverse_iterator it = vec.rbegin(); it != vec.rend(); ++it) {
std::cout << *it << " ";
}
std::cout << std::endl;
return 0;
}
"#

var codeRaw27 = #"
#include <iostream>
#include <memory>
#include <vector>
#include <string>
// 测试类
class TestObject {
private:
std::string m_name;
public:
TestObject(std::string name) : m_name(std::move(name)) {
std::cout << "TestObject created: " << m_name << std::endl;
}
~TestObject() {
std::cout << "TestObject destroyed: " << m_name << std::endl;
}
void showInfo() const {
std::cout << "Object Name: " << m_name << std::endl;
}
// 用于演示 weak_ptr
void checkWeakPtr (const std::weak_ptr<TestObject>& weakObj);
};
void TestObject::checkWeakPtr(const std::weak_ptr<TestObject>& weakObj) {
//lock ()：将 weak_ptr 转为 shared_ptr（若对象存在）
if (auto sharedObj = weakObj.lock ()) {
std::cout << "Weak_ptr is valid, object name:" << sharedObj->m_name << std::endl;
} else {
std::cout << "Weak_ptr is invalid (object destroyed)" << std::endl;
}
}
int main () {
// 1. unique_ptr：独占式智能指针（不可拷贝，可移动）
std::unique_ptr<TestObject> uPtr1 = std::make_unique<TestObject>("Unique Object 1");
uPtr1->showInfo();
// 移动语义（转移所有权）
std::unique_ptr<TestObject> uPtr2 = std::move(uPtr1);
if (!uPtr1) {
std::cout << "uPtr1 is now null (ownership moved)" << std::endl;
}
uPtr2->showInfo();
// 自定义删除器（针对数组）
std::unique_ptr<int [], std::default_delete<int []>> arrPtr (new int [5]{1, 2, 3, 4, 5});
for (int i = 0; i < 5; ++i) {
std::cout << "Array [" << i << "]:" << arrPtr [i] << std::endl;
}
// 2. shared_ptr：共享所有权，引用计数
std::shared_ptr<TestObject> sPtr1 = std::make_shared<TestObject>("Shared Object 1");
std::cout << "Reference count: " << sPtr1.use_count() << std::endl;
std::shared_ptr<TestObject> sPtr2 = sPtr1; // 拷贝，引用计数 + 1
std::cout <<"Reference count after copy:" << sPtr1.use_count () << std::endl;
sPtr1->showInfo();
sPtr2->showInfo();
// 3. weak_ptr：弱引用（不增加引用计数，解决循环引用）
std::weak_ptr<TestObject> wPtr = sPtr1;
std::cout << "Weak_ptr reference count: " << wPtr.use_count() << std::endl;
sPtr1->checkWeakPtr(wPtr);
// 释放 shared_ptr，引用计数归 0，对象销毁
sPtr1.reset ();
sPtr2.reset ();
std::cout << "After reset, check weak_ptr:" << std::endl;
if (auto temp = wPtr.lock ()) {
temp->showInfo ();
} else {
std::cout << "Shared object has been destroyed" << std::endl;
}
return 0;
}
"#


var codeRaw28 = #"
#include <iostream>
#include <stdexcept>
#include <string>
// 自定义异常类（继承 std::exception）
class MyException : public std::exception {
private:
std::string m_errorMsg;
public:
explicit MyException(std::string errorMsg) : m_errorMsg(std::move(errorMsg)) {}
// 重写 what () 方法（const noexcept：异常规范）
const char* what () const noexcept override {
return m_errorMsg.c_str ();
}
~MyException() noexcept override = default;
};
// 可能抛出异常的函数
int divide (int a, int b) {
if (b == 0) {
// 抛出标准异常
throw std::invalid_argument ("Division by zero is not allowed");
}
if (a < 0 || b < 0) {
// 抛出自定义异常
throw MyException ("Negative number is not supported in division");
}
return a /b;
}
// 嵌套异常抛出
void processData (int a, int b) {
try {
int result = divide (a, b);
std::cout << "Division result:" << result << std::endl;
} catch (const std::invalid_argument& e) {
std::cout << "Caught invalid_argument:" << e.what () << std::endl;
// 重新抛出异常（传递给上层）
throw;
}
}
int main () {
try {
// 测试 1：除数为 0
processData (10, 0);
// 测试 2：负数
//processData (-5, 2);
// 测试 3：正常情况
//processData (10, 2);
} catch (const MyException& e) { // 优先捕获自定义异常（子类异常）
std::cout << "Caught MyException:" << e.what () << std::endl;
} catch (const std::exception& e) { // 捕获标准异常（父类异常）
std::cout << "Caught standard exception:" << e.what () << std::endl;
} catch (...) { // 捕获所有未处理的异常（兜底）
std::cout << "Caught unknown exception" << std::endl;
}
std::cout << "Program continues to run after exception handling" << std::endl;
return 0;
}
"#

var codeRaw29 = #"
std::for_each (nums.begin (), nums.end (),
[](int& num) { num *= 2; std::cout << num << " "; });
"#

var codeRaw30 = #"
std::copy_if (nums.begin (), nums.end (), std::back_inserter (evenNums),
[](int num) { return num % 2 == 0; }); //lambda 表达式
std::cout << "\nEven numbers: ";
"#

var codeRaw31 = #"
#include <iostream>
#include <string>
// 函数重载（不同参数类型）
int calculate (int a, int b) {
return a + b;
}
double calculate(double a, double b) {
return a * b;
}
// 带默认参数的函数
std::string getInfo (std::string name = "Unknown", int age = 0) {
return "Name:" + name + ", Age:" + std::to_string (age);
}
int main () {
// 基础数据类型与常量
const int MAX_NUM = 100;
short s = 20;
long long ll = 123456789012345LL;
bool isOk = true;
char ch = 'A';
// 流程控制（if-else、for、switch）
if (calculate (3, 5) > MAX_NUM / 10) {
std::cout << "Sum is large enough" << std::endl;
}
for (int i = 0; i < 5; ++i) {
std::cout << "Loop: " << i << ", Product: " << calculate(2.5, (double)i) << std::endl;
}
switch (ch) {
case 'A':
std::cout << "Grade A" << std::endl;
break;
default:
std::cout << "Other grade" << std::endl;
}
// 默认参数函数调用
std::cout <<getInfo ("Tom", 25) << std::endl;
std::cout << getInfo ("Jerry") << std::endl;
std::cout << getInfo () << std::endl;
return 0;
}
"#

    //   let output1 = codeFormat("c",codeRaw1,FormatConfig())
    //   let output2 = codeFormat("c",codeRaw2,FormatConfig())
    //   let output3 = codeFormat("c",codeRaw3,FormatConfig())
    //   let output4 = codeFormat("c",codeRaw4,FormatConfig())
    //   let output5 = codeFormat("c",codeRaw5,FormatConfig())
    //   let output6 = codeFormat("c",codeRaw6,FormatConfig())
    //   let output7 = codeFormat("c",codeRaw7,FormatConfig())
    //   let output8 = codeFormat("c",codeRaw8,FormatConfig())
    //   let output9 = codeFormat("c",codeRaw9,FormatConfig())
    //   let output10 = codeFormat("c",codeRaw10,FormatConfig())
    //   let output11 = codeFormat("c",codeRaw11,FormatConfig())
    //   let output12 = codeFormat("c",codeRaw12,FormatConfig())
    //   let output13 = codeFormat("c",codeRaw13,FormatConfig())
    //   let output14 = codeFormat("c",codeRaw14,FormatConfig())
    //   let output15 = codeFormat("c++",codeRaw15,FormatConfig())
    //   let output16 = codeFormat("cpp",codeRaw16,FormatConfig())
    //   let output17 = codeFormat("clike",codeRaw17,FormatConfig())
    //   let output18 = codeFormat("clike",codeRaw18,FormatConfig())
    //   let output19 = codeFormat("clike",codeRaw19,FormatConfig())
    //   let output20 = codeFormat("clike",codeRaw20,FormatConfig())
    //   let output21 = codeFormat("clike",codeRaw21,FormatConfig())
    //   let output22 = codeFormat("clike",codeRaw22,FormatConfig())
    //   let output23 = codeFormat("clike",codeRaw23,FormatConfig())
    //   let output24 = codeFormat("clike",codeRaw24,FormatConfig())
    //   let output25 = codeFormat("clike",codeRaw25,FormatConfig())
    //   let output26 = codeFormat("clike",codeRaw26,FormatConfig())
    //   let output27 = codeFormat("clike",codeRaw27,FormatConfig())
    //   let output28 = codeFormat("clike",codeRaw28,FormatConfig())
    //   let output29 = codeFormat("clike",codeRaw29,FormatConfig())
    //   let output30 = codeFormat("clike",codeRaw30,FormatConfig())
         let output31 = codeFormat("clike",codeRaw31,FormatConfig())

      //var str = #"(void)addConditionWithKey:(const std::string &)key strVal:(const std::string &)strVal modifyUpdateReqItem:(std::vector<unifiedPublish::UniPubMatch> &)modifyUpdateReqItem {   	unifiedPublish::UniPubMatch add"#

      //let output19 = codeFormat("clike",str,FormatConfig())



    //    println("---------------------------------")
    //    println(output1)
    //    println("---------------------------------")
    //    println(output2)
    //    println("---------------------------------")
    //    println(output3)
    //    println("---------------------------------")
    //    println(output4)
    //    println("---------------------------------")
    //    println(output5)
    //    println("---------------------------------")
    //    println(output6)
    //    println("---------------------------------")
    //    println(output7)
    //    println("---------------------------------")
    //    println(output8)
    //    println("---------------------------------")
    //    println(output9)
    //    println("---------------------------------")
    //    println(output10)
    //    println("---------------------------------")
    //    println(output11)
    //    println("---------------------------------")
    //    println(output12)
    //    println("---------------------------------")
    //    println(output13)
    //    println("---------------------------------")
    //    println(output14)
    //    println("---------------------------------")
    //    println(output15)
    //    println("---------------------------------")
    //    println(output16)
    //    println("---------------------------------")
    //    println(output17)
    //    println("---------------------------------")
    //    println(output18)
    //    println("---------------------------------")
    //    println(output19)
    //    println("---------------------------------")
    //    println(output20)
    //    println("---------------------------------")
    //    println(output21)
    //    println("---------------------------------")
    //    println(output22)
    //    println("---------------------------------")
    //    println(output23)
    //    println("---------------------------------")
    //    println(output24)
    //    println("---------------------------------") 
    //    println(output25)
    //    println("---------------------------------") 
    //    println(output26)
    //    println("---------------------------------")
    //    println(output27)
    //    println("---------------------------------")
    //    println(output28)
    //    println("---------------------------------")
    //      println(output29)
    //      println("---------------------------------")
    //      println(output30)
    //      println("---------------------------------")
            println(output31)
            println("---------------------------------")
    return 0;
}