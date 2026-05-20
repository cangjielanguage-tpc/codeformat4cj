package codeformat

class StateBean {
    var codeChars: ?Array<Rune> = None
    var isLineStart: Bool = true
    var indentLevel: Int64 = 0 //缩进层级
    var savedIndentLevel: Int64 = 0 //行开始时保存的缩进层级（用于关键字行正确缩进）
    var isInString: Bool = false //是否在字符串中
    var stringQuote: Rune = r' ' //字符串的类型
    var isInMacro: Bool = false //是否在宏中
    var isInAccessFlag: Bool = false //是否在访问修饰符
    var isInFor: Bool = false //是否在for循环中
    var isInSinglelineComment: Bool = false //是否在单行注释里
    var isInMultilineComment: Bool = false //是否在多行注释里
    var smallBracketDouble: Int64 = 0 //小括号配对 
    var middleBracketDouble: Int64 = 0 //中括号配对
    var sharpBracketDouble: Int64 = 0 //尖括号配对
    var currentIndex: Int64 = 0 //当前索引
    var lastChar: Rune = r' ' //上一个char
    var currentChar: Rune = r' ' //当前char
    var output: StringBuilder = StringBuilder() //最后输出的stringbuilder
    var linesList: ArrayList<LineBean> = ArrayList<LineBean>() //多少行
    var perLineStartIndex: Int64 = 0 //上一行到哪里结束
    var perLineOutput: StringBuilder = StringBuilder() //缓存单行数据，如果单行没解析完，就把缓存中的输出到output中

    var isInRetuen: Bool = false //是否在return中 python有用
    var isInExcept: Bool = false //是否在Except中 python有用
    var isInDef: Bool = false //是否在Def中 python有用
    var isInClass: Bool = false //是否在Def中 python有用
    var isInContinue: Bool = false //是否在Continue中 python有用
    var isInBreak: Bool = false //是否在Break中 python有用
    var isInMain: Bool = false //是否在if __name__ == "__main__":中 python有用

    var isInElif: Bool = false //是否在elif中 python有用
    var isInElse: Bool = false //是否在elif中 python有用
    var isLastLineReturn: Bool = false //上一行是否是return 如果是return else不用缩进 否则要缩进一次 python有用

    //为了处理这种情况  python有用
    var isInSmallBracket: Bool = false
    //为了处理这种情况 在小括号和大括号里面没成对走完 里面的:不能执行结束逻辑
    var isInBigBracket: Bool = false // 在python有用
    var bigBracketDoublepy: Int64 = 0 //大括号配对 python有用
    var smallBracketDoublepy: Int64 = 0 //大括号配对 python有用
    var isInMultiString: Bool = false //是否进入多行字符串 相当于python的多行注释 python有用
    var multiStringQuote: Rune = r' ' //多行字符串的类型 python有用
    var isInImport: Bool = false //是否在Import中 python有用
    var isHasClass: Bool = false //是否有class python有用 主要是class和def一起的时候使用
    var isInBackQuote:Bool = false //是否在反引号里 在ts、go中有用

    //dart、kotion语言
    var isTripleQuote: Bool = false //三引号
    var tripleQuoteCount: Int64 = 0 //三引号计数

    var smallBracketDoubleScala: Int64 = 0 //小括号配对 Scala有用
    var isInVal:Bool = false //是否进入val Scala有用

    //sql
    var isInBetween :Bool = false
    var isInWhere :Bool = false  //给and or缩进用
    var isHasWhere :Bool = false //给and or缩进用
    var isInValues :Bool = false
    var isSqlSmallBracket :Int64 = 0
    var isInSet :Bool = false
    var isInSelect :Bool = false
    var isInDeleteFrom:Bool = false //delete from和from区分
    var isInMultiJoin:Bool = false //multijoin和普通join区分
    var isInFrom :Bool = false  //给innerjoin缩进用
    var isHasFrom :Bool = false //给innerjoin缩进用
    var isInJoin :Bool = false //给innerjoin缩进用
    var isInGroupBy :Bool = false //给groupby后的,不要换行
    var isInOrderBy:Bool = false //给orderBy后面的,不要换行
    var isInCreateTable:Bool = false //给createTable后面的,不要换行
    var isHasCreateTableLeft:Bool = false //给createTable后面的,不要换行
    var isHasCreateTableRight:Bool = false //给createTable后面的,不要换行
    var isFirstCreateTableLeft:Bool = true //给createTable后面的,不要换行
    var isFirstCreateTableRight:Bool = true //给createTable后面的,不要换行
    var isInAlterTable:Bool = true //给alertTable后面的缩进用
    var isInSubSelect:Bool = false //给alertTable后面的缩进用
    var isInSubSelectCount:Int64 = 0 //给alertTable后面的缩进用 这个记录左括号个数
    var isJustTurnSubSelectFalse:Bool = false //是不是刚刚走出subselect
    var subSelectHasInAndOr:Bool=false // subselect第一次进where如果没有and or的话要两层 然后碰到and or就只要一层够了 where退出的时候这个也要重置
    var isInUnionAll :Bool = false //给innerjoin缩进用
}
