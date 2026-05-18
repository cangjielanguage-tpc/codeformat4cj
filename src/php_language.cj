package codeformat

class PhpFormat <: GeneralProcessing {
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
            //这里要检测for之后除了空格第一个字符如果不是(那就没有进for
            let currChar: Rune = notNullChar[currentIndex]

            if (currChar == r'{' || currChar == r'}') { //主要是用于for循环中的()成对
                stateBean.isInFor = false
            }
        }
    }

    // 核心格式化函数（整合缩进+换行规则）
    func formatCode(rawCode: String, cfg: FormatConfig): String {
        //每一次的状态变量
        let stateBean: StateBean = StateBean()
        //先把代码分割成诺干行
        stateBean.linesList = ArrayList<LineBean>()
        stateBean.codeChars = rawCode.toRuneArray()
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
                if (currChar == r'/' && stateBean.lastChar == r'/' && !stateBean.isInString) {
                    //这里先判断这种情况 前面没结束符号 不处理的话前面的内容会消失
                    //template <typename T, int DEFAULT_SIZE = 10> // 带默认模板参数    
                    var str = stateBean.perLineOutput.toString().removeSuffix("//")
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

                if (currChar == r'{' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    //处理左大括号逻辑
                    dealWithLeftBigBracket(stateBean)
                    continue
                }
                if (currChar == r'}' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    //处理右大括号逻辑
                    dealWithRightBigBracket(stateBean)
                    continue
                }
                if (currChar == r';' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    //处理分号逻辑
                    dealWithSemicolon(stateBean)
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

            //这里处理如果}前面还有内容就和上一行连在一起解决数组中的{}问题
            //在go语言中这种情况要改下

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
            //去除一次废弃内容
            //这里修改}后面如果是；就连在一起
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (!lineBean.isSingleLine) {
                    if ((lineBean.codeLine.trimAscii() == ";" || lineBean.codeLine.trimAscii() == ")" ||
                        lineBean.codeLine.trimAscii() == "()") && !lineBean.isInMultilineComment &&
                        !lineBean.isInSinglelineComment) {
                        //如果当前行是单行注释，那就看他有没有上一行
                        if (i > 0) {
                            //有上一行，看上一行的结束是不是\n
                            let lastLineBean: LineBean = stateBean.linesList[i - 1]
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            //过滤单行废弃
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (((codeStr.startsWith("else{")) || (codeStr.startsWith("elseif(")) || (codeStr.startsWith("catch("))) &&
                    !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i > 0) {
                        //有上一行，看上一行的结束是不是\n
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii() == "}") {
                            //上一行只有}那么合并这两行
                            //如果这样的话，这一行的内容要加到上一行的后面
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
                if (codeStr.startsWith(".") && codeStr.endsWith("{") && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i > 0) {
                        //有上一行，看上一行是不是}
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii() == "}") {
                            //上一行是}结尾那么合并这两行
                            //如果这样的话，这一行的内容要加到上一行的后面
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

            //处理单行只有);但是上一行是}结尾的情况
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith(");") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    //如果当前行是单行注释，那就看他有没有上一行
                    if (i > 0) {
                        //有上一行，看上一行的结束是不是\n
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith("}")) {
                            //上一行以}结尾那么合并这两行
                            //如果这样的话，这一行的内容要加到上一行的后面
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



                //巧妙处理二维数组

                var inInDoubleArray = false

                for (i in 0..stateBean.linesList.size) {
                    let line = stateBean.linesList[i]
                    let t = line.codeLine.trimAscii().replace(" ","")

                    // 1. 进入 switch {
                    if (t.endsWith("=[") || t.contains("=[//") || t.contains("=[/*")) {
                        inInDoubleArray = true
                        continue
                    }

                    // 2. 离开 switch }
                    if ((t == "];" || t.startsWith("];//") || t.startsWith("];/*")) && inInDoubleArray) {
                        inInDoubleArray = false
                    }

                    // 3. 只在 switch 内部生效
                    if (inInDoubleArray) {
                        line.indentLevel = line.indentLevel+1
                    }
                }



              //巧妙处理swicth的缩进

                var inSwitchBlock = false
                var needIndent = false

                for (i in 0..stateBean.linesList.size) {
                    let line = stateBean.linesList[i]
                    let t = line.codeLine.trimAscii()

                    // 1. 进入 switch {
                    if (t.startsWith("switch ") && t.contains("{")) {
                        inSwitchBlock = true
                        needIndent = false
                    }

                    // 2. 离开 switch }
                    if (t == "}" && inSwitchBlock) {
                        inSwitchBlock = false
                        needIndent = false
                    }

                    // 3. 只在 switch 内部生效
                    if (inSwitchBlock) {
                        if (t.startsWith("case ") || t.startsWith("default")) {
                            // case / default → 缩进 1 级
                            //line.indentLevel = line.indentLevel+1
                            needIndent = true
                        } else if (needIndent) {
                            // case 下面一行 → 再缩进 1 级（总共 2 级）
                            line.indentLevel = line.indentLevel+1
                        }
                    }
                }


            //处理单行只有);但是上一行是}结尾的情况
            var index = 0 
            var isIn = false
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr.startsWith("<?php") && (codeStr != "<?php") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    index = i
                    isIn = true
                    let newStr = lineBean.codeLine.replace("<?php ","")
                    let stringbuilder: StringBuilder = StringBuilder()
                    stringbuilder.append(newStr)
                    lineBean.codeLine = stringbuilder.toString()
                }
            }

            if(isIn){
                let lineBeanAdd: LineBean = LineBean()
                lineBeanAdd.codeLine = "<?php "
                stateBean.linesList.add(lineBeanAdd, at:index)
            }
            



            //获得最终的list
            let usefulList: ArrayList<LineBean> = stateBean.linesList
            for (item in usefulList) {
                item.codeLine = item.codeLine.trimAscii()
            }

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
