package codeformat

/**
 * 代码格式化配置类
 * 支持通用配置和 Bash 特定配置
 */
public class FormatConfig {
    // 通用配置
    var indentWidth: Int64 = 4 // 默认4空格缩进
    var useTab: Bool = false // 可选：是否用制表符（默认false，用空格）

    public init(useTab!: Bool = false, indentWidth!: Int64 = 4) {
        this.useTab = useTab
        this.indentWidth = indentWidth
    }
}
