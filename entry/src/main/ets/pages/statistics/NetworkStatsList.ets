import { NetworkStats } from '../../model/ChartInterfacses';
import { CircleChart } from './components/CircleChart';

/**
 * 网络访问统计组件
 */
@Component
export struct NetworkStatsList {
  @Prop networkStats: Array<NetworkStats> = [];
  private textColor: string = '#1D2129';
  private textColorSecondary: string = '#86909C';
  private themeColor: string = '#4080FF';
  
  // 获取WIFI数据项
  private getWifiItem(): NetworkStats {
    const item = this.networkStats.find(item => item.network.toUpperCase() === 'WIFI');
    return item || { network: 'WIFI', ratio: 0, cnt: 0 };
  }
  
  // 获取移动数据项
  private getMobileItem(): NetworkStats {
    const item = this.networkStats.find(item => 
      item.network.toUpperCase() === '移动数据' || 
      item.network.toUpperCase() === 'MOBILE');
    return item || { network: '移动数据', ratio: 0, cnt: 0 };
  }
  
  build() {
    Column() {
      Row() {
        // WIFI数据
        Column() {
          CircleChart({
            ratio: this.getWifiItem().ratio,
            text: `${(this.getWifiItem().ratio * 100).toFixed(0)}%`,
            subText: `WIFI: ${this.getWifiItem().cnt}次`
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        
        // 移动数据
        Column() {
          CircleChart({
            ratio: this.getMobileItem().ratio,
            text: `${(this.getMobileItem().ratio * 100).toFixed(0)}%`,
            subText: `移动数据: ${this.getMobileItem().cnt}次`
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
      
      // 如果数据为空，显示提示
      if (this.networkStats.length === 0) {
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