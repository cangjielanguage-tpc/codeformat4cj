// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashArithmeticInput = #"
#!/bin/bash
x=5
y=10
((z = x + y))
echo "Sum: $z"

if (( x < y )); then
echo "x is less than y"
fi

for ((i=0; i<5; i++)); do
echo "Iteration $i"
done
"#

var bashArithmeticExpected = #"
#!/bin/bash
x=5
y=10
((z = x + y))
echo "Sum: $z"

if (( x < y )); then
    echo "x is less than y"
fi

for ((i=0; i<5; i++)); do
    echo "Iteration $i"
done
"#

@Test
func testBashArithmetic() {
    let output = codeFormat("bash", bashArithmeticInput, FormatConfig())
    println(output)
    @Assert(output, bashArithmeticExpected)
}