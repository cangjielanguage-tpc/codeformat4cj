// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashCommentInput = #"
#!/bin/bash
# Top level comment
echo "hello"
if [ -f "/tmp/test" ]; then
# Comment inside if
echo "file exists"
# Another comment
fi
for i in 1 2 3; do
# Comment inside for
echo "$i"
done
while [ -n "$var" ]; do
# Comment inside while
echo "loop"
done
case "$x" in
start)
# Comment inside case
echo "starting"
;;
stop)
echo "stopping"
# Trailing comment in case
;;
esac
{
# Comment inside block
echo "block content"
}
"#

var bashCommentExpected = #"
#!/bin/bash
# Top level comment
echo "hello"
if [ -f "/tmp/test" ]; then
    # Comment inside if
    echo "file exists"
    # Another comment
fi
for i in 1 2 3; do
    # Comment inside for
    echo "$i"
done
while [ -n "$var" ]; do
    # Comment inside while
    echo "loop"
done
case "$x" in
    start)
        # Comment inside case
        echo "starting"
        ;;
    stop)
        echo "stopping"
        # Trailing comment in case
        ;;
esac
{
    # Comment inside block
    echo "block content"
}
"#

@Test
func testBashComment() {
    let output = codeFormat("bash", bashCommentInput, FormatConfig())
    println(output)
    @Assert(output, bashCommentExpected)
}
