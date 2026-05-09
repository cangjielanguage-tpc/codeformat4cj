// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashHereStringInput = #"
#!/bin/bash
cat <<< "hello world"
grep pattern <<< "some text"
read -r var <<< "value with spaces"
cat <<< "line1" <<< "line2"
"#

var bashHereStringExpected = #"
#!/bin/bash
cat <<< "hello world"
grep pattern <<< "some text"
read -r var <<< "value with spaces"
cat <<< "line1" <<< "line2"
"#

@Test
func testBashHereString() {
    let output = codeFormat("bash", bashHereStringInput, FormatConfig())
    println(output)
    @Assert(output, bashHereStringExpected)
}
