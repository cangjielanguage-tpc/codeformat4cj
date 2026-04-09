package codeformat

class KotlinFormat <: BaseLanguage {
    public override func dealWithNewLine(stateBean: StateBean): Unit {
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
            stateBean.linesList.add(lineBean) //这里保存了
            stateBean.perLineOutput = StringBuilder()
            stateBean.perLineStartIndex = stateBean.currentIndex + 1
            stateBean.lastChar = r'\n'
        }
    }

    public override func dealWithLeftBigBracket(stateBean: StateBean): Unit {
        //这里是先把一行选出来
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel //当前还是0级
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.indentLevel++ //下一个层级才加1
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'{'
        stateBean.currentIndex++
    }

    public override func dealWithRightBigBracket(stateBean: StateBean): Unit {
        //这里是先把一行选出来
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        stateBean.indentLevel--
        lineBean.indentLevel = stateBean.indentLevel //当前层级是减去一层后的了
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'}'
        stateBean.currentIndex++
    }

    public override func dealWithSingleLineComment(stateBean: StateBean, perStr: String): Unit {
        stateBean.isInSinglelineComment = true
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = stateBean.codeChars.getOrThrow()[stateBean.currentIndex] //中的第二个/

        //往前循环看看有多少空格
        var beforeSpaceCount: Int64 = 0
        var beforeSpaceIndex = stateBean.currentIndex - 2 //第一个/开始 再前面一个是/的前面一个
        while (beforeSpaceIndex >= 0 && stateBean.codeChars.getOrThrow()[beforeSpaceIndex] == r' ') {
            beforeSpaceCount++
            beforeSpaceIndex--
        }
        // //单行前面是不是换行 判断这个单行注释是不是单独一行
        var tempSingleLineAfterChangLine: Bool = false
        if (beforeSpaceIndex < 0) { //值为-1
            //表示是第一行
            tempSingleLineAfterChangLine = true
        } else {
            let char: Rune = stateBean.codeChars.getOrThrow()[beforeSpaceIndex]
            if (char == r'\n') {
                tempSingleLineAfterChangLine = true
            } else {
                tempSingleLineAfterChangLine = false
            }
        }

        if (perStr.size > 0) {
            //出现这个perStr有值的情况表示单行注释已经和前面的内容连接起来了，不用考虑这个tempSingleLineAfterChangLine了
            //因为下面有lineBean.codeLine = perStr+lineCode
            tempSingleLineAfterChangLine = true
        }

        //上面是往前遍历  下面是往后遍历
        while (currChar != r'\n') {
            if (stateBean.currentIndex == stateBean.codeChars.getOrThrow().size - 1) {
                break
            }
            stateBean.currentIndex++
            currChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
            stateBean.perLineOutput.append(currChar)
        }
        let lineEndIndex: Int64 = stateBean.currentIndex
        //从前面那个/算起     /012 //012
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex - 1, lineEndIndex - lineStartIndex + 1 + 1))
        lineBean.codeLine = perStr + lineCode
        //单行注释的缩进和StateBean一致
        lineBean.indentLevel = stateBean.indentLevel
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        lineBean.isInSinglelineComment = stateBean.isInSinglelineComment
        lineBean.singleLineWhiteSpace = beforeSpaceCount
        lineBean.singlelineCommentisAfterChangline = tempSingleLineAfterChangLine
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'\n'
        stateBean.currentIndex++
        stateBean.isInSinglelineComment = false
    }

    public override func dealWithMultiLineComment(stateBean: StateBean, perStr: String): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        stateBean.isInMultilineComment = true
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = notNullChar[stateBean.currentIndex] // /*中的*
        var lastChar: Rune = r'/'
        //往前循环看看有多少空格
        var beforeSpaceCount: Int64 = 0
        var beforeSpaceIndex = stateBean.currentIndex - 2 //第一个*开始 再前面一个是/
        while (beforeSpaceIndex >= 0 && notNullChar[beforeSpaceIndex] == r' ') {
            beforeSpaceCount++
            beforeSpaceIndex--
        }
        // //多行第一行前面是不是换行 判断这个多行第一行注释是不是单独一行
        var tempMultiLineAfterChangLine: Bool = false
        if (beforeSpaceIndex < 0) { //值为-1
            //表示是第一行
            tempMultiLineAfterChangLine = true
        } else {
            let char: Rune = notNullChar[beforeSpaceIndex]
            if (char == r'\n') {
                tempMultiLineAfterChangLine = true
            } else {
                tempMultiLineAfterChangLine = false
            }
        }

        if (perStr.size > 0) {
            //出现这个perStr有值的情况表示单行注释已经和前面的内容连接起来了，不用考虑这个tempSingleLineAfterChangLine了
            tempMultiLineAfterChangLine = true
        }
        //这个跟单行注释不一样 如果前面有内容就只加一个 空格
        if (notNullChar.size > stateBean.currentIndex + 2) {
            stateBean.currentIndex += 2
            let newcurrentIndex = stateBean.currentIndex
            lastChar = notNullChar[newcurrentIndex - 1]
            currChar = notNullChar[newcurrentIndex]
            //因为跳跃了 所以这里补上
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
            //说明长度不够不符合多行注释 很小情况
            if (notNullChar.size > stateBean.currentIndex + 1) {
                stateBean.currentIndex++
            }
        }

        //到这里就是结束的Index了
        let lineEndIndex: Int64 = stateBean.currentIndex
        var lineCodeAll: String = String(notNullChar.slice(lineStartIndex - 1, lineEndIndex - lineStartIndex + 1 + 1))
        lineCodeAll = perStr + lineCodeAll
        //然后这里面的内容根据\n分为几行 解析为几个LineBean
        let lineCodeList: Array<String> = lineCodeAll.split("\n")
        for (index in 0..lineCodeList.size) {
            let lineBean: LineBean = LineBean()
            lineBean.codeLine = lineCodeList[index]
            if (index == 0) {
                lineBean.isFirstMultiCommentLine = true
                lineBean.mutlilineCommentisAfterChangline = tempMultiLineAfterChangLine
            }
            //多行注释的缩进和StateBean一致
            lineBean.indentLevel = stateBean.indentLevel
            lineBean.smallBracketDouble = stateBean.smallBracketDouble
            lineBean.middleBracketDouble = stateBean.middleBracketDouble
            lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
            lineBean.isInString = stateBean.isInString
            lineBean.isInMacro = stateBean.isInMacro
            lineBean.isInFor = stateBean.isInFor
            lineBean.isInMultilineComment = stateBean.isInMultilineComment
            //多行的时候跟单行注释不一样 如果前面有内容就只加一个 空格
            stateBean.linesList.add(lineBean)
            stateBean.perLineOutput = StringBuilder()
        }
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'\n'
        stateBean.currentIndex++
        stateBean.isInMultilineComment = false
    }

    public override func dealWithMacro(stateBean: StateBean): Unit {
    }

    public override func dealWithAccessPublic(stateBean: StateBean): Bool {
        return false
    }

    public override func dealWithAccessPrivate(stateBean: StateBean): Bool {
        return false
    }

    public override func dealWithAccessProtected(stateBean: StateBean): Bool {
        return false
    }

    public override func dealWithString(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        let currChar: Rune = notNullChar[currentIndex]
        var lastChar: Rune = r' '
        if (currentIndex - 1 >= 0) {
            lastChar = notNullChar[currentIndex - 1]
        }
        if ((currChar == r'"') && !stateBean.isInString) {
            stateBean.stringQuote = currChar
            stateBean.isInString = true
            return
        }
        if (stateBean.isInString && currChar == stateBean.stringQuote && lastChar != r'\\') {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
        //解决错误情况单个"号导致字符串没法关闭的情况
        if (stateBean.isInString && currChar == r'\n') {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
    }

    public override func dealWithFor(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 2) {
            if (notNullChar[currentIndex - 2] == r'f' && notNullChar[currentIndex - 1] == r'o' &&
                notNullChar[currentIndex] == r'r') {
                stateBean.isInFor = true
                return
            }
        }
        if (stateBean.isInFor) {
            //这里要检测for之后除了空格第一个字符如果不是(那就没有进for
            let currChar: Rune = notNullChar[currentIndex]

            if (currChar == r'{' || currChar == r'}') { //主要是用于for循环中的()成对
                stateBean.isInFor = false
            }
        }
    }

    public override func dealWithSemicolon(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r';'
        stateBean.currentIndex++
    }

    // 核心格式化函数（整合缩进+换行规则）
    func formatCode(rawCode: String, cfg: FormatConfig): String {
        //每一次的状态变量
        let stateBean: StateBean = StateBean()
        //先把代码分割成诺干行
        stateBean.linesList = ArrayList<LineBean>()
        stateBean.codeChars = rawCode.toRuneArray()
        if (let Some(i) <- stateBean.codeChars) {
            let len = i.size
            if (len == 0) {
                return ""
            }
            while (stateBean.currentIndex < len) {
                let currChar = i[stateBean.currentIndex]
                //没解析完成的话保留在perLineOutput里
                stateBean.perLineOutput.append(currChar)
                //处理单行注释
                if (currChar == r'/' && stateBean.lastChar == r'/' && !stateBean.isInString) {
                    //这里先判断这种情况 前面没结束符号 不处理的话前面的内容会消失
                    //template <typename T, int DEFAULT_SIZE = 10> // 带默认模板参数    
                    var str = stateBean.perLineOutput.toString().removeSuffix("//")
                    if (str.trimAscii().size > 0) {
                        dealWithSingleLineComment(stateBean, str)
                    } else {
                        dealWithSingleLineComment(stateBean, "")
                    }
                    continue
                }
                //处理多行注释
                if (currChar == r'*' && stateBean.lastChar == r'/' && !stateBean.isInString) {
                    //这里先判断这种情况 前面没结束符号 不处理的话前面的内容会消失
                    var str = stateBean.perLineOutput.toString().removeSuffix("/*")
                    if (str.trimAscii().size > 0) {
                        dealWithMultiLineComment(stateBean, str)
                    } else {
                        dealWithMultiLineComment(stateBean, "")
                    }
                    continue
                }
                dealWithString(stateBean)
                if (!stateBean.isInString) {
                    dealWithFor(stateBean)
                }

                if (currChar == r'{' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    //处理左大括号逻辑
                    dealWithLeftBigBracket(stateBean)
                    continue
                }
                if (currChar == r'}' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    //处理右大括号逻辑
                    dealWithRightBigBracket(stateBean)
                    continue
                }
                if (currChar == r';' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    //处理分号逻辑
                    dealWithSemicolon(stateBean)
                    continue
                }
                if (currChar == r'\n' && !stateBean.isInString) {
                    //进入这里没有进入上面也要加到一行，不然会失去数据
                    dealWithNewLine(stateBean)
                    stateBean.isLineStart = true
                } else {
                    //如果LineStart为true,但是接下来是一些空格开头，那么不应该更改状态
                    if (stateBean.isLineStart && (currChar == r' ' || currChar == r'\t')) {
                        //这种情况依然是isLineStart = true
                        stateBean.isLineStart = true
                    } else {
                        stateBean.isLineStart = false
                    }
                }
                stateBean.lastChar = currChar
                stateBean.currentIndex++
            }
            //在这里处理stateBean.perLineOutput还有剩余数据的问题
            dealWithNewLine(stateBean)

            //这里走完的话就收集到了
            //这里lineList开始处理了
            //处理单行注释合并问题
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.isInSinglelineComment) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i > 0) {
                        //有上一行，看上一行的结束是不是\n
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (!lineBean.singlelineCommentisAfterChangline) {
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            for (j in 0..lineBean.singleLineWhiteSpace) {
                                stringbuilder.append(" ")
                            }
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            //处理多行注释合并问题
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.isInMultilineComment && lineBean.isFirstMultiCommentLine) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i > 0) {
                        //有上一行，看上一行的结束是不是\n
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (!lineBean.mutlilineCommentisAfterChangline) {
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            //多行前面有内容 只要隔个一个空格
                            stringbuilder.append(" ")
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }

            //如果只有一个换行就过滤
            removeOnlyChangeLine(stateBean)

            //这里处理如果}前面还有内容就和上一行连在一起解决数组中的{}问题
            //在go语言中这种情况要改下

            let tempArr: ArrayList<LineBean> = ArrayList<LineBean>()

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.codeLine.trimAscii().endsWith("}") && lineBean.codeLine.trimAscii().size > 1 &&
                    !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    let lineBeanNew: LineBean = LineBean()
                    lineBeanNew.codeLine = "}"
                    lineBeanNew.indentLevel = lineBean.indentLevel

                    lineBean.codeLine = String(
                        lineBean.codeLine.toRuneArray().slice(0, lineBean.codeLine.toRuneArray().size - 1))
                    lineBean.indentLevel = lineBean.indentLevel + 1

                    tempArr.add(lineBean)
                    tempArr.add(lineBeanNew)
                } else {
                    tempArr.add(lineBean)
                }
            }
            stateBean.linesList = tempArr
            //去除一次废弃内容
            //这里修改}后面如果是；就连在一起
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (!lineBean.isSingleLine) {
                    if ((lineBean.codeLine.trimAscii() == ";" || lineBean.codeLine.trimAscii() == ")" ||
                        lineBean.codeLine.trimAscii() == "()") && !lineBean.isInMultilineComment &&
                        !lineBean.isInSinglelineComment) {
                        //如果当前行是单行注释，那就看他有没有上一行
                        if (i > 0) {
                            //有上一行，看上一行的结束是不是\n
                            let lastLineBean: LineBean = stateBean.linesList[i - 1]
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            //过滤单行废弃
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (((codeStr.startsWith("else{")) || (codeStr.startsWith("elseif(")) || (codeStr.startsWith("catch("))) &&
                    !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i > 0) {
                        //有上一行，看上一行的结束是不是\n
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii() == "}") {
                            //上一行只有}那么合并这两行
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            //如果if开头 ;结尾和下一行连在一起
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr.startsWith("if ") && codeStr.endsWith(";") && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i < stateBean.linesList.size - 1) {
                        //有上一行，看上一行的结束是不是\n
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        let stringbuilder: StringBuilder = StringBuilder()
                        stringbuilder.append(lineBean.codeLine)
                        stringbuilder.append(nextLineBean.codeLine)
                        lineBean.codeLine = stringbuilder.toString()
                        nextLineBean.isDiscarded = true
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr.startsWith(".") && codeStr.endsWith("{") && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i > 0) {
                        //有上一行，看上一行是不是}
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii() == "}") {
                            //上一行是}结尾那么合并这两行
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            //处理单行只有);但是上一行是}结尾的情况
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith(");") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i > 0) {
                        //有上一行，看上一行的结束是不是\n
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith("}")) {
                            //上一行以}结尾那么合并这两行
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            //获得最终的list
            let usefulList: ArrayList<LineBean> = stateBean.linesList
            for (item in usefulList) {
                item.codeLine = item.codeLine.trimAscii()
            }
            //修改#开始的宏和后面空格不一致问题
            modifyMacroAndSpace(stateBean)

            //最后根据缩进拼接
            for (index in 0..usefulList.size) {
                let item: LineBean = usefulList[index]
                addIndent(stateBean.output, item.indentLevel, cfg)
                stateBean.output.append(item.codeLine)
                if (index != usefulList.size - 1) {
                    stateBean.output.append("\n")
                }
            }
            return stateBean.output.toString()
        } else {
            return ""
        }
    }
}
