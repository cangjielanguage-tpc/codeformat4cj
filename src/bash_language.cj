package codeformat

import std.collection.ArrayList

/**
 * Bash shell 脚本格式化器
 * 支持关键字缩进、Here-document、续行符、字符串等 Bash 特定语法
 * 参考 shfmt (mvdan/sh) 设计理念
 */
class BashFormat <: BaseLanguage {

    // 关键字栈：跟踪嵌套的 if/for/case 结构
    let ifStack: ArrayList<FlagBean> = ArrayList<FlagBean>() // if/elif/else/fi
    let loopStack: ArrayList<FlagBean> = ArrayList<FlagBean>() // for/while/until/done
    let caseStack: ArrayList<FlagBean> = ArrayList<FlagBean>() // case/esac

    // case分支状态：跟踪是否在case分支内
    var isInCaseBranch: Bool = false // 是否在 case分支内容中（pattern 之后）

    // Here-document 状态
    var isInHeredoc: Bool = false
    var heredocDelimiter: String = ""
    var heredocStripTabs: Bool = false // 是否使用 <<- (去除前导Tab)
    var isHeredocDeclarationLine: Bool = false // 标记当前行是heredoc声明行（<<EOF所在行）

    // 续行符状态
    var isInLineContinuation: Bool = false

    // 复合命令状态
    var isInDoubleBracket: Bool = false // [[ ]]
    var isInArithmetic: Bool = false // (( )) 或 $(( ))
    var doubleBracketCount: Int64 = 0
    var arithmeticCount: Int64 = 0

    // 命令替换状态
    var isInCommandSubstitution: Bool = false // $( )
    var commandSubCount: Int64 = 0

    // 算术扩展结束标记（用于跳过第二个 )）
    var skipNextRightParen: Bool = false

    // Shebang 状态
    var shebangProcessed: Bool = false // 标记 shebang 是否已处理

    // ==================== 关键字检测方法 ====================
    // 预缓存常用关键字的字节（避免重复toRuneArray）
    // IF_BYTES已删除（detectIf有特殊实现）
    private static let THEN_BYTES = unsafe { "then".rawData() }
    private static let ELIF_BYTES = unsafe { "elif".rawData() }
    private static let ELSE_BYTES = unsafe { "else".rawData() }
    private static let FI_BYTES = unsafe { "fi".rawData() }
    private static let FOR_BYTES = unsafe { "for".rawData() }
    private static let WHILE_BYTES = unsafe { "while".rawData() }
    private static let UNTIL_BYTES = unsafe { "until".rawData() }
    private static let SELECT_BYTES = unsafe { "select".rawData() }
    private static let DO_BYTES = unsafe { "do".rawData() }
    private static let DONE_BYTES = unsafe { "done".rawData() }
    private static let CASE_BYTES = unsafe { "case".rawData() }
    private static let ESAC_BYTES = unsafe { "esac".rawData() }
    private static let IN_BYTES = unsafe { "in".rawData() }

    /**
     * 检测并处理 if 关键字
     * 格式：if condition; then ... fi
     */
    public func detectIf(stateBean: StateBean): Bool {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        // 检测 "if "：currentIndex指向空格，chars[idx]=' ', chars[idx-1]='f', chars[idx-2]='i'
        if (idx >= 2 && chars[idx - 2] == r'i' && chars[idx - 1] == r'f' && chars[idx] == r' ') {
            let beforeValid = idx - 3 < 0 || !isAlphaNumeric(chars[idx - 3])
            return beforeValid
        }
        return false
    }

    /**
     * 通用关键字检测方法（使用预缓存字节）
     * 检测 currentIndex 指向的字符是否是 keyword 的最后一个字符
     */
    private func detectKeyword(stateBean: StateBean, keywordBytes: Array<Byte>): Bool {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        let klen = keywordBytes.size
        if (idx + 1 < klen) {
            return false
        }
        // 比较字节转换为Rune（ASCII字符：Byte值 == Rune值）
        for (i in 0..klen) {
            let keywordChar = Rune(keywordBytes[i])
            if (chars[idx - klen + 1 + i] != keywordChar) {
                return false
            }
        }
        return isWordBoundary(chars, idx - klen, idx + 1)
    }

    /**
     * 检测 then 关键字
     * then 后缩进增加一级
     */
    public func detectThen(stateBean: StateBean): Bool {
        detectKeyword(stateBean, THEN_BYTES)
    }

    public func detectElif(stateBean: StateBean): Bool {
        detectKeyword(stateBean, ELIF_BYTES)
    }

    public func detectElse(stateBean: StateBean): Bool {
        detectKeyword(stateBean, ELSE_BYTES)
    }

    public func detectFi(stateBean: StateBean): Bool {
        detectKeyword(stateBean, FI_BYTES)
    }

    public func detectFor(stateBean: StateBean): Bool {
        detectKeyword(stateBean, FOR_BYTES)
    }

    public func detectWhile(stateBean: StateBean): Bool {
        detectKeyword(stateBean, WHILE_BYTES)
    }

    public func detectUntil(stateBean: StateBean): Bool {
        detectKeyword(stateBean, UNTIL_BYTES)
    }

    public func detectSelect(stateBean: StateBean): Bool {
        detectKeyword(stateBean, SELECT_BYTES)
    }

    public func detectLoopType(stateBean: StateBean): String {
        if (detectKeyword(stateBean, FOR_BYTES)) {
            return "for"
        }
        if (detectKeyword(stateBean, WHILE_BYTES)) {
            return "while"
        }
        if (detectKeyword(stateBean, UNTIL_BYTES)) {
            return "until"
        }
        if (detectKeyword(stateBean, SELECT_BYTES)) {
            return "select"
        }
        return ""
    }

    public func detectDo(stateBean: StateBean): Bool {
        detectKeyword(stateBean, DO_BYTES)
    }

    public func detectDone(stateBean: StateBean): Bool {
        detectKeyword(stateBean, DONE_BYTES)
    }

    public func detectCase(stateBean: StateBean): Bool {
        detectKeyword(stateBean, CASE_BYTES)
    }

    public func detectEsac(stateBean: StateBean): Bool {
        detectKeyword(stateBean, ESAC_BYTES)
    }

    public func detectIn(stateBean: StateBean): Bool {
        detectKeyword(stateBean, IN_BYTES)
    }

    /**
     * 检测 ;;、;;&、;&（case 分支结束符）
     * 返回结束符类型：
     * - ";;" : 结束分支，跳到esac
     * - ";;&" : 结束分支，继续匹配
     * - ";&" : 执行下一分支
     * - "" : 不是结束符
     */
    public func detectCaseEnd(stateBean: StateBean): String {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex

        // 检测 ;;&
        if (idx >= 2 && chars[idx - 2] == r';' && chars[idx - 1] == r';' && chars[idx] == r'&') {
            return ";;&"
        }

        // 检测 ;&
        if (idx >= 1 && chars[idx - 1] == r';' && chars[idx] == r'&') {
            return ";&"
        }

        // 检测 ;;
        if (idx >= 1 && chars[idx - 1] == r';' && chars[idx] == r';') {
            return ";;"
        }

        return ""
    }

    // ==================== 边界检测辅助函数 ====================

    /**
     * 检测当前位置是否是换行符（支持 LF/CRLF/CR）
     */
    private func isNewline(chars: Array<Rune>, idx: Int64): Bool {
        if (idx >= chars.size) {
            return false
        }
        let c = chars[idx]
        if (c == r'\n') {
            return true
        }
        if (c == r'\r') {
            if (idx + 1 < chars.size && chars[idx + 1] == r'\n') {
                return true
            }
            return true
        }
        return false
    }

    /**
     * 获取换行符长度（LF=1, CRLF=2, CR=1）
     */
    private func getNewlineLength(chars: Array<Rune>, idx: Int64): Int64 {
        if (idx >= chars.size) {
            return 0
        }
        if (chars[idx] == r'\r' && idx + 1 < chars.size && chars[idx + 1] == r'\n') {
            return 2
        }
        if (chars[idx] == r'\n' || chars[idx] == r'\r') {
            return 1
        }
        return 0
    }

    /**
     * 检测字符串是否以换行符结尾（支持 LF/CRLF/CR）
     */
    private func isNewlineEnd(str: String): Bool {
        if (str.size == 0) {
            return false
        }
        let last = str[str.size - 1]
        if (last == b'\n' || last == b'\r') {
            return true
        }
        return false
    }

    /**
     * 检测单词边界（确保是完整关键字而非子字符串）
     * beforeIndex: 关键字前一个字符位置
     * afterIndex: 关键字后一个字符位置
     */
    private func isWordBoundary(chars: Array<Rune>, beforeIndex: Int64, afterIndex: Int64): Bool {
        let beforeValid = beforeIndex < 0 || (!isAlphaNumeric(chars[beforeIndex]) && chars[beforeIndex] != r'$')
        let afterValid = afterIndex >= chars.size || !isAlphaNumeric(chars[afterIndex])
        return beforeValid && afterValid
    }

    private func isAlphaNumeric(c: Rune): Bool {
        return (c >= r'a' && c <= r'z') || (c >= r'A' && c <= r'Z') || (c >= r'0' && c <= r'9')
    }

    // ==================== BaseLanguage 接口实现 ====================

    public override func dealWithNewLine(stateBean: StateBean): Unit {
        let lineBean = LineBean()
        var codeLine = stateBean.perLineOutput.toString()

        if (isInHeredoc && codeLine.size > 0 && isNewlineEnd(codeLine)) {
            // 直接检查并移除末尾换行符（避免toRuneArray）
            let bytes = unsafe { codeLine.rawData() }
            let last = bytes[bytes.size - 1]
            if (last == b'\n' || last == b'\r') {
                let removeLen = if (bytes.size > 1 && bytes[bytes.size - 2] == b'\r' && last == b'\n') {
                    2
                } else {
                    1
                }
                codeLine = unsafe { String.fromUtf8Unchecked(bytes[..bytes.size - removeLen]) }
            }
        }
        lineBean.codeLine = codeLine

        if (isInLineContinuation) {
            lineBean.indentLevel = stateBean.indentLevel
        } else if (isInHeredoc) {
            lineBean.indentLevel = 0 // heredoc内容行不缩进
            lineBean.isHeredocContent = true
        } else {
            lineBean.indentLevel = stateBean.savedIndentLevel
        }

        stateBean.linesList.add(lineBean)
        stateBean.perLineOutput = StringBuilder()
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'\n'
        stateBean.savedIndentLevel = stateBean.indentLevel // 换行后保存当前缩进

        if (isInLineContinuation && stateBean.lastChar != r'\\') {
            isInLineContinuation = false
        }
    }

    public override func dealWithAccessPublic(_: StateBean): Bool {
        false
    }
    public override func dealWithAccessPrivate(_: StateBean): Bool {
        false
    }
    public override func dealWithAccessProtected(_: StateBean): Bool {
        false
    }

    public override func dealWithMultiLineComment(_: StateBean, _: String): Unit {}
    public override func dealWithSingleLineComment(_: StateBean, _: String): Unit {}

    public override func dealWithLeftBigBracket(stateBean: StateBean): Unit {
        // Bash 的 { } 命令组：只增加缩进，不强制换行
        stateBean.indentLevel++
    }

    public func dealWithLeftParen(stateBean: StateBean): Unit {
        // Bash 的 ( ) 子 shell：只增加缩进，不强制换行
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex

        // 如果下一个字符也是 (，则是算术扩展 (( ))，不处理
        if (idx + 1 < chars.size && chars[idx + 1] == r'(') {
            return
        }

        // 检测是否是函数定义：foo() { 或 foo()
        // 如果当前字符是 (，前一个字符不是特殊字符，下一个字符是 )，则可能是函数定义
        if (idx >= 1 && idx + 1 < chars.size && chars[idx + 1] == r')') {
            // 检查 ) 后面是否是空格然后 {，或者是换行
            let nextIdx = idx + 2
            if (nextIdx < chars.size) {
                var j = nextIdx
                // 跳过空格
                while (j < chars.size && chars[j] == r' ') {
                    j++
                }
                // 如果后面是 { 或换行，则是函数定义，不增加缩进
                if (j < chars.size && (chars[j] == r'{' || chars[j] == r'\n' || chars[j] == r'\r')) {
                    return
                }
            }
        }

        stateBean.indentLevel++
    }

    public func dealWithRightParen(stateBean: StateBean): Unit {
        // Bash 的 ( ) 子 shell 结束：只减少缩进，不强制换行
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex

        // 如果前一个字符是 (，则是算术扩展 ))，不处理
        if (idx >= 1 && chars[idx - 1] == r'(') {
            return
        }

        // 如果下一个字符也是 )，则是算术扩展 ))，不处理
        if (idx + 1 < chars.size && chars[idx + 1] == r')') {
            return
        }

        // 如果标记跳过，则是算术扩展结束的第二个 )，不处理并清除标记
        if (skipNextRightParen) {
            skipNextRightParen = false
            return
        }

        stateBean.indentLevel--
        if (stateBean.indentLevel < 0) {
            stateBean.indentLevel = 0
        }
        stateBean.savedIndentLevel = stateBean.indentLevel // 立即更新savedIndent
    }

    public override func dealWithRightBigBracket(stateBean: StateBean): Unit {
        stateBean.indentLevel--
        if (stateBean.indentLevel < 0) {
            stateBean.indentLevel = 0
        }
        stateBean.savedIndentLevel = stateBean.indentLevel // 立即更新savedIndent
    }

    public override func dealWithMacro(_: StateBean): Unit {
        // Bash 的 # 注释在 dealWithNewLine 中处理
    }

    public override func dealWithString(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        let currChar = chars[idx]

        // ANSI-C 引用 $'...'
        // 使用 'S' 标记 ANSI-C 单引号（Single with dollar）
        if (!stateBean.isInString && idx >= 1 && chars[idx - 1] == r'$' && currChar == r'\'') {
            stateBean.isInString = true
            stateBean.stringQuote = r'S' // ANSI-C 引用标记
            return
        }

        // 单引号 '...' - 不展开变量
        if (!stateBean.isInString && currChar == r'\'') {
            stateBean.isInString = true
            stateBean.stringQuote = r'\''
            return
        }

        // 双引号 "..." - 展开变量
        if (!stateBean.isInString && currChar == r'"') {
            stateBean.isInString = true
            stateBean.stringQuote = r'"'
            return
        }

        // 检测字符串结束
        if (stateBean.isInString) {
            if (stateBean.stringQuote == r'S') {
                // ANSI-C 引用结束：检测未转义的 '
                if (currChar == r'\'') {
                    stateBean.isInString = false
                    stateBean.stringQuote = r' '
                    return
                }
            } else if (stateBean.stringQuote == r'\'') {
                // 单引号结束：无转义，直接匹配
                if (currChar == r'\'') {
                    stateBean.isInString = false
                    stateBean.stringQuote = r' '
                    return
                }
            } else if (stateBean.stringQuote == r'"') {
                // 双引号结束：处理转义
                if (currChar == r'"') {
                    var escaped = false
                    if (idx >= 1 && chars[idx - 1] == r'\\') {
                        // 检查是否真的转义（偶数个 \ 表示未转义）
                        var backslashCount: Int64 = 0
                        var checkIdx = idx - 1
                        while (checkIdx >= 0 && chars[checkIdx] == r'\\') {
                            backslashCount++
                            checkIdx--
                        }
                        escaped = (backslashCount % 2 == 1)
                    }
                    if (!escaped) {
                        stateBean.isInString = false
                        stateBean.stringQuote = r' '
                        return
                    }
                }
            }

            // 换行符强制结束字符串（容错）
            if (isNewline(chars, idx)) {
                stateBean.isInString = false
                stateBean.stringQuote = r' '
            }
        }
    }

    public override func dealWithFor(_: StateBean): Unit {
        // Bash for 不需要特殊处理（不同于 C 的 for(;;)）
    }

    public override func dealWithSemicolon(_: StateBean): Unit {
        // Bash 分号处理：不强制换行，只标记case分支结束
        // ;; 会被 detectCaseEnd 处理，这里不做任何操作
    }

    // ==================== Bash 特定处理 ====================

    /**
     * 栈弹出操作：统一处理 fi/done/esac 的栈操作
     * 弹出栈顶元素，恢复缩进级别
     */
    private func popStack(stack: ArrayList<FlagBean>, stateBean: StateBean): Unit {
        if (stack.size > 0) {
            stateBean.indentLevel = stack[stack.size - 1].flagIndent
            stateBean.savedIndentLevel = stateBean.indentLevel
            stack.remove(at: stack.size - 1)
        }
    }

    /**
     * 检查是否在正常上下文中（不在字符串、双括号、算术扩展中）
     * 用于减少重复的条件检查
     */
    private func isInNormalContext(stateBean: StateBean): Bool {
        !stateBean.isInString && !isInDoubleBracket && !isInArithmetic
    }

    /**
     * 处理续行符 \ (line continuation)
     * \ 后必须紧跟换行，无空格
     */
    public func dealWithLineContinuation(stateBean: StateBean): Bool {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex

        if (chars[idx] == r'\\' && isNewline(chars, idx + 1)) {
            isInLineContinuation = true
            return true
        }
        return false
    }

    /**
     * 处理 Here-document <<EOF 或 <<-EOF
     */
    public func dealWithHeredoc(stateBean: StateBean): Bool {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex

        // 检测 << 或 <<-
        if (chars[idx] == r'<' && idx + 1 < chars.size && chars[idx + 1] == r'<') {
            var stripTabs = false
            var startIdx = idx + 2

            // 检测 <<-
            if (idx + 2 < chars.size && chars[idx + 2] == r'-') {
                stripTabs = true
                startIdx = idx + 3
            }

            // 提取定界符
            var delimiter = StringBuilder()
            var delimiterIdx = startIdx

            // 跳过空格
            while (delimiterIdx < chars.size && chars[delimiterIdx] == r' ') {
                delimiterIdx++
            }

            // 提取定界符（到空格或换行）
            while (delimiterIdx < chars.size && chars[delimiterIdx] != r' ' && !isNewline(chars, delimiterIdx) &&
                    chars[delimiterIdx] != r'\t') {
                delimiter.append(chars[delimiterIdx])
                delimiterIdx++
            }

            let delimStr = delimiter.toString()
            if (delimStr.size > 0) {
                // isInHeredoc = true  // 不立即设置，等换行后再设置
                heredocDelimiter = delimStr
                heredocStripTabs = stripTabs
                isHeredocDeclarationLine = true // 标记当前行是heredoc声明行

                // 将 <<... 定界符声明保存到当前行（第一个'<'已在主循环中添加）
                for (i in idx + 1..delimiterIdx) {
                    stateBean.perLineOutput.append(chars[i])
                }
                stateBean.currentIndex = delimiterIdx - 1
                return true
            }
        }
        return false
    }

    /**
     * 检测 Here-document 结束标记
     */
    public func detectHeredocEnd(stateBean: StateBean): Bool {
        if (!isInHeredoc) {
            return false
        }

        let lineContent = stateBean.perLineOutput.toString().trimAscii()

        // 对于 <<-，去除前导 Tab 后匹配
        var compareLine = lineContent
        if (heredocStripTabs) {
            // 使用unsafe处理字节移除前导Tab（避免toRuneArray）
            let bytes = unsafe { compareLine.rawData() }
            var startIdx: Int64 = 0
            while (startIdx < bytes.size && bytes[startIdx] == b'\t') {
                startIdx++
            }
            if (startIdx > 0) {
                compareLine = unsafe { String.fromUtf8Unchecked(bytes[startIdx..]) }
            }
        }

        if (compareLine == heredocDelimiter) {
            return true
        }
        return false
    }

    public func clearHeredocState(): Unit {
        isInHeredoc = false
        heredocDelimiter = ""
        heredocStripTabs = false
    }

    /**
     * 处理复合命令 [[ ]] 和 (( ))
     */
    public func dealWithCompoundCommand(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        let currChar = chars[idx]

        // [[ ]] 条件测试
        if (!isInDoubleBracket && !isInArithmetic && !stateBean.isInString) {
            if (currChar == r'[' && idx + 1 < chars.size && chars[idx + 1] == r'[') {
                isInDoubleBracket = true
                doubleBracketCount = 2
                stateBean.perLineOutput.append(r'[')
                stateBean.currentIndex++
                return
            }
        }

        // $(( )) 算术扩展（先检测，优先级高于 (( ))
        if (!isInDoubleBracket && !isInArithmetic && !stateBean.isInString) {
            if (idx >= 1 && chars[idx - 1] == r'$' && currChar == r'(' && idx + 1 < chars.size && chars[idx + 1] == r'(') {
                isInArithmetic = true
                arithmeticCount = 1
                stateBean.perLineOutput.append(r'(')
                stateBean.currentIndex++
                return
            }
        }

        // (( )) 算术扩展（排除 $(( ))
        if (!isInDoubleBracket && !isInArithmetic && !stateBean.isInString) {
            if (currChar == r'(' && idx + 1 < chars.size && chars[idx + 1] == r'(') {
                if (idx < 1 || chars[idx - 1] != r'$') {
                    isInArithmetic = true
                    arithmeticCount = 1
                    stateBean.perLineOutput.append(r'(')
                    stateBean.currentIndex++
                    return
                }
            }
        }

        // 跟踪嵌套括号
        if (isInDoubleBracket) {
            if (currChar == r'[') {
                doubleBracketCount++
            } else if (currChar == r']') {
                doubleBracketCount--
                if (doubleBracketCount <= 0) {
                    isInDoubleBracket = false
                    doubleBracketCount = 0
                }
            }
        }

        if (isInArithmetic) {
            if (currChar == r'(') {
                arithmeticCount++
            } else if (currChar == r')') {
                arithmeticCount--
                if (arithmeticCount == 0 && idx + 1 < chars.size && chars[idx + 1] == r')') {
                    isInArithmetic = false
                    arithmeticCount = 0
                    skipNextRightParen = true
                }
            }
        }
    }

    /**
     * 处理命令替换 $( ) 或反引号
     */
    public func dealWithCommandSubstitution(stateBean: StateBean): Unit {
        let chars = stateBean.codeChars.getOrThrow()
        let idx = stateBean.currentIndex
        let currChar = chars[idx]

        // $( 开始
        if (!isInCommandSubstitution && !stateBean.isInString) {
            if (idx >= 1 && chars[idx - 1] == r'$' && currChar == r'(') {
                isInCommandSubstitution = true
                commandSubCount = 1
                return
            }
        }

        // 反引号 ` 开始
        if (!isInCommandSubstitution && !stateBean.isInString && !isInArithmetic) {
            if (currChar == r'`') {
                isInCommandSubstitution = true
                commandSubCount = 0 // 反引号不计数
                return
            }
        }

        // 跟踪嵌套
        if (isInCommandSubstitution && commandSubCount > 0) {
            if (currChar == r'(') {
                commandSubCount++
            } else if (currChar == r')') {
                commandSubCount--
                if (commandSubCount <= 0) {
                    isInCommandSubstitution = false
                    commandSubCount = 0
                }
            }
        }

        // 反引号结束
        if (isInCommandSubstitution && commandSubCount == 0 && currChar == r'`') {
            isInCommandSubstitution = false
            commandSubCount = 0
        }
    }

    // ==================== 状态管理辅助方法 ====================

    /**
     * 重置所有成员变量状态
     */
    /**
     * 初始化StateBean并处理开头空行和Shebang
     */
    private func initAndProcessHeader(stateBean: StateBean, chars: Array<Rune>): Unit {
        let len = chars.size
        var startIdx: Int64 = 0

        // 处理开头空行
        while (startIdx < len && isNewline(chars, startIdx)) {
            let newlineLen = getNewlineLength(chars, startIdx)
            if (newlineLen > 0) {
                let lineBean = LineBean()
                lineBean.codeLine = ""
                lineBean.indentLevel = 0
                stateBean.linesList.add(lineBean)
                startIdx += newlineLen
            } else {
                startIdx++
            }
        }

        // 处理Shebang
        if (len - startIdx >= 2 && chars[startIdx] == r'#' && chars[startIdx + 1] == r'!') {
            shebangProcessed = true
            var shebangIdx = startIdx
            var shebangLine = StringBuilder()
            while (shebangIdx < len && !isNewline(chars, shebangIdx)) {
                shebangLine.append(chars[shebangIdx])
                shebangIdx++
            }
            let lineBean = LineBean()
            lineBean.codeLine = shebangLine.toString()
            lineBean.indentLevel = 0
            stateBean.linesList.add(lineBean)
            stateBean.currentIndex = shebangIdx
            if (shebangIdx < len) {
                stateBean.currentIndex += getNewlineLength(chars, shebangIdx)
            }
            stateBean.perLineStartIndex = stateBean.currentIndex
            stateBean.isLineStart = true
        } else {
            shebangProcessed = true
            stateBean.currentIndex = startIdx
            stateBean.perLineStartIndex = startIdx
        }
    }

    // ==================== 辅助函数 ====================

    /**
     * 应用空格规则（合并多空格、管道、逻辑运算符等）
     */
    private func applySpaceRules(lineCode: String): String {
        var result = lineCode

        // Step 1: 合并多个连续空格为一个（跳过字符串内容）
        result = mergeMultiSpacesSkipQuotes(result)

        // Step 2: 规范分号前后空格（;then → ; then）
        result = normalizeSemicolon(result)

        // Step 3: 管道符和逻辑运算符两侧空格（跳过字符串内容）
        result = addSpaceAroundOperatorsSkipQuotes(result)

        // Step 4: 重定向运算符前加空格（> < >>）（跳过字符串和算术表达式）
        result = addSpaceBeforeRedirect(result)

        // Step 5: 最后清理可能产生的双空格
        result = mergeMultiSpacesSkipQuotes(result)

        return result
    }

    /**
     * 合并多个连续ASCII空格为一个，跳过引号内的内容
     * 使用unsafe优化性能（ASCII字符处理）
     */
    private func mergeMultiSpacesSkipQuotes(code: String): String {
        let bytes = unsafe { code.rawData() }
        let builder = ArrayList<Byte>()
        var lastWasSpace = false
        var inQuote = false
        var quoteChar: Byte = b' '

        for (i in 0..bytes.size) {
            let b = bytes[i]

            // 检测进入/退出引号
            if (b == b'"' || b == b'\'') {
                if (!inQuote) {
                    inQuote = true
                    quoteChar = b
                    builder.add(b)
                    lastWasSpace = false
                } else if (b == quoteChar) {
                    inQuote = false
                    quoteChar = b' '
                    builder.add(b)
                    lastWasSpace = false
                } else {
                    builder.add(b)
                    lastWasSpace = false
                }
            } else if (inQuote) {
                builder.add(b)
                lastWasSpace = false
            } else if (b == b' ') {
                if (!lastWasSpace) {
                    builder.add(b)
                    lastWasSpace = true
                }
            } else {
                builder.add(b)
                lastWasSpace = false
            }
        }

        unsafe { String.fromUtf8Unchecked(builder.getRawArray()[..builder.size]) }
    }

    /**
     * 智能添加操作符两侧空格，跳过引号内的内容
     * 处理顺序：||, &&, |（避免 || 被 | 影响）
     * 使用unsafe优化性能（ASCII字符处理）
     */
    private func addSpaceAroundOperatorsSkipQuotes(code: String): String {
        let bytes = unsafe { code.rawData() }
        let builder = ArrayList<Byte>()
        var i: Int64 = 0
        var inQuote = false
        var quoteChar: Byte = b' '

        while (i < bytes.size) {
            let curr = bytes[i]

            // 检测进入/退出引号
            if (curr == b'"' || curr == b'\'') {
                if (!inQuote) {
                    inQuote = true
                    quoteChar = curr
                } else if (curr == quoteChar) {
                    inQuote = false
                    quoteChar = b' '
                }
            }

            if (inQuote) {
                builder.add(curr)
                i++
                continue
            }

            // 先检测双字符运算符：|| 或 &&
            if (i + 1 < bytes.size) {
                if (curr == b'|' && bytes[i + 1] == b'|') {
                    if (i > 0 && bytes[i - 1] != b' ') {
                        builder.add(b' ')
                    }
                    builder.add(b'|')
                    builder.add(b'|')
                    i += 2
                    if (i < bytes.size && bytes[i] != b' ') {
                        builder.add(b' ')
                    }
                    continue
                } else if (curr == b'&' && bytes[i + 1] == b'&') {
                    if (i > 0 && bytes[i - 1] != b' ') {
                        builder.add(b' ')
                    }
                    builder.add(b'&')
                    builder.add(b'&')
                    i += 2
                    if (i < bytes.size && bytes[i] != b' ') {
                        builder.add(b' ')
                    }
                    continue
                }
            }

            // 单字符运算符：|
            if (curr == b'|') {
                if (i > 0 && bytes[i - 1] != b' ') {
                    builder.add(b' ')
                }
                builder.add(b'|')
                i++
                if (i < bytes.size && bytes[i] != b' ' && bytes[i] != b'|') {
                    builder.add(b' ')
                }
            } else {
                builder.add(curr)
                i++
            }
        }

        unsafe { String.fromUtf8Unchecked(builder.getRawArray()[..builder.size]) }
    }

    /**
     * 规范分号前后空格：
     * - 分号前不允许有空格（word ; → word;）
     * - 分号后紧接单词时加空格（;then → ; then）
     * - 保留 ;; 原样（case分支结束符）
     * - 保留 ;;& 和 ;& 原样（case fallthrough操作符）
     * 使用unsafe优化性能（ASCII字符处理）
     */
    private func normalizeSemicolon(code: String): String {
        let bytes = unsafe { code.rawData() }
        let builder = ArrayList<Byte>()
        var i: Int64 = 0

        while (i < bytes.size) {
            if (bytes[i] == b';') {
                // 移除分号前的空格（检查builder末尾）
                if (builder.size > 0 && builder[builder.size - 1] == b' ') {
                    builder.remove(at: builder.size - 1)
                }
                builder.add(b';')

                // 检查 ;;& (case fallthrough with continue)
                if (i + 2 < bytes.size && bytes[i + 1] == b';' && bytes[i + 2] == b'&') {
                    builder.add(b';')
                    builder.add(b'&')
                    i += 2
                    if (i + 1 < bytes.size && bytes[i + 1] != b' ' && bytes[i + 1] != b';' && bytes[i + 1] != b'\n') {
                        builder.add(b' ')
                    }
                }
                    // 检查 ;; (case分支结束符)
                    else if (i + 1 < bytes.size && bytes[i + 1] == b';') {
                    builder.add(b';')
                    i++
                    if (i + 1 < bytes.size && bytes[i + 1] != b' ' && bytes[i + 1] != b';' && bytes[i + 1] != b'&') {
                        builder.add(b' ')
                    }
                }
                    // 检查 ;& (case fallthrough)
                    else if (i + 1 < bytes.size && bytes[i + 1] == b'&') {
                    builder.add(b'&')
                    i++
                    if (i + 1 < bytes.size && bytes[i + 1] != b' ' && bytes[i + 1] != b'\n') {
                        builder.add(b' ')
                    }
                }
                    // 普通分号后面加空格
                    else if (i + 1 < bytes.size && bytes[i + 1] != b' ' && bytes[i + 1] != b'\t') {
                    builder.add(b' ')
                }
            } else {
                builder.add(bytes[i])
            }
            i++
        }

        unsafe { String.fromUtf8Unchecked(builder.getRawArray()[..builder.size]) }
    }

    /**
     * 重定向运算符前加空格（> < >>）
     * 使用unsafe优化性能（ASCII字符处理）
     */
    private func addSpaceBeforeRedirect(code: String): String {
        let bytes = unsafe { code.rawData() }
        let builder = ArrayList<Byte>()
        var i: Int64 = 0
        var inArithmeticExpr = false

        while (i < bytes.size) {
            // 检测进入算术表达式 (( 
            if (i + 1 < bytes.size && bytes[i] == b'(' && bytes[i + 1] == b'(') {
                inArithmeticExpr = true
                builder.add(b'(')
                builder.add(b'(')
                i += 2
                continue
            }

            // 检测退出算术表达式 ))
            if (inArithmeticExpr && i + 1 < bytes.size && bytes[i] == b')' && bytes[i + 1] == b')') {
                inArithmeticExpr = false
                builder.add(b')')
                builder.add(b')')
                i += 2
                continue
            }

            // 在算术表达式内，不处理 < 和 > 作为重定向符
            if (inArithmeticExpr) {
                builder.add(bytes[i])
                i++
                continue
            }

            // 检测 herestring <<<（优先检测，避免被 << 拦截）
            if (bytes[i] == b'<' && i + 2 < bytes.size && bytes[i + 1] == b'<' && bytes[i + 2] == b'<') {
                builder.add(b'<')
                builder.add(b'<')
                builder.add(b'<')
                i += 3
                continue
            }

            // 检测 heredoc << 或 <<-
            if (bytes[i] == b'<' && i + 1 < bytes.size && bytes[i + 1] == b'<') {
                builder.add(b'<')
                builder.add(b'<')
                i += 2
                if (i < bytes.size && bytes[i] == b'-') {
                    builder.add(b'-')
                    i++
                }
                continue
            }

            // 检测进程替换 <( 或 >(
            if ((bytes[i] == b'<' || bytes[i] == b'>') && i + 1 < bytes.size && bytes[i + 1] == b'(') {
                builder.add(bytes[i])
                builder.add(b'(')
                i += 2
                continue
            }

            // 先检测 >>
            if (bytes[i] == b'>' && i + 1 < bytes.size && bytes[i + 1] == b'>') {
                if (i > 0 && bytes[i - 1] != b' ') {
                    builder.add(b' ')
                }
                builder.add(b'>')
                builder.add(b'>')
                i += 2
                if (i < bytes.size && bytes[i] != b' ') {
                    builder.add(b' ')
                }
            // 单个 >
            } else if (bytes[i] == b'>') {
                if (i > 0 && bytes[i - 1] != b' ') {
                    builder.add(b' ')
                }
                builder.add(b'>')
                i++
                if (i < bytes.size && bytes[i] != b' ') {
                    builder.add(b' ')
                }
            // 单个 <（不在 <<, <<<, <( 中）
            } else if (bytes[i] == b'<') {
                if (i > 0 && bytes[i - 1] != b' ') {
                    builder.add(b' ')
                }
                builder.add(b'<')
                i++
                if (i < bytes.size && bytes[i] != b' ') {
                    builder.add(b' ')
                }
            } else {
                builder.add(bytes[i])
                i++
            }
        }

        unsafe { String.fromUtf8Unchecked(builder.getRawArray()[..builder.size]) }
    }

    // ==================== 核心格式化入口 ====================

    /**
     * 核心格式化函数
     * @param rawCode 原始 Bash 代码
     * @param cfg 格式化配置
     * @return 格式化后的代码
     */
    public func formatCode(rawCode: String, cfg: FormatConfig): String {
        // 重置所有状态
        ifStack.clear()
        loopStack.clear()
        caseStack.clear()
        isInHeredoc = false
        heredocDelimiter = ""
        isInLineContinuation = false
        skipNextRightParen = false
        isInDoubleBracket = false
        isInArithmetic = false
        isInCommandSubstitution = false
        shebangProcessed = false
        isInCaseBranch = false
        isHeredocDeclarationLine = false

        let stateBean = StateBean()
        stateBean.linesList = ArrayList<LineBean>()
        stateBean.codeChars = rawCode.toRuneArray()

        if (let Some(chars) <- stateBean.codeChars) {
            if (chars.size == 0) {
                return ""
            }

            initAndProcessHeader(stateBean, chars)
            processMainLoop(stateBean, chars)
            dealWithNewLine(stateBean)

            // 应用空格规则
            for (line in stateBean.linesList) {
                if (!line.isHeredocContent) {
                    line.codeLine = applySpaceRules(line.codeLine.trimAscii())
                }
            }

            // 构建输出
            for (index in 0..stateBean.linesList.size) {
                let item = stateBean.linesList[index]
                if (!item.isHeredocContent) {
                    addIndent(stateBean.output, item.indentLevel, cfg)
                }
                stateBean.output.append(item.codeLine)
                if (index != stateBean.linesList.size - 1) {
                    stateBean.output.append("\n")
                }
            }

            // 确保末尾换行（避免toString）
            let outputStr = stateBean.output.toString()
            if (!outputStr.endsWith("\n")) {
                stateBean.output.append("\n")
            }

            return outputStr
        }
        return ""
    }

    /**
     * 主循环处理逻辑
     */
    private func processMainLoop(stateBean: StateBean, chars: Array<Rune>): Unit {
        let len = chars.size

        while (stateBean.currentIndex < len) {
            let currChar = chars[stateBean.currentIndex]
            stateBean.perLineOutput.append(currChar)

            // 处理行内注释
            if (currChar == r'#' && !stateBean.isInString && stateBean.isLineStart && shebangProcessed) {
                stateBean.currentIndex++
                while (stateBean.currentIndex < chars.size && !isNewline(chars, stateBean.currentIndex)) {
                    stateBean.perLineOutput.append(chars[stateBean.currentIndex])
                    stateBean.currentIndex++
                }
                if (stateBean.currentIndex < chars.size) {
                    stateBean.currentIndex += getNewlineLength(chars, stateBean.currentIndex)
                }
                dealWithNewLine(stateBean)
                stateBean.isLineStart = true
                continue
            }

            dealWithString(stateBean)

            // 处理续行符
            if (!stateBean.isInString && currChar == r'\\' && dealWithLineContinuation(stateBean)) {
                stateBean.lastChar = currChar
                dealWithNewLine(stateBean)
                stateBean.currentIndex += 1 + getNewlineLength(chars, stateBean.currentIndex + 1)
                stateBean.isLineStart = true
                continue
            }

            // 处理Heredoc声明
            if (!stateBean.isInString && currChar == r'<' && dealWithHeredoc(stateBean)) {
                stateBean.currentIndex++
                continue
            }

            if (!stateBean.isInString) {
                dealWithCompoundCommand(stateBean)
                dealWithCommandSubstitution(stateBean)
            }

            if (isInHeredoc) {
                let isHeredocEndLine = detectHeredocEnd(stateBean)
                if (isNewline(chars, stateBean.currentIndex)) {
                    dealWithNewLine(stateBean)
                    if (isHeredocEndLine) {
                        clearHeredocState()
                    }
                    stateBean.isLineStart = true
                }
                stateBean.lastChar = currChar
                stateBean.currentIndex++
                continue
            }

            let normalContext = isInNormalContext(stateBean)
            processKeywords(stateBean, currChar, normalContext)

            // 处理大括号和圆括号
            if (normalContext) {
                if (currChar == r'{') {
                    dealWithLeftBigBracket(stateBean)
                }
                if (currChar == r'}') {
                    dealWithRightBigBracket(stateBean)
                }
                if (currChar == r'(') {
                    dealWithLeftParen(stateBean)
                }
                if (currChar == r')') {
                    dealWithRightParen(stateBean)
                }
            }

            processNewline(stateBean, chars, currChar)

            stateBean.lastChar = currChar
            stateBean.currentIndex++
        }
    }

    /**
     * 处理关键字检测与缩进调整
     */
    private func processKeywords(stateBean: StateBean, _: Rune, normalContext: Bool): Unit {
        if (!normalContext) {
            return
        }

        if (detectIf(stateBean)) {
            ifStack.add(FlagBean("if", stateBean.indentLevel))
        }

        let loopType = detectLoopType(stateBean)
        if (loopType.size > 0) {
            loopStack.add(FlagBean("loop", stateBean.indentLevel))
        }

        let caseEndType = detectCaseEnd(stateBean)
        if (caseEndType.size > 0) {
            isInCaseBranch = false
            if (caseEndType == ";;&") {
                stateBean.currentIndex++
            }
        }

        if (detectThen(stateBean) || detectDo(stateBean)) {
            stateBean.indentLevel++
        }

        // else和elif共用if对齐逻辑
        if (detectElse(stateBean) || detectElif(stateBean)) {
            if (ifStack.size > 0) {
                stateBean.indentLevel = ifStack[ifStack.size - 1].flagIndent
                stateBean.savedIndentLevel = stateBean.indentLevel
            }
            if (detectElse(stateBean)) {
                stateBean.indentLevel++
            }
        }

        if (detectFi(stateBean)) {
            popStack(ifStack, stateBean)
        }
        if (detectDone(stateBean)) {
            popStack(loopStack, stateBean)
        }
        if (detectEsac(stateBean)) {
            popStack(caseStack, stateBean)
        }
    }

    /**
     * 处理换行符（包括case-in和case分支检测）
     */
    private func processNewline(stateBean: StateBean, chars: Array<Rune>, currChar: Rune): Unit {
        if (!isNewline(chars, stateBean.currentIndex) || stateBean.isInString) {
            if (stateBean.isLineStart && (currChar == r' ' || currChar == r'\t')) {
                stateBean.isLineStart = true
            } else {
                stateBean.isLineStart = false
            }
            return
        }

        if (!isInHeredoc && !isHeredocDeclarationLine) {
            let currentLine = stateBean.perLineOutput.toString().trimAscii()

            if (currentLine.startsWith("case") && currentLine.endsWith("in")) {
                caseStack.add(FlagBean("case", stateBean.indentLevel))
                stateBean.indentLevel++
            }

            if (caseStack.size > 0 && !isInCaseBranch && currentLine.contains(")") && !currentLine.startsWith(";;")) {
                isInCaseBranch = true
                stateBean.savedIndentLevel = caseStack[caseStack.size - 1].flagIndent + 1
                stateBean.indentLevel = stateBean.savedIndentLevel + 1
            }
        }

        dealWithNewLine(stateBean)

        if (isHeredocDeclarationLine) {
            isInHeredoc = true
            isHeredocDeclarationLine = false
        }

        stateBean.isLineStart = true
        let newlineLen = getNewlineLength(chars, stateBean.currentIndex)
        if (newlineLen > 1) {
            stateBean.currentIndex += newlineLen - 1
        }
    }
}
