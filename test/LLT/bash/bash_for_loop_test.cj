// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashForLoopInput = #"
#!/bin/bash
for i in 1 2 3 4 5; do
echo "Number: $i"
done
for file in *.txt; do
cat "$file"
done
while [ $count -lt 10 ]; do
echo "Count: $count"
count=$((count + 1))
done
until [ $done -eq 1 ]; do
echo "Waiting..."
sleep 1
done
for ((i=0; i<5; i++)); do
echo "C-style loop: $i"
done
"#

var bashForLoopExpected = #"
#!/bin/bash
for i in 1 2 3 4 5; do
    echo "Number: $i"
done
for file in *.txt; do
    cat "$file"
done
while [ $count -lt 10 ]; do
    echo "Count: $count"
    count=$((count + 1))
done
until [ $done -eq 1 ]; do
    echo "Waiting..."
    sleep 1
done
for ((i=0; i<5; i++)); do
    echo "C-style loop: $i"
done
"#

@Test
func testBashForLoop() {
    let output = codeFormat("bash", bashForLoopInput, FormatConfig())
    println(output)
    @Assert(output, bashForLoopExpected)
}