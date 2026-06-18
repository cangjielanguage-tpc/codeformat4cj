package codeformat

class GoFormat <: GeneralProcessing {
    public func dealWithImport(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        var importMoreThanOne = false
        if (currentIndex >= 6) {
            if (notNullChar[currentIndex - 6] == r'i' && notNullChar[currentIndex - 5] == r'm' &&
                notNullChar[currentIndex - 4] == r'p' && notNullChar[currentIndex - 3] == r'o' &&
                notNullChar[currentIndex - 2] == r'r' && notNullChar[currentIndex - 1] == r't' &&
                notNullChar[currentIndex] == r' ') {
                var currChar: Rune = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
                while (currChar != r'"') {
                    if (stateBean.currentIndex == stateBean.codeChars.getOrThrow().size - 1) {
                        break
                    }
                    stateBean.currentIndex++
                    currChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
                    stateBean.perLineOutput.append(currChar)
                }
                let lineEndIndex: Int64 = stateBean.currentIndex
                let lineCode: String = String(
                    stateBean.codeChars.getOrThrow().slice(currentIndex, lineEndIndex - currentIndex + 1))
                var nextmatchchar = r' '
                if (lineCode.contains("(")) {
                    importMoreThanOne = true
                    nextmatchchar = r')'
                } else {
                    importMoreThanOne = false
                    nextmatchchar = r'"'
                }
                if (stateBean.currentIndex < stateBean.codeChars.getOrThrow().size - 1) {

                    stateBean.currentIndex++
                    var nextChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
                    stateBean.perLineOutput.append(nextChar)

                    while (nextChar != nextmatchchar) {
                        if (stateBean.currentIndex == stateBean.codeChars.getOrThrow().size - 1) {
                            break
                        }
                        stateBean.currentIndex++
                        nextChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
                        stateBean.perLineOutput.append(nextChar)
                    }
                    let lineEndIndex2: Int64 = stateBean.currentIndex
                    let lineCode2: String = String(
                        stateBean.codeChars.getOrThrow().slice(currentIndex, lineEndIndex2 - currentIndex + 1))
                    let lineBeanstart: LineBean = LineBean()
                    let lineBeanend: LineBean = LineBean()
                    if (importMoreThanOne) {
                        lineBeanstart.codeLine = "import ("
                        lineBeanstart.indentLevel = 0
                        stateBean.linesList.add(lineBeanstart)
                        var dealStr = lineCode2.trimAscii().replace("(", "").replace(")", "")
                        var listStr: ArrayList<String> = ArrayList<String>()
                        if (dealStr.contains("\n")) {
                            listStr = ArrayList<String>(dealStr.split("\n"))
                        } else {
                            listStr = ArrayList<String>(dealStr.split(";"))
                        }
                        for (str in listStr) {
                            let lineBeanmid: LineBean = LineBean()
                            lineBeanmid.codeLine = str
                            lineBeanmid.indentLevel = 1
                            stateBean.linesList.add(lineBeanmid)
                        }
                        lineBeanend.codeLine = ")"
                        lineBeanend.indentLevel = 0
                        lineBeanend.isSingleLine = true
                        stateBean.linesList.add(lineBeanend)
                    } else {
                        lineBeanstart.codeLine = "import " + lineCode2.trimAscii()
                        lineBeanstart.indentLevel = 0
                        stateBean.linesList.add(lineBeanstart)
                    }
                    stateBean.perLineOutput = StringBuilder()
                    stateBean.isLineStart = true
                    stateBean.perLineStartIndex = stateBean.currentIndex + 1
                    stateBean.lastChar = r'\n'
                    stateBean.currentIndex++
                    return
                }
            }
        }
    }

    public override func dealWithString(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        let currChar: Rune = notNullChar[currentIndex]
        var lastChar: Rune = r' '
        if (currentIndex - 1 >= 0) {
            lastChar = notNullChar[currentIndex - 1]
        }
        if ((currChar == r'"' || currChar == r'\'') && !stateBean.isInString && !stateBean.isInBackQuote) {
            stateBean.stringQuote = currChar
            stateBean.isInString = true
            return
        }
        if (currChar == r'`' && !stateBean.isInString && !stateBean.isInBackQuote) {
            stateBean.stringQuote = currChar
            stateBean.isInString = true
            stateBean.isInBackQuote = true
        }

        if (stateBean.isInString && currChar == stateBean.stringQuote && handleTransferCharacters(notNullChar, currentIndex - 1)) {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }

        if (stateBean.isInString && currChar == r'\n' && lastChar != r'v' && (currChar == r'"' || currChar == r'\'')) {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
        if (stateBean.isInBackQuote && currChar == stateBean.stringQuote && handleTransferCharacters(notNullChar, currentIndex - 1)) {
            stateBean.isInBackQuote = false
            stateBean.isInString = false
            stateBean.stringQuote = r' '
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

            if (currChar == r'{') {
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

                if (!stateBean.isInString) {
                    dealWithImport(stateBean)
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
                    lineBean.codeLine.trimAscii() == "," || lineBean.codeLine.trimAscii() == "()") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {

                        if (i > 0) {
                            let lastLineBean: LineBean = stateBean.linesList[i - 1]

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
                if (((codeStr.startsWith("else{")) || (codeStr.startsWith("elseif("))) &&
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
                if ((codeStr.startsWith("if ") || codeStr.startsWith("switch ")) && codeStr.endsWith(";") && !lineBean.isInMultilineComment &&
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
                if (codeStr == ")" && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {

                    if (i > 0) {

                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii() =="}") {


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
                if (codeStr.trimAscii() == "}" && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {

                    if (i > 0) {

                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith("interface{")) {


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
                if (codeStr.startsWith("=") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {

                    if (i > 0) {

                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith("interface{}")) {


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
                if (codeStr.startsWith("#") && !lineBean.isInMultilineComment) {
                    lineBean.indentLevel = 0
                }
            }



                var inSwitchBlock = false
                var needIndent = false

                for (i in 0..stateBean.linesList.size) {
                    let line = stateBean.linesList[i]
                    let t = line.codeLine.trimAscii()


                    if (t.startsWith("switch ") && t.contains("{")) {
                        inSwitchBlock = true
                        needIndent = false
                    }


                    if (t == "}" && inSwitchBlock) {
                        inSwitchBlock = false
                        needIndent = false
                    }


                    if (inSwitchBlock) {
                        if (t.startsWith("case ") || t.startsWith("default")) {


                            needIndent = true
                        } else if (needIndent) {

                            line.indentLevel = line.indentLevel+1
                        }
                    }
                }




                var inArrayBlock = false
                var strBuilder:StringBuilder = StringBuilder()
                for (i in 0..stateBean.linesList.size) {
                    let line = stateBean.linesList[i]
                    let t = line.codeLine.trimAscii().replace(" ","")

                    if (t.endsWith("]int{")||t.endsWith("]string{")||t.endsWith("]float64{")||t.contains("]int{//")||t.contains("]string{//")||t.contains("]float64{//")) {
                        if(!(t.contains("][") || t.contains("] ["))){
                            inArrayBlock = true
                        }
                    }


                    if ((t == "}" || t.contains("}//") || t.contains("}/*")) && inArrayBlock) {
                        strBuilder.append(line.codeLine)
                        line.codeLine = strBuilder.toString()
                        inArrayBlock = false
                        strBuilder = StringBuilder()
                    }

                    if (inArrayBlock) {
                        line.isDiscarded = true
                        strBuilder.append(line.codeLine.trimAscii())
                    }
                }

                removediscard(stateBean)






                var inDoubleArrayBlock = false
                var SubArrayBlock = false
                strBuilder = StringBuilder()
                for (i in 0..stateBean.linesList.size) {
                    let line = stateBean.linesList[i]
                    let t = line.codeLine.trimAscii().replace(" ","")

                    if (t.endsWith("]int{")||t.endsWith("]string{")||t.endsWith("]float64{")||t.contains("]int{//")||t.contains("]string{//")||t.contains("]float64{//")) {
                        if((t.contains("][") || t.contains("] ["))){
                            inDoubleArrayBlock = true
                        }
                    }

                    if((t == "{" || t.contains("{//") || t.contains("{/*")) && inDoubleArrayBlock){
                        SubArrayBlock = true
                    }

                    if((t == "},"|| t.contains("},//") || t.contains("},/*")) && inDoubleArrayBlock){
                        strBuilder.append(line.codeLine)
                        line.codeLine = strBuilder.toString()
                        SubArrayBlock = false
                        strBuilder = StringBuilder()
                    }


                    if ((t == "}" || t.contains("}//") || t.contains("}/*")) && inDoubleArrayBlock) {
                        inDoubleArrayBlock = false
                        strBuilder = StringBuilder()
                    }

                    if (inDoubleArrayBlock) {
                        if(SubArrayBlock){

                            line.isDiscarded = true
                            strBuilder.append(line.codeLine.trimAscii())
                        }
                    }
                }

                removediscard(stateBean)




                var isInFactoredDeclaration = false

                for (i in 0..stateBean.linesList.size) {
                    let line = stateBean.linesList[i]
                    let t = line.codeLine.trimAscii().replace(" ","")


                    if (t.startsWith("const(") || t.startsWith("var(")) {
                        isInFactoredDeclaration = true
                        continue
                    }


                    if (t == ")" && isInFactoredDeclaration) {
                        isInFactoredDeclaration = false
                    }


                    if (isInFactoredDeclaration) {
                        line.indentLevel = line.indentLevel+1
                    }
                }




                for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (!lineBean.isSingleLine) {
                    let codeStr = lineBean.codeLine.trimAscii().replace(" ","")
                    if ( (codeStr == "){" || codeStr == "{")  && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {

                        if (i > 0) {
                            let lastLineBean: LineBean = stateBean.linesList[i - 1]

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




            var x = 1
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (x != 1) {
                    lineBean.indentLevel = 0
                    x--
                    continue
                }

                if (!lineBean.codeLine.contains("`")) {
                    continue
                }

                if (lineBean.codeLine.contains("`") && lineBean.codeLine.trimAscii().endsWith("`") && lineBean.codeLine.count("`") > 1) {
                    continue
                }

                if (lineBean.codeLine.contains("`") &&
                !(lineBean.codeLine.trimAscii() == "`") &&
                !handleTransferCharacters(lineBean.codeLine.toRuneArray(), lineBean.codeLine.indexOf("`").getOrThrow() - 1)) {
                    continue
                }
                var nextLineBean = stateBean.linesList[i + x]
                while (!(nextLineBean.codeLine.trimAscii().endsWith("`") &&
                (lineBean.codeLine.trimAscii() == "`" || handleTransferCharacters(lineBean.codeLine.toRuneArray(), lineBean.codeLine.indexOf("`").getOrThrow() - 1)))) {
                    x++
                    nextLineBean = stateBean.linesList[i + x]
                }
                x++
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