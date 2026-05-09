// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashFunctionNoParenInput = #"
#!/bin/bash
function foo {
echo "hello"
}
function bar {
if true; then
echo "nested"
fi
}
function baz {
for i in 1 2 3; do
echo "$i"
done
}
"#

var bashFunctionNoParenExpected = #"
#!/bin/bash
function foo {
    echo "hello"
}
function bar {
    if true; then
        echo "nested"
    fi
}
function baz {
    for i in 1 2 3; do
        echo "$i"
    done
}
"#

@Test
func testBashFunctionNoParen() {
    let output = codeFormat("bash", bashFunctionNoParenInput, FormatConfig())
    println(output)
    @Assert(output, bashFunctionNoParenExpected)
}
