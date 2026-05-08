// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashIfInput = #"
#!/bin/bash
if [ -f "$1" ]; then
echo "File exists"
elif [ -d "$1" ]; then
echo "Directory exists"
else
echo "Not found"
fi
"#

var bashIfExpected = #"
#!/bin/bash
if [ -f "$1" ]; then
    echo "File exists"
elif [ -d "$1" ]; then
    echo "Directory exists"
else
    echo "Not found"
fi
"#

@Test
func testBashIf() {
    let output = codeFormat("bash", bashIfInput, FormatConfig())
    println(output)
    @Assert(output, bashIfExpected)
}