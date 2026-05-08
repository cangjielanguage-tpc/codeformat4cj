// EXEC: cjc %import-path %L %l %f --test
// EXEC: ./main --no-progress --no-color 

package codeformat.test

import codeformat.*
import std.unittest.*
import std.unittest.testmacro.*

var bashComplexInput = #"
#!/bin/bash
set -e
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_FILE="${SCRIPT_DIR}/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
source "$CONFIG_FILE"
fi
function process_file() {
local file="$1"
local output="$2"
if [[ ! -f "$file" ]]; then
echo "Error: File not found: $file"
return 1
fi
cat <<EOF > "$output"
# Generated output
# Source: $file
EOF
cat "$file" >> "$output"
}
for arg in "$@"; do
case "$arg" in
--help)
echo "Usage: $0 [options]"
echo "Options:"
echo "  --help     Show this help"
echo "  --version  Show version"
exit 0
;;
--version)
echo "Version 1.0.0"
exit 0
;;
--)
shift
break
;;
*)
echo "Unknown option: $arg"
exit 1
;;
esac
done
while [[ $# -gt 0 ]]; do
process_file "$1" "${1}.out"
shift
done
echo "Processing complete"
"#

var bashComplexExpected = #"
#!/bin/bash
set -e
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_FILE="${SCRIPT_DIR}/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi
function process_file() {
    local file="$1"
    local output="$2"
    if [[ ! -f "$file" ]]; then
        echo "Error: File not found: $file"
        return 1
    fi
    cat <<EOF > "$output"
# Generated output
# Source: $file
EOF
    cat "$file" >> "$output"
}
for arg in "$@"; do
    case "$arg" in
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --help     Show this help"
            echo "  --version  Show version"
            exit 0
            ;;
        --version)
            echo "Version 1.0.0"
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unknown option: $arg"
            exit 1
            ;;
    esac
done
while [[ $# -gt 0 ]]; do
    process_file "$1" "${1}.out"
    shift
done
echo "Processing complete"
"#

@Test
func testBashComplex() {
    let output = codeFormat("bash", bashComplexInput, FormatConfig())
    println(output)
    @Assert(output, bashComplexExpected)
}