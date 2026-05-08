// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashBraceInput = #"
#!/bin/bash
{
echo "Block 1"
echo "Multiple commands"
}

{
var="test"
if [ -n "$var" ]; then
echo "Nested if"
fi
}
"#

var bashBraceExpected = #"
#!/bin/bash
{
    echo "Block 1"
    echo "Multiple commands"
}

{
    var="test"
    if [ -n "$var" ]; then
        echo "Nested if"
    fi
}
"#

@Test
func testBashBrace() {
    let output = codeFormat("bash", bashBraceInput, FormatConfig())
    println(output)
    @Assert(output, bashBraceExpected)
}