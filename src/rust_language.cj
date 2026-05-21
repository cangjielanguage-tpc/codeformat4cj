package codeformat

class RustFormat <: GeneralProcessing {
    public override func dealWithString(stateBean: StateBean): Unit {
        let notNullChar: Array<Rune> = stateBean.codeChars.getOrThrow()
        let currentIndex: Int64 = stateBean.currentIndex
        let currChar: Rune = notNullChar[currentIndex]
        var lastChar: Rune = r' '
        if (currentIndex - 1 >= 0) {
            lastChar = notNullChar[currentIndex - 1]
        }
        
        // 检测字符串开始（双引号）
        if (currChar == r'"' && !stateBean.isInString) {
            stateBean.stringQuote = currChar
            stateBean.isInString = true
            return
        }
        // 检测字符串结束（处理转义字符）
        if (stateBean.isInString && currChar == stateBean.stringQuote && handleTransferCharacters(notNullChar, currentIndex - 1)) {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
        // 处理换行符强制结束字符串（防止未闭合的字符串）
        if (stateBean.isInString && currChar == r'\n') {
            stateBean.isInString = false
            stateBean.stringQuote = r' '
            return
        }
    }

    /**
     * 核心格式化函数
     * 将原始 Rust 代码解析为行列表，应用格式化规则后重新拼接
     * 
     * 处理流程：
     * 1. 词法分析：逐字符遍历，识别各种语法元素
     * 2. 行分割：将代码分割为多个 LineBean
     * 3. 后处理：合并注释、处理特殊语法、添加空格
     * 4. 输出生成：根据缩进级别拼接最终代码
     * 
     * @param rawCode 原始 Rust 代码
     * @param cfg 格式化配置
     * @return 格式化后的代码
     */
    func formatCode(rawCode: String, cfg: FormatConfig): String {
        let stateBean: StateBean = StateBean()
        stateBean.linesList = ArrayList<LineBean>()
        stateBean.codeChars = rawCode.toRuneArray()
        
        if (let Some(i) <- stateBean.codeChars) {
            let len = i.size
            if (len == 0) {
                return ""
            }
            
            // ========== 第一阶段：词法分析 ==========
            while (stateBean.currentIndex < len) {
                let currChar = i[stateBean.currentIndex]
                stateBean.perLineOutput.append(currChar)
                
                // 处理单行注释 //
                if (currChar == r'/' && stateBean.lastChar == r'/' && !stateBean.isInString) {
                    var str = stateBean.perLineOutput.toString().removeSuffix("//")
                    if (str.trimAscii().size > 0) {
                        dealWithSingleLineComment(stateBean, str)
                    } else {
                        dealWithSingleLineComment(stateBean, "")
                    }
                    continue
                }
                
                // 处理多行注释 /* */
                if (currChar == r'*' && stateBean.lastChar == r'/' && !stateBean.isInString) {
                    var str = stateBean.perLineOutput.toString().removeSuffix("/*")
                    if (str.trimAscii().size > 0) {
                        dealWithMultiLineComment(stateBean, str)
                    } else {
                        dealWithMultiLineComment(stateBean, "")
                    }
                    continue
                }
                
                // 处理字符串状态
                dealWithString(stateBean)
                if (!stateBean.isInString) {
                    dealWithFor(stateBean)
                }

                // 处理 Rust 属性宏 #[...]
                if (currChar == r'#' && !stateBean.isInString && !stateBean.isInMacro) {
                    dealWithMacro(stateBean)
                    continue
                }

                // 处理左大括号 {
                if (currChar == r'{' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    dealWithLeftBigBracket(stateBean)
                    continue
                }
                
                // 处理右大括号 }
                if (currChar == r'}' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    dealWithRightBigBracket(stateBean)
                    continue
                }
                
                // 处理分号 ;
                if (currChar == r';' && !stateBean.isInMacro && !stateBean.isInString && !stateBean.isInFor) {
                    dealWithSemicolon(stateBean)
                    continue
                }
                
                // 处理换行符
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
            
            // 处理剩余的行输出缓冲区
            dealWithNewLine(stateBean)

            // ========== 第二阶段：后处理 ==========
            
            // 2.1 合并单行注释到前一行
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
            
            // 2.2 合并多行注释到前一行
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

            // 2.3 过滤纯换行
            removeOnlyChangeLine(stateBean)
            // 2.4.2 合并use 导包中'{'导致的换行
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (lineBean.codeLine.contains("}") && !lineBean.codeLine.contains("{") && !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (!lastLineBean.codeLine.trimAscii().startsWith("use ")) {
                            continue
                        }
                        let stringbuilder: StringBuilder = StringBuilder()
                        stringbuilder.append(lastLineBean.codeLine.replace("\n", ""))
                        stringbuilder.append(lineBean.codeLine)
                        lastLineBean.codeLine = stringbuilder.toString()
                        lineBean.isDiscarded = true
                    }
                }
            }
            
            removediscard(stateBean)
            // 2.4.1 合并 }; 到前一行
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

            // 2.5 合并 while/else if 到 } 后
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if ((((codeStr.startsWith("while(")) && (!codeStr.contains("{"))) || 
                     (codeStr.startsWith("else{")) || 
                     (codeStr.startsWith("else if("))) && 
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
            // 2.6 合并 ); 、)到 } 后
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii().replace(" ", "")
                if ((codeStr.startsWith(");") || codeStr == ")") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
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
            // 2.7 处理**}场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.endsWith("}") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i > 0) {
                        let lastLineBean: LineBean = stateBean.linesList[i - 1]
                        if (lastLineBean.codeLine.contains("{") && lastLineBean.codeLine.contains("->") && lastLineBean.codeLine.contains("fn ")) {
                            //如果这样的话，这一行的内容要加到上一行的后面
                                let stringbuilder: StringBuilder = StringBuilder()
                                stringbuilder.append(lastLineBean.codeLine)
                                //多行前面有内容 只要隔个一个空格
                                stringbuilder.append(lineBean.codeLine.trimAscii())
                                // 代码后面直接书写'}'缺失一个'\n'的场景，补充一个换行符 '}' -> '\n}' 
                                lastLineBean.codeLine = stringbuilder.toString()
                                lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            // 2.7 处理数组场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.endsWith(";") && 
                codeStr.replace(" ", "").contains(":[") &&
                !lineBean.isInMultilineComment && 
                !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        var x = 1
                        var nextLineBean: LineBean = stateBean.linesList[i + x]
                        while (nextLineBean.codeLine.contains("]") && (!nextLineBean.codeLine.contains("[") || nextLineBean.codeLine.indexOf(']').getOrThrow() < nextLineBean.codeLine.indexOf('[').getOrThrow())) {
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(nextLineBean.codeLine)
                            //多行前面有内容 只要隔个一个空格
                            // 代码后面直接书写'}'缺失一个'\n'的场景，补充一个换行符 '}' -> '\n}' 
                            lineBean.codeLine = stringbuilder.toString()
                            nextLineBean.isDiscarded = true
                            x++
                            nextLineBean = stateBean.linesList[i + x]
                        }
                        if (lineBean.codeLine.trimAscii().replace(" ", "").endsWith("=[")) {
                            var leftBrace = 0
                            while (!((leftBrace + nextLineBean.codeLine.count("[") - nextLineBean.codeLine.count("]") == -1) &&
                            (nextLineBean.codeLine.trimAscii() == "]" || nextLineBean.codeLine.trimAscii() == "];"))) {
                                leftBrace = leftBrace + nextLineBean.codeLine.count("[") - nextLineBean.codeLine.count("]")
                                nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                                x++
                                nextLineBean = stateBean.linesList[i + x]
                            }
                        }
                    }
                }
            }
            removediscard(stateBean)

            // 2.7 处理where场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr == "where" && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    // if (i > 0) {
                    var x = 1
                    var nextLineBean = stateBean.linesList[i + x]
                    while (!(nextLineBean.codeLine.trimAscii() == "{")) {
                        nextLineBean.indentLevel++
                        x++
                        nextLineBean = stateBean.linesList[i + x]
                    }
                    nextLineBean.indentLevel = lineBean.indentLevel
                    var leftBrace = 0
                    x++
                    nextLineBean = stateBean.linesList[i + x]
                    while (!(leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1) && 
                    nextLineBean.codeLine.trimAscii().endsWith("}") &&
                    nextLineBean.codeLine.trimAscii() != "}") {
                        leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                        nextLineBean.indentLevel++
                        x++
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
                    stateBean.linesList.add(newlineBean, at:i + x + 1)
                }
            }
            removediscard(stateBean)

            // 2.7 处理**}场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.endsWith("}") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        if (nextLineBean.codeLine.trimAscii().startsWith("=") || nextLineBean.codeLine.trimAscii().startsWith("=>")) {
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            //多行前面有内容 只要隔个一个空格
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(nextLineBean.codeLine)
                            // 代码后面直接书写'}'缺失一个'\n'的场景，补充一个换行符 '}' -> '\n}' 
                            nextLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            // 2.8 处理}\n;场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.trimAscii().endsWith("}") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        if (nextLineBean.codeLine.trimAscii().startsWith(";")) {
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            //多行前面有内容 只要隔个一个空格
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(nextLineBean.codeLine)
                            // 代码后面直接书写'}'缺失一个'\n'的场景，补充一个换行符 '}' -> '\n}' 
                            nextLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)
            
            // 2.9 处理{**\n};场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.trimAscii().endsWith("{") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        if (nextLineBean.codeLine.trimAscii().endsWith("};")) {
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            //多行前面有内容 只要隔个一个空格
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(nextLineBean.codeLine)
                            // 代码后面直接书写'}'缺失一个'\n'的场景，补充一个换行符 '}' -> '\n}' 
                            nextLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            // 2.10 处理|\n{**\n**};场景
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.trimAscii().endsWith("|") && codeStr.trimAscii().contains("=") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        var nextLineBean: LineBean = stateBean.linesList[i + 1]
                        var x = 1
                        if (nextLineBean.codeLine.trimAscii() == "{") {
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            //多行前面有内容 只要隔个一个空格
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(" ")
                            stringbuilder.append(nextLineBean.codeLine)
                            // 代码后面直接书写'}'缺失一个'\n'的场景，补充一个换行符 '}' -> '\n}' 
                            lineBean.codeLine = stringbuilder.toString()
                            nextLineBean.isDiscarded = true
                            x++
                        }
                        var leftBrace = 0
                        nextLineBean = stateBean.linesList[i + x]
                        while (!(nextLineBean.codeLine.trimAscii().contains("}") &&
                        (nextLineBean.codeLine.trimAscii() == "}" || handleTransferCharacters(nextLineBean.codeLine.toRuneArray(), nextLineBean.codeLine.indexOf("}").getOrThrow() - 1)) &&
                        leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1)) {
                            leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                            x++
                            nextLineBean = stateBean.linesList[i + x]
                        }
                        if (nextLineBean.codeLine.trimAscii().replace(" ", "").startsWith("}") && nextLineBean.indentLevel == lineBean.indentLevel) {
                            continue
                        }
                        nextLineBean.indentLevel++
                        var codeSplit = nextLineBean.codeLine.trimAscii().split("}", removeEmpty: false)
                        let newlineBean = LineBean()
                        newlineBean.codeLine = "}" + codeSplit[codeSplit.size - 1]
                        nextLineBean.codeLine = nextLineBean.codeLine.replace(newlineBean.codeLine, "")
                        newlineBean.indentLevel = nextLineBean.indentLevel - 1
                        stateBean.linesList.add(newlineBean, at:i + x + 1)
                    }
                }
            }
            removediscard(stateBean)

            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine
                if (codeStr.endsWith("{") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        let nextLineBean: LineBean = stateBean.linesList[i + 1]
                        if ((nextLineBean.codeLine.trimAscii().contains("=") || nextLineBean.codeLine.trimAscii().contains("=>")) && 
                        nextLineBean.codeLine.contains("}") &&
                        (!nextLineBean.codeLine.contains("{") || nextLineBean.codeLine.indexOf('}').getOrThrow() < nextLineBean.codeLine.indexOf('{').getOrThrow())
                        ) {
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            //多行前面有内容 只要隔个一个空格
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(" ")
                            stringbuilder.append(nextLineBean.codeLine)
                            // 代码后面直接书写'}'缺失一个'\n'的场景，补充一个换行符 '}' -> '\n}' 
                            nextLineBean.codeLine = stringbuilder.toString()
                            lineBean.isDiscarded = true
                        }
                    }
                }
            }
            removediscard(stateBean)

            // 处理参数中使用if代码块
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr.endsWith("=") && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 2) {
                        var nextLineBean: LineBean = stateBean.linesList[i + 1]
                        if (nextLineBean.codeLine.trimAscii().startsWith("if ") && stateBean.linesList[i + 2].codeLine.trimAscii() == "{") {
                            //如果这样的话，这一行的内容要加到上一行的后面
                            let stringbuilder: StringBuilder = StringBuilder()
                            //多行前面有内容 只要隔个一个空格
                            stringbuilder.append(lineBean.codeLine.trimAscii())
                            stringbuilder.append(" ")
                            stringbuilder.append(nextLineBean.codeLine.replace("\n", ""))
                            stringbuilder.append("{")
                            // 代码后面直接书写'}'缺失一个'\n'的场景，补充一个换行符 '}' -> '\n}' 
                            lineBean.codeLine = stringbuilder.toString()
                            nextLineBean.isDiscarded = true
                            stateBean.linesList[i + 2].isDiscarded = true
                            var x = 3
                            var leftBrace = 0
                            nextLineBean = stateBean.linesList[i + x]
                            while (!((leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1) && nextLineBean.codeLine.trimAscii().endsWith("}"))) {
                                leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                                x++
                                nextLineBean = stateBean.linesList[i + x]
                            }
                            if (!(nextLineBean.codeLine.trimAscii() == "}")) {
                                nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                                nextLineBean.codeLine = nextLineBean.codeLine.trimAscii().removeSuffix("}")
                            } else {
                                nextLineBean.isDiscarded = true
                            }
                            x++
                            nextLineBean = stateBean.linesList[i + x]
                            if (nextLineBean.codeLine.trimAscii() == "else") {
                                nextLineBean.codeLine = "} else {"
                                nextLineBean.indentLevel = stateBean.linesList[i + x - 1].indentLevel - 1
                                x++
                                nextLineBean = stateBean.linesList[i + x]
                                leftBrace = 0
                                if (nextLineBean.codeLine.trimAscii().startsWith("{")) {
                                    nextLineBean.codeLine = nextLineBean.codeLine.trimAscii()[1..]
                                    while (!(leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1)) {
                                        leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                                        x++
                                        nextLineBean = stateBean.linesList[i + x]
                                    }
                                    if ((nextLineBean.codeLine.trimAscii().replace(" ", "") == "}" || nextLineBean.codeLine.trimAscii().replace(" ", "") == "};") && nextLineBean.indentLevel == lineBean.indentLevel) {
                                        continue
                                    }
                                    nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                                    var tailCodeArr = nextLineBean.codeLine.split("}", removeEmpty: false)
                                    nextLineBean.codeLine = nextLineBean.codeLine.removeSuffix("}" + tailCodeArr[tailCodeArr.size-1])
                                    let newlineBean = LineBean()
                                    newlineBean.codeLine = "}" + tailCodeArr[tailCodeArr.size-1]
                                    newlineBean.indentLevel = nextLineBean.indentLevel - 1
                                    stateBean.linesList.add(newlineBean, at:i + x + 1)
                                }
                            } else if (nextLineBean.codeLine.trimAscii().startsWith("else {")) {
                                var newlineBean = LineBean()
                                newlineBean.codeLine = nextLineBean.codeLine.trimAscii()[7..]
                                nextLineBean.codeLine = "} else {"
                                nextLineBean.indentLevel = stateBean.linesList[i + x - 1].indentLevel - 1
                                newlineBean.indentLevel = stateBean.linesList[i + x - 1].indentLevel - 1
                                stateBean.linesList.add(newlineBean, at:i + x + 1)
                                x++
                                nextLineBean = stateBean.linesList[i + x]
                                leftBrace = 0
                                while (!(leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1)) {
                                    leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                                    x++
                                    nextLineBean = stateBean.linesList[i + x]
                                }
                                if ((nextLineBean.codeLine.trimAscii().replace(" ", "") == "}" || nextLineBean.codeLine.trimAscii().replace(" ", "") == "};") && nextLineBean.indentLevel == lineBean.indentLevel) {
                                    continue
                                }
                                nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                                var tailCodeArr = nextLineBean.codeLine.split("}", removeEmpty: false)
                                nextLineBean.codeLine = nextLineBean.codeLine.removeSuffix("}" + tailCodeArr[tailCodeArr.size-1])
                                newlineBean = LineBean()
                                newlineBean.codeLine = "}" + tailCodeArr[tailCodeArr.size-1]
                                newlineBean.indentLevel = nextLineBean.indentLevel - 1
                                stateBean.linesList.add(newlineBean, at:i + x + 1)
                            }
                        }
                    }
                }
            }
            removediscard(stateBean)

            // 处理普通if代码块
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr.startsWith("if") && !(i > 0 && stateBean.linesList[i - 1].codeLine.trimAscii().endsWith("=")) && !lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                    if (i < stateBean.linesList.size - 1) {
                        var x = 1
                        var leftBrace = 0
                        var nextLineBean: LineBean = stateBean.linesList[i + 1]
                        while (!(nextLineBean.codeLine.trimAscii().endsWith("}") && (leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1))) {
                            leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                            x++
                            nextLineBean = stateBean.linesList[i + x]
                        }
                        if (nextLineBean.codeLine.trimAscii().replace(" ", "") == "}") {
                            continue
                        }
                        nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                        var tailCodeArr = nextLineBean.codeLine.split("}", removeEmpty: false)
                        nextLineBean.codeLine = nextLineBean.codeLine.removeSuffix("}" + tailCodeArr[tailCodeArr.size-1])
                        let newlineBean = LineBean()
                        newlineBean.codeLine = "}" + tailCodeArr[tailCodeArr.size-1]
                        newlineBean.indentLevel = nextLineBean.indentLevel - 1
                        stateBean.linesList.add(newlineBean, at:i + x + 1)
                        x = x + 2
                        nextLineBean = stateBean.linesList[i + x]
                        if (nextLineBean.codeLine.trimAscii() == "else {") {
                            stateBean.linesList[i + x - 1].isDiscarded = true
                            nextLineBean.codeLine = nextLineBean.codeLine.trimAscii().replace("else {", "} else {")
                            leftBrace = 0
                            x++
                            nextLineBean = stateBean.linesList[i + x]
                            while (!(nextLineBean.codeLine.trimAscii().endsWith("}") && (leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}") == -1))) {
                                leftBrace = leftBrace + nextLineBean.codeLine.count("{") - nextLineBean.codeLine.count("}")
                                x++
                                nextLineBean = stateBean.linesList[i + x]
                            }
                            if (nextLineBean.codeLine.trimAscii().replace(" ", "") == "}") {
                                continue
                            }
                            nextLineBean.indentLevel = nextLineBean.indentLevel + 1
                            var tailCodeArr = nextLineBean.codeLine.split("}", removeEmpty: false)
                            nextLineBean.codeLine = nextLineBean.codeLine.removeSuffix("}" + tailCodeArr[tailCodeArr.size-1])
                            let newlineBean = LineBean()
                            newlineBean.codeLine = "}" + tailCodeArr[tailCodeArr.size-1]
                            newlineBean.indentLevel = nextLineBean.indentLevel - 1
                            stateBean.linesList.add(newlineBean, at:i + x + 1)
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
                    while (!stateBean.linesList[i + x].codeLine.trimAscii().startsWith(")")) {
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
                        stateBean.linesList[i + x].indentLevel++
                        x++
                    }
                }
            }
                    
            var x = 1
            //处理链式调用
            for (i in 0..stateBean.linesList.size) {
                let lineBean: LineBean = stateBean.linesList[i]
                if (x != 1) {
                    x--
                    continue
                }
                let codeStr = lineBean.codeLine.trimAscii()
                if (codeStr.startsWith(".") && 
                    (i - 1 >= 0) && 
                    (stateBean.linesList[i].indentLevel == stateBean.linesList[i - 1].indentLevel) && 
                    !lineBean.isInMultilineComment &&
                    !lineBean.isInSinglelineComment) {
                    stateBean.linesList[i].indentLevel++
                    while (stateBean.linesList[i + x].codeLine.trimAscii().startsWith(".")) {
                        if (i + x >= stateBean.linesList.size) {
                            break
                        }
                        stateBean.linesList[i + x].indentLevel++
                        x++
                    }
                }
            }

            // ========== 第三阶段：空格规范化 ==========
            normalizeRustSpaces(stateBean)

            // ========== 第四阶段：输出生成 ==========
            let usefulList: ArrayList<LineBean> = stateBean.linesList
            for (item in usefulList) {
                item.codeLine = item.codeLine.trimAscii()
            }

            // 根据缩进拼接最终代码
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

    /**
     * 规范化 Rust 代码中的空格
     * 处理运算符、冒号、箭头等周围的空格
     * 
     * @param stateBean 当前解析状态对象
     */
    func normalizeRustSpaces(stateBean: StateBean): Unit {
        for (i in 0..stateBean.linesList.size) {
            let lineBean: LineBean = stateBean.linesList[i]
            if (!lineBean.isInMultilineComment && !lineBean.isInSinglelineComment) {
                var line = lineBean.codeLine
                
                // 处理 use 语句中的空格
                if (line.trimAscii().startsWith("use ")) {
                    line = normalizeUseStatement(line)
                }
                // 处理常量/静态变量定义
                else if (line.trimAscii().startsWith("const ") || line.trimAscii().startsWith("static ")) {
                    line = normalizeConstDef(line)
                }
                // 处理类型别名
                else if (line.trimAscii().startsWith("type ")) {
                    line = normalizeTypeAlias(line)
                }
                // 处理结构体字段
                else if (line.contains(":") && !line.contains("fn ") && !line.contains("->")) {
                    line = normalizeFieldDef(line)
                }
                // 处理函数定义
                else if (line.contains("fn ") || line.contains("->")) {
                    line = normalizeFunctionDef(line)
                }
                // 处理 match 臂
                else if (line.contains("=>")) {
                    line = normalizeMatchArm(line)
                }
                // 处理 impl 块的方法调用
                else if (line.contains(".") && !line.contains("fn ")) {
                    line = normalizeMethodCall(line)
                }
                
                lineBean.codeLine = line
            }
        }
    }

    /**
     * 规范化 use 语句中的空格
     * 处理 `{Display,Formatter,Result as FmtResult}` -> `{Display, Formatter, Result as FmtResult}`
     * 
     * @param line 原始行内容
     * @return 规范化后的行
     */
    func normalizeUseStatement(line: String): String {
        var result = line
        // 处理花括号内的逗号后空格
        if (result.contains("{") && result.contains("}")) {
            let startIdx = result.indexOf("{").getOrThrow()
            let endIdx = result.indexOf("}").getOrThrow()
            if (startIdx >= 0 && endIdx > startIdx) {
                let prefix = result[0..startIdx + 1]
                let content = result[startIdx + 1..endIdx]
                let suffix = result[endIdx..]
                
                // 在逗号后添加空格（如果没有）
                var normalizedContent = content.replace(",", ", ")
                // 清理多余空格
                normalizedContent = normalizedContent.replace("  ", " ")
                
                result = prefix + normalizedContent + suffix
            }
        }
        return result
    }

    /**
     * 规范化常量/静态变量定义
     * 处理 `const MAX_VALUE:u32=100` -> `const MAX_VALUE: u32 = 100`
     * 
     * @param line 原始行内容
     * @return 规范化后的行
     */
    func normalizeConstDef(line: String): String {
        var result = line
        // 处理类型注解冒号后的空格
        result = normalizeColonSpacing(result)
        // 处理等号周围的空格
        result = normalizeEqualSpacing(result)
        return result
    }

    /**
     * 规范化类型别名
     * 处理 `type AppResult<T>=Result<T,AppError>` -> `type AppResult<T> = Result<T, AppError>`
     * 
     * @param line 原始行内容
     * @return 规范化后的行
     */
    func normalizeTypeAlias(line: String): String {
        var result = line
        // 处理等号周围的空格
        result = normalizeEqualSpacing(result)
        // 处理泛型参数中的逗号
        result = normalizeGenericSpacing(result)
        return result
    }

    /**
     * 规范化结构体/枚举字段定义
     * 处理 `pub city:String` -> `pub city: String`
     * 
     * @param line 原始行内容
     * @return 规范化后的行
     */
    func normalizeFieldDef(line: String): String {
        var result = line
        // 处理类型注解冒号后的空格
        result = normalizeColonSpacing(result)
        // 处理逗号后的空格
        result = normalizeCommaSpacing(result)
        return result
    }

    /**
     * 规范化函数定义
     * 处理 `fn fmt(&self,f:&mut Formatter<'_>)->FmtResult` -> `fn fmt(&self, f: &mut Formatter<'_>) -> FmtResult`
     * 
     * @param line 原始行内容
     * @return 规范化后的行
     */
    func normalizeFunctionDef(line: String): String {
        var result = line
        // 处理参数列表中的逗号
        if (result.contains("(") && result.contains(")")) {
            let startIdx = result.indexOf("(").getOrThrow()
            let endIdx = result.indexOf(")").getOrThrow()
            if (startIdx >= 0 && endIdx > startIdx) {
                let prefix = result[0..startIdx + 1]
                let params = result[startIdx + 1..endIdx]
                let suffix = result[endIdx..]
                
                // 规范化参数列表
                var normalizedParams = params.replace(",", ", ")
                normalizedParams = normalizedParams.replace("  ", " ")
                // 处理参数中的类型注解
                normalizedParams = normalizeColonSpacing(normalizedParams)
                
                result = prefix + normalizedParams + suffix
            }
        }
        // 处理返回类型箭头
        if (result.contains("->")) {
            result = result.replace("->", " -> ")
            result = result.replace("  ", " ")
            // 处理返回类型中的泛型
            result = normalizeGenericSpacing(result)
        }
        return result
    }

    /**
     * 规范化 match 臂
     * 处理 `UserStatus::Active=>write!(f,"active")` -> `UserStatus::Active => write!(f, "active")`
     * 
     * @param line 原始行内容
     * @return 规范化后的行
     */
    func normalizeMatchArm(line: String): String {
        var result = line
        // 处理 => 周围的空格
        result = result.replace("=>", " => ")
        result = result.replace("  ", " ")
        // 处理逗号后的空格
        result = normalizeCommaSpacing(result)
        return result
    }

    /**
     * 规范化方法调用
     * 处理链式调用 `.filter(|&&x|x%2==0).map(|x|x*2)` -> `.filter(|&&x| x % 2 == 0).map(|x| x * 2)`
     * 
     * @param line 原始行内容
     * @return 规范化后的行
     */
    func normalizeMethodCall(line: String): String {
        var result = line
        // 处理闭包参数和主体之间的空格
        if (result.contains("|") && result.count("|") > 1) {
            let firstPipe = result.indexOf("|").getOrThrow()
            let secondPipe = result.indexOf("|", firstPipe + 1).getOrThrow()
            if (firstPipe >= 0 && secondPipe > firstPipe) {
                let beforeClosure = result[0..firstPipe].trimAscii()
                let closureParams = result[firstPipe..secondPipe + 1].trimAscii()
                let closureBody = result[secondPipe + 1..].trimAscii()
                
                // 规范化闭包主体
                var normalizedBody = closureBody.replace("  ", " ")
                result = beforeClosure + closureParams + " " + normalizedBody
            }
        }
        return result
    }

    /**
     * 规范化冒号 : 周围的空格
     * 类型注解中冒号后应有一个空格，如 `name: String`
     * 
     * @param line 原始行内容
     * @return 规范化后的行
     */
    func normalizeColonSpacing(line: String): String {
        var result = line
        var sb = StringBuilder()
        var chars = result.toRuneArray()
        var i = 0
        
        while (i < chars.size) {
            let ch = chars[i]
            if (ch == r':' && i + 1 < chars.size && chars[i + 1] != r':' && chars[i + 1] != r' ') {
                // 检查前面不是 => 或 '或:
                if (i > 0 && chars[i - 1] == r'=') {
                    sb.append(ch)
                } else if (i > 0 && chars[i - 1] == r'\'') {
                    sb.append(ch)
                } else if (i > 0 && chars[i - 1] == r':') {
                    sb.append(ch)
                } else {
                    sb.append(ch)
                    sb.append(r' ')
                }
            } else {
                sb.append(ch)
            }
            i++
        }
        return sb.toString()
    }

    /**
     * 规范化等号 = 周围的空格
     * 赋值和类型别名中的等号前后应有空格
     * 
     * @param line 原始行内容
     * @return 规范化后的行
     */
    func normalizeEqualSpacing(line: String): String {
        var result = line
        var sb = StringBuilder()
        var chars = result.toRuneArray()
        var i = 0
        
        while (i < chars.size) {
            let ch = chars[i]
            if (ch == r'=') {
                // 检查是否是 == 或 =>
                if (i + 1 < chars.size && (chars[i + 1] == r'=' || chars[i + 1] == r'>')) {
                    sb.append(ch)
                } else if (i > 0 && chars[i - 1] == r'=' ) {
                    sb.append(ch)
                } else if (i > 0 && chars[i - 1] == r'-' ) {
                    sb.append(ch)
                } else {
                    // 单个等号，添加空格
                    if (i > 0 && chars[i - 1] != r' ') {
                        sb.append(r' ')
                    }
                    sb.append(ch)
                    if (i + 1 < chars.size && chars[i + 1] != r' ') {
                        sb.append(r' ')
                    }
                }
            } else {
                sb.append(ch)
            }
            i++
        }
        return sb.toString()
    }

    /**
     * 规范化逗号 , 后的空格
     * 逗号后应有一个空格，如 `a, b, c`
     * 
     * @param line 原始行内容
     * @return 规范化后的行
     */
    func normalizeCommaSpacing(line: String): String {
        var result = line
        var sb = StringBuilder()
        var chars = result.toRuneArray()
        var i = 0
        
        while (i < chars.size) {
            let ch = chars[i]
            if (ch == r',' && i + 1 < chars.size && chars[i + 1] != r' ') {
                sb.append(ch)
                sb.append(r' ')
            } else {
                sb.append(ch)
            }
            i++
        }
        return sb.toString()
    }

    /**
     * 规范化泛型参数中的空格
     * 泛型参数中的逗号后应有空格，如 `<T, U>`
     * 
     * @param line 原始行内容
     * @return 规范化后的行
     */
    func normalizeGenericSpacing(line: String): String {
        var result = line
        // 处理泛型参数：`<T,U>` -> `<T, U>`
        result = result.replace(",>", ", >")
        return result
    }
}