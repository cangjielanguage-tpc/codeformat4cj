// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashAnsiStringInput = #"
#!/bin/bash
echo $'Hello\tWorld'
echo $'Line1\nLine2\nLine3'
printf $'Name:\t%s\n' "$USER"
echo $'Single\'quote'
echo $'Hex\x41\x42\x43'
echo $'Unicode\u0041\u0042'
"#

var bashAnsiStringExpected = #"
#!/bin/bash
echo $'Hello\tWorld'
echo $'Line1\nLine2\nLine3'
printf $'Name:\t%s\n' "$USER"
echo $'Single\'quote'
echo $'Hex\x41\x42\x43'
echo $'Unicode\u0041\u0042'
"#

@Test
func testBashAnsiString() {
    let output = codeFormat("bash", bashAnsiStringInput, FormatConfig())
    println(output)
    @Assert(output, bashAnsiStringExpected)
}
