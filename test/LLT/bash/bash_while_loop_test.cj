// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var whileLoopInput = #"
#!/bin/bash
while [ $count -lt 10 ]; do
echo "Count: $count"
count=$((count + 1))
done
"#

var whileLoopExpected = #"
#!/bin/bash
while [ $count -lt 10 ]; do
    echo "Count: $count"
    count=$((count + 1))
done
"#

@Test
func testWhileLoop() {
    let output = codeFormat("bash", whileLoopInput, FormatConfig())
    println(output)
    @Assert(output, whileLoopExpected)
}