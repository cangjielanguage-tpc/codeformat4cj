// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var debugInput = #"
for ((i=0; i<5; i++)); do
echo "test"
done
"#

var debugExpected = #"
for ((i=0; i<5; i++)); do
    echo "test"
done
"#

@Test
func testDebug() {
    let output = codeFormat("bash", debugInput, FormatConfig())
    // println(output)
    @Assert(output, debugExpected)
}

var piplineInput = #"
# 6. 长命令换行 + 管道
echo hello world|grep h|awk '{print $1}'
cat file.txt | while read line;do echo $line;done

echo "hello world" \
| grep "h" \
| awk '{print $1}'
"#

var piplineExpected = #"
# 6. 长命令换行 + 管道
echo hello world | grep h | awk '{print $1}'
cat file.txt | while read line; do echo $line; done

echo "hello world" \
    | grep "h" \
    | awk '{print $1}'
"#

@Test
func piplineTest() {
    let output = codeFormat("bash", piplineInput, FormatConfig())
    println(output)
    @Assert(output, piplineExpected)
}

var func_if_input = #"
func_bad(){
if [ $a -eq 1 ]; then
 echo hi;   fi
}
"#

var func_if_expected = #"
func_bad(){
    if [ $a -eq 1 ]; then
        echo hi; fi
}
"#

@Test
func func_if_test() {
    let output = codeFormat("bash", func_if_input, FormatConfig())
    println(output)
    @Assert(output, func_if_expected)
}

var bash1_input = #"
#!/bin/bash
  # ==============================
# Bash 格式化测试用例集合
# 覆盖：缩进、空格、换行、注释、字符串、heredoc、数组、函数
# ==============================

# 1. 函数：混乱缩进 + 空格不规范
"#

var bash1_expected = #"
#!/bin/bash
# ==============================
# Bash 格式化测试用例集合
# 覆盖：缩进、空格、换行、注释、字符串、heredoc、数组、函数
# ==============================

# 1. 函数：混乱缩进 + 空格不规范
"#

@Test
func bash1_test() {
    let output = codeFormat("bash", bash1_input, FormatConfig())
    println(output)
    @Assert(output, bash1_expected)
}