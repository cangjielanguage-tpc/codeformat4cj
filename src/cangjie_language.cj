package codeformat

class CangjieFormat <: GeneralProcessing {

    func makeAccessLine(stateBean: StateBean, kw: String, kwLen: Int64): Unit {
        stateBean.isInAccessFlag = true
        let lb = LineBean()
        lb.codeLine = kw
        lb.indentLevel = stateBean.indentLevel
        setCommonFields(lb, stateBean)
        lb.isInFor = stateBean.isInFor
        stateBean.linesList.add(lb)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + kwLen
        stateBean.isInAccessFlag = false
        stateBean.lastChar = r'\n'
        stateBean.currentIndex += kwLen + 1
    }

    public override func dealWithAccessPublic(stateBean: StateBean): Bool {
        if (matchKw(stateBean, "public", 6)) {
            makeAccessLine(stateBean, "public", 6)
            return true
        }
        return false
    }

    public override func dealWithAccessPrivate(stateBean: StateBean): Bool {
        if (matchKw(stateBean, "private", 7)) {
            makeAccessLine(stateBean, "private", 7)
            return true
        }
        return false
    }

    public override func dealWithAccessProtected(stateBean: StateBean): Bool {
        if (matchKw(stateBean, "protected", 9)) {
            makeAccessLine(stateBean, "protected", 9)
            return true
        }
        return false
    }

    func formatCode(rawCode: String, cfg: FormatConfig): String {
        let runCode = rawCode.replace("\r\n","\n")
        let stateBean: StateBean = StateBean()
        stateBean.linesList = ArrayList<LineBean>()
        stateBean.codeChars = runCode.toRuneArray()
        if (let Some(i) <- stateBean.codeChars) {
            let len = i.size
            if (len == 0) {
                return ""
            }
            while (stateBean.currentIndex < len) {
                let currChar = i[stateBean.currentIndex]
                stateBean.perLineOutput.append(currChar)
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
                if (currChar == r'/' && stateBean.lastChar == r'/' && !stateBean.isInString) {
                    var str = stateBean.perLineOutput.toString().removeSuffix("//")
                    if (str.trimAscii().size > 0) {
                        dealWithSingleLineComment(stateBean, str)
                    } else {
                        dealWithSingleLineComment(stateBean, "")
                    }
                    continue
                }
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

                if (currChar == r'`' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    if (!stateBean.isInBackQuote) {
                        stateBean.isInBackQuote = true
                    } else {
                        stateBean.isInBackQuote = false
                    }
                }

                if (currChar == r'{' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor &&
                    !stateBean.isInBackQuote) {
                    dealWithLeftBigBracket(stateBean)
                    continue
                }
                if (currChar == r'}' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor &&
                    !stateBean.isInBackQuote) {
                    dealWithRightBigBracket(stateBean)
                    continue
                }
                if (currChar == r';' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    dealWithSemicolon(stateBean)
                    continue
                }
                if (currChar == r'\n' && !stateBean.isInString) {
                    dealWithNewLine(stateBean)
                    stateBean.isLineStart = true
                } else {
                    if (stateBean.isLineStart && (currChar == r' ' || currChar == r'\t')) {
                        stateBean.isLineStart = true
                    } else {
                        stateBean.isLineStart = false
                    }
                }
                stateBean.lastChar = currChar
                stateBean.currentIndex++
            }
            dealWithNewLine(stateBean)

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

            removeOnlyChangeLine(stateBean)
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
            removediscard(stateBean)
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
                            if (i + x >= stateBean.linesList.size) {
                                break
                            }
                            nextLineBean = stateBean.linesList[i + x]
                        }
                    }
                }
            }
            removediscard(stateBean)

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
                            if (i + x >= stateBean.linesList.size) {
                                break
                            }
                            nextLineBean = stateBean.linesList[i + x]
                        }
                    }
                }
            }
            removediscard(stateBean)
            
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
                            if (i + x >= stateBean.linesList.size) {
                                break
                            }
                            nextLineBean = stateBean.linesList[i + x]
                        }
                        if (x == 1) {
                            lineBean.codeLine = lineBean.codeLine.trimAscii().replace("\n", "") + nextLineBean.codeLine.trimAscii()
                        }
                    }
                }
            }
            removediscard(stateBean)

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

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith("#") && !lineBean.isInMultilineComment) {
                    lineBean.indentLevel = 0
                }
            }

            let usefulList: ArrayList<LineBean> = stateBean.linesList
            for (item in usefulList) {
                item.codeLine = item.codeLine.trimAscii()
            }
            modifyMacroAndSpace(stateBean)

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
