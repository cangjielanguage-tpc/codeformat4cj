// EXEC: cjc %import-path %L %l %f
// EXEC: ./main

package codeformat.test

import codeformat.*
import std.fs.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let formatRust = FormatRust()
    formatRust.testRustFormat()
    return 0
}

@Test
class FormatRust {
var rustFormatTestCode = #"
//! Rust 测试格式化专用
use std::fmt::{Display, Formatter, Result as FmtResult};
use std::ops::Add;
const MAX_VALUE: u32 = 100;
static SERVICE_NAME: &str = "rust-format-demo";
#[derive(Debug,Clone,Copy,PartialEq,Eq)]
pub enum UserStatus{
Active,
Inactive,
Banned,
}
impl Display for UserStatus {
fn fmt(&self, f: &mut Formatter<'_>) -> FmtResult {
match self {
UserStatus::Active => write!(f, "active"),
UserStatus::Inactive => write!(f, "inactive"),
UserStatus::Banned => write!(f, "banned"),
}
}
}
#[derive(Debug,Default)]
pub struct Address{
pub city: String,
pub street: String,
pub zip_code: String,
}
/// 带泛型的结构体
#[derive(Debug)]
pub struct Container<T> {
item: T,
capacity: usize,
}
impl<T> Container<T> {
pub fn new(item: T) -> Self {
Self {
item,
capacity: std::mem::size_of::<T>(),
}
}
pub fn get_item(&self) -> &T {
&self.item
}
}
/// 自定义trait
pub trait Identifiable {
fn id(&self) -> u64;
fn is_valid(&self) -> bool {
true
}
}
/// 用户结构体
#[derive(Debug)]
pub struct User {
pub id: u64,
pub name: String,
pub age: u32,
pub status: UserStatus,
pub address: Option<Address>,
}
impl Identifiable for User {
fn id(&self) -> u64 {
self.id
}
}
impl Display for User {
fn fmt(&self, f: &mut Formatter<'_>) -> FmtResult {
write!(
f,
"User[id: {}, name: {}, age: {}, status: {}]",
self.id, self.name, self.age, self.status
)
}
}
/// 实现加法
impl Add for User {
type Output = Self;
fn add(self, rhs: Self) -> Self::Output {
Self {
id: self.id + rhs.id,
name: format!("{}+{}", self.name, rhs.name),
age: self.age + rhs.age,
status: self.status,
address: None,
}
}
}
/// 自定义错误类型
#[derive(Debug)]
pub enum AppError {
InvalidId,
AgeTooSmall,
NotFound,
}
impl Display for AppError {
fn fmt(&self, f: &mut Formatter<'_>) -> FmtResult {
match self {
AppError::InvalidId => write!(f, "invalid user id"),
AppError::AgeTooSmall => write!(f, "age must be greater than 0"),
AppError::NotFound => write!(f, "user not found"),
}
}
}
/// 结果类型别名
type AppResult<T> = Result<T, AppError>;
/// 函数：创建用户
pub fn create_user(id: u64, name: String, age: u32) -> AppResult<User> {
if id == 0 {
return Err(AppError::InvalidId);
}
if age == 0 {
return Err(AppError::AgeTooSmall);
}
Ok(User {
id,
name,
age,
status: UserStatus::Active,
address: Some(Address::default()),
})
}
/// 模式匹配演示
pub fn check_status(user: &User) -> &'static str {
match user.status {
UserStatus::Active => "online",
UserStatus::Inactive => "offline",
UserStatus::Banned => "blocked",
}
}
/// 闭包 & 迭代器演示
pub fn process_numbers() -> Vec<u32> {
let numbers = vec![1, 2, 3, 4, 5, 6, 7, 8, 9];
numbers
.iter()
.filter(|&&x| x % 2 == 0)
.map(|x| x * 2)
.collect()
}
/// 生命周期演示
pub fn get_longest<'a>(a: &'a str, b: &'a str) -> &'a str {
if a.len() > b.len() {
a
} else {
b
}
}
fn complex_function<T, U>(a: T, b: U) -> i32
where
T: Summary + Clone,
U: PartialOrd + Clone,
{ 42 }
fn pattern_matching_advanced() {
// 解构结构体
let p = Person {
name: "Alice".to_string(),
age: 30,
};
let Person { name, age } = p;
// 解构枚举
let event = WebEvent::KeyPress('x');
match event {
WebEvent::KeyPress(c) => println!("char: {}", c),
WebEvent::Click { x, y } => println!("click"),
_ => (),
}
// 使用 @ 绑定
match 5 {
n @ 1..=10 => println!("{} in range", n),
_ => (),
}
// 匹配守卫
let pair = (2, -2);
match pair {
(x, y) if x == y => println!("equal"),
(x, y) if x + y == 0 => println!("opposite"),
_ => (),
}
// 忽略剩余部分 ..
let numbers = (1, 2, 3, 4);
match numbers {
(first, .., last) => println!("first={}, last={}", first, last),
}
}
// 闭包
fn closure_demo() {
let add_one = |x: i32| -> i32 { x + 1 };
let add_two = |x| x + 2; // 类型推断
let res = add_one(5);
// 捕获环境
let factor = 10;
let multiply = |x| x * factor; // 不可变借用
let mut count = 0;
let mut increment = || 
{ count += 1; count }; // 可变借用
// move 闭包（转移所有权）
let s = String::from("hello");
let consume = move || {
println!("{}", s);
// s 所有权移入闭包
};
consume();
// 高阶函数
let numbers = vec![1, 2, 3];
let doubled: Vec<_> = numbers.iter().map(|x| x * 2).collect();
}
fn control_flow() {
// if 表达式
let num = 3;
let result = 
if num > 0 
{ "positive" } else 
{ "non-positive" };
let result = 
if num > 0 
{ "positive" } else { "non-positive" };
// loop 循环（无限）
let mut count = 0;
let result = loop {
count += 1;
if count == 3 { break count * 2; }
};
// while
let mut n = 0;
while n < 3 {
n += 1;
}
// for 循环
for i in 0..3 {
print!("{} ", i);
}
// 迭代器 for
let arr = [10, 20, 30];
for elem in arr.iter() {
print!("{} ", elem);
}
// match 模式匹配（核心特性）
let value = 2;
match value {
1 => println!("one"),
2 | 3 => println!("two or three"),
4..=10 => println!("between 4 and 10"),
_ => println!("other"),
}
// if let 简洁匹配
let optional = Some(5);
if let Some(x) = optional {
println!("x is {}", x);
}
// while let
let mut stack = Vec::new();
stack.push(1);
while let Some(top) = stack.pop() {
println!("{}", top);
}
}
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
if x.len() > y.len() { x } else { y }
}
// 结构体中的生命周期
struct Excerpt<'a> {
part: &'a str,
}
let matrix: [[i32; 5]; 5] = [
[1, 2, 3, 4, 5],
[6, 7, 8, 9, 10],
[11, 12, 13, 14, 15],
[16, 17, 18, 19, 20],
[21, 22, 23, 24, 25],
];
/// 测试主逻辑
fn main() {
println!("=== Rust Format Test Start ===");
// 变量与可变性
let mut count = 0;
count += 1;
// 元组
let tuple = (100, "rust", true);
let (num, lang, flag) = tuple;
// 数组
let arr = [1, 2, 3, 4, 5];
let slice = &arr[1..3];
// 创建用户
let user1 = create_user(1, "Alice".into(), 20).unwrap();
let user2 = create_user(2, "Bob".into(), 25).unwrap();
let user_sum = user1 + user2;
println!("User1: {}", user1);
println!("User Sum: {: ?}", user_sum);
let container=Container:: new("test item");
println!("Container: {: ?}", container);
for i in 0..5{
println!("loop: {}", i);
}
while count<3{
count+=1;
}
let add=|a,b|a+b;
let _arr: [i32; 3] = [1, 2, 3];
let sum=add(10,20);
println!("closure sum: {}", sum);
let even_numbers=process_numbers();
println!("even numbers: {: ?}", even_numbers);
let status_str=check_status(&user1);
println!("user status: {}", status_str);
let s1="short";
let s2="longer string";
let longest=get_longest(s1,s2);
println!("longest: {}", longest);
if let Some(addr)=&user1.address{
println!("user address: {: ?}", addr);
}
println!("max value: {}", MAX_VALUE);
println!("service: {}", SERVICE_NAME);
println!("=== Rust Format Test End ===");
}
"#
        
    @TestCase
    func testRustFormat() {
        let output = codeFormat("rust", rustFormatTestCode, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/rustFormatTest.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr = String.fromUtf8(allBytes)
        @Assert(output, expectedStr.replace("\r\n","\n"))
    }
}
