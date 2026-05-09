// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashSubshellInput = #"
#!/bin/bash
(
cd /tmp
echo "In subshell: $(pwd)"
)

(
for i in 1 2 3; do
echo "Number: $i"
done
)
"#

var bashSubshellExpected = #"
#!/bin/bash
(
    cd /tmp
    echo "In subshell: $(pwd)"
)

(
    for i in 1 2 3; do
        echo "Number: $i"
    done
)
"#

@Test
func testBashSubshell() {
    let output = codeFormat("bash", bashSubshellInput, FormatConfig())
    println(output)
    @Assert(output, bashSubshellExpected)
}