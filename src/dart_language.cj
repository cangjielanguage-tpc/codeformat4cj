package codeformat

class DartFormat <: GeneralProcessing {
    public override func dealWithMacro(stateBean: StateBean): Unit {
        stateBean.isInMacro = true
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]

        while (currChar != r'\n' && currChar != r'{') {
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
        stateBean.lastChar = currChar
        stateBean.isInMacro = false
    }

    public override func dealWithString(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        let currChar: Rune = notNullChar[currentIndex]
        var lastChar: Rune = r' '
        if (currentIndex - 1 >= 0) {
            lastChar = notNullChar[currentIndex - 1]
        }
        if ((currChar == r'"' || currChar == r'\'') && !stateBean.isInString) {
            if (currentIndex + 2 < notNullChar.size && 
                currChar == notNullChar[currentIndex + 1] && 
                currChar == notNullChar[currentIndex + 2]) {
                stateBean.stringQuote = currChar
                stateBean.isInString = true
                stateBean.isTripleQuote = true
                stateBean.tripleQuoteCount = 0
                return
            } else {
                stateBean.stringQuote = currChar
                stateBean.isInString = true
                stateBean.isTripleQuote = false
                return
            }
        }
        if (stateBean.isInString) {
            if (stateBean.isTripleQuote) {
                if (currChar == stateBean.stringQuote) {
                    stateBean.tripleQuoteCount++
                    if (stateBean.tripleQuoteCount >= 3 && lastChar == stateBean.stringQuote) {
                        stateBean.isInString = false
                        stateBean.stringQuote = r' '
                        stateBean.isTripleQuote = false
                        stateBean.tripleQuoteCount = 0
                    }
                } else {
                    stateBean.tripleQuoteCount = 0
                }
            } else {
                if (currChar == stateBean.stringQuote && lastChar != r'\\') {
                    stateBean.isInString = false
                    stateBean.stringQuote = r' '
                }
            }
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

                if (currChar == r'@' && (stateBean.lastChar == r'\n' || stateBean.lastChar == r' ') && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor &&
                    !stateBean.isInBackQuote) {
                    dealWithMacro(stateBean)
                    continue
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

            mergeSingleLineComments(stateBean)

            mergeMultiLineComments(stateBean)

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
                if ((((codeStr.startsWith("while(")) && (!codeStr.contains("{"))) || 
                    (codeStr.startsWith(",")) ||
                    (codeStr.startsWith("finally{")) || 
                    (codeStr.startsWith("else{")) ||
                    (codeStr.startsWith("elseif(")) ||
                    (codeStr.startsWith("catch(")) ||
                    (lineBean.codeLine.trimAscii().startsWith("on ") && lineBean.codeLine.trimAscii().endsWith("{"))
                    ) &&
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
                if ((codeStr.endsWith("];") || codeStr.endsWith("]")) && !codeStr.contains("[") && i > 0 && stateBean.linesList[i - 1].codeLine.contains("[") &&
                    !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
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

            removediscard(stateBean)
            
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii()
                if (!codeStr.startsWith("{") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if ((lastLineBean.codeLine.trimAscii().startsWith("for ") || 
                            lastLineBean.codeLine.trimAscii().startsWith("for(")) && 
                            !lastLineBean.codeLine.contains("{")) {
                            lineBean.indentLevel = lineBean.indentLevel + 1
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
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        let stringbuilder: StringBuilder = StringBuilder()
                        stringbuilder.append(lineBean.codeLine + " ")
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
                if (i > 0 && codeStr.endsWith("}") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith("\${")) {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            stringbuilder.append(lineBean.codeLine)
                            stringbuilder.append(stateBean.linesList[i + 1].codeLine)
                            lastLineBean.codeLine = stringbuilder.toString().replace("\n", "")
                            lineBean.isDiscarded = true
                            stateBean.linesList[i + 1].isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)
           
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (i > 0 && codeStr.startsWith(")") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith("}")) {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString().replace("\n", "")
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
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith("switch") && codeStr.endsWith("{") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    var x = 1
                    var leftBrace = 0
                    var nextLineBean = stateBean.linesList[i + x]
                    while (!(leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1)) {
                        leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                        x++
                        if(!(nextLineBean.codeLine.trimAscii().startsWith("case") || nextLineBean.codeLine.trimAscii().startsWith("default") || nextLineBean.codeLine.trimAscii().endsWith(":"))) {
                            nextLineBean.indentLevel++
                        }
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
                        nextLineBean = stateBean.linesList[i + x]
                    }
                }
            }
            removediscard(stateBean)

            return finalFormatOutput(stateBean, cfg)
        } else {
            return ""
        }
    }
}
