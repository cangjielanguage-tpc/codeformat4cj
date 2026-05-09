package codeformat

class SqlFormat <: BaseLanguage {
    public override func dealWithNewLine(stateBean: StateBean): Unit {
        if (stateBean.perLineOutput.size > 0) {
            let lineBean: LineBean = LineBean()
            lineBean.codeLine = stateBean.perLineOutput.toString()
            lineBean.indentLevel = stateBean.indentLevel
            lineBean.smallBracketDouble = stateBean.smallBracketDouble
            lineBean.middleBracketDouble = stateBean.middleBracketDouble
            lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
            lineBean.isInString = stateBean.isInString
            lineBean.isInMacro = stateBean.isInMacro
            lineBean.isInFor = stateBean.isInFor
            stateBean.linesList.add(lineBean) //这里保存了
            stateBean.perLineOutput = StringBuilder()
            stateBean.perLineStartIndex = stateBean.currentIndex + 1
            stateBean.lastChar = r'\n'
        }
    }

    public override func dealWithLeftBigBracket(stateBean: StateBean): Unit {

    }

    public override func dealWithRightBigBracket(stateBean: StateBean): Unit {
        
    }

    public override func dealWithSingleLineComment(stateBean: StateBean, perStr: String): Unit {
        stateBean.isInSinglelineComment = true
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = stateBean.codeChars.getOrThrow()[stateBean.currentIndex] //中的第二个/

        //往前循环看看有多少空格
        var beforeSpaceCount: Int64 = 0
        var beforeSpaceIndex = stateBean.currentIndex - 2 //第一个/开始 再前面一个是/的前面一个
        while (beforeSpaceIndex >= 0 && stateBean.codeChars.getOrThrow()[beforeSpaceIndex] == r' ') {
            beforeSpaceCount++
            beforeSpaceIndex--
        }
        // //单行前面是不是换行 判断这个单行注释是不是单独一行
        var tempSingleLineAfterChangLine: Bool = false
        if (beforeSpaceIndex < 0) { //值为-1
            //表示是第一行
            tempSingleLineAfterChangLine = true
        } else {
            let char: Rune = stateBean.codeChars.getOrThrow()[beforeSpaceIndex]
            if (char == r'\n') {
                tempSingleLineAfterChangLine = true
            } else {
                tempSingleLineAfterChangLine = false
            }
        }

        if (perStr.size > 0) {
            //出现这个perStr有值的情况表示单行注释已经和前面的内容连接起来了，不用考虑这个tempSingleLineAfterChangLine了
            //因为下面有lineBean.codeLine = perStr+lineCode
            tempSingleLineAfterChangLine = true
        }

        //上面是往前遍历  下面是往后遍历
        while (currChar != r'\n') {
            if (stateBean.currentIndex == stateBean.codeChars.getOrThrow().size - 1) {
                break
            }
            stateBean.currentIndex++
            currChar = stateBean.codeChars.getOrThrow()[stateBean.currentIndex]
            stateBean.perLineOutput.append(currChar)
        }
        let lineEndIndex: Int64 = stateBean.currentIndex
        //从前面那个/算起     /012 //012
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex - 1, lineEndIndex - lineStartIndex + 1 + 1))
        lineBean.codeLine = perStr + lineCode
        //单行注释的缩进和StateBean一致
        lineBean.indentLevel = stateBean.indentLevel
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        lineBean.isInSinglelineComment = stateBean.isInSinglelineComment
        lineBean.singleLineWhiteSpace = beforeSpaceCount
        lineBean.singlelineCommentisAfterChangeLine = tempSingleLineAfterChangLine
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'\n'
        stateBean.currentIndex++
        stateBean.isInSinglelineComment = false
    }

    public override func dealWithMultiLineComment(stateBean: StateBean, perStr: String): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        stateBean.isInMultilineComment = true
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = notNullChar[stateBean.currentIndex] // /*中的*
        var lastChar: Rune = r'/'
        //往前循环看看有多少空格
        var beforeSpaceCount: Int64 = 0
        var beforeSpaceIndex = stateBean.currentIndex - 2 //第一个*开始 再前面一个是/
        while (beforeSpaceIndex >= 0 && notNullChar[beforeSpaceIndex] == r' ') {
            beforeSpaceCount++
            beforeSpaceIndex--
        }
        // //多行第一行前面是不是换行 判断这个多行第一行注释是不是单独一行
        var tempMultiLineAfterChangLine: Bool = false
        if (beforeSpaceIndex < 0) { //值为-1
            //表示是第一行
            tempMultiLineAfterChangLine = true
        } else {
            let char: Rune = notNullChar[beforeSpaceIndex]
            if (char == r'\n') {
                tempMultiLineAfterChangLine = true
            } else {
                tempMultiLineAfterChangLine = false
            }
        }

        if (perStr.size > 0) {
            //出现这个perStr有值的情况表示单行注释已经和前面的内容连接起来了，不用考虑这个tempSingleLineAfterChangLine了
            tempMultiLineAfterChangLine = true
        }
        //这个跟单行注释不一样 如果前面有内容就只加一个 空格
        if (notNullChar.size > stateBean.currentIndex + 2) {
            stateBean.currentIndex += 2
            let newcurrentIndex = stateBean.currentIndex
            lastChar = notNullChar[newcurrentIndex - 1]
            currChar = notNullChar[newcurrentIndex]
            //因为跳跃了 所以这里补上
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
            //说明长度不够不符合多行注释 很小情况
            if (notNullChar.size > stateBean.currentIndex + 1) {
                stateBean.currentIndex++
            }
        }

        //到这里就是结束的Index了
        let lineEndIndex: Int64 = stateBean.currentIndex
        var lineCodeAll: String = String(notNullChar.slice(lineStartIndex - 1, lineEndIndex - lineStartIndex + 1 + 1))
        lineCodeAll = perStr + lineCodeAll
        //然后这里面的内容根据\n分为几行 解析为几个LineBean
        let lineCodeList: Array<String> = lineCodeAll.split("\n")
        for (index in 0..lineCodeList.size) {
            let lineBean: LineBean = LineBean()
            lineBean.codeLine = lineCodeList[index]
            if (index == 0) {
                lineBean.isFirstMultiCommentLine = true
                lineBean.multilineCommentisAfterChangeLine = tempMultiLineAfterChangLine
            }
            //多行注释的缩进和StateBean一致
            lineBean.indentLevel = stateBean.indentLevel
            lineBean.smallBracketDouble = stateBean.smallBracketDouble
            lineBean.middleBracketDouble = stateBean.middleBracketDouble
            lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
            lineBean.isInString = stateBean.isInString
            lineBean.isInMacro = stateBean.isInMacro
            lineBean.isInFor = stateBean.isInFor
            lineBean.isInMultilineComment = stateBean.isInMultilineComment
            //多行的时候跟单行注释不一样 如果前面有内容就只加一个 空格
            stateBean.linesList.add(lineBean)
            stateBean.perLineOutput = StringBuilder()
        }
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'\n'
        stateBean.currentIndex++
        stateBean.isInMultilineComment = false
    }

    public override func dealWithMacro(stateBean: StateBean): Unit {
    }

    public override func dealWithAccessPublic(stateBean: StateBean): Bool {
        return false
    }

    public override func dealWithAccessPrivate(stateBean: StateBean): Bool {
        return false
    }

    public override func dealWithAccessProtected(stateBean: StateBean): Bool {
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
        if ((currChar == r'\'') && !stateBean.isInString) {
            stateBean.stringQuote = currChar
            stateBean.isInString = true
            return
        }
        if (stateBean.isInString && currChar == stateBean.stringQuote && lastChar != r'\\') {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
        //解决错误情况单个"号导致字符串没法关闭的情况
        if (stateBean.isInString && currChar == r'\n') {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
    }

    public override func dealWithFor(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 2) {
            if (notNullChar[currentIndex - 2].toAsciiLowerCase() == r'f' && notNullChar[currentIndex - 1].toAsciiLowerCase() == r'o' &&
                notNullChar[currentIndex].toAsciiLowerCase() == r'r') {
                stateBean.isInFor = true
                return
            }
        }
        if (stateBean.isInFor) {
            //这里要检测for之后除了空格第一个字符如果不是(那就没有进for
            let currChar: Rune = notNullChar[currentIndex]

            if (currChar == r'{' || currChar == r'}') { //主要是用于for循环中的()成对
                stateBean.isInFor = false
            }
        }
    }

    public override func dealWithSemicolon(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r';'
        stateBean.currentIndex++
    }

    public func dealWithSqlValues(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 5) {
            if (notNullChar[currentIndex - 5].toAsciiLowerCase() == r'v' && notNullChar[currentIndex - 4].toAsciiLowerCase()== r'a' &&
                notNullChar[currentIndex - 3].toAsciiLowerCase() == r'l' && notNullChar[currentIndex - 2].toAsciiLowerCase()== r'u' &&
                notNullChar[currentIndex - 1].toAsciiLowerCase()== r'e' &&notNullChar[currentIndex] == r's') {
                stateBean.isInValues = true
                dealWithInSqlValues(stateBean)
                return
            }
        }
    }

    public func dealWithSqlJoin(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 4) {
            if (notNullChar[currentIndex - 4].toAsciiLowerCase()== r'j' &&
                notNullChar[currentIndex - 3].toAsciiLowerCase() == r'o' && notNullChar[currentIndex - 2].toAsciiLowerCase()== r'i' &&
                notNullChar[currentIndex - 1].toAsciiLowerCase() == r'n' && notNullChar[currentIndex] == r' ') {  
                stateBean.isInJoin = true      
                dealWithInSqlJoin(stateBean)
                return
            }
        }
    }

    public func dealWithSqlCrossJoin(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 10) {
            if (notNullChar[currentIndex - 10].toAsciiLowerCase() == r'c' && notNullChar[currentIndex - 9].toAsciiLowerCase()== r'r' &&
                notNullChar[currentIndex - 8].toAsciiLowerCase() == r'o' && notNullChar[currentIndex - 7].toAsciiLowerCase()== r's' &&
                notNullChar[currentIndex - 6].toAsciiLowerCase() == r's' && notNullChar[currentIndex - 5].toAsciiLowerCase()== r' ' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'j' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r'o' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'i' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'n' &&
                notNullChar[currentIndex] == r' ') {  
                stateBean.isInJoin = true    
                stateBean.isInMultiJoin = true   
                dealWithInSqlCrossJoin(stateBean)
                return
            }
        }
    }

    public func dealWithSqlInnerJoin(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 10) {
            if (notNullChar[currentIndex - 10].toAsciiLowerCase() == r'i' && notNullChar[currentIndex - 9].toAsciiLowerCase()== r'n' &&
                notNullChar[currentIndex - 8].toAsciiLowerCase() == r'n' && notNullChar[currentIndex - 7].toAsciiLowerCase()== r'e' &&
                notNullChar[currentIndex - 6].toAsciiLowerCase() == r'r' && notNullChar[currentIndex - 5].toAsciiLowerCase()== r' ' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'j' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r'o' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'i' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'n' &&
                notNullChar[currentIndex] == r' ') {  
                stateBean.isInJoin = true    
                stateBean.isInMultiJoin = true 
                dealWithInSqlInnerJoin(stateBean)
                return
            }
        }
    }

    public func dealWithSqlLeftJoin(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 9) {
            if (notNullChar[currentIndex - 9].toAsciiLowerCase()== r'l' &&
                notNullChar[currentIndex - 8].toAsciiLowerCase() == r'e' && notNullChar[currentIndex - 7].toAsciiLowerCase()== r'f' &&
                notNullChar[currentIndex - 6].toAsciiLowerCase() == r't' && notNullChar[currentIndex - 5].toAsciiLowerCase()== r' ' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'j' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r'o' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'i' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'n' &&
                notNullChar[currentIndex] == r' ') {  
                stateBean.isInJoin = true  
                stateBean.isInMultiJoin = true     
                dealWithInSqlLeftJoin(stateBean)
                return
            }
        }
    }


    public func dealWithSqlRightJoin(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 10) {
            if (notNullChar[currentIndex - 10].toAsciiLowerCase() == r'r' && notNullChar[currentIndex - 9].toAsciiLowerCase()== r'i' &&
                notNullChar[currentIndex - 8].toAsciiLowerCase() == r'g' && notNullChar[currentIndex - 7].toAsciiLowerCase()== r'h' &&
                notNullChar[currentIndex - 6].toAsciiLowerCase() == r't' && notNullChar[currentIndex - 5].toAsciiLowerCase()== r' ' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'j' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r'o' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'i' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'n' &&
                notNullChar[currentIndex] == r' ') {  
                stateBean.isInJoin = true     
                stateBean.isInMultiJoin = true  
                dealWithInSqlRightJoin(stateBean)
                return
            }
        }
    }


    public func dealWithSqlFullOuterJoin(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 15) {
            if (notNullChar[currentIndex - 15].toAsciiLowerCase()== r'f' && notNullChar[currentIndex - 14].toAsciiLowerCase()== r'u' &&
                notNullChar[currentIndex - 13].toAsciiLowerCase()== r'l' && notNullChar[currentIndex - 12].toAsciiLowerCase()== r'l' &&
                notNullChar[currentIndex - 11].toAsciiLowerCase() == r' ' && notNullChar[currentIndex - 10].toAsciiLowerCase()== r'o' &&
                notNullChar[currentIndex - 9].toAsciiLowerCase() == r'u'  &&
                notNullChar[currentIndex - 8].toAsciiLowerCase() == r't' && notNullChar[currentIndex - 7].toAsciiLowerCase()== r'e' &&
                notNullChar[currentIndex - 6].toAsciiLowerCase() == r'r' && notNullChar[currentIndex - 5].toAsciiLowerCase()== r' ' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'j' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r'o' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'i' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'n' &&
                notNullChar[currentIndex] == r' ') {  
                stateBean.isInJoin = true    
                stateBean.isInMultiJoin = true   
                dealWithInSqlFullOuterJoin(stateBean)
                return
            }
        }
    }


    public func dealWithSqlCreateTable(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 12) {
            if (notNullChar[currentIndex - 12].toAsciiLowerCase() == r'c' && notNullChar[currentIndex - 11].toAsciiLowerCase() == r'r' &&
                notNullChar[currentIndex - 10].toAsciiLowerCase() == r'e' && notNullChar[currentIndex - 9].toAsciiLowerCase()== r'a' &&
                notNullChar[currentIndex - 8].toAsciiLowerCase() == r't' && notNullChar[currentIndex - 7].toAsciiLowerCase()== r'e' &&
                notNullChar[currentIndex - 6].toAsciiLowerCase() == r' ' && notNullChar[currentIndex - 5].toAsciiLowerCase()== r't' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'a' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r'b' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'l' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'e' &&
                notNullChar[currentIndex] == r' ') {
                stateBean.isInCreateTable = true   
                stateBean.isHasCreateTableLeft = true     
                stateBean.isHasCreateTableRight = true     
                return
            }
        }
    }


    public func dealWithSqlAlertTable(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 11) {
            if (notNullChar[currentIndex - 11].toAsciiLowerCase() == r'a' &&
                notNullChar[currentIndex - 10].toAsciiLowerCase() == r'l' && notNullChar[currentIndex - 9].toAsciiLowerCase()== r'e' &&
                notNullChar[currentIndex - 8].toAsciiLowerCase() == r'r' && notNullChar[currentIndex - 7].toAsciiLowerCase()== r't' &&
                notNullChar[currentIndex - 6].toAsciiLowerCase() == r' ' && notNullChar[currentIndex - 5].toAsciiLowerCase()== r't' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'a' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r'b' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'l' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'e' &&
                notNullChar[currentIndex] == r' ') {
                stateBean.isInAlertTable = true    
                return
            }
        }
    }


    public func dealWithSqlAddColumn(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 10) {
            if (notNullChar[currentIndex - 10].toAsciiLowerCase() == r'a' && notNullChar[currentIndex - 9].toAsciiLowerCase() == r'd' &&
                notNullChar[currentIndex - 8].toAsciiLowerCase() == r'd' && notNullChar[currentIndex - 7].toAsciiLowerCase()== r' ' &&
                notNullChar[currentIndex - 6].toAsciiLowerCase() == r'c' && notNullChar[currentIndex - 5].toAsciiLowerCase()== r'o' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'l' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r'u' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'm' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'n' &&
                notNullChar[currentIndex] == r' ') {
                dealWithInSqlAddColumn(stateBean)
                return
            }
        }
    }

    public func dealWithSqlModifyColumn(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 13) {
            if (notNullChar[currentIndex - 13].toAsciiLowerCase() == r'm' &&
                notNullChar[currentIndex - 12].toAsciiLowerCase() == r'o' && notNullChar[currentIndex - 11].toAsciiLowerCase() == r'd' &&
                notNullChar[currentIndex - 10].toAsciiLowerCase() == r'i' && notNullChar[currentIndex - 9].toAsciiLowerCase()== r'f' &&
                notNullChar[currentIndex - 8].toAsciiLowerCase() == r'y' && notNullChar[currentIndex - 7].toAsciiLowerCase()== r' ' &&
                notNullChar[currentIndex - 6].toAsciiLowerCase() == r'c' && notNullChar[currentIndex - 5].toAsciiLowerCase()== r'o' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'l' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r'u' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'm' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'n' &&
                notNullChar[currentIndex] == r' ') { 
                dealWithInSqlModifyColumn(stateBean)
                return
            }
        }
    }

    public func dealWithSqlDropColumn(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 11) {
            if (notNullChar[currentIndex - 11].toAsciiLowerCase() == r'd' &&
                notNullChar[currentIndex - 10].toAsciiLowerCase() == r'r' && notNullChar[currentIndex - 9].toAsciiLowerCase()== r'o' &&
                notNullChar[currentIndex - 8].toAsciiLowerCase() == r'p' && notNullChar[currentIndex - 7].toAsciiLowerCase()== r' ' &&
                notNullChar[currentIndex - 6].toAsciiLowerCase() == r'c' && notNullChar[currentIndex - 5].toAsciiLowerCase()== r'o' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'l' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r'u' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'm' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'n' &&
                notNullChar[currentIndex] == r' ') {   
                dealWithInSqlDropColumn(stateBean)
                return
            }
        }
    }


    public func dealWithSqlSelect(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 6) {
            if (notNullChar[currentIndex - 6].toAsciiLowerCase() == r's' && notNullChar[currentIndex - 5].toAsciiLowerCase() == r'e' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'l' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r'e' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'c' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r't' &&
                notNullChar[currentIndex] == r' ') {
                stateBean.isInSelect = true
                //stateBean.isInSelectCount++
                dealWithInSqlSelect(stateBean)
                return
            }
        }
    }

    public func dealWithSqlSubSelect(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 7) {
            if (notNullChar[currentIndex - 7].toAsciiLowerCase() == r'(' &&
                notNullChar[currentIndex - 6].toAsciiLowerCase() == r's' && notNullChar[currentIndex - 5].toAsciiLowerCase() == r'e' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'l' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r'e' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'c' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r't' &&
                notNullChar[currentIndex] == r' ') {
                //左括号计数
                if(!stateBean.isInSubSelect){
                    stateBean.isInSubSelectCount++
                }
                stateBean.isInSubSelect = true
                dealWithInSqlSubSelect(stateBean)
                return
            }
        }
    }

    public func dealWithSqlDeleteFrom(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 11) {
            if (notNullChar[currentIndex - 11].toAsciiLowerCase() == r'd' && notNullChar[currentIndex - 10].toAsciiLowerCase() == r'e' &&
                notNullChar[currentIndex - 9].toAsciiLowerCase() == r'l' && notNullChar[currentIndex - 8].toAsciiLowerCase()== r'e' &&
                notNullChar[currentIndex - 7].toAsciiLowerCase() == r't' && notNullChar[currentIndex - 6].toAsciiLowerCase()== r'e' &&
                notNullChar[currentIndex - 5].toAsciiLowerCase() == r' ' && notNullChar[currentIndex - 4].toAsciiLowerCase()== r'f' &&
                notNullChar[currentIndex - 3].toAsciiLowerCase() == r'r' && notNullChar[currentIndex - 2].toAsciiLowerCase() == r'o' && 
                notNullChar[currentIndex - 1].toAsciiLowerCase()== r'm' && notNullChar[currentIndex] == r' ') {
                stateBean.isInDeleteFrom = true    
                return
            }
        }
    }


    public func dealWithSqlFrom(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 4) {
            if (notNullChar[currentIndex - 4].toAsciiLowerCase() == r'f' && notNullChar[currentIndex - 3].toAsciiLowerCase() == r'r' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'o' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'm' &&
                notNullChar[currentIndex] == r' ') {
                stateBean.isInSelect = false
                stateBean.isInFrom = true
                stateBean.isHasFrom = true
                //这里一般还没where 出了子select
                //stateBean.isHasWhere = false
                dealWithInSqlFrom(stateBean)
                return
            }
        }
    }


    public func dealWithSqlSet(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 3) {
            if (notNullChar[currentIndex - 3].toAsciiLowerCase() == r's' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'e' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r't' &&
                notNullChar[currentIndex] == r' ') {
                stateBean.isInSet = true    
                dealWithInSqlSet(stateBean)
                return
            }
        }
    }

    public func dealWithSqlWhere(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 5) {
            if (notNullChar[currentIndex - 5].toAsciiLowerCase() == r'w' && notNullChar[currentIndex - 4].toAsciiLowerCase() == r'h' &&
                notNullChar[currentIndex - 3].toAsciiLowerCase() == r'e' && notNullChar[currentIndex - 2].toAsciiLowerCase()== r'r' &&
                notNullChar[currentIndex - 1].toAsciiLowerCase() == r'e'&& notNullChar[currentIndex] == r' ') {
                stateBean.isHasWhere = true    
                stateBean.isInWhere = true    
                dealWithInSqlWhere(stateBean)
                return
            }
        }
    }


    public func dealWithSqlAnd(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 3) {
            if (notNullChar[currentIndex - 3].toAsciiLowerCase() == r'a' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'n' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'd' &&
                notNullChar[currentIndex] == r' ') {
                if(stateBean.isInBetween){
                    stateBean.isInBetween = false     
                }else{
                    //其实就是判断经过了and 或者 or
                    stateBean.subSelectHasInAndOr = true
                    dealWithInAnd(stateBean)
                }    
                return
            }
        }
    }


    public func dealWithSqlOr(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 2) {
            if (notNullChar[currentIndex - 2].toAsciiLowerCase() == r'o' &&
                notNullChar[currentIndex - 1].toAsciiLowerCase() == r'r' &&
                notNullChar[currentIndex] == r' ') {
                //其实就是判断经过了and 或者 or
                stateBean.subSelectHasInAndOr = true
                dealWithInOr(stateBean)    
                return
            }
        }
    }

    public func dealWithSqlGroupBy(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 8) {
            if (notNullChar[currentIndex - 8].toAsciiLowerCase() == r'g' && notNullChar[currentIndex - 7].toAsciiLowerCase() == r'r' &&
                notNullChar[currentIndex - 6].toAsciiLowerCase() == r'o' && notNullChar[currentIndex - 5].toAsciiLowerCase()== r'u' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'p' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r' ' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'b' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'y' &&
                notNullChar[currentIndex] == r' ') {
                stateBean.isInGroupBy = true    
                dealWithInGroupBy(stateBean)
                return
            }
        }
    }


    public func dealWithSqlHaving(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 6) {
            if (notNullChar[currentIndex - 6].toAsciiLowerCase() == r'h' && notNullChar[currentIndex - 5].toAsciiLowerCase() == r'a' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'v' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r'i' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'n' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'g' &&
                notNullChar[currentIndex] == r' ') {
                if(stateBean.isInGroupBy){
                    stateBean.isInGroupBy = false
                }    
                dealWithInHaving(stateBean)
                return
            }
        }
    }


    public func dealWithSqlOrderBy(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 8) {
            if (notNullChar[currentIndex - 8].toAsciiLowerCase() == r'o' && notNullChar[currentIndex - 7].toAsciiLowerCase() == r'r' &&
                notNullChar[currentIndex - 6].toAsciiLowerCase() == r'd' && notNullChar[currentIndex - 5].toAsciiLowerCase()== r'e' &&
                notNullChar[currentIndex - 4].toAsciiLowerCase() == r'r' && notNullChar[currentIndex - 3].toAsciiLowerCase()== r' ' &&
                notNullChar[currentIndex - 2].toAsciiLowerCase() == r'b' && notNullChar[currentIndex - 1].toAsciiLowerCase()== r'y' &&
                notNullChar[currentIndex] == r' ') {
                if(stateBean.isInGroupBy){
                    stateBean.isInGroupBy = false
                }   
                stateBean.isInOrderBy = true    
                dealWithInOrderBy(stateBean)
                return
            }
        }
    }

    public func dealWithSqlLimit(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 5) {
            if (notNullChar[currentIndex - 5].toAsciiLowerCase() == r'l' && notNullChar[currentIndex - 4].toAsciiLowerCase() == r'i' &&
                notNullChar[currentIndex - 3].toAsciiLowerCase() == r'm' && notNullChar[currentIndex - 2].toAsciiLowerCase()== r'i' &&
                notNullChar[currentIndex - 1].toAsciiLowerCase() == r't'&& notNullChar[currentIndex] == r' ') {    
                if(stateBean.isInGroupBy){
                    stateBean.isInGroupBy = false
                }  
                if(stateBean.isInOrderBy){
                    stateBean.isInOrderBy = false
                }     
                dealWithInLimit(stateBean)
                return
            }
        }
    }


    public func dealWithSqlSmallBracket(stateBean: StateBean): Bool {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if(notNullChar[currentIndex] == r'('){

            //加上subselect逻辑
            if(stateBean.isInSubSelect){
                stateBean.isInSubSelectCount++    
            }

            stateBean.isSqlSmallBracket ++
            if(stateBean.isInCreateTable && stateBean.isFirstCreateTableLeft){
                //如果进入了创建表格
                stateBean.isFirstCreateTableLeft = false
                dealWithSmallLeftBracket(stateBean)
                return true
            }
        }
        if(notNullChar[currentIndex] == r')'){

             //加上subselect逻辑
            if(stateBean.isInSubSelect){
                stateBean.isInSubSelectCount--
                if(stateBean.isInSubSelectCount == 0){
                    //如果减到0 表示出了subselect
                    stateBean.isInSubSelect = false
                    //出子查询了
                    stateBean.isJustTurnSubSelectFalse = true
                }    
            }

            stateBean.isSqlSmallBracket --
            if(stateBean.isInCreateTable && stateBean.isFirstCreateTableRight && stateBean.isSqlSmallBracket == 0){
                stateBean.isFirstCreateTableRight = false
                dealWithSmallRightBracket(stateBean)
                return true
            }
        }
        return false
    }


    public func dealWithSqlBetween(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        if (currentIndex >= 7) {
            if (notNullChar[currentIndex - 7].toAsciiLowerCase() == r'b' && notNullChar[currentIndex - 6].toAsciiLowerCase() == r'e' &&
                notNullChar[currentIndex - 5].toAsciiLowerCase() == r't' && notNullChar[currentIndex - 4].toAsciiLowerCase()== r'w' &&
                notNullChar[currentIndex - 3].toAsciiLowerCase() == r'e' && notNullChar[currentIndex - 2].toAsciiLowerCase()== r'e' &&
                notNullChar[currentIndex - 1].toAsciiLowerCase() == r'n'&& notNullChar[currentIndex] == r' ') {
                stateBean.isInBetween = true
                return
            }
        }
    }


    public func dealWithInSqlSelect(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 7))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-7
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }


    public func dealWithInSqlSubSelect(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 8))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-8
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }

    //select * from 
    public func dealWithInSqlFrom(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 5))
        lineBean.codeLine = lineCode
        //多个select处理 进了子select缩进加1
        if(stateBean.isInSubSelect){
            stateBean.indentLevel ++
            if(stateBean.isHasWhere){
                //注意这个只要生效一次
                //进了子select并且进了where缩进再加1
                //没经过and和or才加1经历过 就不加这个1了
                if(!stateBean.subSelectHasInAndOr){
                    stateBean.indentLevel ++
                }
            }
         }

        lineBean.indentLevel = stateBean.indentLevel

        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                //如果是在where中再减一次
                stateBean.indentLevel--
            }
        }

        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-5
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }


    public func dealWithInSqlSet(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 4))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-4
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }


    //select * from 
    public func dealWithInSqlWhere(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 6))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        if(stateBean.isInSet){
            stateBean.isInSet = false
        }
        lineBean.indentLevel = stateBean.indentLevel
         //这块是给innerJoin使用的
         if(stateBean.isHasFrom && stateBean.isInJoin){
            stateBean.indentLevel--
            stateBean.isHasFrom = false
            stateBean.isInJoin = false
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-6
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }

    public func dealWithInOrderBy(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 9))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel

         //如果不是在子查询 这个就是0层级   
         if(stateBean.isInSubSelectCount == 0){
             stateBean.indentLevel = 0
         }

        //这块是给and or缩进用的
        if(stateBean.isHasWhere){
            stateBean.indentLevel--
            //where推出设为false
            stateBean.subSelectHasInAndOr = false
            stateBean.isHasWhere = false
        }

        //刚出子查询的缩进判断
        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                //如果是在where中再减一次
                stateBean.indentLevel--
            }
        }


        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-9
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }


    public func dealWithInGroupBy(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 9))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel

        //如果不是在子查询 这个就是0层级   
        if(stateBean.isInSubSelectCount == 0){
            stateBean.indentLevel = 0
        }
        //这块是给and or缩进用的
        if(stateBean.isHasWhere){
            stateBean.indentLevel--
            //where推出设为false
            stateBean.subSelectHasInAndOr = false
            stateBean.isHasWhere = false
        }

              //刚出子查询的缩进判断
        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                //如果是在where中再减一次
                stateBean.indentLevel--
            }
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-9
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }

    public func dealWithInHaving(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 7))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel

         //如果不是在子查询 这个就是0层级   
         if(stateBean.isInSubSelectCount == 0){
             stateBean.indentLevel = 0
         }

        //这块是给and or缩进用的
        if(stateBean.isHasWhere){
            stateBean.indentLevel--
            //where推出设为false
            stateBean.subSelectHasInAndOr = false
            stateBean.isHasWhere = false
        }

        //刚出子查询的缩进判断
        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                //如果是在where中再减一次
                stateBean.indentLevel--
            }
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-7
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }


    public func dealWithInLimit(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 6))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel

        //如果不是在子查询 这个就是0层级   
        if(stateBean.isInSubSelectCount == 0){
            stateBean.indentLevel = 0
        }
        //这块是给and or缩进用的
        if(stateBean.isHasWhere){
            stateBean.indentLevel--
            //where推出设为false
            stateBean.subSelectHasInAndOr = false
            stateBean.isHasWhere = false
        }

              //刚出子查询的缩进判断
        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                //如果是在where中再减一次
                stateBean.indentLevel--
            }
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-6
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }

    public func dealWithInAnd(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 4))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        //这块是给and or缩进用的
        if(stateBean.isInWhere){
            stateBean.indentLevel++
            stateBean.isInWhere = false
        }

        //刚出子查询的缩进判断
        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                //如果是在where中再减一次
                stateBean.indentLevel--
            }
        }
         
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-4
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }


    public func dealWithInOr(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 3))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        //这块是给and or缩进用的
        if(stateBean.isInWhere){
            stateBean.indentLevel++
            stateBean.isInWhere = false
        }

        //刚出子查询的缩进判断
        if(stateBean.isJustTurnSubSelectFalse){
            stateBean.isJustTurnSubSelectFalse = false
            stateBean.indentLevel--
            if(stateBean.isHasWhere && stateBean.indentLevel>0){
                //如果是在where中再减一次
                stateBean.indentLevel--
            }
        }

        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-3
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }


    public func dealWithInSqlValues(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 7))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-7
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }

    
    public func dealWithInSqlAddColumn(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 11))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        if(stateBean.isInAlertTable){
            stateBean.indentLevel++ 
            stateBean.isInAlertTable = false
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-11
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }

        public func dealWithInSqlModifyColumn(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 14))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        if(stateBean.isInAlertTable){
            stateBean.indentLevel++ 
            stateBean.isInAlertTable = false
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-14
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }


    public func dealWithInSqlDropColumn(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 12))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        if(stateBean.isInAlertTable){
            stateBean.indentLevel++ 
            stateBean.isInAlertTable = false
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-12
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }



     public func dealWithInSqlJoin(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 5))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        //这块是给innerJoin使用的
        if(stateBean.isInFrom){
            stateBean.isInFrom = false
            stateBean.indentLevel++
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-5
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }


    public func dealWithInSqlCrossJoin(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 11))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        //这块是给innerJoin使用的
        if(stateBean.isInFrom){
            stateBean.isInFrom = false
            stateBean.indentLevel++
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-11
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }


    public func dealWithInSqlInnerJoin(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 11))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        //这块是给innerJoin使用的
        if(stateBean.isInFrom){
            stateBean.isInFrom = false
            stateBean.indentLevel++
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-11
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }

       public func dealWithInSqlLeftJoin(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 10))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        //这块是给innerJoin使用的
        if(stateBean.isInFrom){
            stateBean.isInFrom = false
            stateBean.indentLevel++
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-10
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }

       public func dealWithInSqlRightJoin(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 11))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        //这块是给innerJoin使用的
        if(stateBean.isInFrom){
            stateBean.isInFrom = false
            stateBean.indentLevel++
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-11
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }

       public func dealWithInSqlFullOuterJoin(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1 - 16))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        //这块是给innerJoin使用的
        if(stateBean.isInFrom){
            stateBean.isInFrom = false
            stateBean.indentLevel++
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = false
        stateBean.perLineStartIndex = stateBean.currentIndex +1-16
        stateBean.lastChar = r' '
        stateBean.currentIndex ++
    }

    public  func dealWithSqlComma(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        if(stateBean.isInValues){
            stateBean.indentLevel++
            stateBean.isInValues = false
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r','
        stateBean.currentIndex++
    }


    public func dealWithSmallLeftBracket(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex + 1))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        if(stateBean.isHasCreateTableLeft){
            stateBean.indentLevel++
            stateBean.isHasCreateTableLeft = false
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r'('
        stateBean.currentIndex++
    }


    public func dealWithSmallRightBracket(stateBean: StateBean): Unit {
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.perLineStartIndex
        let lineEndIndex: Int64 = stateBean.currentIndex
        let lineCode: String = String(
            stateBean.codeChars.getOrThrow().slice(lineStartIndex, lineEndIndex - lineStartIndex+1))
        lineBean.codeLine = lineCode
        //记录上一行结束的index
        lineBean.indentLevel = stateBean.indentLevel
        if(stateBean.isHasCreateTableRight){
            stateBean.indentLevel--
            stateBean.isHasCreateTableRight = false
        }
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        stateBean.linesList.add(lineBean) //这里保存了一个lineBean了
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = r')'
        stateBean.currentIndex++
    }





    // 核心格式化函数（整合缩进+换行规则）
    func formatCode(rawCode: String, cfg: FormatConfig): String {
        //每一次的状态变量
        var realRawCode = rawCode.replace("\r\n","").replace("\n","").trimAscii()
        if(!realRawCode.endsWith(";")){
            realRawCode = realRawCode+";"
        }
        let stateBean: StateBean = StateBean()
        //先把代码分割成诺干行
        stateBean.linesList = ArrayList<LineBean>()
        stateBean.codeChars = realRawCode.toRuneArray()
        if (let Some(i) <- stateBean.codeChars) {
            let len = i.size
            if (len == 0) {
                return ""
            }
            while (stateBean.currentIndex < len) {
                let currChar = i[stateBean.currentIndex]
                //没解析完成的话保留在perLineOutput里
                stateBean.perLineOutput.append(currChar)
                //处理单行注释
                if (currChar == r'-' && stateBean.lastChar == r'-' && !stateBean.isInString) {
                    //这里先判断这种情况 前面没结束符号 不处理的话前面的内容会消失
                    //template <typename T, int DEFAULT_SIZE = 10> // 带默认模板参数    
                    var str = stateBean.perLineOutput.toString().removeSuffix("--")
                    if (str.trimAscii().size > 0) {
                        dealWithSingleLineComment(stateBean, str)
                    } else {
                        dealWithSingleLineComment(stateBean, "")
                    }
                    continue
                }
                //处理多行注释
                if (currChar == r'*' && stateBean.lastChar == r'/' && !stateBean.isInString) {
                    //这里先判断这种情况 前面没结束符号 不处理的话前面的内容会消失
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
                    dealWithSqlCreateTable(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlAlertTable(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlAddColumn(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlModifyColumn(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlDropColumn(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlSubSelect(stateBean)
                }

                if (!stateBean.isInString) {
                    if(!stateBean.isInSubSelect){
                        dealWithSqlSelect(stateBean)
                    }
                }

                if (!stateBean.isInString) {
                    dealWithSqlDeleteFrom(stateBean)
                }

                if (!stateBean.isInString) {
                    if(stateBean.isInDeleteFrom){
                        stateBean.isInDeleteFrom = false
                    }else{
                        dealWithSqlFrom(stateBean)
                    }
                }

                if (!stateBean.isInString) {
                    dealWithSqlValues(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlSet(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlWhere(stateBean)
                }
              
                if (!stateBean.isInString) {
                    dealWithSqlAnd(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlOr(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlBetween(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlGroupBy(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlHaving(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlOrderBy(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlLimit(stateBean)
                }

                if (!stateBean.isInString) {
                   let res = dealWithSqlSmallBracket(stateBean)
                   if(res){
                     continue
                   }
                }

                if (!stateBean.isInString) {
                    dealWithSqlInnerJoin(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlCrossJoin(stateBean)
                }

                if (!stateBean.isInString) {
                    dealWithSqlLeftJoin(stateBean)
                }

                 if (!stateBean.isInString) {
                    dealWithSqlRightJoin(stateBean)
                }

                 if (!stateBean.isInString) {
                    dealWithSqlFullOuterJoin(stateBean)
                }

                if (!stateBean.isInString) {
                    if(stateBean.isInMultiJoin){
                        stateBean.isInMultiJoin = false
                    }else{
                        dealWithSqlJoin(stateBean)
                    }
                }
           
                //cerateTable和增删改查的，区分开来    
                if (currChar == r',' && ((!stateBean.isInGroupBy && !stateBean.isInOrderBy  &&!stateBean.isInSet && !stateBean.isInSelect && stateBean.isSqlSmallBracket == 0) || stateBean.isInCreateTable)   && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    //处理分号逻辑
                    dealWithSqlComma(stateBean)
                    continue
                }
              

                if (currChar == r';' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    //处理分号逻辑
                    dealWithSemicolon(stateBean)
                    //这里要重置很多参数比如
                    stateBean.indentLevel = 0
                    //
                    stateBean.isInBetween = false
                    stateBean.isInWhere  = false  //给and or缩进用
                    stateBean.isHasWhere  = false //给and or缩进用
                    stateBean.isInValues  = false
                    stateBean.isSqlSmallBracket  = 0
                    stateBean.isInSet  = false
                    stateBean.isInSelect  = false
                    stateBean.isInDeleteFrom = false //delete from和from区分
                    stateBean.isInMultiJoin = false //multijoin和普通join区分
                    stateBean.isInFrom  = false  //给innerjoin缩进用
                    stateBean.isHasFrom  = false //给innerjoin缩进用
                    stateBean.isInJoin  = false //给innerjoin缩进用
                    stateBean.isInGroupBy  = false //给groupby后的,不要换行
                    stateBean.isInOrderBy = false //给orderBy后面的,不要换行
                    stateBean.isInCreateTable = false //给createTable后面的,不要换行
                    stateBean.isHasCreateTableLeft = false //给createTable后面的,不要换行
                    stateBean.isHasCreateTableRight = false //给createTable后面的,不要换行
                    stateBean.isFirstCreateTableLeft = true //给createTable后面的,不要换行
                    stateBean.isFirstCreateTableRight = true //给createTable后面的,不要换行
                    stateBean.isInAlertTable = true //给alertTable后面的缩进用
                    stateBean.isInSubSelect = false //给alertTable后面的缩进用
                    stateBean.isInSubSelectCount = 0 //给alertTable后面的缩进用 这个记录左括号个数
                    stateBean.isJustTurnSubSelectFalse = false //是不是刚刚走出subselect
                    stateBean.subSelectHasInAndOr=false // subselect

                    continue
                }
                if (currChar == r'\n' && !stateBean.isInString) {
                    //进入这里没有进入上面也要加到一行，不然会失去数据
                    dealWithNewLine(stateBean)
                    stateBean.isLineStart = true
                } else {
                    //如果LineStart为true,但是接下来是一些空格开头，那么不应该更改状态
                    if (stateBean.isLineStart && (currChar == r' ' || currChar == r'\t')) {
                        //这种情况依然是isLineStart = true
                        stateBean.isLineStart = true
                    } else {
                        stateBean.isLineStart = false
                    }
                }
                stateBean.lastChar = currChar
                stateBean.currentIndex++
            }
            //在这里处理stateBean.perLineOutput还有剩余数据的问题
            dealWithNewLine(stateBean)

            //这里走完的话就收集到了
            //这里lineList开始处理了
            //处理单行注释合并问题
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.isInSinglelineComment) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i > 0) {
                        //有上一行，看上一行的结束是不是\n
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (!lineBean.singlelineCommentisAfterChangeLine) {
                            //如果这样的话，这一行的内容要加到上一行的后面
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
            //处理多行注释合并问题
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.isInMultilineComment && lineBean.isFirstMultiCommentLine) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i > 0) {
                        //有上一行，看上一行的结束是不是\n
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (!lineBean.multilineCommentisAfterChangeLine) {
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            //多行前面有内容 只要隔个一个空格
                            stringbuilder.append(" ")
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }

            //如果只有一个换行就过滤
            removeOnlyChangeLine(stateBean)

            //获得最终的list
            let usefulList: ArrayList<LineBean> = stateBean.linesList
            for (item in usefulList) {
                item.codeLine = item.codeLine.trimAscii()
            }
            //修改#开始的宏和后面空格不一致问题
            modifyMacroAndSpace(stateBean)

            //最后根据缩进拼接
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

