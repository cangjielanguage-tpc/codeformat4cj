package codeformat

class CsharpFormat <: GeneralProcessing {
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
                if ((((codeStr.startsWith("while(")) && (!codeStr.contains("{"))) || (codeStr.startsWith(",")) || (codeStr
                    .startsWith("finally{")) || (codeStr.startsWith("else{")) || (codeStr.startsWith("elseif(")) || (codeStr
                    .startsWith("catch("))) && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
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
                if (((codeStr.startsWith("if(") && (codeStr.endsWith(")"))) || codeStr.trimAscii() == "else") && 
                (lineBean.codeLine.count("(") - lineBean.codeLine.count(")") == 0) && 
                !lineBean.isInMultilineComment &&
                !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith("from") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().startsWith("import")) {
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
                if ((codeStr.startsWith("for ") || codeStr.startsWith("foreach ")) && 
                !lineBean.isInMultilineComment &&
                !lineBean.isInSinglelineComment) {
                    var index = 0
                    var count = -1
                    for (i in 0..codeStr.size) {
                        if (codeStr.get(i).getOrThrow() == 40) {
                            if (count == -1) {
                                count = 1
                            } else {
                                count++
                            }
                        } else if (codeStr.get(i).getOrThrow() == 41) {
                            count--
                        }
                        if (count == 0) {
                            index = i
                            break
                        }
                    }
                    if (index > 0 && index < codeStr.size - 1) {
                        let stringbuilder: StringBuilder = StringBuilder()
                        stringbuilder.append(codeStr[(index+1)..])
                        lineBean.codeLine = codeStr[0..(index+1)]
                        let newlineBean = LineBean()
                        newlineBean.codeLine = stringbuilder.toString()
                        newlineBean.indentLevel = lineBean.indentLevel + 1
                        stateBean.linesList.add(newlineBean, at:i + 1)
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith("switch") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    var x = 1
                    var leftBrace = 0
                    var nextLineBean = stateBean.linesList[i + x]
                    if (nextLineBean.codeLine.trimAscii() == "{") {
                        x++
                    }
                    if (i + x >= stateBean.linesList.size) {
                        break
                    }
                    nextLineBean = stateBean.linesList[i + x]
                    while (!(leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1)) {
                        leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                        x++
                        if(!(nextLineBean.codeLine.trimAscii().startsWith("case ") || nextLineBean.codeLine.trimAscii().startsWith("default:"))) {
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

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith(";") || codeStr.startsWith(",") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        var lastLineBean = stateBean.linesList[i - 1]
                        lastLineBean.codeLine = lastLineBean.codeLine.trimAscii() + lineBean.codeLine.trimAscii()
                        lineBean.isDiscarded = true 
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

            return finalFormatOutput(stateBean, cfg)
        } else {
            return ""
        }
    }
}
