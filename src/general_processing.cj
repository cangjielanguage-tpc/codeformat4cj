package codeformat

open class GeneralProcessing <: BaseLanguage {
    /**
     * 处理换行符
     * 当遇到换行符时，将当前行保存到 linesList 中
     * 
     * @param stateBean 当前解析状态对象
     */
    open public override func dealWithNewLine(stateBean: StateBean): Unit {
        if (stateBean.perLineOutput.size > 0) {
            let lineBean: LineBean = LineBean()
            lineBean.codeLine = stateBean.perLineOutput.toString()
            lineBean.indentLevel = stateBean.indentLevel
            lineBean.smallBracketDouble = stateBean.smallBracketDouble
            lineBean.middleBracketDouble = stateBean.middleBracketDouble
            lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
            lineBean.isInString = stateBean.isInString
            lineBean.isInMacro = stateBean.isInMacro
            lineBean.isInFor = stateBean.isInFor
            stateBean.linesList.add(lineBean)
            stateBean.perLineOutput = StringBuilder()
            stateBean.perLineStartIndex = stateBean.currentIndex + 1
            stateBean.lastChar = r'\n'
        }
    }

    /**
     * 处理左大括号 {
     * 遇到 { 时：
     * 1. 保存当前行到 linesList
     * 2. 增加缩进级别
     * 3. 重置行输出缓冲区
     * 
     * @param stateBean 当前解析状态对象
     */
    open public override func dealWithLeftBigBracket(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1))

        lineBean.codeLine = lineCode
        lineBean.indentLevel = stateBean.indentLevel
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean)
        
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.indentLevel++
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'{'
        stateBean.currentIndex++
    }

    /**
     * 处理右大括号 }
     * 遇到 } 时：
     * 1. 先减少缩进级别
     * 2. 保存当前行（使用减少后的缩进）
     * 3. 重置行输出缓冲区
     * 
     * @param stateBean 当前解析状态对象
     */
    open public override func dealWithRightBigBracket(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1))
        lineBean.codeLine = lineCode
        stateBean.indentLevel-- // 先减少缩进级别
        if (stateBean.indentLevel <= 0) {
            stateBean.indentLevel = 0
        }
        lineBean.indentLevel = stateBean.indentLevel // 使用减少后的缩进
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) // 保存当前行
        
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'}'
        stateBean.currentIndex++
    }


    /**
     * 处理单行注释 //
     * 检测注释前的空格数量，判断注释是否独立成行
     * 
     * @param stateBean 当前解析状态对象
     * @param perStr 注释前的前缀字符串
     */
    open public override func dealWithSingleLineComment(stateBean: StateBean, perStr: String): Unit {
        stateBean.isInSinglelineComment = true
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]

        // 向前遍历计算注释前的空格数量
        var beforeSpaceCount: Int64 = 0
        var beforeSpaceIndex = stateBean.currentIndex - 2
        while (beforeSpaceIndex >= 0 && stateBean.codeChars.getOrThrow()[beforeSpaceIndex] == r' ') {
            beforeSpaceCount++
            beforeSpaceIndex--
        }
        
        // 判断注释是否独立成行
        var tempSingleLineAfterChangeLine: Bool = false
        if (beforeSpaceIndex < 0) {
            tempSingleLineAfterChangeLine = true // 第一行
        } else {
            let char: Rune = stateBean.codeChars.getOrThrow()[beforeSpaceIndex]
            tempSingleLineAfterChangeLine = (char == r'\n')
        }

        if (perStr.size > 0) {
            tempSingleLineAfterChangeLine = true // 有前缀内容时视为独立行
        }

        // 向后遍历直到换行符
        while (currChar != r'\n') {
            if (stateBean.currentIndex == stateBean.codeChars.getOrThrow().size - 1) {
                break
            }
            stateBean.currentIndex++
            currChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
            stateBean.perLineOutput.append(currChar)
        }
        
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex - 1, lineEndIndex - lineStartIndex + 1 + 1))
        lineBean.codeLine = perStr + lineCode
        lineBean.indentLevel = stateBean.indentLevel
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        lineBean.isInSinglelineComment = stateBean.isInSinglelineComment
        lineBean.singleLineWhiteSpace = beforeSpaceCount
        lineBean.singlelineCommentisAfterChangeLine = tempSingleLineAfterChangeLine
        stateBean.linesList.add(lineBean)
        
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'\n'
        stateBean.currentIndex++
        stateBean.isInSinglelineComment = false
    }

    /**
     * 处理多行注释 /* */
     * 将多行注释按换行符分割为多个 LineBean
     * 
     * @param stateBean 当前解析状态对象
     * @param perStr 注释前的前缀字符串
     */
    open public override func dealWithMultiLineComment(stateBean: StateBean, perStr: String): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        stateBean.isInMultilineComment = true
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = notNullChar[stateBean.currentIndex]
        var lastChar: Rune = r'/'
        
        // 向前遍历计算注释前的空格数量
        var beforeSpaceCount: Int64 = 0
        var beforeSpaceIndex = stateBean.currentIndex - 2
        while (beforeSpaceIndex >= 0 && notNullChar[beforeSpaceIndex] == r' ') {
            beforeSpaceCount++
            beforeSpaceIndex--
        }
        
        // 判断多行注释是否独立成行
        var tempMultiLineAfterChangeLine: Bool = false
        if (beforeSpaceIndex < 0) {
            tempMultiLineAfterChangeLine = true
        } else {
            let char: Rune = notNullChar[beforeSpaceIndex]
            tempMultiLineAfterChangeLine = (char == r'\n')
        }

        if (perStr.size > 0) {
            tempMultiLineAfterChangeLine = true
        }
        
        // 向后遍历直到找到 */
        if (notNullChar.size > stateBean.currentIndex + 2) {
            stateBean.currentIndex += 2
            lastChar = notNullChar[stateBean.currentIndex - 1]
            currChar = notNullChar[stateBean.currentIndex]
            stateBean.perLineOutput.append(lastChar)
            
            while (!(lastChar == r'*' && currChar == r'/')) {
                if (stateBean.currentIndex == notNullChar.size - 1) {
                    break
                }
                stateBean.currentIndex++
                stateBean.perLineOutput.append(currChar)
                currChar = notNullChar[stateBean.currentIndex]
                lastChar = notNullChar[stateBean.currentIndex - 1]
            }
        } else {
            if (notNullChar.size > stateBean.currentIndex + 1) {
                stateBean.currentIndex++
            }
        }

        // 将多行注释按换行分割
        let lineEndIndex: Int64 = stateBean.currentIndex
        var lineCodeAll: String = String(notNullChar.slice(lineStartIndex - 1, lineEndIndex - lineStartIndex + 1 + 1))
        lineCodeAll = perStr + lineCodeAll
        let lineCodeList: Array<String> = lineCodeAll.split("\n")
        
        for (index in 0..lineCodeList.size) {
            let lineBean: LineBean = LineBean()
            lineBean.codeLine = lineCodeList[index]
            if (index == 0) {
                lineBean.isFirstMultiCommentLine = true
                lineBean.multilineCommentisAfterChangeLine = tempMultiLineAfterChangeLine
            }
            lineBean.indentLevel = stateBean.indentLevel
            lineBean.smallBracketDouble = stateBean.smallBracketDouble
            lineBean.middleBracketDouble = stateBean.middleBracketDouble
            lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
            lineBean.isInString = stateBean.isInString
            lineBean.isInMacro = stateBean.isInMacro
            lineBean.isInFor = stateBean.isInFor
            lineBean.isInMultilineComment = stateBean.isInMultilineComment
            stateBean.linesList.add(lineBean)
            stateBean.perLineOutput = StringBuilder()
        }
        
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'\n'
        stateBean.currentIndex++
        stateBean.isInMultilineComment = false
    }

    /**
     * 处理宏定义 #
     * 
     * @param stateBean 当前解析状态对象
     */
    open public override func dealWithMacro(stateBean: StateBean): Unit {
        stateBean.isInMacro = true
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
        
        while (currChar != r'\n') {
            if (stateBean.currentIndex == stateBean.codeChars.getOrThrow().size - 1) {
                break
            }
            stateBean.currentIndex++
            currChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
            stateBean.perLineOutput.append(currChar)
        }
        
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1))
        lineBean.codeLine = lineCode
        lineBean.indentLevel = stateBean.indentLevel
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean)
        
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'\n'
        stateBean.currentIndex++
        stateBean.isInMacro = false
    }

    /**
     * 处理访问修饰符 public:
     * 
     * @param stateBean 当前解析状态对象
     * @return 是否成功处理
     */
    open public override func dealWithAccessPublic(stateBean: StateBean): Bool {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (notNullChar.size > currentIndex + 6) {
            if (notNullChar[currentIndex] == r'p' && notNullChar[currentIndex + 1] == r'u'
                && notNullChar[currentIndex + 2] == r'b' && notNullChar[currentIndex + 3] == r'l'
                && notNullChar[currentIndex + 4] == r'i' && notNullChar[currentIndex + 5] == r'c' &&
                notNullChar[currentIndex + 6] == r':') {
                stateBean.isInAccessFlag = true
                let lineBean: LineBean = LineBean()
                let lineCode: String = "public:"
                lineBean.codeLine = lineCode
                lineBean.indentLevel = 0 //访问修饰符没有缩进
                lineBean.smallBracketDouble = stateBean.smallBracketDouble
                lineBean.middleBracketDouble = stateBean.middleBracketDouble
                lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
                lineBean.isInString = stateBean.isInString
                lineBean.isInMacro = stateBean.isInMacro
                lineBean.isInFor = stateBean.isInFor
                stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
                stateBean.perLineOutput = StringBuilder()
                stateBean.isLineStart = true
                stateBean.perLineStartIndex = stateBean.currentIndex + 6 + 1
                stateBean.isInAccessFlag = false
                stateBean.lastChar = r'\n'
                stateBean.currentIndex += 7
                return true
            } else {
                return false
            }
        }
        return false
    }

    /**
     * 处理访问修饰符 private:
     * 
     * @param stateBean 当前解析状态对象
     * @return 是否成功处理
     */
    open public override func dealWithAccessPrivate(stateBean: StateBean): Bool {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (notNullChar.size > currentIndex + 7) {
            if (notNullChar[currentIndex] == r'p' && notNullChar[currentIndex + 1] == r'r' &&
                notNullChar[currentIndex + 2] == r'i' && notNullChar[currentIndex + 3] == r'v' &&
                notNullChar[currentIndex + 4] == r'a' && notNullChar[currentIndex + 5] == r't' &&
                notNullChar[currentIndex + 6] == r'e' && notNullChar[currentIndex + 7] == r':') {
                stateBean.isInAccessFlag = true
                let lineBean: LineBean = LineBean()
                let lineCode: String = "private:"
                lineBean.codeLine = lineCode
                lineBean.indentLevel = 0 //访问修饰符没有缩进
                lineBean.smallBracketDouble = stateBean.smallBracketDouble
                lineBean.middleBracketDouble = stateBean.middleBracketDouble
                lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
                lineBean.isInString = stateBean.isInString
                lineBean.isInMacro = stateBean.isInMacro
                lineBean.isInFor = stateBean.isInFor
                stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
                stateBean.perLineOutput = StringBuilder()
                stateBean.isLineStart = true
                stateBean.perLineStartIndex = stateBean.currentIndex + 7 + 1
                stateBean.isInAccessFlag = false
                stateBean.lastChar = r'\n'
                stateBean.currentIndex += 8
                return true
            } else {
                return false
            }
        }
        return false
    }

    /**
     * 处理访问修饰符 protected:
     * 
     * @param stateBean 当前解析状态对象
     * @return 是否成功处理
     */
    open public override func dealWithAccessProtected(stateBean: StateBean): Bool {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (notNullChar.size > currentIndex + 9) {
            if (notNullChar[currentIndex] == r'p' && notNullChar[currentIndex + 1] == r'r' &&
                notNullChar[currentIndex + 2] == r'o' && notNullChar[currentIndex + 3] == r't' &&
                notNullChar[currentIndex + 4] == r'e' && notNullChar[currentIndex + 5] == r'c' &&
                notNullChar[currentIndex + 6] == r't' && notNullChar[currentIndex + 7] == r'e' &&
                notNullChar[currentIndex + 8] == r'd' && notNullChar[currentIndex + 9] == r':') {
                stateBean.isInAccessFlag = true
                let lineBean: LineBean = LineBean()
                let lineCode: String = "protected:"
                lineBean.codeLine = lineCode
                lineBean.indentLevel = 0 //访问修饰符没有缩进
                lineBean.smallBracketDouble = stateBean.smallBracketDouble
                lineBean.middleBracketDouble = stateBean.middleBracketDouble
                lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
                lineBean.isInString = stateBean.isInString
                lineBean.isInMacro = stateBean.isInMacro
                lineBean.isInFor = stateBean.isInFor
                stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
                stateBean.perLineOutput = StringBuilder()
                stateBean.isLineStart = true
                stateBean.perLineStartIndex = stateBean.currentIndex + 9 + 1
                stateBean.isInAccessFlag = false
                stateBean.lastChar = r'\n'
                stateBean.currentIndex += 10
                return true
            } else {
                return false
            }
        }
        return false
    }

    /**
     * 处理字符串引号
     * 跟踪字符串的开始和结束，防止字符串内的特殊字符被误解析
     * 支持双引号 " 和单引号 '
     * 
     * @param stateBean 当前解析状态对象
     */
    open public override func dealWithString(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        let currChar: Rune = notNullChar[currentIndex]
        var lastChar: Rune = r' '
        if (currentIndex - 1 >= 0) {
            lastChar = notNullChar[currentIndex - 1]
        }
        
        // 检测字符串开始（双引号）
        if ((currChar == r'"' || currChar == r'\'') && !stateBean.isInString) {
            stateBean.stringQuote = currChar
            stateBean.isInString = true
            return
        }
        // 检测字符串结束（处理转义字符）
        if (stateBean.isInString && currChar == stateBean.stringQuote && handleTransferCharacters(notNullChar, currentIndex - 1)) {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
        // 处理换行符强制结束字符串（防止未闭合的字符串）
        if (stateBean.isInString && currChar == r'\n') {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
    }

    /**
     * 处理 for 循环
     * 跟踪 for 循环中的小括号配对，防止括号内的分号被误解析为语句结束
     * 
     * @param stateBean 当前解析状态对象
     */
    open public override func dealWithFor(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        
        // 检测 for 关键字
        if (currentIndex >= 2) {
            if (notNullChar[currentIndex - 2] == r'f' && notNullChar[currentIndex - 1] == r'o' &&
                notNullChar[currentIndex] == r'r') {
                stateBean.isInFor = true
                return
            }
        }
        
        if (stateBean.isInFor) {
            let currChar: Rune = notNullChar[currentIndex]
            if (stateBean.smallBracketDouble == 0) {
                if (!(currChar == r' ' || currChar == r'\t' || currChar == r'(')) {
                    stateBean.isInFor = false
                    return
                }
            }

            // 跟踪小括号配对
            if (currChar == r'(') {
                stateBean.smallBracketDouble++
            }
            if (currChar == r')') {
                stateBean.smallBracketDouble--
                if (stateBean.smallBracketDouble == 0) {
                    stateBean.isInFor = false // 退出 for 循环
                }
            }
        }
    }

    /**
     * 处理分号 ;
     * 分号标志语句结束，保存当前行到 linesList
     * 
     * @param stateBean 当前解析状态对象
     */
    open public override func dealWithSemicolon(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1))
        lineBean.codeLine = lineCode
        lineBean.indentLevel = stateBean.indentLevel
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r';'
        stateBean.currentIndex++
    }

    public func handleTransferCharacters(charArr: Array<Rune>, lastIndex: Int64): Bool {
        var count: Int64 = 0
        var indexChar: Rune = charArr[lastIndex - count]
        while (indexChar == r'\\') {
            count++
            if (lastIndex - count < 0) {
                break
            }
            indexChar = charArr[lastIndex - count]
        }
        if (count % 2 == 0) {
            return true
        } else {
            return false
        }
    }
}