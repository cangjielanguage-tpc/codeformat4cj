// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashNestedInput = #"
#!/bin/bash
if [ -f config.sh ]; then
for var in VAR1 VAR2 VAR3; do
if [ -n "$var" ]; then
echo "Processing: $var"
fi
done
fi
while read line; do
case $line in
error*)
echo "Error: $line"
;;
warn*)
echo "Warning: $line"
;;
*)
echo "Info: $line"
;;
esac
done < logfile.txt
"#

var bashNestedExpected = #"
#!/bin/bash
if [ -f config.sh ]; then
    for var in VAR1 VAR2 VAR3; do
        if [ -n "$var" ]; then
            echo "Processing: $var"
        fi
    done
fi
while read line; do
    case $line in
        error*)
            echo "Error: $line"
            ;;
        warn*)
            echo "Warning: $line"
            ;;
        *)
            echo "Info: $line"
            ;;
    esac
done < logfile.txt
"#

@Test
func testBashNested() {
    let output = codeFormat("bash", bashNestedInput, FormatConfig())
    println(output)
    @Assert(output, bashNestedExpected)
}