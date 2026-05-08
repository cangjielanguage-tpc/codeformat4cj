// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var minLoopInput = #"
while true; do
echo "test"
done
"#

var minLoopExpected = #"
while true; do
    echo "test"
done
"#

@Test
func testMinLoop() {
    let output = codeFormat("bash", minLoopInput, FormatConfig())
    println(output)
    @Assert(output, minLoopExpected)
}