package codeformat

internal import std.collection.ArrayList

func addIndent(codeBuilder: StringBuilder, level: Int64, cfg: FormatConfig) {
    if (level <= 0) {
        return
    }
    if (cfg.useTab) {
        for (_ in 0..level) {
            codeBuilder.append("\t")
        }
    } else {
        for (_ in 0..cfg.indentWidth * level) {
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
    func substring(beginIndex: Int64, endIndex: Int64): String {
        let strLen = this.size
        if (beginIndex < 0 || endIndex < 0) {
            return this
        }
        if (beginIndex >= endIndex) {
            return ""
        }
        if (beginIndex >= strLen) {
            return ""
        }
        let actualEndIndex = if (endIndex > strLen) { strLen } else { endIndex }
        let sb = StringBuilder()
        for (i in beginIndex..actualEndIndex) {
            sb.append(fromUtf8(this.get(i).getOrThrow()))
        }
        return sb.toString()
    }

    func substring(beginIndex: Int64): String {
        let strLen = this.size
        if (beginIndex < 0) {
            return this
        }
        if (beginIndex >= strLen) {
            return ""
        }
        let sb = StringBuilder()
        for (i in beginIndex..strLen) {
            sb.append(fromUtf8(this.get(i).getOrThrow()))
        }
        return sb.toString()
    }
}
