// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashFunctionInput = #"
#!/bin/bash
function greet() {
echo "Hello, $1"
}
greet "World"
myfunc() {
local var="local value"
echo "$var"
return 0
}
"#

var bashFunctionExpected = #"
#!/bin/bash
function greet() {
    echo "Hello, $1"
}
greet "World"
myfunc() {
    local var="local value"
    echo "$var"
    return 0
}
"#

@Test
func testBashFunction() {
    let output = codeFormat("bash", bashFunctionInput, FormatConfig())
    println(output)
    @Assert(output, bashFunctionExpected)
}