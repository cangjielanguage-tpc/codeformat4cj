import { requireCJLib } from 'libark_interop_loader.so'
import { CustomLib } from "libark_interop_api_codeformat_hybrid.so"

export let global_customLib: CustomLib | undefined = undefined


export class CodeFormatTS {
  useCangjie: boolean = true

  constructor(useCangjie: boolean = true) {
    this.useCangjie = useCangjie
    if (this.useCangjie) {
      if (global_customLib === undefined) {
        global_customLib = requireCJLib("libcodeformat_hybrid.so") as CustomLib
      }
    } else {
      global_customLib = undefined
    }
  }

  public codeFormatDefault(languageType: string | undefined, code: string): string {
    if (global_customLib === undefined) {
      return code
    }
    let res = global_customLib.codeFormatDefault(languageType, code)
    return res
  }

  public codeFormatWithWhiteSpace(languageType: string | undefined, code: string, indentWidth: number): string {
    if (global_customLib === undefined) {
      return code
    }
    let res = global_customLib.codeFormatWithWhiteSpace(languageType, code, indentWidth)
    return res
  }

  public codeFormatWithTab(languageType: string | undefined, code: string): string {
    if (global_customLib === undefined) {
      return code
    }
    let res = global_customLib.codeFormatWithTab(languageType, code)
    return res
  }
}
