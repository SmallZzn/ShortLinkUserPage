import { OsStats } from '../../model/ChartInterfacses';

/**
 * 操作系统统计组件
 */
@Component
export struct OsStatsList {
  @Prop osStats: Array<OsStats> = [];
  private textColor: string = '#1D2129';
  private textColorSecondary: string = '#86909C';
  private themeColor: string = '#4080FF';
  
  build() {
    Column() {
      // 显示操作系统列表
      List() {
        ForEach(this.osStats, (item: OsStats, index: number) => {
          ListItem() {
            Column() {
              Row() {
                // 操作系统名称和占比
                Row() {
                  Text(item.os)
                    .fontSize(14)
                    .fontColor(this.textColor)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  
                  Text(`（${(item.ratio * 100).toFixed(2)}%）`)
                    .fontSize(14)
                    .fontColor(this.textColorSecondary)
                    .margin({ left: 4 })
                }
                .layoutWeight(1)
                
                // 访问次数
                Text(`${item.cnt}次`)
                  .fontSize(14)
                  .fontColor(this.textColorSecondary)
              }
              .width('100%')
              .padding({ left: 16, right: 16 })
              .justifyContent(FlexAlign.SpaceBetween)
              .height(32)
              
              // 进度条
              Row() {
                Row()
                  .width(`${item.ratio * 100}%`)
                  .height(3)
                  .backgroundColor(this.themeColor)
                  .borderRadius(1.5)
              }
              .width('100%')
              .height(8)
              .backgroundColor('#F2F3F5')
              .borderRadius(1.5)
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
            .margin({ bottom: index < this.osStats.length - 1 ? 8 : 0 })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      
      // 如果数据为空，显示提示
      if (this.osStats.length === 0) {
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
    .height(200)
    .backgroundColor(Color.White)
    .borderRadius(8)
  }
} 