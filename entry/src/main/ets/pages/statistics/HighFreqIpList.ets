import { TopIpStats } from '../../model/ChartInterfacses';

/**
 * 高频访问IP列表组件
 */
@Component
export struct HighFreqIpList {
  @Prop ipStats: Array<TopIpStats> = [];
  private themeColor: string = '#4080FF';
  private textColor: string = '#1D2129';
  private textColorSecondary: string = '#86909C';
  
  build() {
    Column() {
      // 标题栏，保持与一周分布图表的视觉高度一致
      Row() {
        Text('IP地址')
          .fontSize(12)
          .fontColor(this.textColorSecondary)
          .layoutWeight(1)
        
        Text('访问次数')
          .fontSize(12)
          .fontColor(this.textColorSecondary)
      }
      .width('100%')
      .height(30)
      .padding({ left: 16, right: 16, top: 8 })
      
      // 显示IP列表，设置最大高度确保内容适合区域
      List() {
        ForEach(this.ipStats.slice(0, 5), (item: TopIpStats, index: number) => {
          ListItem() {
            Row() {
              // IP地址
              Text(item.ip)
                .fontSize(14)
                .fontColor(this.textColor)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
              
              // 访问次数
              Text(`${item.cnt}次`)
                .fontSize(14)
                .fontColor(this.textColorSecondary)
            }
            .width('100%')
            .height(40)
            .padding({ left: 16, right: 16 })
            .justifyContent(FlexAlign.SpaceBetween)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      
      // 如果数据为空，显示提示
      if (this.ipStats.length === 0) {
        Column() {
          Text('暂无数据')
            .fontSize(14)
            .fontColor(this.textColorSecondary)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .borderRadius(8)
    .padding(0)
  }
} 