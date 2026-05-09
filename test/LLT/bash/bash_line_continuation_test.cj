// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashLineContinuationInput = #"
#!/bin/bash
echo "This is a very long line that \
continues on the next line"
command1 && \
command2 && \
command3
long_var="value1 \
value2 \
value3"
"#

var bashLineContinuationExpected = #"
#!/bin/bash
echo "This is a very long line that \
continues on the next line"
command1 && \
command2 && \
command3
long_var="value1 \
value2 \
value3"
"#

@Test
func testBashLineContinuation() {
    let output = codeFormat("bash", bashLineContinuationInput, FormatConfig())
    println(output)
    @Assert(output, bashLineContinuationExpected)
}