package codeformat

class FlagBean {
    var flagName: String = ""
    var flagIndent: Int64 = 0

    init(flagName: String, flagIndent: Int64) {
        this.flagName = flagName
        this.flagIndent = flagIndent
    }
}
