package codeformat

class DartFormat <: GeneralProcessing {
    public override func dealWithMacro(stateBean: StateBean): Unit {
        // 标记进入注解状态
        stateBean.isInMacro = true
        let lineBean: LineBean = LineBean()
        let lineStartIndex: Int64 = stateBean.currentIndex
        var currChar: Rune = stateBean.codeChars.getOrThrow()[stateBean.currentIndex] // @

        // 向后扫描直到行尾
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
        // 注解保持当前缩进
        lineBean.indentLevel = stateBean.indentLevel
        // 保存各种状态
        lineBean.smallBracketDouble = stateBean.smallBracketDouble
        lineBean.middleBracketDouble = stateBean.middleBracketDouble
        lineBean.sharpBracketDouble = stateBean.sharpBracketDouble
        lineBean.isInString = stateBean.isInString
        lineBean.isInMacro = stateBean.isInMacro
        lineBean.isInFor = stateBean.isInFor
        // 保存此行到列表
        stateBean.linesList.add(lineBean)
        // 重置状态，准备下一行
        stateBean.perLineOutput = StringBuilder()
        stateBean.isLineStart = true
        stateBean.perLineStartIndex = stateBean.currentIndex + 1
        stateBean.lastChar = currChar
        // 退出注解状态
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
        // 检测字符串开始（遇到引号且不在字符串内）
        if ((currChar == r'"' || currChar == r'\'') && !stateBean.isInString) {
            // 检查是否是三引号（多行字符串）
            if (currentIndex + 2 < notNullChar.size && 
                currChar == notNullChar[currentIndex + 1] && 
                currChar == notNullChar[currentIndex + 2]) {
                // 三引号字符串
                stateBean.stringQuote = currChar
                stateBean.isInString = true
                stateBean.isTripleQuote = true
                stateBean.tripleQuoteCount = 0
                return
            } else {
                // 单引号或双引号字符串
                stateBean.stringQuote = currChar
                stateBean.isInString = true
                stateBean.isTripleQuote = false
                return
            }
        }
        // 检测字符串结束（遇到匹配的引号且前面不是转义符）
        if (stateBean.isInString) {
            if (stateBean.isTripleQuote) {
                // 处理三引号字符串的结束
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
                // 处理单引号或双引号字符串的结束
                if (currChar == stateBean.stringQuote && lastChar != r'\\') {
                    stateBean.isInString = false
                    stateBean.stringQuote = r' '
                }
            }
            return
        }
    }

    func formatCode(rawCode: String, cfg: FormatConfig): String {
        // 每一次的状态变量
        let stateBean: StateBean = StateBean()
        // 初始化逻辑行列表
        stateBean.linesList = ArrayList<LineBean>()
        // 将原始代码转换为Rune数组（支持Unicode字符）
        stateBean.codeChars = rawCode.toRuneArray()

        // 确保代码数组不为空
        if (let Some(i) <- stateBean.codeChars) {
            let len = i.size
            if (len == 0) {
                return ""
            }

            // ========== 第一阶段：解析阶段 ==========
            // 逐字符扫描原始代码，解析为逻辑行
            while (stateBean.currentIndex < len) {
                let currChar = i[stateBean.currentIndex]
                // 将当前字符追加到行缓冲区
                stateBean.perLineOutput.append(currChar)

                // 处理行起始位置的访问修饰符（Dart不使用，保留以兼容）
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

                // 处理单行注释（//）
                if (currChar == r'/' && stateBean.lastChar == r'/' && !stateBean.isInString) {
                    // 先判断前面是否有未结束的内容
                    var str = stateBean.perLineOutput.toString().removeSuffix("//")
                    if (str.trimAscii().size > 0) {
                        dealWithSingleLineComment(stateBean, str)
                    } else {
                        dealWithSingleLineComment(stateBean, "")
                    }
                    continue
                }

                // 处理多行注释（/* */）
                if (currChar == r'*' && stateBean.lastChar == r'/' && !stateBean.isInString) {
                    // 先判断前面是否有未结束的内容
                    var str = stateBean.perLineOutput.toString().removeSuffix("/*")
                    if (str.trimAscii().size > 0) {
                        dealWithMultiLineComment(stateBean, str)
                    } else {
                        dealWithMultiLineComment(stateBean, "")
                    }
                    continue
                }

                // 处理字符串（保护字符串内容不被错误解析）
                dealWithString(stateBean)

                // 如果不在字符串内，处理for循环
                if (!stateBean.isInString) {
                    dealWithFor(stateBean)
                }

                // 处理注解（@）
                if (currChar == r'@' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor &&
                    !stateBean.isInBackQuote) {
                    dealWithMacro(stateBean)
                    continue
                }

                // 处理左大括号（代码块开始）
                if (currChar == r'{' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor &&
                    !stateBean.isInBackQuote) {
                    dealWithLeftBigBracket(stateBean)
                    continue
                }

                // 处理右大括号（代码块结束）
                if (currChar == r'}' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor &&
                    !stateBean.isInBackQuote) {
                    dealWithRightBigBracket(stateBean)
                    continue
                }

                // 处理分号（语句结束）
                if (currChar == r';' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    dealWithSemicolon(stateBean)
                    continue
                }

                // 处理换行符
                if (currChar == r'\n' && !stateBean.isInString) {
                    dealWithNewLine(stateBean)
                    stateBean.isLineStart = true
                } else {
                    // 如果是行起始位置且当前字符是空格或制表符，保持行起始状态
                    if (stateBean.isLineStart && (currChar == r' ' || currChar == r'\t')) {
                        stateBean.isLineStart = true
                    } else {
                        stateBean.isLineStart = false
                    }
                }

                stateBean.lastChar = currChar
                stateBean.currentIndex++
            }

            // 处理行缓冲区中剩余的数据
            dealWithNewLine(stateBean)

            // ========== 第二阶段：后处理阶段 ==========
            // 对解析后的逻辑行列表进行多轮合并和调整

            // 处理单行注释合并问题
            // 如果单行注释不是独立成行（前面有代码），则合并到上一行
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (!lineBean.singlelineCommentisAfterChangeLine) {
                            // 将注释追加到上一行，保留原有的空格
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lastLineBean.codeLine)
                            for (j in 0..lineBean.singleLineWhiteSpace) {
                                stringbuilder.append(" ")
                            }
                            stringbuilder.append(lineBean.codeLine)
                            lastLineBean.codeLine = stringbuilder.toString()
                            // 标记此行为废弃
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }

            // 处理多行注释合并问题
            // 如果多行注释的第一行不是独立成行，则合并到上一行
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.isInMultilineComment && lineBean.isFirstMultiCommentLine) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (!lineBean.multilineCommentisAfterChangeLine) {
                            // 将注释追加到上一行，只加一个空格
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

            // 过滤掉只有换行的空行
            removeOnlyChangeLine(stateBean)

            // 处理Map字面量中的{}问题
            // 如果}前面还有内容（不是独立成行），则连接到上一行
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.codeLine.trimAscii().endsWith("}") && lineBean.codeLine.trimAscii().size > 1 &&
                    !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        // 要求上一行不是废弃的
                        if (!lastLineBean.isDiscarded) {
                            // 如果上一行不是以;结束，则合并
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

            // 去除一次废弃的内容
            removediscard(stateBean)

            // 处理}后面如果是;就连在一起（如箭头函数）
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.codeLine.trimAscii() == ";" && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        // 将;连接到上一行
                        let stringbuilder: StringBuilder = StringBuilder()
                        stringbuilder.append(lastLineBean.codeLine.replace("\n", ""))
                        stringbuilder.append(lineBean.codeLine)
                        lastLineBean.codeLine = stringbuilder.toString()
                        lineBean.isDiscarded = true
                    }
                }
            }

            // 过滤掉废弃的内容
            removediscard(stateBean)

            // 处理else/finally/catch等关键字与}的合并
            // 例如: }\ncatch(Exception ex) { 应该合并为 } catch(Exception ex) {
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
                            // 上一行只有}，那么合并这两行
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

            // 处理数组/Map索引结束的];或]与上一行以逗号结束的情况
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if ((codeStr.endsWith("];") || codeStr.endsWith("]")) && stateBean.linesList[i - 1].codeLine.contains("[") && !codeStr.contains("[") &&
                    !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith(",")) {
                            // 上一行以逗号结束，合并这两行
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
            
            // 处理for和foreach代码块只包含一行代码的场景
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

            // 处理单行只有);但是上一行是}结尾的情况（如匿名函数或闭包）
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith(");") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith("}")) {
                            // 上一行以}结尾，合并这两行
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

            // 处理if()后面没有{的情况，将下一行合并到当前行
            // 例如: if (condition)\n  DoSomething(); 应该合并为一行
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (codeStr.startsWith("if(") && (codeStr.endsWith(")")) && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        // 将下一行合并到当前行
                        let stringbuilder: StringBuilder = StringBuilder()
                        stringbuilder.append(lineBean.codeLine + " ")
                        stringbuilder.append(nextLineBean.codeLine.trimAscii())
                        lineBean.codeLine = stringbuilder.toString().replace("\n", "")
                        nextLineBean.isDiscarded = true
                    }
                }
            }
            removediscard(stateBean)

            // 处理字符串中的${,}导致的多余回车场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (i > 0 && codeStr.endsWith("}") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith("\${")) {
                            // 将下两行合并到当前行
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
           
            // 处理入参中}\n)场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if (i > 0 && codeStr.startsWith(")") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.trimAscii().endsWith("}")) {
                            // 将当前行合并到前一行
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

            // ========== 第三阶段：生成阶段 ==========
            // 获取最终有效的行列表（过滤掉废弃的行）
            let usefulList: ArrayList<LineBean> = stateBean.linesList
            // 去除每行两端的空格
            for (item in usefulList) {
                item.codeLine = item.codeLine.trimAscii()
            }

            // 修改注解后面的空格不一致问题
            modifyMacroAndSpace(stateBean)

            // 最后根据缩进拼接所有行
            for (index in 0..usefulList.size) {
                let item: LineBean = usefulList[index]
                // 根据缩进级别添加相应的空格
                addIndent(stateBean.output, item.indentLevel, cfg)
                stateBean.output.append(item.codeLine)
                // 最后一行不需要添加换行符
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
