package codeformat

// FormatConfig: 格式化配置。
//
// indentWidth 行为说明（SEC-M2/SEC-L1）：缩进发射点（utils.cj 的 addIndent，全语言
// 唯一收口）将每级缩进空格宽度钳制为 MAX_INDENT_WIDTH(64)、缩进层数钳制为
// MAX_INDENT_LEVEL(64)——超出上限的取值按上限行为生效，用于阻断超大配置导致的
// 输出放大与 Int64 乘法溢出；负值按原语义产生空缩进。useTab 模式下每级 1 个 tab。
//
// init 保持透传（不在此处做范围校验）：钳制在唯一消费点统一收口；若未来需要
// “配置即报错”的语义，可在此追加范围校验（见检视 #112 建议）。
public class FormatConfig {
    var indentWidth: Int64 = 4
    var useTab: Bool = false

    public init(useTab!: Bool = false, indentWidth!: Int64 = 4) {
        this.useTab = useTab
        this.indentWidth = indentWidth
    }
}
