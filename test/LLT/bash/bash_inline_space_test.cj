// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

/**
 * 行内空格格式化测试
 *
 * 考察点：
 * 1. 行首空白被去除（isLineStart 跳过）
 * 2. 行尾空白被去除（trimAscii()）
 * 3. 多个连续空格合并为一个（待实现）
 * 4. 管道符 | 两侧添加空格（addSpaceAround 待实现）
 * 5. 逻辑运算符 && / || 两侧添加空格（addSpaceAround 待实现）
 * 6. 分号 ; 后添加空格（如 ; then, ; do）
 * 7. 重定向符 > / < 前添加空格
 */

// ===== 用例1：多空格合并 =====
var inputMultiSpace = #"
echo    hello   world
if   true   ;   then
echo    spaced
fi
"#

var expectedMultiSpace = #"
echo hello world
if true; then
    echo spaced
fi
"#

// ===== 用例2：分号后空格（if;then）=====
var inputSemicolonThen = #"
if true;then
echo ok
fi
"#

var expectedSemicolonThen = #"
if true; then
    echo ok
fi
"#

// ===== 用例3：分号后空格（for;do）=====
var inputSemicolonDo = #"
for i in *;do
echo $i
done
"#

var expectedSemicolonDo = #"
for i in *; do
    echo $i
done
"#

// ===== 用例4：管道符两侧空格 =====
var inputPipe = #"
echo hello|grep h|wc -l
"#

var expectedPipe = #"
echo hello | grep h | wc -l
"#

// ===== 用例5：逻辑与 && 两侧空格 =====
var inputAnd = #"
test -n "$a"&&test -n "$b"
"#

var expectedAnd = #"
test -n "$a" && test -n "$b"
"#

// ===== 用例6：逻辑或 || 两侧空格 =====
var inputOr = #"
test -z "$a"||test -n "$b"
"#

var expectedOr = #"
test -z "$a" || test -n "$b"
"#

// ===== 用例7：重定向符前空格 =====
var inputRedirect = #"
echo hello>out.txt
cat<in.txt
echo world>>out.txt
"#

var expectedRedirect = #"
echo hello > out.txt
cat < in.txt
echo world >> out.txt
"#

// ===== 用例8：行首空白去除 =====
var inputTrimLeading = #"
    echo leading
  if true; then
        echo deep
  fi
"#

var expectedTrimLeading = #"
echo leading
if true; then
    echo deep
fi
"#

// ===== 用例9：行尾空白去除 =====
var inputTrimTrailing = #"
echo trailing    
echo another  
"#

var expectedTrimTrailing = #"
echo trailing
echo another
"#

// ===== 用例10：综合行内空格 =====
var inputMixed = #"
if [[ -n  "$a"  &&  -z  "$b"  ]];then
echo   mixed  inline   |  grep  pattern
fi
"#

var expectedMixed = #"
if [[ -n "$a" && -z "$b" ]]; then
    echo mixed inline | grep pattern
fi
"#

// ===== 测试函数 =====

@Test
func testMultiSpace() {
    let output = codeFormat("bash", inputMultiSpace, FormatConfig())
    println(output)
    @Assert(output, expectedMultiSpace)
}

@Test
func testSemicolonThen() {
    let output = codeFormat("bash", inputSemicolonThen, FormatConfig())
    println(output)
    @Assert(output, expectedSemicolonThen)
}

@Test
func testSemicolonDo() {
    let output = codeFormat("bash", inputSemicolonDo, FormatConfig())
    println(output)
    @Assert(output, expectedSemicolonDo)
}

@Test
func testPipeSpace() {
    let output = codeFormat("bash", inputPipe, FormatConfig())
    println(output)
    @Assert(output, expectedPipe)
}

@Test
func testAndSpace() {
    let output = codeFormat("bash", inputAnd, FormatConfig())
    println(output)
    @Assert(output, expectedAnd)
}

@Test
func testOrSpace() {
    let output = codeFormat("bash", inputOr, FormatConfig())
    println(output)
    @Assert(output, expectedOr)
}

@Test
func testRedirectSpace() {
    let output = codeFormat("bash", inputRedirect, FormatConfig())
    println(output)
    @Assert(output, expectedRedirect)
}

@Test
func testTrimLeading() {
    let output = codeFormat("bash", inputTrimLeading, FormatConfig())
    println(output)
    @Assert(output, expectedTrimLeading)
}

@Test
func testTrimTrailing() {
    let output = codeFormat("bash", inputTrimTrailing, FormatConfig())
    println(output)
    @Assert(output, expectedTrimTrailing)
}

@Test
func testMixedInline() {
    let output = codeFormat("bash", inputMixed, FormatConfig())
    println(output)
    @Assert(output, expectedMixed)
}
