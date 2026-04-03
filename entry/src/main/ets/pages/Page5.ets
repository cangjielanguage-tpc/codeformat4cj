import { CodeFormatTS } from '@cangjie-tpc/codeformat_hybrid'
import { hilog } from '@kit.PerformanceAnalysisKit'


@Entry
@Component
struct page5Test {


  @State text:string = "111"

  code1:string = `
  #include <stdio.h>
  #include <stdlib.h>
  int main() {
  int a = 10;
  int b = 20;
  int sum = a + b;
  printf("Sum: %d\\n", sum);
  return 0;
}
`


  async aboutToAppear(): Promise<void> {
    this.text = new CodeFormatTS(false).codeFormatWithWhiteSpace("c",this.code1,8)
  }

  aboutToDisappear(): void {

  }

  build() {
    Row() {
      Scroll() {
        Column() {
          Text(this.text)
        }
        .width('100%')
      }.scrollBar(BarState.Off)
      .height('100%')
    }
  }
}

