import { DeviceStats } from '../../model/ChartInterfacses';
import { CircleChart } from './components/CircleChart';

/**
 * 访问设备统计组件
 */
@Component
export struct DeviceStatsList {
  @Prop deviceStats: Array<DeviceStats> = [];
  private textColor: string = '#1D2129';
  private textColorSecondary: string = '#86909C';
  private themeColor: string = '#4080FF';
  
  // 获取电脑设备数据项
  private getPcItem(): DeviceStats {
    const item = this.deviceStats.find(item => 
      item.device.toUpperCase() === 'PC' || 
      item.device.toUpperCase() === '电脑' ||
      item.device.toUpperCase() === 'DESKTOP');
    return item || { device: '电脑', ratio: 0, cnt: 0 };
  }
  
  // 获取移动设备数据项
  private getMobileItem(): DeviceStats {
    const item = this.deviceStats.find(item => 
      item.device.toUpperCase() === 'MOBILE' || 
      item.device.toUpperCase() === '移动设备' ||
      item.device.toUpperCase() === 'PHONE');
    return item || { device: '移动设备', ratio: 0, cnt: 0 };
  }
  
  build() {
    Column() {
      Row() {
        // 电脑设备数据
        Column() {
          CircleChart({
            ratio: this.getPcItem().ratio,
            text: `${(this.getPcItem().ratio * 100).toFixed(0)}%`,
            subText: `电脑: ${this.getPcItem().cnt}次`
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        
        // 移动设备数据
        Column() {
          CircleChart({
            ratio: this.getMobileItem().ratio,
            text: `${(this.getMobileItem().ratio * 100).toFixed(0)}%`,
            subText: `移动设备: ${this.getMobileItem().cnt}次`
          })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
      
      // 如果数据为空，显示提示
      if (this.deviceStats.length === 0) {
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