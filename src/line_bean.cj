package codeformat

class LineBean {
    var codeLine: String = ""
    var indentLevel: Int64 = 0
    var smallBracketDouble: Int64 = 0
    var middleBracketDouble: Int64 = 0
    var sharpBracketDouble: Int64 = 0
    var isInString: Bool = false
    var isInMacro: Bool = false
    var isInAccessFlag: Bool = false
    var isInFor: Bool = false
    var isInSinglelineComment: Bool = false
    var isInMultilineComment: Bool = false
    var singleLineWhiteSpace: Int64 = 0
    var singlelineCommentisAfterChangeLine: Bool = false
    var isDiscarded: Bool = false
    var isFirstMultiCommentLine: Bool = false
    var multilineCommentisAfterChangeLine: Bool = false
    var isInMultiString: Bool = false
    var isSingleLine: Bool = false
    var isHeredocContent: Bool = false
}
