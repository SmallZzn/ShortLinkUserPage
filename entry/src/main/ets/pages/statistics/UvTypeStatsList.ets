import { UvTypeStats } from '../../model/ChartInterfacses';
import { CircleChart } from './components/CircleChart';

/**
 * 访客类型统计组件
 */
@Component
export struct UvTypeStatsList {
  @Prop uvTypeStats: Array<UvTypeStats> = [];
  private textColor: string = '#1D2129';
  private textColorSecondary: string = '#86909C';
  private themeColor: string = '#4080FF';
  
  // 获取新访客数据项
  private getNewVisitorItem(): UvTypeStats {
    const item = this.uvTypeStats.find(item => 
      item.uvType === '1' || 
      item.uvType.toUpperCase() === 'NEWUSER');
    return item || { uvType: '1', ratio: 0, cnt: 0 };
  }
  
  // 获取老访客数据项
  private getOldVisitorItem(): UvTypeStats {
    const item = this.uvTypeStats.find(item => 
      item.uvType === '0' || 
      item.uvType.toUpperCase() === 'OLDUSER');
    return item || { uvType: '0', ratio: 0, cnt: 0 };
  }
  
  build() {
    Column() {
      Row() {
        // 新访客数据
        Column() {
          CircleChart({
            ratio: this.getNewVisitorItem().ratio,
            text: `${(this.getNewVisitorItem().ratio * 100).toFixed(0)}%`,
            subText: `新访客: ${this.getNewVisitorItem().cnt}人`
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        
        // 老访客数据
        Column() {
          CircleChart({
            ratio: this.getOldVisitorItem().ratio,
            text: `${(this.getOldVisitorItem().ratio * 100).toFixed(0)}%`,
            subText: `老访客: ${this.getOldVisitorItem().cnt}人`
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
      
      // 如果数据为空，显示提示
      if (this.uvTypeStats.length === 0) {
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