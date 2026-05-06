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
    let formatSwift = FormatSwift()
    formatSwift.testSwiftFormat()
    return 0
}

@Test
class FormatSwift {
var swiftFormatTestCode = #"
import Foundation
import UIKit

// MARK: - 协议定义
protocol Identifiable {
var id: UUID { get }
}

protocol Actionable {
func execute() -> String
}

// MARK: - 枚举
enum UserStatus: Int, CaseIterable {
case active = 0
case inactive
case banned
case unknown

var description: String {
switch self {
case .active: return "活跃用户"
case .inactive: return "未活跃用户"
case .banned: return "已封禁"
case .unknown: return "未知状态"
}
}
}

// MARK: - 结构体
struct Address {
let street: String
let city: String
let zipCode: String

func fullAddress() -> String {
return "\(street), \(city) \(zipCode)"
}
}

// MARK: - 基类
class BaseModel: Identifiable {
let id: UUID = UUID()
var createTime: Date = Date()

init() {}
}

// MARK: - 主类
final class User: BaseModel, Actionable {
// MARK: Stored Properties
let name: String
let age: Int
var email: String?
var address: Address?
var status: UserStatus

// MARK: Computed Property
var isAdult: Bool {
return age >= 18
}

// MARK: 自定义初始化器
init(
name: String,
age: Int,
email: String?,
status: UserStatus
) {
self.name = name
self.age = age
self.email = email
self.status = status
super.init()
}

// MARK: 方法
func updateEmail(to newEmail: String) {
email = newEmail
}

func clearEmail() {
email = nil
}

func execute() -> String {
return "用户 \(name) 执行操作"
}

// MARK: 可选链式调用
func getAddressZip() -> String? {
return address?.zipCode
}
}

// MARK: - 扩展
extension User {
convenience init(name: String, age: Int) {
self.init(
name: name,
age: age,
email: nil,
status: .unknown
)
}
}

extension String {
func trimmed() -> String {
return trimmingCharacters(in: .whitespacesAndNewlines)
}
}

// MARK: - 泛型结构体
struct Box<T> {
let value: T

func unwrap() -> T {
return value
}
}

// MARK: - 泛型函数
func wrap<T>(_ value: T) -> Box<T> {
return Box(value: value)
}

// MARK: - 错误类型
enum NetworkError: Error {
case invalidURL
case requestFailed
case emptyResponse}

// MARK: - 错误抛出函数
func fetchData(from urlString: String) throws -> Data {
guard let url = URL(string: urlString) else {
throw NetworkError.invalidURL
}

do {
return try Data(contentsOf: url)
} catch {
throw NetworkError.requestFailed
}
}

// MARK: - 闭包 & 高阶函数
func calculate(
a: Int,
b: Int,
operation: (Int, Int) -> Int
) -> Int {
return operation(a, b)
}

let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
let evenNumbers = numbers.filter { $0 % 2 == 0 }
let doubledNumbers = numbers.map { $0 * 2 }
let sumTotal = numbers.reduce(0, +)

// MARK: - 控制流
func checkNumber(_ number: Int) -> String {
if number < 0 {
return "负数"
} else if number == 0 {
return "零"
} else if number < 10 {
return "个位数"
} else if number < 100 {
return "两位数"
} else {
return "大数"
}
}

func printLoop() {
for number in 1...5 {
print("数字: \(number)")
}

var count = 0
while count < 3 {
defer { count += 1 }
print("循环计数: \(count)")
}
}

// MARK: - 可选项处理
func unwrapString(_ optionalString: String?) -> String {
guard let str = optionalString else {
return "空字符串"
}
return str
}

// MARK: - 类扩展方法演示
let user = User(name: "张三", age: 25)
user.updateEmail(to: "test@example.com")
let boxedInt = wrap(100)
let boxedString = wrap("测试格式化")

// MARK: - 多返回值（元组）
func getUserInfo() -> (name: String, age: Int, email: String?) {
return ("李四", 30, "lisi@example.com")
}

// MARK: - 嵌套类型
struct App {
enum Theme {
case light
case dark
case system
}

let name: String
let theme: Theme
}

// MARK: - 惰性存储属性
class LazyTest {
lazy var dateFormatter: DateFormatter = {
let formatter = DateFormatter()
formatter.dateStyle = .medium
formatter.timeStyle = .short
return formatter
}()
}

// MARK: - 下标脚本
struct TextCollection {
private var texts: [String]

init(texts: [String]) {
self.texts = texts
}

subscript(index: Int) -> String? {
get {
guard index >= 0, index < texts.count else {
return nil
}
return texts[index]
}
set {
guard let newValue = newValue, index >= 0, index < texts.count else {
return
}
texts[index] = newValue
}
}
}

// MARK: - 结果生成
let result1 = calculate(a: 10, b: 20) { $0 + $1 }
let result2 = calculate(a: 10, b: 5) { $0 - $1 }
let result3 = calculate(a: 10, b: 3) { $0 * $1 }

let textCollection = TextCollection(texts: ["A", "B", "C"])
let firstText = textCollection[0]

let info = getUserInfo()
let lazyDemo = LazyTest()
let app = App(name: "测试App", theme: .dark)
"#
        
    @TestCase
    func testSwiftFormat() {
        let output = codeFormat("swift", swiftFormatTestCode, FormatConfig())
        let filePath: Path = Path("../../../test/LLT/swiftFormatTest.txt")
        let allBytes: Array<Byte> = File.readFrom(filePath)
        let expectedStr = String.fromUtf8(allBytes)
        @Assert(output, expectedStr.replace("\r\n","\n"))
    }
}
