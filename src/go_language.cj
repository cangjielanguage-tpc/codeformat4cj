package codeformat

class GoFormat <: GeneralProcessing {
    public func dealWithImport(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        var importMoreThanOne = false
        if (currentIndex >= 6) {
            if (notNullChar[currentIndex - 6] == r'i' && notNullChar[currentIndex - 5] == r'm' &&
                notNullChar[currentIndex - 4] == r'p' && notNullChar[currentIndex - 3] == r'o' &&
                notNullChar[currentIndex - 2] == r'r' && notNullChar[currentIndex - 1] == r't' &&
                notNullChar[currentIndex] == r' ') {
                var currChar: Rune = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
                while (currChar != r'"') {
                    if (stateBean.currentIndex == stateBean.codeChars.getOrThrow().size - 1) {
                        break
                    }
                    stateBean.currentIndex++
                    currChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
                    stateBean.perLineOutput.append(currChar)
                }
                let lineEndIndex: Int64 = stateBean.currentIndex
                let lineCode: String = String(
                    stateBean.codeChars.getOrThrow().slice(currentIndex, lineEndIndex - currentIndex + 1))
                var nextmatchchar = r' '
                if (lineCode.contains("(")) {
                    importMoreThanOne = true
                    nextmatchchar = r')'
                } else {
                    importMoreThanOne = false
                    nextmatchchar = r'"'
                }
                if (stateBean.currentIndex < stateBean.codeChars.getOrThrow().size - 1) {
                    //如果没有(代码读到后面那个"，否则代码读到后面那个)
                    stateBean.currentIndex++
                    var nextChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
                    stateBean.perLineOutput.append(nextChar)

                    while (nextChar != nextmatchchar) {
                        if (stateBean.currentIndex == stateBean.codeChars.getOrThrow().size - 1) {
                            break
                        }
                        stateBean.currentIndex++
                        nextChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
                        stateBean.perLineOutput.append(nextChar)
                    }
                    let lineEndIndex2: Int64 = stateBean.currentIndex
                    let lineCode2: String = String(
                        stateBean.codeChars.getOrThrow().slice(currentIndex, lineEndIndex2 - currentIndex + 1))
                    let lineBeanstart: LineBean = LineBean()
                    let lineBeanend: LineBean = LineBean()
                    if (importMoreThanOne) {
                        lineBeanstart.codeLine = "import ("
                        lineBeanstart.indentLevel = 0
                        stateBean.linesList.add(lineBeanstart)
                        var dealStr = lineCode2.trimAscii().replace("(", "").replace(")", "")
                        var listStr: ArrayList<String> = ArrayList<String>()
                        if (dealStr.contains("\n")) {
                            listStr = ArrayList<String>(dealStr.split("\n"))
                        } else {
                            listStr = ArrayList<String>(dealStr.split(";"))
                        }
                        for (str in listStr) {
                            let lineBeanmid: LineBean = LineBean()
                            lineBeanmid.codeLine = str
                            lineBeanmid.indentLevel = 1
                            stateBean.linesList.add(lineBeanmid)
                        }
                        lineBeanend.codeLine = ")"
                        lineBeanend.indentLevel = 0
                        lineBeanend.isSingleLine = true
                        stateBean.linesList.add(lineBeanend)
                    } else {
                        lineBeanstart.codeLine = "import " + lineCode2.trimAscii()
                        lineBeanstart.indentLevel = 0
                        stateBean.linesList.add(lineBeanstart)
                    }
                    stateBean.perLineOutput = StringBuilder()
                    stateBean.isLineStart = true
                    stateBean.perLineStartIndex = stateBean.currentIndex + 1
                    stateBean.lastChar = r'\n'
                    stateBean.currentIndex++
                    return
                }
            }
        }
    }

    public override func dealWithString(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        let currChar: Rune = notNullChar[currentIndex]
        var lastChar: Rune = r' '
        if (currentIndex - 1 >= 0) {
            lastChar = notNullChar[currentIndex - 1]
        }
        if ((currChar == r'"' || currChar == r'\'') && !stateBean.isInString && !stateBean.isInBackQuote) {
            stateBean.stringQuote = currChar
            stateBean.isInString = true
            return
        }
        if (currChar == r'`' && !stateBean.isInString && !stateBean.isInBackQuote) {
            stateBean.stringQuote = currChar
            stateBean.isInString = true
            stateBean.isInBackQuote = true
        }

        if (stateBean.isInString && currChar == stateBean.stringQuote && handleTransferCharacters(notNullChar, currentIndex - 1)) {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
        //解决错误情况单个"号导致字符串没法关闭的情况
        if (stateBean.isInString && currChar == r'\n' && lastChar != r'v' && (currChar == r'"' || currChar == r'\'')) {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
        if (stateBean.isInBackQuote && currChar == stateBean.stringQuote && handleTransferCharacters(notNullChar, currentIndex - 1)) {
            stateBean.isInBackQuote = false
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

            if (currChar == r'{') { //主要是用于for循环中的()成对
                stateBean.isInFor = false
            }
        }
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
                    //template <typename T, int DEFAULT_SIZE = 10> /* 带默认模板参数    
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

                if (!stateBean.isInString) {
                    dealWithImport(stateBean)
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
                        if (!lineBean.singlelineCommentisAfterChangeLine) {
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
                        if (!lineBean.multilineCommentisAfterChangeLine) {
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
            //在go语言中这种情况要改下 go可以没分号

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

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (!lineBean.isSingleLine) {
                    if ((lineBean.codeLine.trimAscii() == ";" ||
                    lineBean.codeLine.trimAscii() == "," || lineBean.codeLine.trimAscii() == "()") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                        //如果当前行是这些字符串就和上一行连在一起
                        if (i > 0) {
                            let lastLineBean: LineBean = stateBean.linesList[i - 1]
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine.trimAscii())
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
                if (((codeStr.startsWith("else{")) || (codeStr.startsWith("elseif("))) &&
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
                if ((codeStr.startsWith("if ") || codeStr.startsWith("switch ")) && codeStr.endsWith(";") && !lineBean.isInMultilineComment &&
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


            //处理单行只有)但是上一行只有}结尾的情况
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr == ")" && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i > 0) {
                        //有上一行，看上一行的结束是不是\n
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii() =="}") {
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


             //处理interface{}=问题   
             for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.trimAscii() == "}" && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i > 0) {
                        //有上一行，看上一行的结束是不是\n
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith("interface{")) {
                            //上一行只有}那么合并这两行
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine.trimAscii())
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)    

            //处理interface{}=问题   
             for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith("=") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i > 0) {
                        //有上一行，看上一行的结束是不是\n
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith("interface{}")) {
                            //上一行只有}那么合并这两行
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine.trimAscii())
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)  






            //去除了对macro宏的逻辑，如果是#开头的宏代码 lineBean的indentLevel还是要设置一下，不然会有问题
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith("#") && !lineBean.isInMultilineComment) {
                    lineBean.indentLevel = 0
                }
            }

                //巧妙处理swicth的缩进

                var inSwitchBlock = false
                var needIndent = false

                for (i in 0..stateBean.linesList.size) {
                    let line = stateBean.linesList[i]
                    let t = line.codeLine.trimAscii()

                    // 1. 进入 switch {
                    if (t.startsWith("switch ") && t.contains("{")) {
                        inSwitchBlock = true
                        needIndent = false
                    }

                    // 2. 离开 switch }
                    if (t == "}" && inSwitchBlock) {
                        inSwitchBlock = false
                        needIndent = false
                    }

                    // 3. 只在 switch 内部生效
                    if (inSwitchBlock) {
                        if (t.startsWith("case ") || t.startsWith("default")) {
                            // case / default → 缩进 1 级
                            //line.indentLevel = line.indentLevel+1
                            needIndent = true
                        } else if (needIndent) {
                            // case 下面一行 → 再缩进 1 级（总共 2 级）
                            line.indentLevel = line.indentLevel+1
                        }
                    }
                }


             //巧妙处理array

                var inArrayBlock = false
                var strBuilder:StringBuilder = StringBuilder()
                for (i in 0..stateBean.linesList.size) {
                    let line = stateBean.linesList[i]
                    let t = line.codeLine.trimAscii().replace(" ","")

                    if (t.endsWith("]int{")||t.endsWith("]string{")||t.endsWith("]float64{")||t.contains("]int{//")||t.contains("]string{//")||t.contains("]float64{//")) {
                        if(!(t.contains("][") || t.contains("] ["))){
                            inArrayBlock = true
                        }
                    }


                    if ((t == "}" || t.contains("}//") || t.contains("}/*")) && inArrayBlock) {
                        strBuilder.append(line.codeLine)
                        line.codeLine = strBuilder.toString()
                        inArrayBlock = false
                        strBuilder = StringBuilder()
                    }

                    if (inArrayBlock) {
                        line.isDiscarded = true
                        strBuilder.append(line.codeLine.trimAscii())
                    }
                }

                removediscard(stateBean)




                 //巧妙处理Doublearray

                var inDoubleArrayBlock = false
                var SubArrayBlock = false
                strBuilder = StringBuilder()
                for (i in 0..stateBean.linesList.size) {
                    let line = stateBean.linesList[i]
                    let t = line.codeLine.trimAscii().replace(" ","")

                    if (t.endsWith("]int{")||t.endsWith("]string{")||t.endsWith("]float64{")||t.contains("]int{//")||t.contains("]string{//")||t.contains("]float64{//")) {
                        if((t.contains("][") || t.contains("] ["))){
                            inDoubleArrayBlock = true
                        }
                    }

                    if((t == "{" || t.contains("{//") || t.contains("{/*")) && inDoubleArrayBlock){
                        SubArrayBlock = true
                    }

                    if((t == "},"|| t.contains("},//") || t.contains("},/*")) && inDoubleArrayBlock){
                        strBuilder.append(line.codeLine)
                        line.codeLine = strBuilder.toString()
                        SubArrayBlock = false
                        strBuilder = StringBuilder()
                    }


                    if ((t == "}" || t.contains("}//") || t.contains("}/*")) && inDoubleArrayBlock) {
                        inDoubleArrayBlock = false
                        strBuilder = StringBuilder()
                    }

                    if (inDoubleArrayBlock) {
                        if(SubArrayBlock){
                            //进来了
                            line.isDiscarded = true
                            strBuilder.append(line.codeLine.trimAscii())
                        }
                    }
                }

                removediscard(stateBean)



               //处理分组声明
                var isInFactoredDeclaration = false

                for (i in 0..stateBean.linesList.size) {
                    let line = stateBean.linesList[i]
                    let t = line.codeLine.trimAscii().replace(" ","")

                    // 1. 进入 switch {
                    if (t.startsWith("const(") || t.startsWith("var(")) {
                        isInFactoredDeclaration = true
                        continue
                    }

                    // 2. 离开 switch }
                    if (t == ")" && isInFactoredDeclaration) {
                        isInFactoredDeclaration = false
                    }

                    // 3. 只在 switch 内部生效
                    if (isInFactoredDeclaration) {
                        line.indentLevel = line.indentLevel+1
                    }
                }




                for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (!lineBean.isSingleLine) {
                    let codeStr = lineBean.codeLine.trimAscii().replace(" ","")
                    if ( (codeStr == "){" || codeStr == "{")  && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                        //如果当前行是这些字符串就和上一行连在一起
                        if (i > 0) {
                            let lastLineBean: LineBean = stateBean.linesList[i - 1]
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine.trimAscii())
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            //过滤单行废弃
            removediscard(stateBean)



            // 处理`符号的多行字符串，防止使用缩进可能导致源码被修改
            var x = 1
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (x != 1) {
                    lineBean.indentLevel = 0
                    x--
                    continue
                }
                // 过滤没使用`符号字符串
                if (!lineBean.codeLine.contains("`")) {
                    continue
                }
                // 过滤使用`的单行字符串
                if (lineBean.codeLine.contains("`") && lineBean.codeLine.trimAscii().endsWith("`") && lineBean.codeLine.count("`") > 1) {
                    continue
                }
                // 过滤使用了转义的`符号
                if (lineBean.codeLine.contains("`") && 
                !(lineBean.codeLine.trimAscii() == "`") &&
                !handleTransferCharacters(lineBean.codeLine.toRuneArray(), lineBean.codeLine.indexOf("`").getOrThrow() - 1)) {
                    continue
                }
                var nextLineBean = stateBean.linesList[i + x]
                while (!(nextLineBean.codeLine.trimAscii().endsWith("`") &&
                (lineBean.codeLine.trimAscii() == "`" || handleTransferCharacters(lineBean.codeLine.toRuneArray(), lineBean.codeLine.indexOf("`").getOrThrow() - 1)))) {
                    x++
                    nextLineBean = stateBean.linesList[i + x]
                }
                x++
            }

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
