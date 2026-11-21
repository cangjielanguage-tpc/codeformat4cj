package codeformat_hybrid

internal import ohos.ark_interop.JSModule
internal import ohos.ark_interop.JSContext
internal import ohos.ark_interop.JSCallInfo
internal import ohos.ark_interop.JSValue
internal import ohos.hilog.Hilog
internal import codeformat.codeFormat
internal import codeformat.FormatConfig

// SEC-HY1：依赖 codeformat v1.0.7 存在常规输入即可触发的未捕获运行时异常
// （IndexOutOfBoundsException / 负下标 / OverflowException——语言实现层大量
// 无防护下标访问，如 linesList[i-1]、[i+2]、tailCodeArr[size-1] 等；本层
// asString()/toNumber() 对 undefined/缺参/错型参数同样会抛）。异常若不在此层
// 拦截，会沿 ArkTS 互操作边界以互操作异常形态穿透回宿主 JS，中断宿主页面/线程
// 正常流程。统一拦截策略：互操作入口 try/catch 全覆盖（含取参）→ 日志只含异常
// 信息、不含用户代码内容 → 宿主拿到可处理的错误信息字符串（"format failed: ..."），
// 返回类型契约不变（仍为 string，见 libcodeformat_hybrid/index.d.ts）。

// languageType 在 d.ts 中声明为 string|undefined：undefined/缺参/错型时传 None
// 给依赖（依赖按未识别语言返回原文），不再让 asString() 抛异常穿透
func langTypeArg(value: JSValue): ?String {
    try {
        return Some(value.asString().toString())
    } catch (e: Exception) {
        return None
    }
}

// 统一失败出口：捕获一切异常（依赖库越界/溢出 + 互操作取参失败），降级为
// 宿主可判别的错误信息字符串，宿主线程正常流程不再被互操作异常打断
func safeFormatToJS(runtime: JSContext, name: String, body: () -> String): JSValue {
    try {
        let result = body()
        return runtime.string(result).toJSValue()
    } catch (e: Exception) {
        Hilog.error(0, "codeformat_hybrid", "${name} failed: ${e}")
        return runtime.string("format failed: ${e}").toJSValue()
    }
}

func codeFormatDefault(runtime: JSContext, callInfo: JSCallInfo): JSValue {
    safeFormatToJS(runtime, "codeFormatDefault") {
        let langType = langTypeArg(callInfo[0])
        let code = callInfo[1].asString().toString()
        codeFormat(langType, code, FormatConfig(indentWidth: 4, useTab: false))
    }
}

func codeFormatWithWhiteSpace(runtime: JSContext, callInfo: JSCallInfo): JSValue {
    safeFormatToJS(runtime, "codeFormatWithWhiteSpace") {
        let langType = langTypeArg(callInfo[0])
        let code = callInfo[1].asString().toString()
        let indentWidth = callInfo[2].toNumber()
        codeFormat(langType, code, FormatConfig(indentWidth: Int64(indentWidth), useTab: false))
    }
}

func codeFormatWithTab(runtime: JSContext, callInfo: JSCallInfo): JSValue {
    safeFormatToJS(runtime, "codeFormatWithTab") {
        let langType = langTypeArg(callInfo[0])
        let code = callInfo[1].asString().toString()
        codeFormat(langType, code, FormatConfig(indentWidth: 1, useTab: true))
    }
}

let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports =>
    exports["codeFormatDefault"] = runtime.function(codeFormatDefault).toJSValue()
    exports["codeFormatWithWhiteSpace"] = runtime.function(codeFormatWithWhiteSpace).toJSValue()
    exports["codeFormatWithTab"] = runtime.function(codeFormatWithTab).toJSValue()

}
