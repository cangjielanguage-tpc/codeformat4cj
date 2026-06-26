package codeformat

class SwiftFormat <: GeneralProcessing {
    public override func dealWithRightBigBracket(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        var lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1))
        
        if (lineCode.startsWith(" ") && !lineCode.startsWith("  ") ) {
            lineCode = " " + lineCode
        }
        lineBean.codeLine = lineCode
        stateBean.indentLevel--
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
        stateBean.lastChar = r'}'
        stateBean.currentIndex++
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
                            if (!lastLineBean.codeLine.trimAscii().endsWith(";") && 
                                !(lastLineBean.codeLine.trimAscii().replace(" ", "").startsWith("set{") || lastLineBean.codeLine.trimAscii().replace(" ", "").startsWith("get{"))) {
                                let stringbuilder: StringBuilder = StringBuilder()
                                stringbuilder.append(lastLineBean.codeLine)
                                if (lastLineBean.codeLine.trimAscii().endsWith("{") && lineBean.codeLine.contains(" }")) {
                                    stringbuilder.append(" ")
                                }
                                stringbuilder.append(lineBean.codeLine.trimAscii())
                                if (!lastLineBean.codeLine.trimAscii().contains("{") && !lineBean.codeLine.trimAscii().contains("{")) {
                                    stringbuilder.reset()
                                    lineBean.codeLine = lineBean.codeLine.replace("}", "\n}")
                                    lineBean.indentLevel = lastLineBean.indentLevel
                                } else {
                                    lastLineBean.codeLine = stringbuilder.toString()
                                    lineBean.isDiscarded = true
                                }
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
                    .startsWith("catch(")) || (codeStr.startsWith("catch{")) || ((codeStr.startsWith("elseif")) && (codeStr.contains("{")))) && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
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
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith("std::for_each") && (!codeStr.endsWith("}")) && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        if (nextLineBean.codeLine.trimAscii().endsWith("{")) {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lineBean.codeLine)
                            stringbuilder.append(nextLineBean.codeLine)
                            lineBean.codeLine = stringbuilder.toString().replace("\n", "")
                            nextLineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if ((codeStr == "()" || codeStr == ")") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii() == "}") {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            stringbuilder.append(lineBean.codeLine)
                            lineBean.codeLine = stringbuilder.toString().replace("\n", "")
                            lastLineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)
            
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if ((codeStr == "set{" || codeStr == "get{") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    var x = 1
                    var leftBrace = 0
                    var nextLineBean = stateBean.linesList[i + x]
                    while (!(nextLineBean.codeLine.trimAscii().endsWith("}") &&
                    (nextLineBean.codeLine.trimAscii() == "}" || handleTransferCharacters(nextLineBean.codeLine.toRuneArray(), nextLineBean.codeLine.indexOf("}").getOrThrow() - 1)) &&
                    leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1)) {
                        leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                        x++
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
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
                    if (i + x + 1 >= stateBean.linesList.size) {
                        break
                    }
                    stateBean.linesList.add(newlineBean, at:i + x + 1)
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
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
                        if(!(nextLineBean.codeLine.trimAscii().startsWith("case") || nextLineBean.codeLine.trimAscii().startsWith("default"))) {
                            nextLineBean.indentLevel++
                        }
                        nextLineBean = stateBean.linesList[i + x]
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.replace(" ", "").contains("]=[") && 
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
                if (codeStr.endsWith("(") && 
                    (i + 1 < stateBean.linesList.size) && 
                    (stateBean.linesList[i].indentLevel == stateBean.linesList[i + 1].indentLevel) && 
                    !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    var x = 1
                    var nextLineBeanStr = stateBean.linesList[i + x].codeLine.trimAscii()
                    while (stateBean.linesList[i + x].codeLine.trimAscii().contains(":")) {
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
                        stateBean.linesList[i + x].indentLevel++
                        x++
                    }
                }
            }

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
