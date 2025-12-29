# codeformat4cj 特性文档

## 介绍

codeformat4cj是一个对代码进行格式化的库,目前仅支持C和C++语言

### 全局函数

```cangjie
/*
 * 格式化方法
 * 
 * 参数 languageType:String - 格式化的语言类型，目前只支持C和C++ languageType目前只支持"c"|"cpp"|"c++"|"clike"
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
}

```

