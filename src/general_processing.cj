package codeformat

open class GeneralProcessing <: BaseLanguage {
    open public override func dealWithNewLine(stateBean: StateBean): Unit {
        if (stateBean.perLineOutput.size > 0) {
            let lb = LineBean()
            lb.codeLine = stateBean.perLineOutput.toString()
            lb.indentLevel = stateBean.indentLevel
            setCommonFields(lb, stateBean)
            stateBean.linesList.add(lb)
            stateBean.perLineOutput = StringBuilder()
            stateBean.perLineStartIndex = stateBean.currentIndex + 1
            stateBean.lastChar = r'\n'
        }
    }

    open public override func dealWithLeftBigBracket(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
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
        stateBean.indentLevel++
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'{'
        stateBean.currentIndex++
    }

    open public override func dealWithRightBigBracket(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1))
        lineBean.codeLine = lineCode
        stateBean.indentLevel--
        if (stateBean.indentLevel <= 0) {
            stateBean.indentLevel = 0
        }
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

    open public override func dealWithSingleLineComment(stateBean: StateBean, perStr: String): Unit {
        stateBean.isInSinglelineComment = true
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]

        var beforeSpaceCount: Int64 = 0
        var beforeSpaceIndex = stateBean.currentIndex - 2
        while (beforeSpaceIndex >= 0 && stateBean.codeChars.getOrThrow()[beforeSpaceIndex] == r' ') {
            beforeSpaceCount++
            beforeSpaceIndex--
        }

        var tempSingleLineAfterChangeLine: Bool = false
        if (beforeSpaceIndex < 0) {
            tempSingleLineAfterChangeLine = true
        } else {
            let char: Rune = stateBean.codeChars.getOrThrow()[beforeSpaceIndex]
            tempSingleLineAfterChangeLine = (char == r'\n')
        }

        if (perStr.size > 0) {
            tempSingleLineAfterChangeLine = true
        }

        while (currChar != r'\n') {
            if (stateBean.currentIndex == stateBean.codeChars.getOrThrow().size - 1) {
                break
            }
            stateBean.currentIndex++
            currChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
            stateBean.perLineOutput.append(currChar)
        }

        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex - 1, lineEndIndex - lineStartIndex + 1 + 1))
        lineBean.codeLine = perStr + lineCode
        lineBean.indentLevel = stateBean.indentLevel
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        lineBean.isInSinglelineComment = stateBean.isInSinglelineComment
        lineBean.singleLineWhiteSpace = beforeSpaceCount
        lineBean.singlelineCommentisAfterChangeLine = tempSingleLineAfterChangeLine
        stateBean.linesList.add(lineBean)

        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'\n'
        stateBean.currentIndex++
        stateBean.isInSinglelineComment = false
    }

    open public override func dealWithMultiLineComment(stateBean: StateBean, perStr: String): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        stateBean.isInMultilineComment = true
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = notNullChar[stateBean.currentIndex]
        var lastChar: Rune = r'/'

        var beforeSpaceCount: Int64 = 0
        var beforeSpaceIndex = stateBean.currentIndex - 2
        while (beforeSpaceIndex >= 0 && notNullChar[beforeSpaceIndex] == r' ') {
            beforeSpaceCount++
            beforeSpaceIndex--
        }

        var tempMultiLineAfterChangeLine: Bool = false
        if (beforeSpaceIndex < 0) {
            tempMultiLineAfterChangeLine = true
        } else {
            let char: Rune = notNullChar[beforeSpaceIndex]
            tempMultiLineAfterChangeLine = (char == r'\n')
        }

        if (perStr.size > 0) {
            tempMultiLineAfterChangeLine = true
        }

        if (notNullChar.size > stateBean.currentIndex + 2) {
            stateBean.currentIndex += 2
            lastChar = notNullChar[stateBean.currentIndex - 1]
            currChar = notNullChar[stateBean.currentIndex]
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
            if (notNullChar.size > stateBean.currentIndex + 1) {
                stateBean.currentIndex++
            }
        }

        let lineEndIndex: Int64 = stateBean.currentIndex
        var lineCodeAll: String = String(notNullChar.slice(lineStartIndex - 1, lineEndIndex - lineStartIndex + 1 + 1))
        lineCodeAll = perStr + lineCodeAll
        let lineCodeList: Array<String> = lineCodeAll.split("\n")

        for (index in 0..lineCodeList.size) {
            let lineBean: LineBean = LineBean()
            lineBean.codeLine = lineCodeList[index]
            if (index == 0) {
                lineBean.isFirstMultiCommentLine = true
                lineBean.multilineCommentisAfterChangeLine = tempMultiLineAfterChangeLine
            }
            lineBean.indentLevel = stateBean.indentLevel
            lineBean.smallBracketDouble = stateBean.smallBracketDouble
            lineBean.middleBracketDouble = stateBean.middleBracketDouble
            lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
            lineBean.isInString = stateBean.isInString
            lineBean.isInMacro = stateBean.isInMacro
            lineBean.isInFor = stateBean.isInFor
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

    open public override func dealWithMacro(stateBean: StateBean): Unit {
        stateBean.isInMacro = true
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]

        while (currChar != r'\n') {
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
        stateBean.lastChar = r'\n'
        stateBean.currentIndex++
        stateBean.isInMacro = false
    }

    open public override func dealWithAccessPublic(stateBean: StateBean): Bool {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (notNullChar.size > currentIndex + 6) {
            if (notNullChar[currentIndex] == r'p' && notNullChar[currentIndex + 1] == r'u'
                && notNullChar[currentIndex + 2] == r'b' && notNullChar[currentIndex + 3] == r'l'
                && notNullChar[currentIndex + 4] == r'i' && notNullChar[currentIndex + 5] == r'c' &&
                notNullChar[currentIndex + 6] == r':') {
                stateBean.isInAccessFlag = true
                let lineBean: LineBean = LineBean()
                let lineCode: String = "public:"
                lineBean.codeLine = lineCode
                lineBean.indentLevel = 0
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

    open public override func dealWithAccessPrivate(stateBean: StateBean): Bool {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (notNullChar.size > currentIndex + 7) {
            if (notNullChar[currentIndex] == r'p' && notNullChar[currentIndex + 1] == r'r' &&
                notNullChar[currentIndex + 2] == r'i' && notNullChar[currentIndex + 3] == r'v' &&
                notNullChar[currentIndex + 4] == r'a' && notNullChar[currentIndex + 5] == r't' &&
                notNullChar[currentIndex + 6] == r'e' && notNullChar[currentIndex + 7] == r':') {
                stateBean.isInAccessFlag = true
                let lineBean: LineBean = LineBean()
                let lineCode: String = "private:"
                lineBean.codeLine = lineCode
                lineBean.indentLevel = 0
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

    open public override func dealWithAccessProtected(stateBean: StateBean): Bool {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (notNullChar.size > currentIndex + 9) {
            if (notNullChar[currentIndex] == r'p' && notNullChar[currentIndex + 1] == r'r' &&
                notNullChar[currentIndex + 2] == r'o' && notNullChar[currentIndex + 3] == r't' &&
                notNullChar[currentIndex + 4] == r'e' && notNullChar[currentIndex + 5] == r'c' &&
                notNullChar[currentIndex + 6] == r't' && notNullChar[currentIndex + 7] == r'e' &&
                notNullChar[currentIndex + 8] == r'd' && notNullChar[currentIndex + 9] == r':') {
                stateBean.isInAccessFlag = true
                let lineBean: LineBean = LineBean()
                let lineCode: String = "protected:"
                lineBean.codeLine = lineCode
                lineBean.indentLevel = 0
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

    open public override func dealWithString(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        let currChar: Rune = notNullChar[currentIndex]
        var lastChar: Rune = r' '
        if (currentIndex - 1 >= 0) {
            lastChar = notNullChar[currentIndex - 1]
        }

        if ((currChar == r'"' || currChar == r'\'') && !stateBean.isInString) {
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

    open public override func dealWithFor(stateBean: StateBean): Unit {
        if (!stateBean.isInFor) {
            let notNullChar = stateBean.codeChars.getOrThrow()
            let currentIndex = stateBean.currentIndex
            if (currentIndex >= 2) {
                if (notNullChar[currentIndex - 2] == r'f' && notNullChar[currentIndex - 1] == r'o' &&
                    notNullChar[currentIndex] == r'r') {
                    stateBean.isInFor = true
                    return
                }
            }
        }

        if (stateBean.isInFor) {
            let notNullChar = stateBean.codeChars.getOrThrow()
            let currChar: Rune = notNullChar[stateBean.currentIndex]
            if (stateBean.smallBracketDouble == 0) {
                if (!(currChar == r' ' || currChar == r'\t' || currChar == r'(')) {
                    stateBean.isInFor = false
                    return
                }
            }

            if (currChar == r'(') {
                stateBean.smallBracketDouble++
            }
            if (currChar == r')') {
                stateBean.smallBracketDouble--
                if (stateBean.smallBracketDouble == 0) {
                    stateBean.isInFor = false
                }
            }
        }
    }

    open public override func dealWithSemicolon(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 0)
        setCommonFields(lb, stateBean)
        stateBean.linesList.add(lb)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r';'
        stateBean.currentIndex++
    }

    public func handleTransferCharacters(charArr: Array<Rune>, lastIndex: Int64): Bool {
        var count: Int64 = 0
        var indexChar: Rune = charArr[lastIndex - count]
        while (indexChar == r'\\') {
            count++
            if (lastIndex - count < 0) {
                break
            }
            indexChar = charArr[lastIndex - count]
        }
        if (count % 2 == 0) {
            return true
        } else {
            return false
        }
    }

    func createLineBean(stateBean: StateBean, offset: Int64): LineBean {
        let lb = LineBean()
        let start = stateBean.perLineStartIndex
        let end = stateBean.currentIndex
        let codeChars = stateBean.codeChars.getOrThrow()
        let safeEnd = min(end, codeChars.size - 1)
        lb.codeLine = String(codeChars.slice(start, safeEnd - start + 1 - offset))
        lb.indentLevel = stateBean.indentLevel
        return lb
    }

    func setCommonFields(lb: LineBean, stateBean: StateBean): Unit {
        lb.smallBracketDouble = stateBean.smallBracketDouble
        lb.middleBracketDouble = stateBean.middleBracketDouble
        lb.sharpBracketDouble = stateBean.sharpBracketDouble
        lb.isInString = stateBean.isInString
        lb.isInMacro = stateBean.isInMacro
        lb.isInFor = stateBean.isInFor
    }

    func finishLine(lb: LineBean, stateBean: StateBean, offset: Int64, lastChar: Rune, advance!: Bool = true): Unit {
        setCommonFields(lb, stateBean)
        stateBean.linesList.add(lb)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1 - offset
        stateBean.lastChar = lastChar
        if (advance) {
            stateBean.currentIndex++
        }
    }

    func makeSimpleLine(stateBean: StateBean, offset: Int64, lastChar: Rune): Unit {
        finishLine(createLineBean(stateBean, offset), stateBean, offset, lastChar)
    }

    func matchKw(stateBean: StateBean, kw: String, kwLen: Int64): Bool {
        let notNullChar = stateBean.codeChars.getOrThrow()
        let currentIndex = stateBean.currentIndex
        if (notNullChar.size <= currentIndex + kwLen - 1) {
            return false
        }
        for (i in 0..kwLen) {
            if (notNullChar[currentIndex + i].toAsciiLowerCase() != kw.toRuneArray()[i].toAsciiLowerCase()) {
                return false
            }
        }
        return true
    }

    func mergeSingleLineComments(stateBean: StateBean): Unit {
        for (i in 0..stateBean.linesList.size) {
            let lineBean = stateBean.linesList[i]
            if (lineBean.isInSinglelineComment) {
                if (i > 0) {
                    let lastLineBean = stateBean.linesList[i - 1]
                    if (!lineBean.singlelineCommentisAfterChangeLine) {
                        let sb = StringBuilder()
                        sb.append(lastLineBean.codeLine)
                        for (j in 0..lineBean.singleLineWhiteSpace) {
                            sb.append(" ")
                        }
                        sb.append(lineBean.codeLine)
                        lastLineBean.codeLine = sb.toString()
                        lineBean.isDiscarded = true
                    }
                }
            }
        }
    }

    func mergeMultiLineComments(stateBean: StateBean): Unit {
        for (i in 0..stateBean.linesList.size) {
            let lineBean = stateBean.linesList[i]
            if (lineBean.isInMultilineComment && lineBean.isFirstMultiCommentLine) {
                if (i > 0) {
                    let lastLineBean = stateBean.linesList[i - 1]
                    if (!lineBean.multilineCommentisAfterChangeLine) {
                        let sb = StringBuilder()
                        sb.append(lastLineBean.codeLine)
                        sb.append(" ")
                        sb.append(lineBean.codeLine)
                        lastLineBean.codeLine = sb.toString()
                        lineBean.isDiscarded = true
                    }
                }
            }
        }
    }

    func finalFormatOutput(stateBean: StateBean, cfg: FormatConfig, runModifyMacro!: Bool = true): String {
        let usefulList = stateBean.linesList
        for (item in usefulList) {
            item.codeLine = item.codeLine.trimAscii()
        }
        if (runModifyMacro) {
            modifyMacroAndSpace(stateBean)
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
    }
}
