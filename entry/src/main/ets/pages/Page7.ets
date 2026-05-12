import { CodeFormatTS } from '@cangjie-tpc/codeformat_hybrid'

@Entry
@Component
struct page7Test {

  @State text:string = "111"

  code1:string = `
select username,age,phone,address from user_list where status=1 and type=1 order by id desc limit 15;
`
  async aboutToAppear(): Promise<void> {
    this.text = new CodeFormatTS().codeFormatDefault("sql",this.code1)
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

