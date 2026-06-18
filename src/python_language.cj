package codeformat

class PythonFormat <: BaseLanguage {

    let arrayListFlagTry: ArrayList<FlagBean> = ArrayList<FlagBean>()
    let arrayListFlagIf: ArrayList<FlagBean> = ArrayList<FlagBean>()

    func doTryFlag(lineBean: LineBean) {
        if (lineBean.codeLine.trimAscii().startsWith("try:")) {
            let flagBean = FlagBean("try", lineBean.indentLevel)
            arrayListFlagTry.add(flagBean)
        }
    }

    func doIfFlag(lineBean: LineBean) {
        if (lineBean.codeLine.trimAscii().startsWith("if ")) {
            let flagBean = FlagBean("if", lineBean.indentLevel)
            arrayListFlagIf.add(flagBean)
        }
    }

    public override func dealWithNewLine(stateBean: StateBean): Unit {
        if (stateBean.perLineOutput.size > 0) {
            let lineBean: LineBean = LineBean()
            lineBean.codeLine = stateBean.perLineOutput.toString()
            setLineFlagsAndIndent(lineBean, stateBean)
            setCommonFields(lineBean, stateBean)
            doTryFlag(lineBean)
            doIfFlag(lineBean)
            stateBean.linesList.add(lineBean)

            if (stateBean.isInRetuen) {
                stateBean.indentLevel--
                stateBean.isInRetuen = false
            } else {
                if (lineBean.codeLine.trimAscii().size != 0) {
                    stateBean.isLastLineReturn = false
                }
            }
            if (stateBean.isInContinue) {
                stateBean.indentLevel--
                stateBean.isInContinue = false
            }
            if (stateBean.isInBreak) {
                stateBean.indentLevel--
                stateBean.isInBreak = false
            }
            stateBean.perLineOutput = StringBuilder()
            stateBean.perLineStartIndex = stateBean.currentIndex + 1
            stateBean.lastChar = r'\n'
        }
    }

    public func dealWithColon(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 0)
        setLineFlagsAndIndent(lb, stateBean)
        setCommonFields(lb, stateBean)
        doTryFlag(lb)
        doIfFlag(lb)
        stateBean.linesList.add(lb)
        handlePostLineFlags(stateBean)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.indentLevel++
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r':'
        stateBean.currentIndex++
    }

    public override func dealWithLeftBigBracket(_: StateBean): Unit {
    }

    public override func dealWithRightBigBracket(_: StateBean): Unit {
    }

    public func dealWithMultiLineString(stateBean: StateBean): Bool {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = notNullChar[currentIndex]
        if (currentIndex >= 2) {
            var lastChar = notNullChar[currentIndex - 1]
            var lastlastChar = notNullChar[currentIndex - 2]
            if (((lastlastChar == r'"' && lastChar == r'"' && currChar == r'"') || (lastlastChar == r'\'' && lastChar ==
                r'\'' && currChar == r'\''))) {
                if (!stateBean.isInMultiString) {
                    stateBean.isInMultiString = true
                    stateBean.multiStringQuote = currChar
                    var perStr = ""
                    if (currChar == r'"') {
                        perStr = stateBean.perLineOutput.toString().removeSuffix("\"\"\"")
                    } else {
                        perStr = stateBean.perLineOutput.toString().removeSuffix("'''")
                    }
                    if (notNullChar.size > currentIndex + 3) {
                        stateBean.currentIndex += 3
                        let newcurrentIndex = stateBean.currentIndex
                        lastlastChar = notNullChar[newcurrentIndex - 2]
                        lastChar = notNullChar[newcurrentIndex - 1]
                        currChar = notNullChar[newcurrentIndex]
                        stateBean.perLineOutput.append(lastlastChar)
                        stateBean.perLineOutput.append(lastChar)
                        while (!(lastlastChar == stateBean.multiStringQuote && lastChar == stateBean.multiStringQuote &&
                                currChar == stateBean.multiStringQuote)) {
                            if (stateBean.currentIndex == stateBean.codeChars.getOrThrow().size - 1) {
                                break
                            }
                            stateBean.currentIndex++
                            stateBean.perLineOutput.append(currChar)
                            currChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
                            lastChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex - 1]
                            lastlastChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex - 2]
                        }
                    } else {
                        stateBean.isInMultiString = false
                        stateBean.multiStringQuote = r" "
                        return false
                    }

                    let lineEndIndex: Int64 = stateBean.currentIndex
                    var lineCodeAll: String = String(
                        stateBean.codeChars.getOrThrow().slice(currentIndex - 2, lineEndIndex - currentIndex + 2 + 1))
                    if (perStr.trimAscii().size > 0) {
                        let lb: LineBean = LineBean()
                        lb.codeLine = perStr
                        lb.indentLevel = stateBean.indentLevel
                        setCommonFields(lb, stateBean)
                        doTryFlag(lb)
                        doIfFlag(lb)
                        stateBean.linesList.add(lb)
                        stateBean.perLineOutput = StringBuilder()
                    }

                    let lineCodeList: Array<String> = lineCodeAll.split("\n")
                    for (index in 0..lineCodeList.size) {
                        let lb: LineBean = LineBean()
                        lb.codeLine = lineCodeList[index]
                        if (index == 0) {
                            lb.isFirstMultiCommentLine = true
                            lb.multilineCommentisAfterChangeLine = true
                        }
                        lb.indentLevel = stateBean.indentLevel
                        setCommonFields(lb, stateBean)
                        lb.isInMultiString = stateBean.isInMultiString
                        stateBean.linesList.add(lb)
                        stateBean.perLineOutput = StringBuilder()
                    }
                    handlePostLineFlags(stateBean)
                    stateBean.isLineStart = true
                    stateBean.perLineStartIndex = stateBean.currentIndex + 1
                    stateBean.lastChar = r'\n'
                    stateBean.currentIndex++
                    stateBean.multiStringQuote = r" "
                    stateBean.isInMultiString = false
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }

    public override func dealWithSingleLineComment(_: StateBean, _: String): Unit {
    }

    public override func dealWithMultiLineComment(_: StateBean, _: String): Unit {
    }

    public override func dealWithMacro(stateBean: StateBean): Unit {
        stateBean.isInMacro = true
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
        let lb = LineBean()
        lb.codeLine = lineCode
        lb.indentLevel = stateBean.indentLevel
        setCommonFields(lb, stateBean)
        stateBean.linesList.add(lb)
        handlePostLineFlags(stateBean)
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'\n'
        stateBean.currentIndex++
        stateBean.isInMacro = false
    }

    public override func dealWithAccessPublic(_: StateBean): Bool {
        return false
    }

    public override func dealWithAccessPrivate(_: StateBean): Bool {
        return false
    }

    public override func dealWithAccessProtected(_: StateBean): Bool {
        return false
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
            stateBean.stringQuote = currChar
            stateBean.isInString = true
            return
        }
        if (stateBean.isInString && currChar == stateBean.stringQuote && lastChar != r'\\') {
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

    public func dealWithReturn(stateBean: StateBean): Unit {
        if (matchKwEndingAt(stateBean, "return", 6)) {
            stateBean.isInRetuen = true
            stateBean.isLastLineReturn = true
        }
    }

    public func dealWithContinue(stateBean: StateBean): Unit {
        if (matchKwEndingAt(stateBean, "continue", 8)) {
            stateBean.isInContinue = true
        }
    }

    public func dealWithBreak(stateBean: StateBean): Unit {
        if (matchKwEndingAt(stateBean, "break", 5)) {
            stateBean.isInBreak = true
        }
    }

    public func dealWithExcept(stateBean: StateBean): Unit {
        if (matchKwEndingAt(stateBean, "except", 6)) {
            stateBean.isInExcept = true
        }
    }

    public func dealWithElif(stateBean: StateBean): Unit {
        if (matchKwEndingAt(stateBean, "elif", 4)) {
            stateBean.isInElif = true
        }
    }

    public func dealWithElse(stateBean: StateBean): Unit {
        if (matchKwEndingAt(stateBean, "else", 4)) {
            stateBean.isInElse = true
        }
    }

    public func dealWithDef(stateBean: StateBean): Unit {
        if (matchKwEndingAt(stateBean, "def ", 4)) {
            stateBean.isInDef = true
        }
    }

    public func dealWithImport(stateBean: StateBean): Unit {
        if (matchKwEndingAt(stateBean, "import ", 7)) {
            stateBean.isInImport = true
        }
    }

    public func dealWithClass(stateBean: StateBean): Unit {
        if (matchKwEndingAt(stateBean, "class ", 6)) {
            stateBean.isInClass = true
            stateBean.isHasClass = true
        }
    }

    public func dealWithMain(stateBean: StateBean): Unit {
        if (matchKwEndingAt(stateBean, " __name__", 9)) {
            stateBean.isInMain = true
        }
    }

    func matchKwEndingAt(stateBean: StateBean, kw: String, kwLen: Int64): Bool {
        let chars = stateBean.codeChars.getOrThrow()
        let ci = stateBean.currentIndex
        if (ci < kwLen - 1 || chars.size <= ci) { return false }
        for (i in 0..kwLen) {
            if (chars[ci - kwLen + 1 + i].toAsciiLowerCase() != kw.toRuneArray()[i].toAsciiLowerCase()) { return false }
        }
        return true
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
    }

    func setLineFlagsAndIndent(lineBean: LineBean, stateBean: StateBean): Unit {
        if (stateBean.isInExcept) {
            if (arrayListFlagTry.size > 0) {
                let tryflagBean = arrayListFlagTry.get(arrayListFlagTry.size - 1).getOrThrow()
                stateBean.indentLevel = tryflagBean.flagIndent
                lineBean.indentLevel = stateBean.indentLevel
                arrayListFlagTry.remove(at: arrayListFlagTry.size - 1)
            } else {
                lineBean.indentLevel = stateBean.indentLevel
            }
            stateBean.isInExcept = false
        } else if (stateBean.isInElif) {
            if (arrayListFlagIf.size > 0) {
                let ifFlagBean = arrayListFlagIf.get(arrayListFlagIf.size - 1).getOrThrow()
                stateBean.indentLevel = ifFlagBean.flagIndent
                lineBean.indentLevel = stateBean.indentLevel
            } else {
                lineBean.indentLevel = stateBean.indentLevel
            }
            stateBean.isInElif = false
        } else if (stateBean.isInElse) {
            if (arrayListFlagIf.size > 0) {
                let ifFlagBean = arrayListFlagIf.get(arrayListFlagIf.size - 1).getOrThrow()
                stateBean.indentLevel = ifFlagBean.flagIndent
                lineBean.indentLevel = stateBean.indentLevel
                arrayListFlagIf.remove(at: arrayListFlagIf.size - 1)
            } else {
                lineBean.indentLevel = stateBean.indentLevel
            }
            stateBean.isInElse = false
        } else if (stateBean.isInDef) {
            stateBean.indentLevel = if(stateBean.isHasClass) { 1 } else { 0 }
            lineBean.indentLevel = stateBean.indentLevel
            stateBean.isInDef = false
        } else if (stateBean.isInImport) {
            stateBean.indentLevel = 0
            lineBean.indentLevel = stateBean.indentLevel
            stateBean.isInImport = false
        } else if (stateBean.isInClass) {
            stateBean.indentLevel = 0
            lineBean.indentLevel = stateBean.indentLevel
            stateBean.isInClass = false
        } else if (stateBean.isInMain) {
            stateBean.indentLevel = 0
            lineBean.indentLevel = stateBean.indentLevel
            stateBean.isInMain = false
        } else {
            lineBean.indentLevel = stateBean.indentLevel
        }
    }

    func handlePostLineFlags(stateBean: StateBean): Unit {
        if (stateBean.isInRetuen) {
            stateBean.indentLevel--
            stateBean.isInRetuen = false
        } else {
            stateBean.isLastLineReturn = false
        }
        if (stateBean.isInContinue) {
            stateBean.indentLevel--
            stateBean.isInContinue = false
        }
        if (stateBean.isInBreak) {
            stateBean.indentLevel--
            stateBean.isInBreak = false
        }
    }

    public override func dealWithFor(_: StateBean): Unit {
    }

    public func dealWithSmallBracket(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        let currChar: Rune = notNullChar[currentIndex]
        if (currChar == r'(') {
            stateBean.isInSmallBracket = true
            stateBean.smallBracketDoublepy++
            return
        }

        if (stateBean.isInSmallBracket) {
            let currChar: Rune = notNullChar[currentIndex]

            if (currChar == r'(') {
                stateBean.smallBracketDoublepy++
            }
            if (currChar == r')') {
                stateBean.smallBracketDoublepy--
                if (stateBean.smallBracketDoublepy == 0) {
                    stateBean.isInSmallBracket = false
                }
            }
        }
    }

    public func dealWithBigBracket(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        let currChar: Rune = notNullChar[currentIndex]
        if (currChar == r'{') {
            stateBean.isInBigBracket = true
            stateBean.bigBracketDoublepy++
            return
        }

        if (stateBean.isInBigBracket) {
            let currChar: Rune = notNullChar[currentIndex]

            if (currChar == r'{') {
                stateBean.bigBracketDoublepy++
            }
            if (currChar == r'}') {
                stateBean.bigBracketDoublepy--
                if (stateBean.bigBracketDoublepy == 0) {
                    stateBean.isInBigBracket = false
                }
            }
        }
    }

    public override func dealWithSemicolon(stateBean: StateBean): Unit {
        let lb = createLineBean(stateBean, 0)
        setLineFlagsAndIndent(lb, stateBean)
        setCommonFields(lb, stateBean)
        lb.isInFor = stateBean.isInFor
        doTryFlag(lb)
        doIfFlag(lb)
        stateBean.linesList.add(lb)
        handlePostLineFlags(stateBean)
        if (stateBean.isInFor) {
            stateBean.isInFor = false
        }
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r';'
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
                if (currChar == r'#' && stateBean.isLineStart) {
                    dealWithMacro(stateBean)
                    continue
                }

                let res = dealWithMultiLineString(stateBean)
                if (res) {
                    continue
                }

                dealWithString(stateBean)

                if (!stateBean.isInString) {
                    dealWithSmallBracket(stateBean)
                    dealWithBigBracket(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithDef(stateBean)
                }
                if (!stateBean.isInString) {
                    dealWithImport(stateBean)
                }
                if (!stateBean.isInString) {
                    dealWithClass(stateBean)
                }
                if (!stateBean.isInString) {
                    dealWithMain(stateBean)
                }
                if (!stateBean.isInString) {
                    dealWithReturn(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithContinue(stateBean)
                }
                if (!stateBean.isInString) {
                    dealWithBreak(stateBean)
                }
                if (!stateBean.isInString) {
                    dealWithExcept(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithElif(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithElse(stateBean)
                }

                if (currChar == r':' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInSmallBracket &&
                    !stateBean.isInBigBracket) {
                    dealWithColon(stateBean)
                    continue
                }
                if (currChar == r';' && !stateBean.isInMacro && !stateBean.isInString) {
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

            removeOnlyChangeLine(stateBean)

            removediscard(stateBean)
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.codeLine.trimAscii() == ";" && !lineBean.isInMultiString && !lineBean.isInMacro) {
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
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith(");") && !lineBean.isInMultiString && !lineBean.isInMacro) {
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
                if (codeStr.endsWith("]") && !codeStr.contains("[") && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
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
}
