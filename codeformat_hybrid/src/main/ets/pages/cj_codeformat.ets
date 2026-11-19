import { requireCJLib } from 'libark_interop_loader.so'
import { CustomLib } from "libark_interop_api_codeformat_hybrid.so"

let global_customLib: CustomLib | null = null

function lib(): CustomLib {
  if (global_customLib === null) {
    global_customLib = requireCJLib("libcodeformat_hybrid.so") as CustomLib
  }
  return global_customLib
}

export class CodeFormatTS {
  useCangjie: boolean = true

  constructor(useCangjie: boolean = true) {
    this.useCangjie = useCangjie
    if (!this.useCangjie) {
        global_customLib = null
    }
  }

  public codeFormatDefault(languageType: string | undefined, code: string): string {
    if (global_customLib === null && !this.useCangjie) {
      return code
    }
    let res = lib().codeFormatDefault(languageType, code)
    return res
  }

  public codeFormatWithWhiteSpace(languageType: string | undefined, code: string, indentWidth: number): string {
    if (global_customLib === null && !this.useCangjie) {
      return code
    }
    let res = lib().codeFormatWithWhiteSpace(languageType, code, indentWidth)
    return res
  }

  public codeFormatWithTab(languageType: string | undefined, code: string): string {
    if (global_customLib === null && !this.useCangjie) {
      return code
    }
    let res = lib().codeFormatWithTab(languageType, code)
    return res
  }
}
