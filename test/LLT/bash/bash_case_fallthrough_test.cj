// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashCaseFallthroughInput = #"
#!/bin/bash
case "$x" in
a)
echo "match a"
;;&
b)
echo "fall through from a"
;&
c)
echo "fall through from b"
;;
*)
echo "default"
;;
esac
"#

var bashCaseFallthroughExpected = #"
#!/bin/bash
case "$x" in
    a)
        echo "match a"
        ;;&
    b)
        echo "fall through from a"
        ;&
    c)
        echo "fall through from b"
        ;;
    *)
        echo "default"
        ;;
esac
"#

@Test
func testBashCaseFallthrough() {
    let output = codeFormat("bash", bashCaseFallthroughInput, FormatConfig())
    println(output)
    @Assert(output, bashCaseFallthroughExpected)
}
