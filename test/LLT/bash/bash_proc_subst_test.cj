// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashProcSubstInput = #"
#!/bin/bash
diff <(echo hello) <(echo world)
cat <(cmd1) > >(cmd2)
while read line; do
echo "$line"
done < <(some_command)
diff <(sort a.txt) \
<(sort b.txt)
"#

var bashProcSubstExpected = #"
#!/bin/bash
diff <(echo hello) <(echo world)
cat <(cmd1) > >(cmd2)
while read line; do
    echo "$line"
done < <(some_command)
diff <(sort a.txt) \
    <(sort b.txt)
"#

@Test
func testBashProcSubst() {
    let output = codeFormat("bash", bashProcSubstInput, FormatConfig())
    println(output)
    @Assert(output, bashProcSubstExpected)
}
