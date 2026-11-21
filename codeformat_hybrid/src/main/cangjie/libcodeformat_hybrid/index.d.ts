export declare interface CustomLib {

    // SEC-HY1: 仓颉层已拦截全部异常（依赖库越界/溢出 + 互操作取参失败）。
    // 失败时不再向宿主抛互操作异常，而是返回以 "format failed: " 开头的错误信息字符串，
    // 宿主可据此判别失败（如 result.startsWith('format failed: ')）。
    // languageType 传 undefined 时等价于未知语言，返回原文。
    codeFormatDefault(languageType: string|undefined,code:string): string
    codeFormatWithWhiteSpace(languageType: string|undefined,code:string,indentWidth:number): string
    codeFormatWithTab(languageType: string|undefined,code:string): string

}