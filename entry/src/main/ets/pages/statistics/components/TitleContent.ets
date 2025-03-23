@Component
export struct TitleContent {
  title: string = '';
  @BuilderParam content: () => void;

  build() {
    Column() {
      // 标题
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 16 })

      // 内容区域
      this.content()
    }
    .backgroundColor(Color.White)
    .borderRadius(8)
    .padding(20)
    .margin(10)
  }
} 