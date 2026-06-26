package codeformat

class KotlinFormat <: GeneralProcessing {
    public override func dealWithString(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        let currChar: Rune = notNullChar[currentIndex]
        var lastChar: Rune = r' '
        if (currentIndex - 1 >= 0) {
            lastChar = notNullChar[currentIndex - 1]
        }
        if ((currChar == r'"') && !stateBean.isInString) {
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
                if (currChar == stateBean.stringQuote && handleTransferCharacters(notNullChar, currentIndex - 1)) {
                    stateBean.isInString = false
                    stateBean.stringQuote = r' '
                }
            }
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
            let currChar: Rune = notNullChar[currentIndex]

            if (currChar == r'{' || currChar == r'}') {
                stateBean.isInFor = false
            }
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

            mergeSingleLineComments(stateBean)
            mergeMultiLineComments(stateBean)

            removeOnlyChangeLine(stateBean)

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
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (!lineBean.isSingleLine) {
                    if ((lineBean.codeLine.trimAscii() == ";" ||
                        lineBean.codeLine.trimAscii() == "()") && !lineBean.isInMultilineComment &&
                        !lineBean.isInSinglelineComment) {
                        if (i > 0) {
                            let lastLineBean: LineBean = stateBean.linesList[i - 1]
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
                if (((codeStr.startsWith("else{")) || (codeStr.startsWith("elseif(")) || (codeStr.startsWith("catch("))) &&
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
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr.startsWith("if ") && codeStr.endsWith(";") && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
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


                var inInDoubleArray = false

                for (i in 0..stateBean.linesList.size) {
                    let line = stateBean.linesList[i]
                    let t = line.codeLine.trimAscii().replace(" ","")

                    if (t.endsWith("=arrayOf(") || t.contains("=arrayOf(//") || t.contains("=arrayOf(/*")) {
                        inInDoubleArray = true
                        continue
                    }

                    if ((t == ")" || t.startsWith(")//") || t.startsWith(")/*")) && inInDoubleArray) {
                        inInDoubleArray = false
                    }

                    if (inInDoubleArray) {
                        line.indentLevel = line.indentLevel+1
                    }
                }



            return finalFormatOutput(stateBean, cfg)
        } else {
            return ""
        }
    }
}
