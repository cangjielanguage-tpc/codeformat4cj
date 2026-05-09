// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var twoLoopsInput = #"
while true; do
echo "first"
done
until false; do
echo "second"
done
"#

var twoLoopsExpected = #"
while true; do
    echo "first"
done
until false; do
    echo "second"
done
"#

@Test
func testTwoLoops() {
    let output = codeFormat("bash", twoLoopsInput, FormatConfig())
    println(output)
    @Assert(output, twoLoopsExpected)
}