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