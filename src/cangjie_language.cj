package codeformat

class CangjieFormat <: GeneralProcessing {

    // 处理访问修饰符 public
    public override func dealWithAccessPublic(stateBean: StateBean): Bool {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (notNullChar.size > currentIndex + 6) {
            if (notNullChar[currentIndex] == r'p' && notNullChar[currentIndex + 1] == r'u' &&
                notNullChar[currentIndex + 2] == r'b' && notNullChar[currentIndex + 3] == r'l' &&
                notNullChar[currentIndex + 4] == r'i' && notNullChar[currentIndex + 5] == r'c') {
                // Cangjie 语言的访问修饰符后面没有冒号
                stateBean.isInAccessFlag = true
                let lineBean: LineBean = LineBean()
                let lineCode: String = "public"
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

    // 处理访问修饰符 private
    public override func dealWithAccessPrivate(stateBean: StateBean): Bool {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (notNullChar.size > currentIndex + 7) {
            if (notNullChar[currentIndex] == r'p' && notNullChar[currentIndex + 1] == r'r' &&
                notNullChar[currentIndex + 2] == r'i' && notNullChar[currentIndex + 3] == r'v' &&
                notNullChar[currentIndex + 4] == r'a' && notNullChar[currentIndex + 5] == r't' &&
                notNullChar[currentIndex + 6] == r'e') {
                // Cangjie 语言的访问修饰符后面没有冒号
                stateBean.isInAccessFlag = true
                let lineBean: LineBean = LineBean()
                let lineCode: String = "private"
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

    // 处理访问修饰符 protected
    public override func dealWithAccessProtected(stateBean: StateBean): Bool {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (notNullChar.size > currentIndex + 9) {
            if (notNullChar[currentIndex] == r'p' && notNullChar[currentIndex + 1] == r'r' &&
                notNullChar[currentIndex + 2] == r'o' && notNullChar[currentIndex + 3] == r't' &&
                notNullChar[currentIndex + 4] == r'e' && notNullChar[currentIndex + 5] == r'c' &&
                notNullChar[currentIndex + 6] == r't' && notNullChar[currentIndex + 7] == r'e' &&
                notNullChar[currentIndex + 8] == r'd') {
                // Cangjie 语言的访问修饰符后面没有冒号
                stateBean.isInAccessFlag = true
                let lineBean: LineBean = LineBean()
                let lineCode: String = "protected"
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

    // 核心格式化函数（整合缩进+换行规则）
    func formatCode(rawCode: String, cfg: FormatConfig): String {
        // 每一次的状态变量
        let stateBean: StateBean = StateBean()
        // 先把代码分割成诺干行
        stateBean.linesList = ArrayList<LineBean>()
        stateBean.codeChars = rawCode.toRuneArray()
        if (let Some(i) <- stateBean.codeChars) {
            let len = i.size
            if (len == 0) {
                return ""
            }
            while (stateBean.currentIndex < len) {
                let currChar = i[stateBean.currentIndex]
                // 没解析完成的话保留在perLineOutput里
                stateBean.perLineOutput.append(currChar)
                // 处理访问修饰符
                if (stateBean.isLineStart) {
                    if (dealWithAccessPublic(stateBean)) {
                        continue
                    }
                    if (dealWithAccessPrivate(stateBean)) {
                        continue
                    }
                    if (dealWithAccessProtected(stateBean)) {
                        continue
                    }
                }
                // 处理单行注释
                if (currChar == r'/' && stateBean.lastChar == r'/' && !stateBean.isInString) {
                    var str = stateBean.perLineOutput.toString().removeSuffix("//")
                    if (str.trimAscii().size > 0) {
                        dealWithSingleLineComment(stateBean, str)
                    } else {
                        dealWithSingleLineComment(stateBean, "")
                    }
                    continue
                }
                // 处理多行注释
                if (currChar == r'*' && stateBean.lastChar == r'/' && !stateBean.isInString) {
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

                // 处理反引号
                if (currChar == r'`' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    if (!stateBean.isInBackQuote) {
                        stateBean.isInBackQuote = true
                    } else {
                        stateBean.isInBackQuote = false
                    }
                }

                if (currChar == r'{' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor &&
                    !stateBean.isInBackQuote) {
                    // 处理左大括号逻辑
                    dealWithLeftBigBracket(stateBean)
                    continue
                }
                if (currChar == r'}' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor &&
                    !stateBean.isInBackQuote) {
                    // 处理右大括号逻辑
                    dealWithRightBigBracket(stateBean)
                    continue
                }
                if (currChar == r';' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    // 处理分号逻辑
                    dealWithSemicolon(stateBean)
                    continue
                }
                if (currChar == r'\n' && !stateBean.isInString) {
                    // 进入这里没有进入上面也要加到一行，不然会失去数据
                    dealWithNewLine(stateBean)
                    stateBean.isLineStart = true
                } else {
                    // 如果LineStart为true,但是接下来是一些空格开头，那么不应该更改状态
                    if (stateBean.isLineStart && (currChar == r' ' || currChar == r'\t')) {
                        stateBean.isLineStart = true
                    } else {
                        stateBean.isLineStart = false
                    }
                }
                stateBean.lastChar = currChar
                stateBean.currentIndex++
            }
            // 在这里处理stateBean.perLineOutput还有剩余数据的问题
            dealWithNewLine(stateBean)

            // 处理单行注释合并问题
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (!lineBean.singlelineCommentisAfterChangeLine) {
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
            // 处理多行注释合并问题
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.isInMultilineComment && lineBean.isFirstMultiCommentLine) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (!lineBean.multilineCommentisAfterChangeLine) {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            stringbuilder.append(" ")
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }

            // 如果只有一个换行就过滤
            removeOnlyChangeLine(stateBean)
            // 这里处理如果}前面还有内容就和上一行连在一起解决数组中的{}问题
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.codeLine.trimAscii().endsWith("}") && lineBean.codeLine.trimAscii().size > 1 &&
                    !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (!lastLineBean.isDiscarded) {
                            if (!lastLineBean.codeLine.trimAscii().endsWith(";")) {
                                let stringbuilder: StringBuilder = StringBuilder()
                                stringbuilder.append(lastLineBean.codeLine)
                                stringbuilder.append(lineBean.codeLine.trimAscii())
                                lastLineBean.codeLine = stringbuilder.toString()
                                lineBean.isDiscarded = true
                            }
                        }
                    }
                }
            }
            // 去除一次废弃内容
            removediscard(stateBean)
            // 这里修改}后面如果是；就连在一起
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.codeLine.trimAscii() == ";" && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        let stringbuilder: StringBuilder = StringBuilder()
                        stringbuilder.append(lastLineBean.codeLine.replace("\n", ""))
                        stringbuilder.append(lineBean.codeLine)
                        lastLineBean.codeLine = stringbuilder.toString()
                        lineBean.isDiscarded = true
                    }
                }
            }
            // 过滤单行废弃
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if ((((codeStr.startsWith("while(")) && (!codeStr.contains("{"))) || (codeStr.startsWith(",")) || (codeStr
                    .startsWith("finally{")) || (codeStr.startsWith("else{")) || (codeStr.startsWith("elseif(")) || (codeStr
                    .startsWith("catch("))) && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii() == "}") {
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

            // 处理上一行,结尾 下一行是];结尾的情况
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if ((codeStr.endsWith("];") || codeStr.endsWith("]")) && !codeStr.contains("[") &&
                    !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith(",")) {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine.trimAscii())
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            lastLineBean.codeLine = stringbuilder.toString().replace("\n", "")
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            // 处理单行只有);但是上一行是}结尾的情况
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith(");") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith("}")) {
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

            // 处理if()后面没有{，下一行有，就下一行就和他一起
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith("if(") && (codeStr.endsWith(")")) && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    let nextLineBean: LineBean = stateBean.linesList[i + 1]
                    if (i < stateBean.linesList.size - 1 && nextLineBean.codeLine.trimAscii().replace(" ", "").endsWith("{")) {
                        let stringbuilder: StringBuilder = StringBuilder()
                        stringbuilder.append(lineBean.codeLine.trimAscii() + " ")
                        stringbuilder.append(nextLineBean.codeLine.trimAscii())
                        lineBean.codeLine = stringbuilder.toString().replace("\n", "")
                        nextLineBean.isDiscarded = true
                    }
                }
            }
            removediscard(stateBean)

            // 处理if(...\n...){场景(当if中的判断条件换行时，换行之后的条件代码需要缩进加一)
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith("if(") && !(codeStr.endsWith("){")) && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    var j = 1
                    var nextLineBean: LineBean = stateBean.linesList[i + j]
                    while (!nextLineBean.codeLine.trimAscii().replace(" ", "").endsWith("){")) {
                        nextLineBean.indentLevel++
                        j++
                        nextLineBean = stateBean.linesList[i + j]
                    }
                    nextLineBean.indentLevel++
                }
            }
            removediscard(stateBean)

            // 处理数组场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.trimAscii().endsWith("[") && 
                codeStr.replace(" ", "").contains("=[") &&
                !lineBean.isInMultilineComment && 
                !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        var x = 1
                        var nextLineBean: LineBean = stateBean.linesList[i + x]
                        var leftBrace = 0
                        while (!((leftBrace + nextLineBean.codeLine.count("[") - nextLineBean.codeLine.count("]") == -1) &&
                        (nextLineBean.codeLine.trimAscii() == "]" || nextLineBean.codeLine.trimAscii() == "];"))) {
                            leftBrace = leftBrace + nextLineBean.codeLine.count("[") - nextLineBean.codeLine.count("]")
                            nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                            x++
                            nextLineBean = stateBean.linesList[i + x]
                        }
                    }
                }
            }
            removediscard(stateBean)

            // 处理修饰符场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if ((codeStr.trimAscii() == "private" || 
                codeStr.trimAscii() == "public" ||
                codeStr.trimAscii() == "protected") &&
                !lineBean.isInMultilineComment && 
                !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        var nextLineBean: LineBean = stateBean.linesList[i + 1]
                        lineBean.codeLine = codeStr.trimAscii() + " " + nextLineBean.codeLine.trimAscii()
                        nextLineBean.isDiscarded = true
                    }
                }
            }
            removediscard(stateBean)

            // 处理return场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.trimAscii().startsWith("return") && 
                codeStr.trimAscii().endsWith("(") &&
                !lineBean.isInMultilineComment && 
                !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        var x = 1
                        var nextLineBean: LineBean = stateBean.linesList[i + x]
                        var leftBrace = 0
                        while (!((leftBrace + nextLineBean.codeLine.count("(") - nextLineBean.codeLine.count(")") == -1) &&
                        nextLineBean.codeLine.trimAscii() == ")" )) {
                            leftBrace = leftBrace + nextLineBean.codeLine.count("(") - nextLineBean.codeLine.count(")")
                            nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                            x++
                            nextLineBean = stateBean.linesList[i + x]
                        }
                    }
                }
            }
            removediscard(stateBean)
            
            // 处理多余换行的场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.trimAscii() == ")" &&
                !lineBean.isInMultilineComment && 
                !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        var lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.count("(") - lastLineBean.codeLine.count(")") == 1) {
                            lastLineBean.codeLine = lastLineBean.codeLine.trimAscii().replace("\n", "") + ")"
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            // 2.7 处理数组场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.trimAscii().endsWith("[") &&
                !codeStr.trimAscii().replace(" ", "").contains("=[") &&
                !lineBean.isInMultilineComment && 
                !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        var x = 1
                        var nextLineBean: LineBean = stateBean.linesList[i + x]
                        var leftBrace = 0
                        while (!(leftBrace + nextLineBean.codeLine.count("[") - nextLineBean.codeLine.count("]") == -1)) {
                            leftBrace = leftBrace + nextLineBean.codeLine.count("[") - nextLineBean.codeLine.count("]")
                            nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                            x++
                            nextLineBean = stateBean.linesList[i + x]
                        }
                        // 只有一行，加到上一行末尾
                        if (x == 1) {
                            lineBean.codeLine = lineBean.codeLine.trimAscii().replace("\n", "") + nextLineBean.codeLine.trimAscii()
                        }
                    }
                }
            }
            removediscard(stateBean)

            // 处理单行有未闭合的]、)、}这类符号，上一行有未闭合的[、(、{，则将该行添加到上一行
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                var rightSymbolArr = ArrayList<String>()
                var unclosedSymbols = false
                if (codeStr.count("[") - codeStr.count("]") == -1) {
                    rightSymbolArr.add("]")
                    unclosedSymbols = true
                }
                
                if (codeStr.count("(") - codeStr.count(")") == -1) {
                    rightSymbolArr.add(")")
                    unclosedSymbols = true
                }
                
                if (codeStr.count("{") - codeStr.count("}") == -1) {
                    rightSymbolArr.add("}")
                    unclosedSymbols = true
                }
                
                if (codeStr.count("<") - codeStr.count(">") == -1) {
                    rightSymbolArr.add(">")
                    unclosedSymbols = true
                }

                if (unclosedSymbols &&
                !lineBean.isInMultilineComment && 
                !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        var lastLineBean: LineBean = stateBean.linesList[i - 1]
                        for (i in 0..rightSymbolArr.size) {
                            var antiSymbol = match (rightSymbolArr[i]) {
                                case "]" => "["
                                case "}" => "{"
                                case ")" => "("
                                case ">" => "<"
                                case _ => break
                            }
                            if (lastLineBean.codeLine.count(antiSymbol) - lastLineBean.codeLine.count(rightSymbolArr[i]) == 1) {
                                lastLineBean.codeLine = lastLineBean.codeLine.trimAscii().replace("\n", "") + lineBean.codeLine.trimAscii()
                                lineBean.isDiscarded = true
                                break
                            }
                        }
                    }
                }
            }
            removediscard(stateBean)

            // 去除了对macro宏的逻辑，如果是#开头的宏代码 lineBean的indentLevel还是要设置一下，不然会有问题
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith("#") && !lineBean.isInMultilineComment) {
                    lineBean.indentLevel = 0
                }
            }

            // 获得最终的list
            let usefulList: ArrayList<LineBean> = stateBean.linesList
            for (item in usefulList) {
                item.codeLine = item.codeLine.trimAscii()
            }
            // 修改#开始的宏和后面空格不一致问题
            modifyMacroAndSpace(stateBean)

            // 最后根据缩进拼接
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
