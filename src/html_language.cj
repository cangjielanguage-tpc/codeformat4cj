package codeformat

class HtmlFormat <: GeneralProcessing {
    public override func dealWithMultiLineComment(stateBean: StateBean, perStr: String): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        stateBean.isInMultilineComment = true
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = notNullChar[stateBean.currentIndex]
        var lastChar: Rune = r'<'
        var lastLastChar: Rune = r'!'

        if (notNullChar.size > stateBean.currentIndex + 2) {
            stateBean.currentIndex += 2
            let newcurrentIndex = stateBean.currentIndex
            lastChar = notNullChar[newcurrentIndex - 1]
            currChar = notNullChar[newcurrentIndex]
            stateBean.perLineOutput.append(lastChar)
            while (!(lastLastChar == r'-' && lastChar == r'-' && currChar == r'>')) {
                if (stateBean.currentIndex == notNullChar.size - 1) {
                    break
                }
                stateBean.currentIndex = stateBean.currentIndex + 1
                stateBean.perLineOutput.append(currChar)
                lastLastChar = lastChar
                lastChar = currChar
                currChar = notNullChar[stateBean.currentIndex]
            }
        }

        let lineEndIndex: Int64 = stateBean.currentIndex + 1
        var lineCodeAll: String = String(notNullChar.slice(lineStartIndex - 3, lineEndIndex - lineStartIndex + 3))
        lineCodeAll = perStr + lineCodeAll
        let lineCodeList: Array<String> = lineCodeAll.split("\n")
        for (index in 0..lineCodeList.size) {
            let lineBean: LineBean = LineBean()
            lineBean.codeLine = lineCodeList[index]
            lineBean.indentLevel = stateBean.indentLevel
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

    public override func dealWithString(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        let currChar: Rune = notNullChar[currentIndex]
        var lastChar: Rune = r' '
        if (currentIndex - 1 >= 0) {
            lastChar = notNullChar[currentIndex - 1]
        }
        if (currChar == r'"' && !stateBean.isInString && lastChar != r'\\') {
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

    func isDoctypeTag(tagContent: String): Bool {
        return tagContent.toAsciiLower().startsWith("<!doctype")
    }

    func isCommentTag(tagContent: String): Bool {
        return tagContent.startsWith("<!--")
    }

    func isStartTag(tagContent: String): Bool {
        return tagContent.contains("<") && !tagContent.contains("</") && !tagContent.contains("<!") && !tagContent.contains("< ")
    }

    func isEndTag(tagContent: String): Bool {
        return tagContent.contains("</")
    }

    func isSelfClosingTag(tagContent: String): Bool {
        let lower = tagContent.toAsciiLower()
        return lower.contains("/>") || 
               lower.startsWith("<area") || lower.startsWith("<base") || 
               lower.startsWith("<br") || lower.startsWith("<col") || 
               lower.startsWith("<embed") || lower.startsWith("<hr") || 
               lower.startsWith("<img") || lower.startsWith("<input") || 
               lower.startsWith("<keygen") || lower.startsWith("<link") || 
               lower.startsWith("<meta") || lower.startsWith("<param") || 
               lower.startsWith("<source") || lower.startsWith("<track") || 
               lower.startsWith("<wbr")
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

                if (currChar == r'-' && stateBean.lastChar == r'-' && !stateBean.isInString) {
                    if (stateBean.currentIndex >= 2 && i[stateBean.currentIndex - 2] == r'!' && i[stateBean.currentIndex - 3] == r'<') {
                        var str = stateBean.perLineOutput.toString().removeSuffix("<!--")
                        if (str.trimAscii().size > 0) {
                            dealWithMultiLineComment(stateBean, str)
                        } else {
                            dealWithMultiLineComment(stateBean, "")
                        }
                        continue
                    }
                }

                if (currChar == r'{' && !stateBean.isInString && !stateBean.isInMacro) {
                    dealWithLeftBigBracket(stateBean)
                    continue
                }
                if (currChar == r'}' && !stateBean.isInString && !stateBean.isInMacro) {
                    dealWithRightBigBracket(stateBean)
                    continue
                }

                if (currChar == r'>' && !stateBean.isInString) {
                    let currentOutput = stateBean.perLineOutput.toString()
                    let lineBean = LineBean()
                    lineBean.codeLine = currentOutput.trimAscii()
                    lineBean.indentLevel = stateBean.indentLevel
                    
                    let tagContent = lineBean.codeLine
                    
                    if (isDoctypeTag(tagContent)) {
                        lineBean.indentLevel = 0
                    } else if (isCommentTag(tagContent)) {
                        lineBean.isInMultilineComment = true
                    } else if (isEndTag(tagContent)) {
                        stateBean.indentLevel--
                        if (stateBean.indentLevel < 0) {
                            stateBean.indentLevel = 0
                        }
                        lineBean.indentLevel = stateBean.indentLevel
                    } else if (isStartTag(tagContent)) {
                        if (!isSelfClosingTag(tagContent)) {
                            lineBean.indentLevel = stateBean.indentLevel
                            stateBean.indentLevel++
                        } else {
                            lineBean.indentLevel = stateBean.indentLevel
                        }
                    }
                    
                    stateBean.linesList.add(lineBean)
                    stateBean.perLineOutput = StringBuilder()
                    stateBean.isLineStart = true
                    stateBean.perLineStartIndex = stateBean.currentIndex + 1
                    stateBean.lastChar = r'>'
                    stateBean.currentIndex++
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

            removeOnlyChangeLine(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr.endsWith("}") && !lineBean.isInMultilineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith("{")) {
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
                if (codeStr.endsWith(">") && codeStr.startsWith("<") && !lineBean.isInMultilineComment) {
                    var tagHeader = ""
                    if (codeStr.contains(" ")) {
                        tagHeader = codeStr.split(" ")[0] + ">"
                    } else {
                        tagHeader = codeStr
                    }
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        if (nextLineBean.codeLine.trimAscii().endsWith(tagHeader.replace("<", "</"))) {
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lineBean.codeLine)
                            stringbuilder.append(nextLineBean.codeLine)
                            lineBean.codeLine = stringbuilder.toString()
                            nextLineBean.isDiscarded = true
                            if (nextLineBean.codeLine.trimAscii() == tagHeader.replace("<", "</")) {
                                continue
                            }
                        } else if (nextLineBean.codeLine.contains("<") && nextLineBean.codeLine.trimAscii().endsWith(">")) {
                            var x = 1
                            while (!stateBean.linesList[i + x].codeLine.trimAscii().startsWith("<")) {
                                if (i + x >= stateBean.linesList.size) {
                                    break
                                }
                                let stringbuilder: StringBuilder = StringBuilder()
                                stringbuilder.append(lineBean.codeLine)
                                stringbuilder.append(stateBean.linesList[i + x].codeLine)
                                lineBean.codeLine = stringbuilder.toString()
                                stateBean.linesList[i + x].isDiscarded = true
                                x++
                            }
                        }
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.endsWith(">") && codeStr.startsWith("<") && !lineBean.isInMultilineComment) {
                    var tagHeader = ""
                    if (codeStr.contains(" ")) {
                        tagHeader = codeStr.split(" ")[0] + ">"
                    } else {
                        tagHeader = codeStr
                    }
                    if ((tagHeader == "<p>" || codeStr.trimAscii().startsWith("<p>")) && !codeStr.contains("</p>")) {
                        let stringbuilder: StringBuilder = StringBuilder()
                        stringbuilder.append(codeStr)
                        var x = 1
                        var nextLineBeanStr = stateBean.linesList[i + x].codeLine.trimAscii()
                        while (!nextLineBeanStr.endsWith("</p>")) {
                            stringbuilder.append(stateBean.linesList[i + x].codeLine)
                            stateBean.linesList[i + x].isDiscarded = true
                            x++
                            if (i + x >= stateBean.linesList.size) {
                                break
                            }
                            nextLineBeanStr = stateBean.linesList[i + x].codeLine.trimAscii()
                        }
                        stringbuilder.append(stateBean.linesList[i + x].codeLine)
                        lineBean.codeLine = stringbuilder.toString()
                        stateBean.linesList[i + x].isDiscarded = true
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii()
                if (!codeStr.contains("<") && !codeStr.contains(">") && !lineBean.isInMultilineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().contains("<li>") || lastLineBean.codeLine.trimAscii().contains("<input")) {
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
                if (codeStr.startsWith("<html") && !lineBean.isInMultilineComment) {
                    if (i > 0) {
                        var x = 1
                        var nextLineBean: LineBean = stateBean.linesList[i + x]
                        while (!nextLineBean.codeLine.trimAscii().startsWith("</html")) {
                            nextLineBean.indentLevel--
                            x++
                            if (i+x >= stateBean.linesList.size) {
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
                if (!lineBean.codeLine.trimAscii().endsWith("<div>") || lineBean.isDiscarded == true) {
                    continue
                }
                var x = 1
                while (lineBean.codeLine.trimAscii().endsWith("<div>") && !lineBean.isInMultilineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
                        var nextLineBean: LineBean = stateBean.linesList[i + x]
                        if (!nextLineBean.codeLine.trimAscii().startsWith("<")) {
                            lineBean.codeLine = lineBean.codeLine.trimAscii() + nextLineBean.codeLine.trimAscii()
                            nextLineBean.isDiscarded = true
                            x++
                        } else {
                            break
                        }
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.codeLine.trimAscii() == "<!--" && lineBean.isInMultilineComment) {
                    var x = 1
                    while (!(i < stateBean.linesList.size - x && stateBean.linesList[i + x].codeLine.trimAscii().endsWith("-->"))) {
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
                        stateBean.linesList[i + x].indentLevel = 0
                        x++
                    }
                    stateBean.linesList[i + x].indentLevel = 0
                }
            }
            removediscard(stateBean)

            let usefulList = stateBean.linesList
            for (item in usefulList) {
                item.codeLine = item.codeLine.trimAscii()
            }

            for (index in 0..usefulList.size) {
                let item = usefulList[index]
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
