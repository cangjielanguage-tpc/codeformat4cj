package codeformat

internal import std.collection.ArrayList

// 辅助函数：根据配置添加对应缩进
func addIndent(codeBuilder: StringBuilder, level: Int64, cfg: FormatConfig) {
    if (level <= 0) {
        return
    }
    if (cfg.useTab) {
        for (_ in 0..level) {
            codeBuilder.append("\t") // 制表符缩进
        }
    } else {
        for (_ in 0..cfg.indentWidth * level) {
            codeBuilder.append(" ") // 空格缩进
        }
    }
}

//去除废弃的lineBean
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
            //如果这种情况#include<stdio.h>       
            if (item.codeLine.trimAscii().startsWith("#include") && !item.codeLine.contains("#include ")) {
                item.codeLine = item.codeLine.replace("#include", "#include ")
            }
            //对宏的行进行处理
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


/**
 * 字符串截取工具类
 * 
 * 功能说明：
 * - 支持两种截取方式：
 *   1. 传入两个参数：截取 [beginIndex, endIndex) 范围的子串
 *   2. 传入一个参数：截取从 beginIndex 到字符串末尾的子串
 * 
 */
extend String {
  
    /**
     * 字符串截取方法（两个参数版本）
     * 截取范围：[beginIndex, endIndex)，包含 beginIndex，不包含 endIndex
     * 
     * @param str 原始字符串
     * @param beginIndex 起始索引（包含）
     * @param endIndex 结束索引（不包含）
     * @return 截取后的子串
     */
    func substring(beginIndex: Int64, endIndex: Int64): String {
        let strLen = this.size
        
        // 参数校验：索引不能为负数
        if (beginIndex < 0 || endIndex < 0) {
            return this
        }
        
        // 参数校验：起始索引不能大于结束索引
        if (beginIndex >= endIndex) {
            return ""
        }
        
        // 参数校验：起始索引超出范围
        if (beginIndex >= strLen) {
            return ""
        }
        
        // 结束索引超出范围时，截断到字符串末尾
        let actualEndIndex = if (endIndex > strLen) { strLen } else { endIndex }
        
        // 手动拼接子串
        let sb = StringBuilder()
        for (i in beginIndex..actualEndIndex) {
            sb.append(fromUtf8(this.get(i).getOrThrow()))
        }
        return sb.toString()
    }
    
    /**
     * 字符串截取方法（一个参数版本）
     * 截取范围：[beginIndex, str.size)，从 beginIndex 到字符串末尾
     * 
     * @param str 原始字符串
     * @param beginIndex 起始索引（包含）
     * @return 截取后的子串
     */
    func substring(beginIndex: Int64): String {
        let strLen = this.size
        
        // 参数校验：索引不能为负数
        if (beginIndex < 0) {
            return this
        }
        
        // 参数校验：起始索引超出范围
        if (beginIndex >= strLen) {
            return ""
        }
        
        // 手动拼接子串（从 beginIndex 到末尾）
        let sb = StringBuilder()
        for (i in beginIndex..strLen) {
            sb.append(fromUtf8(this.get(i).getOrThrow()))
        }
        return sb.toString()
    }
}