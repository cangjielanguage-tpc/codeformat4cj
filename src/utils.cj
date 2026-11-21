package codeformat

internal import std.collection.ArrayList

// SEC-M2: indentation amplification caps. indentLevel accumulates linearly with
// unmatched braces / colons / then / do keywords (per-language increment sites) and
// used to be multiplied verbatim into the per-line indent: output size O(lines x level),
// so a ~100 KB input of unclosed blocks produced GB-scale output (memory exhaustion /
// host hang). addIndent is the SINGLE emission choke point shared by every language
// formatter, so capping the operands here bounds every language's output to
// O(lines x MAX_INDENT_LEVEL x MAX_INDENT_WIDTH) without touching any of the
// per-language increment sites. Operands are clamped BEFORE the multiplication,
// which also makes Int64 overflow (OverflowException) structurally impossible.
const MAX_INDENT_LEVEL: Int64 = 64
const MAX_INDENT_WIDTH: Int64 = 64

func addIndent(codeBuilder: StringBuilder, level: Int64, cfg: FormatConfig) {
    if (level <= 0) {
        return
    }
    let safeLevel = if (level > MAX_INDENT_LEVEL) { MAX_INDENT_LEVEL } else { level }
    if (cfg.useTab) {
        for (_ in 0..safeLevel) {
            codeBuilder.append("\t")
        }
    } else {
        let width = if (cfg.indentWidth > MAX_INDENT_WIDTH) { MAX_INDENT_WIDTH } else { cfg.indentWidth }
        for (_ in 0..width * safeLevel) {
            codeBuilder.append(" ")
        }
    }
}

func removediscard(stateBean: StateBean): Unit {
    let usefulList: ArrayList<LineBean> = ArrayList<LineBean>()
    for (item in stateBean.linesList) {
        if (!item.isDiscarded) {
            usefulList.add(item)
        }
    }
    stateBean.linesList = usefulList
}

func removeOnlyChangeLine(stateBean: StateBean): Unit {
    let usefulList: ArrayList<LineBean> = ArrayList<LineBean>()
    for (item in stateBean.linesList) {
        if (item.codeLine.trimAscii().size > 0) {
            usefulList.add(item)
        }
    }
    stateBean.linesList = usefulList
}

func modifyMacroAndSpace(stateBean: StateBean): Unit {
    for (item in stateBean.linesList) {
        if (item.codeLine.trimAscii().startsWith("#")) {
            if (item.codeLine.trimAscii().startsWith("#include") && !item.codeLine.contains("#include ")) {
                item.codeLine = item.codeLine.replace("#include", "#include ")
            }
            let array = item.codeLine.split(" ", 2, removeEmpty: true)
            if (array.size > 1) {
                item.codeLine = array[0] + " " + array[1]
            } else {
                item.codeLine = array[0]
            }
        }
    }
}

public func codeFormat(languageType: ?String, code: String, cfg: FormatConfig): String {
    if (let Some(i) <- languageType) {
        let result = match (i.toAsciiLower()) {
            case "c" | "cpp" | "c++" | "clike" | "objective-c" | "objective-c++" => CandJavaLikeFormat().formatCode(code, cfg)
            case "java" => CandJavaLikeFormat().formatCode(code, cfg)
            case "js" | "ts" | "javascript" | "typescript" => CandJavaLikeFormat().formatCode(code, cfg)
            case "python" | "python3" | "py" | "py3" | "python ml" | "pythonml" | "pandas" | "pythondata" => PythonFormat().formatCode(code, cfg)
            case "go"| "golang" => GoFormat().formatCode(code, cfg)
            case "kotlin" | "kt" => KotlinFormat().formatCode(code, cfg)
            case "php" => PhpFormat().formatCode(code, cfg)
            case "scala" => ScalaFormat().formatCode(code, cfg)
            case "csharp" | "c#"=> CsharpFormat().formatCode(code, cfg)
            case "swift" => SwiftFormat().formatCode(code, cfg)
            case "dart" => DartFormat().formatCode(code, cfg)
            case "cangjie" => CangjieFormat().formatCode(code, cfg)
            case "rust" => RustFormat().formatCode(code, cfg)
            case "bash" | "sh" | "shell" | "shellscript" => BashFormat().formatCode(code, cfg)
            case "html"| "html5" => HtmlFormat().formatCode(code, cfg)
            case "sql" | "mysql" | "oracle" | "oraclesql"| "sqlserver" | "ms sql server" | "mssql" | "postgresql" | "pgsql" => SqlFormat().formatCode(code, cfg)
            case _ => return code
        }
        return result.replace("\r\n","\n")
    } else {
        return code
    }
}

extend String {
    // SEC-L2 fix: rune-granularity slicing - the old implementation indexed UTF-8
    // bytes (this.get(i)) and re-assembled them byte-by-byte via fromUtf8, which
    // corrupted multi-byte characters (e.g. Chinese) inside the range. Rune indexing
    // keeps every character intact; behavior is unchanged for ASCII input
    // (1 byte == 1 rune), which covers all current call sites.
    func substring(beginIndex: Int64, endIndex: Int64): String {
        let runeArr = this.toRuneArray()
        let runeLen = runeArr.size
        if (beginIndex < 0 || endIndex < 0) {
            return this
        }
        if (beginIndex >= endIndex) {
            return ""
        }
        if (beginIndex >= runeLen) {
            return ""
        }
        let actualEndIndex = if (endIndex > runeLen) { runeLen } else { endIndex }
        let sb = StringBuilder()
        for (i in beginIndex..actualEndIndex) {
            sb.append(runeArr[i])
        }
        return sb.toString()
    }

    func substring(beginIndex: Int64): String {
        let runeArr = this.toRuneArray()
        let runeLen = runeArr.size
        if (beginIndex < 0) {
            return this
        }
        if (beginIndex >= runeLen) {
            return ""
        }
        let sb = StringBuilder()
        for (i in beginIndex..runeLen) {
            sb.append(runeArr[i])
        }
        return sb.toString()
    }
}
