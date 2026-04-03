package codeformat_hybrid

internal import ohos.ark_interop.JSModule
internal import ohos.ark_interop.JSContext
internal import ohos.ark_interop.JSCallInfo
internal import ohos.ark_interop.JSValue
internal import codeformat.codeFormat
internal import codeformat.FormatConfig

func codeFormatDefault(runtime: JSContext, callInfo: JSCallInfo):JSValue{
    let langType = callInfo[0].asString().toString()
    let code = callInfo[1].asString().toString()
    let result = codeFormat(langType, code,FormatConfig(indentWidth:4,useTab:false))
    return runtime.string(result).toJSValue()
}

func codeFormatWithWhiteSpace(runtime: JSContext, callInfo: JSCallInfo):JSValue{
    let langType = callInfo[0].asString().toString()
    let code = callInfo[1].asString().toString()
    let indentWidth = callInfo[2].toNumber()
    let result = codeFormat(langType, code,FormatConfig(indentWidth:Int64(indentWidth),useTab:false))
    return runtime.string(result).toJSValue()
}

func codeFormatWithTab(runtime: JSContext, callInfo: JSCallInfo):JSValue{
    let langType = callInfo[0].asString().toString()
    let code = callInfo[1].asString().toString()
    let result = codeFormat(langType, code,FormatConfig(indentWidth:1,useTab:true))
    return runtime.string(result).toJSValue()
}


let EXPORT_MODULE = JSModule.registerModule {
    runtime, exports =>
    exports["codeFormatDefault"] = runtime.function(codeFormatDefault).toJSValue()
    exports["codeFormatWithWhiteSpace"] = runtime.function(codeFormatWithWhiteSpace).toJSValue()
    exports["codeFormatWithTab"] = runtime.function(codeFormatWithTab).toJSValue()

}
