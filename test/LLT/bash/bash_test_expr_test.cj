// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashTestExprInput = #"
#!/bin/bash
if [[ -f "$1" && -r "$1" ]]; then
echo "File exists and is readable"
fi

if [[ $str =~ ^[0-9]+$ ]]; then
echo "String is numeric"
fi

if [[ $a -gt $b ]]; then
echo "a is greater"
elif [[ $a -eq $b ]]; then
echo "a equals b"
else
echo "b is greater"
fi
"#

var bashTestExprExpected = #"
#!/bin/bash
if [[ -f "$1" && -r "$1" ]]; then
    echo "File exists and is readable"
fi

if [[ $str =~ ^[0-9]+$ ]]; then
    echo "String is numeric"
fi

if [[ $a -gt $b ]]; then
    echo "a is greater"
elif [[ $a -eq $b ]]; then
    echo "a equals b"
else
    echo "b is greater"
fi
"#

@Test
func testBashTestExpr() {
    let output = codeFormat("bash", bashTestExprInput, FormatConfig())
    println(output)
    @Assert(output, bashTestExprExpected)
}