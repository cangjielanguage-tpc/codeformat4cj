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
        File.writeTo("../../../test/LLT/rust.txt", output.toArray())
        @Assert(output, expectedStr.replace("\r\n","\n"))
    }
}
