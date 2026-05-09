// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashCaseInput = #"
#!/bin/bash
case $1 in
start)
echo "Starting service"
service start
;;
stop)
echo "Stopping service"
service stop
;;
restart)
echo "Restarting service"
service stop
service start
;;
*)
echo "Usage: $0 {start|stop|restart}"
exit 1
;;
esac
"#

var bashCaseExpected = #"
#!/bin/bash
case $1 in
    start)
        echo "Starting service"
        service start
        ;;
    stop)
        echo "Stopping service"
        service stop
        ;;
    restart)
        echo "Restarting service"
        service stop
        service start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
"#

@Test
func testBashCase() {
    let output = codeFormat("bash", bashCaseInput, FormatConfig())
    println(output)
    @Assert(output, bashCaseExpected)
}