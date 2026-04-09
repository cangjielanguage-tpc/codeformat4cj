# codeformat4cj 特性文档

## 介绍

codeformat4cj是一个对代码进行格式化的库,目前仅支持C和C++语言,OC/OC++,js/ts,java,python，go,kotlin

### 全局函数

```cangjie
/*
 * 格式化方法
 * 
 * 参数 languageType:String - 格式化的语言类型，目前只支持C和C++ languageType目前只支持"c"|"cpp"|"c++"|"clike"|"objective-c"|"objective-c++"|
    "java"|"js"|"ts"|"javascript"|"typescript"|"python"| "python3" | "py" | "py3" | "python ml" | "pythonml" | "pandas" | "pythondata"|
    "go" |"kotlin" | "kt"    
 * 参数 code:String - 要格式化的代码
 * 参数 cfg:FormatConfig - 格式化配置对象
 * 返回值 String - 格式化后输出的字符串
 */
public func codeFormat(languageType:String,code: String, cfg: FormatConfig): String

```

### class FormatConfig

```cangjie
/*
 * 格式化配置类
 * 
 * 参数 useTab - 是否使用tab作为缩进 true是用一个Tab作为缩进  false使用空格作为缩进
 * 参数 indentWidth - 使用空格缩进时，指定空格的数量 默认为4
 */
public class FormatConfig {
    var useTab: Bool = false  // 可选：是否用制表符（默认false，用空格）
    var indentWidth: Int64 = 4  // 默认4空格缩进

    /*
     * 构造函数
     * 参数 useTab:Bool - 是否使用制表符作为缩进 默认false,默认为空格 
     * 参数 indentWidth:Int64 - 使用空格时候每个缩进需要多少空格，默认为4
     */    
    public init(useTab!: Bool = false, indentWidth!: Int64 = 4)

}

```

