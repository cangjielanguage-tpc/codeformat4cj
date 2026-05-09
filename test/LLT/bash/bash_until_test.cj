// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashUntilInput = #"
#!/bin/bash
count=0
until [ $count -eq 5 ]; do
echo "Count: $count"
count=$((count + 1))
done
"#

var bashUntilExpected = #"
#!/bin/bash
count=0
until [ $count -eq 5 ]; do
    echo "Count: $count"
    count=$((count + 1))
done
"#

@Test
func testBashUntil() {
    let output = codeFormat("bash", bashUntilInput, FormatConfig())
    println(output)
    @Assert(output, bashUntilExpected)
}