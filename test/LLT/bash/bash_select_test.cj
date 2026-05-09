// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashSelectInput = #"
#!/bin/bash
select option in "Start" "Stop" "Restart"; do
case $REPLY in
1) echo "Starting";;
2) echo "Stopping";;
3) echo "Restarting";;
q) break;;
esac
done
"#

var bashSelectExpected = #"
#!/bin/bash
select option in "Start" "Stop" "Restart"; do
    case $REPLY in
        1) echo "Starting";;
        2) echo "Stopping";;
        3) echo "Restarting";;
        q) break;;
    esac
done
"#

@Test
func testBashSelect() {
    let output = codeFormat("bash", bashSelectInput, FormatConfig())
    println(output) // bashSelectInput以换行开头 output开发的换行没了 为什么
    println(bashSelectExpected)
    @Assert(output, bashSelectExpected)
}