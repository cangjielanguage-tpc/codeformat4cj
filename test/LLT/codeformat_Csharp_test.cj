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
    let formatCsharp = FormatCsharp()
    formatCsharp.testCsharpFormat()
    return 0
}

@Test
class FormatCsharp {
var csharpFormatTestCode = #"
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

// 自定义特性 - 测试特性语法
[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
public class TestAttribute : Attribute
{
public string Description { get; }
public int Version { get; }

// 构造函数
public TestAttribute(string description, int version = 1)
{
Description = description;
Version = version;
}
}

// 枚举类型 - 测试枚举语法
public enum LogLevel
{
Debug,
Info,
Warning,
Error,
Critical
}

// 结构体 - 测试值类型语法
public struct Point
{
public int X { get; set; }
public int Y { get; set; }

// 结构体构造函数
public Point(int x, int y)
{
X = x;
Y = y;
}

// 重写ToString方法
public override string ToString()
{
return $"坐标：X={X}, Y={Y}";
}
}

// 接口 - 测试接口语法
public interface ILogger
{
void Log(string message, LogLevel level = LogLevel.Info);
Task LogAsync(string message);
}

// 泛型接口 - 测试泛型接口语法
public interface IRepository<T> where T : class
{
T GetById(int id);
void Add(T entity);
List<T> GetAll();
}

// 基类 - 测试继承、虚方法语法
public abstract class BaseEntity
{
public int Id { get; set; }
public DateTime CreateTime { get; set; }

// 抽象方法
public abstract void DisplayInfo();

// 虚方法
public virtual void Validate()
{
if (Id <= 0)
throw new ArgumentOutOfRangeException(nameof(Id), "ID必须大于0");
}
}

// 实现类 - 测试继承、接口实现、方法重写
[Test("用户实体类", 2)]
public class User : BaseEntity, IComparable<User>
{
// 自动属性
public string UserName { get; set; }
public int Age { get; set; }

// 私有字段
private string _password;

// 完整属性
public string Password
{
get => _password;
set
{
if (!string.IsNullOrEmpty(value))
_password = value;
}
}

// 静态构造函数
static User()
{
Console.WriteLine("User静态构造函数执行");
}

// 无参构造函数
public User()
{
CreateTime = DateTime.Now;
}

// 有参构造函数
public User(int id, string userName, int age) : this()
{
Id = id;
UserName = userName;
Age = age;
}

// 重写抽象方法
public override void DisplayInfo()
{
Console.WriteLine($"用户ID：{Id}，用户名：{UserName}，年龄：{Age}，创建时间：{CreateTime:yyyy-MM-dd}");
}

// 重写虚方法
public override void Validate()
{
base.Validate();
if (string.IsNullOrEmpty(UserName))
throw new ArgumentException("用户名不能为空");
if (Age < 0 || Age > 150)
throw new ArgumentOutOfRangeException(nameof(Age), "年龄必须在0-150之间");
}

// 实现接口方法
public int CompareTo(User other)
{
if (other == null) return 1;
return Age.CompareTo(other.Age);
}

// 方法重载
public void UpdateName(string newName)
{
UserName = newName;
}

public void UpdateName(string newName, int age)
{
UserName = newName;
Age = age;
}

// 重写ToString
public override string ToString()
{
return $"User[Id={Id}, Name={UserName}, Age={Age}]";
}
}

// 泛型类 - 测试泛型语法
public class UserRepository : IRepository<User>
{
private readonly List<User> _users = new List<User>();

public User GetById(int id)
{
return _users.FirstOrDefault(u => u.Id == id);
}

public void Add(User entity)
{
if (entity == null)
throw new ArgumentNullException(nameof(entity));
_users.Add(entity);
}

public List<User> GetAll()
{
return _users.ToList();
}

// 泛型方法
public List<T> Filter<T>(List<T> list, Func<T, bool> predicate) where T : class
{
return list.Where(predicate).ToList();
}
}

// 委托定义 - 测试委托语法
public delegate void MathOperation(int a, int b);

// 主测试类
public class CSharpSyntaxTest
{
// 常量
private const string AppName = "C#语法测试程序";
// 只读字段
private readonly DateTime _runTime = DateTime.Now;

// 异步方法 - 测试async/await语法
public async Task RunTestAsync()
{
Console.WriteLine($"===== {AppName} 开始执行 =====");
Console.WriteLine($"运行时间：{_runTime:yyyy-MM-dd HH:mm:ss}\n");

// 测试结构体
TestStruct();

// 测试类与对象
await TestClassAndObjectAsync();

// 测试泛型
TestGeneric();

// 测试委托与事件
TestDelegate();

// 测试LINQ
TestLinq();

// 测试流程控制
TestFlowControl();

Console.WriteLine("\n===== 所有测试执行完成 =====");
}

// 测试结构体
private void TestStruct()
{
Console.WriteLine("----- 测试结构体 -----");
Point point = new Point(10, 20);
Console.WriteLine(point);
Console.WriteLine();
}

// 测试类与对象（异步）
private async Task TestClassAndObjectAsync()
{
Console.WriteLine("----- 测试类、继承、接口、异步 -----");
try
{
User user1 = new User(1, "张三", 25);
User user2 = new User(2, "李四", 30);

user1.DisplayInfo();
user2.DisplayInfo();

user1.Validate();
user2.Validate();

// 异步日志
ILogger logger = new ConsoleLogger();
await logger.LogAsync("用户创建成功");
}
catch (Exception ex)
{
Console.WriteLine($"异常：{ex.Message}");
}
Console.WriteLine();
}

// 测试泛型
private void TestGeneric()
{
Console.WriteLine("----- 测试泛型 -----");
UserRepository repository = new UserRepository();
repository.Add(new User(1, "张三", 25));
repository.Add(new User(2, "李四", 30));

var user = repository.GetById(1);
Console.WriteLine($"查询到用户：{user}");

var allUsers = repository.GetAll();
Console.WriteLine($"总用户数：{allUsers.Count}");
Console.WriteLine();
}

// 测试委托
private void TestDelegate()
{
Console.WriteLine("----- 测试委托 -----");
MathOperation operation = AddNumbers;
operation += MultiplyNumbers;

operation(10, 5);
Console.WriteLine();
}

// 测试LINQ
private void TestLinq()
{
Console.WriteLine("----- 测试LINQ -----");
List<User> users = new List<User>
{
new User(1, "张三", 25),
new User(2, "李四", 30),
new User(3, "王五", 20),
new User(4, "赵六", 35)
};

// LINQ查询语法
var youngUsers = from u in users
where u.Age < 30
orderby u.Age
select u;

Console.WriteLine("年龄小于30的用户：");
foreach (var u in youngUsers)
Console.WriteLine(u);

// LINQ方法语法
var adultUsers = users.Where(u => u.Age >= 18).ToList();
Console.WriteLine($"成年用户数量：{adultUsers.Count}");
Console.WriteLine();
}

// 测试流程控制
private void TestFlowControl()
{
Console.WriteLine("----- 测试流程控制 -----");
// for循环
for (int i = 0; i < 3; i++)
Console.WriteLine($"for循环：{i}");

// foreach循环
int[] numbers = { 1, 2, 3, 4, 5 };
foreach (var num in numbers)
Console.WriteLine($"foreach循环：{num}");

// while循环
int count = 0;
while (count < 2)
{
Console.WriteLine($"while循环：{count}");
count++;
}

// switch语句
LogLevel level = LogLevel.Error;
switch (level)
{
case LogLevel.Debug:
Console.WriteLine("调试日志");
break;
case LogLevel.Info:
Console.WriteLine("信息日志");
break;
case LogLevel.Error:
Console.WriteLine("错误日志");
break;
default:
Console.WriteLine("其他日志");
break;
}

// 三元运算符
string status = count > 0 ? "已执行" : "未执行";
Console.WriteLine($"状态：{status}");
}

// 委托绑定方法1
private void AddNumbers(int a, int b)
{
Console.WriteLine($"{a} + {b} = {a + b}");
}

// 委托绑定方法2
private void MultiplyNumbers(int a, int b)
{
Console.WriteLine($"{a} * {b} = {a * b}");
}

// 程序入口
public static async Task Main(string[] args)
{
CSharpSyntaxTest test = new CSharpSyntaxTest();
await test.RunTestAsync();
}
}

// 日志实现类
public class ConsoleLogger : ILogger
{
public void Log(string message, LogLevel level = LogLevel.Info)
{
Console.WriteLine($"[{level}] {message}");
}

public async Task LogAsync(string message)
{
await Task.Delay(100); // 模拟异步操作
Console.WriteLine($"[异步日志] {message}");
}
}
"#
        
    @TestCase
    func testCsharpFormat() {
        let output = codeFormat("c#", csharpFormatTestCode, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/CsharpFormatTest.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr = String.fromUtf8(allBytes)
        @Assert(output, expectedStr.replace("\r\n","\n"))
    }
}
