package codeformat

class RustFormat <: GeneralProcessing {
    public override func dealWithString(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        let currChar: Rune = notNullChar[currentIndex]
        var lastChar: Rune = r' '
        if (currentIndex - 1 >= 0) {
            lastChar = notNullChar[currentIndex - 1]
        }
        
        if (currChar == r'"' && !stateBean.isInString) {
            stateBean.stringQuote = currChar
            stateBean.isInString = true
            return
        }
        if (stateBean.isInString && currChar == stateBean.stringQuote && handleTransferCharacters(notNullChar, currentIndex - 1)) {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
        if (stateBean.isInString && currChar == r'\n') {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
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

                if (currChar == r'#' && !stateBean.isInString && !stateBean.isInMacro) {
                    dealWithMacro(stateBean)
                    continue
                }

                if (currChar == r'{' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    dealWithLeftBigBracket(stateBean)
                    continue
                }
                
                if (currChar == r'}' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
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
                if (lineBean.codeLine.contains("}") && !lineBean.codeLine.contains("{") && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (!lastLineBean.codeLine.trimAscii().startsWith("use ")) {
                            continue
                        }
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
                if ((((codeStr.startsWith("while(")) && (!codeStr.contains("{"))) || 
                     (codeStr.startsWith("else{")) || 
                     (codeStr.startsWith("else if("))) && 
                    !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii() == "}") {
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
                if ((codeStr.startsWith(");") || codeStr == ")") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
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
                let codeStr = lineBean.codeLine
                if (codeStr.endsWith("}") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.contains("{") && lastLineBean.codeLine.contains("->") && lastLineBean.codeLine.contains("fn ")) {
                                let stringbuilder: StringBuilder = StringBuilder()
                                stringbuilder.append(lastLineBean.codeLine)
                                stringbuilder.append(lineBean.codeLine.trimAscii())
                                lastLineBean.codeLine = stringbuilder.toString()
                                lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.endsWith(";") && 
                codeStr.replace(" ", "").contains(":[") &&
                !lineBean.isInMultilineComment && 
                !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        var x = 1
                        var nextLineBean: LineBean = stateBean.linesList[i + x]
                        while (nextLineBean.codeLine.contains("]") && (!nextLineBean.codeLine.contains("[") || nextLineBean.codeLine.indexOf(']').getOrThrow() < nextLineBean.codeLine.indexOf('[').getOrThrow())) {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(nextLineBean.codeLine)
                            lineBean.codeLine = stringbuilder.toString()
                            nextLineBean.isDiscarded = true
                            x++
                            if (i + x >= stateBean.linesList.size) {
                                break
                            }
                            nextLineBean = stateBean.linesList[i + x]
                        }
                        if (lineBean.codeLine.trimAscii().replace(" ", "").endsWith("=[")) {
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
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr == "where" && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    var x = 1
                    var nextLineBean = stateBean.linesList[i + x]
                    while (!(nextLineBean.codeLine.trimAscii() == "{")) {
                        nextLineBean.indentLevel++
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
                        x++
                        nextLineBean = stateBean.linesList[i + x]
                    }
                    nextLineBean.indentLevel = lineBean.indentLevel
                    var leftBrace = 0
                    x++
                    if (i + x >= stateBean.linesList.size) {
                        break
                    }
                    nextLineBean = stateBean.linesList[i + x]
                    while (!(leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1) && 
                    nextLineBean.codeLine.trimAscii().endsWith("}") &&
                    nextLineBean.codeLine.trimAscii() != "}") {
                        leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                        nextLineBean.indentLevel++
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
                        x++
                        nextLineBean = stateBean.linesList[i + x]
                    }
                    if (nextLineBean.codeLine.trimAscii().replace(" ", "") == "}" && nextLineBean.indentLevel == lineBean.indentLevel) {
                        continue
                    }
                    nextLineBean.indentLevel++
                    nextLineBean.codeLine = nextLineBean.codeLine.removeSuffix("}")
                    let newlineBean = LineBean()
                    newlineBean.codeLine = "}"
                    newlineBean.indentLevel = nextLineBean.indentLevel - 1
                    stateBean.linesList.add(newlineBean, at:i + x + 1)
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.endsWith("}") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        if (nextLineBean.codeLine.trimAscii().startsWith("=") || nextLineBean.codeLine.trimAscii().startsWith("=>")) {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(nextLineBean.codeLine)
                            nextLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.trimAscii().endsWith("}") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        if (nextLineBean.codeLine.trimAscii().startsWith(";")) {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(nextLineBean.codeLine)
                            nextLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)
            
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.trimAscii().endsWith("{") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        if (nextLineBean.codeLine.trimAscii().endsWith("};")) {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(nextLineBean.codeLine)
                            nextLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.trimAscii().endsWith("|") && codeStr.trimAscii().contains("=") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        var nextLineBean: LineBean = stateBean.linesList[i + 1]
                        var x = 1
                        if (nextLineBean.codeLine.trimAscii() == "{") {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(" ")
                            stringbuilder.append(nextLineBean.codeLine)
                            lineBean.codeLine = stringbuilder.toString()
                            nextLineBean.isDiscarded = true
                            x++
                        }
                        var leftBrace = 0
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
                        nextLineBean = stateBean.linesList[i + x]
                        while (!(nextLineBean.codeLine.trimAscii().contains("}") &&
                        (nextLineBean.codeLine.trimAscii() == "}" || handleTransferCharacters(nextLineBean.codeLine.toRuneArray(), nextLineBean.codeLine.indexOf("}").getOrThrow() - 1)) &&
                        leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1)) {
                            leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                            x++
                            if (i + x >= stateBean.linesList.size) {
                                break
                            }
                            nextLineBean = stateBean.linesList[i + x]
                        }
                        if (nextLineBean.codeLine.trimAscii().replace(" ", "").startsWith("}") && nextLineBean.indentLevel == lineBean.indentLevel) {
                            continue
                        }
                        nextLineBean.indentLevel++
                        var codeSplit = nextLineBean.codeLine.trimAscii().split("}", removeEmpty: false)
                        let newlineBean = LineBean()
                        newlineBean.codeLine = "}" + codeSplit[codeSplit.size - 1]
                        nextLineBean.codeLine = nextLineBean.codeLine.replace(newlineBean.codeLine, "")
                        newlineBean.indentLevel = nextLineBean.indentLevel - 1
                        stateBean.linesList.add(newlineBean, at:i + x + 1)
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.endsWith("{") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        if ((nextLineBean.codeLine.trimAscii().contains("=") || nextLineBean.codeLine.trimAscii().contains("=>")) && 
                        nextLineBean.codeLine.contains("}") &&
                        (!nextLineBean.codeLine.contains("{") || nextLineBean.codeLine.indexOf('}').getOrThrow() < nextLineBean.codeLine.indexOf('{').getOrThrow())
                        ) {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(" ")
                            stringbuilder.append(nextLineBean.codeLine)
                            nextLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr.endsWith("=") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 2) {
                        var nextLineBean: LineBean = stateBean.linesList[i + 1]
                        if (nextLineBean.codeLine.trimAscii().startsWith("if ") && stateBean.linesList[i + 2].codeLine.trimAscii() == "{") {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(" ")
                            stringbuilder.append(nextLineBean.codeLine.replace("\n", ""))
                            stringbuilder.append("{")
                            lineBean.codeLine = stringbuilder.toString()
                            nextLineBean.isDiscarded = true
                            stateBean.linesList[i + 2].isDiscarded = true
                            var x = 3
                            var leftBrace = 0
                            if (i + x >= stateBean.linesList.size) {
                                break
                            }
                            nextLineBean = stateBean.linesList[i + x]
                            while (!((leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1) && nextLineBean.codeLine.trimAscii().endsWith("}"))) {
                                leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                                if (i + x >= stateBean.linesList.size) {
                                    break
                                }
                                x++
                                nextLineBean = stateBean.linesList[i + x]
                            }
                            if (!(nextLineBean.codeLine.trimAscii() == "}")) {
                                nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                                nextLineBean.codeLine = nextLineBean.codeLine.trimAscii().removeSuffix("}")
                            } else {
                                nextLineBean.isDiscarded = true
                            }
                            x++
                            if (i + x >= stateBean.linesList.size) {
                                break
                            }
                            nextLineBean = stateBean.linesList[i + x]
                            if (nextLineBean.codeLine.trimAscii() == "else") {
                                if (i + x >= stateBean.linesList.size) {
                                    break
                                }
                                nextLineBean.codeLine = "} else {"
                                nextLineBean.indentLevel = stateBean.linesList[i + x - 1].indentLevel - 1
                                x++
                                nextLineBean = stateBean.linesList[i + x]
                                leftBrace = 0
                                if (nextLineBean.codeLine.trimAscii().startsWith("{")) {
                                    nextLineBean.codeLine = nextLineBean.codeLine.trimAscii()[1..]
                                    while (!(leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1)) {
                                        leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                                        if (i + x >= stateBean.linesList.size) {
                                            break
                                        }
                                        x++
                                        nextLineBean = stateBean.linesList[i + x]
                                    }
                                    if ((nextLineBean.codeLine.trimAscii().replace(" ", "") == "}" || nextLineBean.codeLine.trimAscii().replace(" ", "") == "};") && nextLineBean.indentLevel == lineBean.indentLevel) {
                                        continue
                                    }
                                    nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                                    var tailCodeArr = nextLineBean.codeLine.split("}", removeEmpty: false)
                                    nextLineBean.codeLine = nextLineBean.codeLine.removeSuffix("}" + tailCodeArr[tailCodeArr.size-1])
                                    let newlineBean = LineBean()
                                    newlineBean.codeLine = "}" + tailCodeArr[tailCodeArr.size-1]
                                    newlineBean.indentLevel = nextLineBean.indentLevel - 1
                                    stateBean.linesList.add(newlineBean, at:i + x + 1)
                                }
                            } else if (nextLineBean.codeLine.trimAscii().startsWith("else {")) {
                                var newlineBean = LineBean()
                                newlineBean.codeLine = nextLineBean.codeLine.trimAscii()[7..]
                                nextLineBean.codeLine = "} else {"
                                nextLineBean.indentLevel = stateBean.linesList[i + x - 1].indentLevel - 1
                                newlineBean.indentLevel = stateBean.linesList[i + x - 1].indentLevel - 1
                                stateBean.linesList.add(newlineBean, at:i + x + 1)
                                x++
                                if (i + x >= stateBean.linesList.size) {
                                    break
                                }
                                nextLineBean = stateBean.linesList[i + x]
                                leftBrace = 0
                                while (!(leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1)) {
                                    leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                                    if (i + x >= stateBean.linesList.size) {
                                        break
                                    }
                                    x++
                                    nextLineBean = stateBean.linesList[i + x]
                                }
                                if ((nextLineBean.codeLine.trimAscii().replace(" ", "") == "}" || nextLineBean.codeLine.trimAscii().replace(" ", "") == "};") && nextLineBean.indentLevel == lineBean.indentLevel) {
                                    continue
                                }
                                nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                                var tailCodeArr = nextLineBean.codeLine.split("}", removeEmpty: false)
                                nextLineBean.codeLine = nextLineBean.codeLine.removeSuffix("}" + tailCodeArr[tailCodeArr.size-1])
                                newlineBean = LineBean()
                                newlineBean.codeLine = "}" + tailCodeArr[tailCodeArr.size-1]
                                newlineBean.indentLevel = nextLineBean.indentLevel - 1
                                stateBean.linesList.add(newlineBean, at:i + x + 1)
                            }
                        }
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr.startsWith("if") && !(i > 0 && stateBean.linesList[i - 1].codeLine.trimAscii().endsWith("=")) && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        var x = 1
                        var leftBrace = 0
                        var nextLineBean: LineBean = stateBean.linesList[i + 1]
                        while (!(nextLineBean.codeLine.trimAscii().endsWith("}") && (leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1))) {
                            leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                            if (i + x >= stateBean.linesList.size) {
                                break
                            }
                            x++
                            nextLineBean = stateBean.linesList[i + x]
                        }
                        if (nextLineBean.codeLine.trimAscii().replace(" ", "") == "}") {
                            continue
                        }
                        nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                        var tailCodeArr = nextLineBean.codeLine.split("}", removeEmpty: false)
                        nextLineBean.codeLine = nextLineBean.codeLine.removeSuffix("}" + tailCodeArr[tailCodeArr.size-1])
                        let newlineBean = LineBean()
                        newlineBean.codeLine = "}" + tailCodeArr[tailCodeArr.size-1]
                        newlineBean.indentLevel = nextLineBean.indentLevel - 1
                        stateBean.linesList.add(newlineBean, at:i + x + 1)
                        x = x + 2
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
                        nextLineBean = stateBean.linesList[i + x]
                        if (nextLineBean.codeLine.trimAscii() == "else {") {
                            if (i + x >= stateBean.linesList.size) {
                                break
                            }
                            stateBean.linesList[i + x - 1].isDiscarded = true
                            nextLineBean.codeLine = nextLineBean.codeLine.trimAscii().replace("else {", "} else {")
                            leftBrace = 0
                            x++
                            nextLineBean = stateBean.linesList[i + x]
                            while (!(nextLineBean.codeLine.trimAscii().endsWith("}") && (leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1))) {
                                leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                                if (i + x >= stateBean.linesList.size) {
                                    break
                                }
                                x++
                                nextLineBean = stateBean.linesList[i + x]
                            }
                            if (nextLineBean.codeLine.trimAscii().replace(" ", "") == "}") {
                                continue
                            }
                            nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                            var tailCodeArr = nextLineBean.codeLine.split("}", removeEmpty: false)
                            nextLineBean.codeLine = nextLineBean.codeLine.removeSuffix("}" + tailCodeArr[tailCodeArr.size-1])
                            let newlineBean = LineBean()
                            newlineBean.codeLine = "}" + tailCodeArr[tailCodeArr.size-1]
                            newlineBean.indentLevel = nextLineBean.indentLevel - 1
                            stateBean.linesList.add(newlineBean, at:i + x + 1)
                        }
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr.endsWith("(") && 
                    (i + 1 < stateBean.linesList.size) && 
                    (stateBean.linesList[i].indentLevel == stateBean.linesList[i + 1].indentLevel) && 
                    !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    var x = 1
                    while (!stateBean.linesList[i + x].codeLine.trimAscii().startsWith(")")) {
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
                        stateBean.linesList[i + x].indentLevel++
                        x++
                    }
                }
            }
                    
            var x = 1
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (x != 1) {
                    x--
                    continue
                }
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr.startsWith(".") && 
                    (i - 1 >= 0) && 
                    (stateBean.linesList[i].indentLevel == stateBean.linesList[i - 1].indentLevel) && 
                    !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    stateBean.linesList[i].indentLevel++
                    while (stateBean.linesList[i + x].codeLine.trimAscii().startsWith(".")) {
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
                        stateBean.linesList[i + x].indentLevel++
                        x++
                    }
                }
            }

            normalizeRustSpaces(stateBean)

            let usefulList: ArrayList<LineBean> = stateBean.linesList
            for (item in usefulList) {
                item.codeLine = item.codeLine.trimAscii()
            }

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

    func normalizeRustSpaces(stateBean: StateBean): Unit {
        for (i in 0..stateBean.linesList.size) {
            let lineBean: LineBean = stateBean.linesList[i]
            if (!lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                var line = lineBean.codeLine
                
                if (line.trimAscii().startsWith("use ")) {
                    line = normalizeUseStatement(line)
                }
                else if (line.trimAscii().startsWith("const ") || line.trimAscii().startsWith("static ")) {
                    line = normalizeConstDef(line)
                }
                else if (line.trimAscii().startsWith("type ")) {
                    line = normalizeTypeAlias(line)
                }
                else if (line.contains(":") && !line.contains("fn ") && !line.contains("->")) {
                    line = normalizeFieldDef(line)
                }
                else if (line.contains("fn ") || line.contains("->")) {
                    line = normalizeFunctionDef(line)
                }
                else if (line.contains("=>")) {
                    line = normalizeMatchArm(line)
                }
                else if (line.contains(".") && !line.contains("fn ")) {
                    line = normalizeMethodCall(line)
                }
                
                lineBean.codeLine = line
            }
        }
    }

    func normalizeUseStatement(line: String): String {
        var result = line
        if (result.contains("{") && result.contains("}")) {
            let startIdx = result.indexOf("{").getOrThrow()
            let endIdx = result.indexOf("}").getOrThrow()
            if (startIdx >= 0 && endIdx > startIdx) {
                let prefix = result[0..startIdx + 1]
                let content = result[startIdx + 1..endIdx]
                let suffix = result[endIdx..]
                
                var normalizedContent = content.replace(",", ", ")
                normalizedContent = normalizedContent.replace("  ", " ")
                
                result = prefix + normalizedContent + suffix
            }
        }
        return result
    }

    func normalizeConstDef(line: String): String {
        var result = line
        result = normalizeColonSpacing(result)
        result = normalizeEqualSpacing(result)
        return result
    }

    func normalizeTypeAlias(line: String): String {
        var result = line
        result = normalizeEqualSpacing(result)
        result = normalizeGenericSpacing(result)
        return result
    }

    func normalizeFieldDef(line: String): String {
        var result = line
        result = normalizeColonSpacing(result)
        result = normalizeCommaSpacing(result)
        return result
    }

    func normalizeFunctionDef(line: String): String {
        var result = line
        if (result.contains("(") && result.contains(")")) {
            let startIdx = result.indexOf("(").getOrThrow()
            let endIdx = result.indexOf(")").getOrThrow()
            if (startIdx >= 0 && endIdx > startIdx) {
                let prefix = result[0..startIdx + 1]
                let params = result[startIdx + 1..endIdx]
                let suffix = result[endIdx..]
                
                var normalizedParams = params.replace(",", ", ")
                normalizedParams = normalizedParams.replace("  ", " ")
                normalizedParams = normalizeColonSpacing(normalizedParams)
                
                result = prefix + normalizedParams + suffix
            }
        }
        if (result.contains("->")) {
            result = result.replace("->", " -> ")
            result = result.replace("  ", " ")
            result = normalizeGenericSpacing(result)
        }
        return result
    }

    func normalizeMatchArm(line: String): String {
        var result = line
        result = result.replace("=>", " => ")
        result = result.replace("  ", " ")
        result = normalizeCommaSpacing(result)
        return result
    }

    func normalizeMethodCall(line: String): String {
        var result = line
        if (result.contains("|") && result.count("|") > 1) {
            let firstPipe = result.indexOf("|").getOrThrow()
            let secondPipe = result.indexOf("|", firstPipe + 1).getOrThrow()
            if (firstPipe >= 0 && secondPipe > firstPipe) {
                let beforeClosure = result[0..firstPipe].trimAscii()
                let closureParams = result[firstPipe..secondPipe + 1].trimAscii()
                let closureBody = result[secondPipe + 1..].trimAscii()
                
                var normalizedBody = closureBody.replace("  ", " ")
                result = beforeClosure + closureParams + " " + normalizedBody
            }
        }
        return result
    }

    func normalizeColonSpacing(line: String): String {
        var result = line
        var sb = StringBuilder()
        var chars = result.toRuneArray()
        var i = 0
        
        while (i < chars.size) {
            let ch = chars[i]
            if (ch == r':' && i + 1 < chars.size && chars[i + 1] != r':' && chars[i + 1] != r' ') {
                if (i > 0 && chars[i - 1] == r'=') {
                    sb.append(ch)
                } else if (i > 0 && chars[i - 1] == r'\'') {
                    sb.append(ch)
                } else if (i > 0 && chars[i - 1] == r':') {
                    sb.append(ch)
                } else {
                    sb.append(ch)
                    sb.append(r' ')
                }
            } else {
                sb.append(ch)
            }
            i++
        }
        return sb.toString()
    }

    func normalizeEqualSpacing(line: String): String {
        var result = line
        var sb = StringBuilder()
        var chars = result.toRuneArray()
        var i = 0
        
        while (i < chars.size) {
            let ch = chars[i]
            if (ch == r'=') {
                if (i + 1 < chars.size && (chars[i + 1] == r'=' || chars[i + 1] == r'>')) {
                    sb.append(ch)
                } else if (i > 0 && chars[i - 1] == r'=' ) {
                    sb.append(ch)
                } else if (i > 0 && chars[i - 1] == r'-' ) {
                    sb.append(ch)
                } else {
                    if (i > 0 && chars[i - 1] != r' ') {
                        sb.append(r' ')
                    }
                    sb.append(ch)
                    if (i + 1 < chars.size && chars[i + 1] != r' ') {
                        sb.append(r' ')
                    }
                }
            } else {
                sb.append(ch)
            }
            i++
        }
        return sb.toString()
    }

    func normalizeCommaSpacing(line: String): String {
        var result = line
        var sb = StringBuilder()
        var chars = result.toRuneArray()
        var i = 0
        
        while (i < chars.size) {
            let ch = chars[i]
            if (ch == r',' && i + 1 < chars.size && chars[i + 1] != r' ') {
                sb.append(ch)
                sb.append(r' ')
            } else {
                sb.append(ch)
            }
            i++
        }
        return sb.toString()
    }

    func normalizeGenericSpacing(line: String): String {
        var result = line
        result = result.replace(",>", ", >")
        return result
    }
}
