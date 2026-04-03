export declare interface CustomLib {

    codeFormatDefault(languageType: string|undefined,code:string): string
    codeFormatWithWhiteSpace(languageType: string|undefined,code:string,indentWidth:number): string
    codeFormatWithTab(languageType: string|undefined,code:string): string

}