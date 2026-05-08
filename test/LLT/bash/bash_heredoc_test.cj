// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashHeredocInput = #"
#!/bin/bash
cat <<EOF
This is a heredoc content.
It spans multiple lines.
EOF
cat <<-EOF
This content has leading tabs stripped.
	Line with tab
EOF
grep pattern <<'EOF'
$variable will not expand
$(command) will not run
EOF
"#

var bashHeredocExpected = #"
#!/bin/bash
cat <<EOF
This is a heredoc content.
It spans multiple lines.
EOF
cat <<-EOF
This content has leading tabs stripped.
	Line with tab
EOF
grep pattern <<'EOF'
$variable will not expand
$(command) will not run
EOF
"#

@Test
func testBashHeredoc() {
    let output = codeFormat("bash", bashHeredocInput, FormatConfig())
    println(output)
    @Assert(output, bashHeredocExpected)
}