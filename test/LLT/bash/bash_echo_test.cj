// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashUntilInput = "cat << EOF\r\nline 1\r\nline 2\r\nline 3\r\nEOF"

var bashUntilExpected = "cat << EOF\nline 1\nline 2\nline 3\nEOF"

@Test
func test1() {
    let output = codeFormat("bash", bashUntilInput, FormatConfig())
    println(output)
    @Assert(output, bashUntilExpected)
}