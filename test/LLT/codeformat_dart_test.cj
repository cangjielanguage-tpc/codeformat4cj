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
    let formatDart = FormatDart()
    formatDart.testDartFormat()
    return 0
}

@Test
class FormatDart {
var dartFormatTestCode = #"
import 'dart:async';
import 'dart:collection';

// 自定义注解
class TestAnnotation {
final String description;
final int version;

const TestAnnotation(this.description, {this.version = 1});
}

// 枚举类型（增强枚举）
enum LogLevel {
debug('DEBUG', 1),
info('INFO', 2),
warning('WARNING', 3),
error('ERROR', 4),
critical('CRITICAL', 5);

final String name;
final int level;

const LogLevel(this.name, this.level);

bool isError() => level >= 4;
}

// 混入 Mixin
mixin LogMixin {
void log(String message, LogLevel level) {
print('[${level.name}] $message');
}

void logSimple(String message) => print('[LOG] $message');
}

// 接口类（抽象类）
abstract class ILogger {
void logMessage(String message);
Future<void> logAsync(String message);
}

// 泛型接口
abstract class IRepository<T> {
T? getById(int id);
void add(T entity);
List<T> getAll();
}

// 基类
class BaseEntity {
final int id;
final DateTime createTime;

BaseEntity({
required this.id,
DateTime? createTime,
}) : createTime = createTime ?? DateTime.now();

void validate() {
if (id <= 0) {
throw ArgumentError('ID must be greater than 0');
}
}

@override
String toString() => 'BaseEntity(id: $id, createTime: $createTime)';
}

// 实体类，继承 + 混入
@TestAnnotation('User entity class')
class User extends BaseEntity with LogMixin implements Comparable<User> {
String userName;
int age;
String? _password;

// 命名构造函数
User.create({
required super.id,
required this.userName,
required this.age,
});

// 命名构造函数重定向
User.guest(int id) : this.create(id: id, userName: 'Guest', age: 0);

// Getter & Setter
String? get password => _password;

set password(String? value) {
if (value != null && value.isNotEmpty) {
_password = value;
}
}

// 方法重写
@override
void validate() {
super.validate();
if (userName.isEmpty) {
throw ArgumentError('Username cannot be empty');
}
if (age < 0 || age > 150) {
throw ArgumentError('Age must be between 0 and 150');
}
}

// 实现接口方法
@override
int compareTo(User other) => age.compareTo(other.age);

// 方法重载（Dart 不支持重载，使用可选参数模拟）
void updateName(String newName, [int? newAge]) {
userName = newName;
if (newAge != null) {
age = newAge;
}
}

// 命名参数方法
void updateInfo({required String newName, int? newAge}) {
userName = newName;
if (newAge != null) {
age = newAge;
}
}

@override
String toString() => 'User(id: $id, name: $userName, age: $age)';
}

// 泛型实现类
class UserRepository implements IRepository<User> {
final List<User> _users = [];

@override
User? getById(int id) => _users.firstWhereOrNull((u) => u.id == id);

@override
void add(User entity) {
if (entity == null) throw ArgumentError.notNull('entity');
_users.add(entity);
}

@override
List<User> getAll() => List.unmodifiable(_users);

// 泛型方法
List<T> filter<T>(List<T> list, bool Function(T) test) {
return list.where(test).toList();
}
}

// 扩展方法
extension UserListExtension on List<User> {
List<User> get adults => where((u) => u.age >= 18).toList();
List<User> sortByAge() => this..sort((a, b) => a.age.compareTo(b.age));
}

// 扩展函数
extension StringExtension on String {
bool get isBlank => trim().isEmpty;
String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

// 顶级函数
void printWelcome() {
print('===== Dart Syntax Test Program =====');
}

// 闭包函数
Function makeAdder(int addBy) {
return (int i) => addBy + i;
}

// 异步函数
Future<void> simulateAsyncTask() async {
await Future.delayed(const Duration(milliseconds: 100));
}

// Stream 函数
Stream<int> countStream(int max) async* {
for (int i = 1; i <= max; i++) {
await Future.delayed(const Duration(milliseconds: 50));
yield i;
}
}

// 主测试类
class DartSyntaxTest with LogMixin {
// 常量
static const appName = 'DartTest';
// 静态变量
static int runCount = 0;

late final DateTime _startTime;

DartSyntaxTest() {
_startTime = DateTime.now();
runCount++;
}

// 主测试入口
Future<void> runAllTests() async {
printWelcome();
log('Test started at: $_startTime', LogLevel.info);

await testEnum();
await testClassAndObject();
await testGeneric();
testClosure();
await testAsync();
await testStream();
testCollection();
testFlowControl();
testExtension();
testErrorHandling();

final duration = DateTime.now().difference(_startTime);
log('Test finished in ${duration.inMilliseconds}ms', LogLevel.info);
log('Total runs: $runCount', LogLevel.info);
}

// 测试枚举
Future<void> testEnum() async {
logSimple('--- Testing Enum ---');
final level = LogLevel.error;
print('Level: ${level.name}, isError: ${level.isError()}');
await simulateAsyncTask();
}

// 测试类与对象
Future<void> testClassAndObject() async {
logSimple('--- Testing Class & Object ---');
final user1 = User.create(id: 1, userName: 'alice', age: 25);
final user2 = User.guest(2);
final user3 = User.create(id: 3, userName: 'bob', age: 17);

user1.password = '123456';
user1.validate();

user1.updateName('Alice');
user1.updateInfo(newName: 'Alice Smith', newAge: 26);

print(user1);
print(user2);
await simulateAsyncTask();
}

// 测试泛型
Future<void> testGeneric() async {
logSimple('--- Testing Generic ---');
final repo = UserRepository();
repo.add(User.create(id: 1, userName: 'alice', age: 25));
repo.add(User.create(id: 2, userName: 'bob', age: 30));

final user = repo.getById(1);
print('Found user: $user');
print('All users: ${repo.getAll()}');
await simulateAsyncTask();
}

// 测试闭包
void testClosure() {
logSimple('--- Testing Closure ---');
final add2 = makeAdder(2);
final add5 = makeAdder(5);
print('add2(3): ${add2(3)}');
print('add5(3): ${add5(3)}');
}

// 测试异步
Future<void> testAsync() async {
logSimple('--- Testing Async/Await ---');
await simulateAsyncTask();
print('Async task completed');
}

// 测试Stream
Future<void> testStream() async {
logSimple('--- Testing Stream ---');
await for (final i in countStream(3)) {
print('Stream count: $i');
}
}

// 测试集合
void testCollection() {
logSimple('--- Testing Collection ---');

// List
final List<int> numbers = [1, 2, 3, 4, 5];
final evenNumbers = numbers.where((n) => n.isEven).toList();

// Map
final Map<String, dynamic> userMap = {
'id': 1,
'name': 'Test',
'age': 20,
};

// Set
final Set<String> uniqueNames = {'alice', 'bob', 'alice'};

// Queue
final queue = Queue<int>()..add(1)..add(2);

print('Even numbers: $evenNumbers');
print('Unique names: $uniqueNames');
}

// 测试流程控制
void testFlowControl() {
logSimple('--- Testing Flow Control ---');

// For loop
for (int i = 0; i < 3; i++) {
print('For loop: $i');
}

// For in
final list = [10, 20, 30];
for (final item in list) {
print('For in: $item');
}

// While
int count = 0;
while (count < 2) {
print('While: $count');
count++;
}

// Switch
final level = LogLevel.info;
switch (level) {
case LogLevel.debug:
print('Debug log');
break;
case LogLevel.info:
print('Info log');
break;
default:
print('Other log');
}

// 三元运算符
final status = count > 0 ? 'Running' : 'Stopped';
print('Status: $status');
}

// 测试扩展方法
void testExtension() {
logSimple('--- Testing Extension ---');
final str = 'hello dart';
print('Capitalized: ${str.capitalize()}');
print('Is blank: ${str.isBlank}');

final users = [
User.create(id: 1, userName: 'alice', age: 17),
User.create(id: 2, userName: 'bob', age: 22),
];

print('Adults: ${users.adults}');
print('Sorted: ${users.sortByAge()}');
}

// 测试异常处理
void testErrorHandling() {
logSimple('--- Testing Error Handling ---');
try {
final user = User.create(id: -1, userName: '', age: 200);
user.validate();
} on ArgumentError catch (e) {
log('Caught error: ${e.message}', LogLevel.error);
} catch (e) {
log('Unknown error: $e', LogLevel.critical);
}
}
}

// 程序入口
void main() async {
final test = DartSyntaxTest();
await test.runAllTests();

final test2 = DartSyntaxTest();
await test2.runAllTests();
}
"#
        
    @TestCase
    func testDartFormat() {
        let output = codeFormat("dart", dartFormatTestCode, FormatConfig(useTab: false, indentWidth: 2))
        let filePath: Path = Path("../../../test/LLT/dartFormatTest.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr = String.fromUtf8(allBytes)
        @Assert(output, expectedStr.replace("\r\n","\n"))
    }
}
