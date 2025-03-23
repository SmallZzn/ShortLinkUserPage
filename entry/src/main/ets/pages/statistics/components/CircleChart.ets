/**
 * 定义点坐标接口
 */
interface Point {
  x: number;
  y: number;
}

/**
 * 环形图组件
 */
@Component
export struct CircleChart {
  @Prop ratio: number = 0; // 比例
  @Prop text: string = ''; // 显示的文本
  @Prop subText: string = ''; // 显示的子文本
  private circleSize: number = 110; // 圆环大小
  private strokeWidth: number = 10; // 圆环宽度
  private circleColor: string = '#4080FF'; // 主题色
  private circleBgColor: string = '#F2F3F5'; // 背景色
  private textColor: string = '#1D2129'; // 文字颜色
  private textColorSecondary: string = '#86909C'; // 次要文字颜色

  // 计算圆弧路径
  private getArcPath(radius: number, startAngle: number, endAngle: number): string {
    const center = radius; // 圆心坐标
    const start: Point = {
      x: center + radius * Math.cos(startAngle * Math.PI / 180),
      y: center + radius * Math.sin(startAngle * Math.PI / 180)
    };
    
    const end: Point = {
      x: center + radius * Math.cos(endAngle * Math.PI / 180),
      y: center + radius * Math.sin(endAngle * Math.PI / 180)
    };
    
    // 确定是否为大弧（大于180度）
    const largeArcFlag = (endAngle - startAngle <= 180) ? '0' : '1';
    
    return `M ${center} ${center} L ${start.x} ${start.y} A ${radius} ${radius} 0 ${largeArcFlag} 1 ${end.x} ${end.y} Z`;
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        // 背景圆环
        Circle()
          .width(this.circleSize)
          .height(this.circleSize)
          .fill(Color.Transparent)
          .stroke(this.circleBgColor)
          .strokeWidth(this.strokeWidth)

        // 使用Progress组件显示比例
        Progress({
          value: this.ratio * 100,
          total: 100,
          type: ProgressType.Ring
        })
          .width(this.circleSize)
          .height(this.circleSize)
          .color(this.circleColor)
          .backgroundColor(Color.Transparent)
          .style({ strokeWidth: this.strokeWidth })

        // 中心文字
        Column() {
          Text(this.text)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.textColor)
          Text(this.subText)
            .fontSize(14)
            .fontColor(this.textColorSecondary)
            .margin({ top: 4 })
            .textAlign(TextAlign.Center)
            .maxLines(2)
            .width(this.circleSize * 0.85)
        }
      }
      .width(this.circleSize + this.strokeWidth * 2)
      .height(this.circleSize + this.strokeWidth * 2)
      .padding(this.strokeWidth)
      .backgroundColor(Color.White)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
} 