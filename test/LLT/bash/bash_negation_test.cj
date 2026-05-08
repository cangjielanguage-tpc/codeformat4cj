// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashNegationInput = #"
#!/bin/bash
if ! command -v foo; then
echo "not found"
fi
if ! [[ -f "$file" ]]; then
echo "no file"
fi
while ! ping -c1 host; do
sleep 1
done
until ! [[ "$x" == "$y" ]]; do
echo "not equal"
break
done
"#

var bashNegationExpected = #"
#!/bin/bash
if ! command -v foo; then
    echo "not found"
fi
if ! [[ -f "$file" ]]; then
    echo "no file"
fi
while ! ping -c1 host; do
    sleep 1
done
until ! [[ "$x" == "$y" ]]; do
    echo "not equal"
    break
done
"#

@Test
func testBashNegation() {
    let output = codeFormat("bash", bashNegationInput, FormatConfig())
    println(output)
    @Assert(output, bashNegationExpected)
}
