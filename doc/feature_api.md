# codeformat4hybrid 特性文档

## 介绍

codeformat是一个对代码进行格式化的库,目前支持C和C++,OC/OC++,js/ts，Java,Python,Html,Go,kotlin,swift,Rust,C#,Dart,PHP,Cangjie,SQL,Scala,Bash 20种语言

### 全局函数

```ets

export class CodeFormatTS {

  /*
   * 构造函数,useCangjie 默认true,true表示使用仓颉，false表示不使用仓颉
   *
   */ 
  constructor(useCangjie:boolean=true) 

  /*
   * 默认格式化函数,使用4个空格作为一次缩进
   *
   * @param 参数 languageType - 语言的类型languageType目前只支持
   *  "c" | "cpp" | "c++" | "clike" | "objective-c" | "objective-c++" | "java"
   *  "js" | "ts" | "javascript" | "typescript"
   *  "python" | "python3" | "py" | "py3" | "python ml" | "pythonml" | "pandas" | "pythondata"
   *  "go"| "golang"|"kotlin" | "kt"| "php"| "scala" |  "csharp" | "c#" |"swift" |"dart"
   *  "cangjie" | "rust"| "bash" | "sh" | "shell" | "shellscript"| "html"| "html5"
   "  “sql" | "mysql" | "oracle" | "oraclesql"| "sqlserver" | "ms sql server" | "mssql" | "postgresql" | "pgsql" 
   * @param 参数 code - 需要格式化的代码
   *
   *
   * @return 返回 string 类型，格式化后的字符串
   */
  public codeFormatDefault(languageType: string | undefined, code: string): string 

  /*
   * 使用空格缩进的格式化函数,多少个空格作为一次缩进由自己定义
   *
   * @param 参数 languageType - 语言的类型languageType目前支持
   *  "c" | "cpp" | "c++" | "clike" | "objective-c" | "objective-c++" | "java"
   *  "js" | "ts" | "javascript" | "typescript"
   *  "python" | "python3" | "py" | "py3" | "python ml" | "pythonml" | "pandas" | "pythondata"
   *  "go"| "golang"|"kotlin" | "kt"| "php"| "scala" |  "csharp" | "c#" |"swift" |"dart"
   *  "cangjie" | "rust"| "bash" | "sh" | "shell" | "shellscript"| "html"| "html5"
   "  “sql" | "mysql" | "oracle" | "oraclesql"| "sqlserver" | "ms sql server" | "mssql" | "postgresql" | "pgsql" 
   * @param 参数 code - 需要格式化的代码
   * @param 参数 indentWidth - 定义多少个空格为一个缩进
   *
   * @return 返回 string 类型，格式化后的字符串
   */
  public codeFormatWithWhiteSpace(languageType: string | undefined, code: string, indentWidth:number): string 

  /*
   * 使用Tab键的格式化函数,使用1个Tab作为一次缩进
   *
   * @param 参数 languageType - 语言的类型languageType目前只支持
   *  "c" | "cpp" | "c++" | "clike" | "objective-c" | "objective-c++" | "java"
   *  "js" | "ts" | "javascript" | "typescript"
   *  "python" | "python3" | "py" | "py3" | "python ml" | "pythonml" | "pandas" | "pythondata"
   *  "go"| "golang"|"kotlin" | "kt"| "php"| "scala" |  "csharp" | "c#" |"swift" |"dart"
   *  "cangjie" | "rust"| "bash" | "sh" | "shell" | "shellscript"| "html"| "html5"
   "  “sql" | "mysql" | "oracle" | "oraclesql"| "sqlserver" | "ms sql server" | "mssql" | "postgresql" | "pgsql" 
   * @param 参数 code - 需要格式化的代码
   *
   *
   * @return 返回 string 类型，格式化后的字符串
   */
  public codeFormatWithTab(languageType: string | undefined, code: string): string
}


```
