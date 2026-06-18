package codeformat

public class FormatConfig {
    var indentWidth: Int64 = 4
    var useTab: Bool = false

    public init(useTab!: Bool = false, indentWidth!: Int64 = 4) {
        this.useTab = useTab
        this.indentWidth = indentWidth
    }
}
