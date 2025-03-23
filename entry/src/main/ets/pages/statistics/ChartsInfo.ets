import { TitleContent } from './components/TitleContent';
import { BarChart } from './components/BarChart';
import { DailyChart } from './DailyChart';
import { ShortLink } from '../../model/LoginInterfaces';

// 统计数据类型定义
class DailyStats {
  date: string = '';
  pv: number = 0;
  uv: number = 0;
  uip: number = 0;
}

class CountStats {
  cnt: number = 0;
  name: string = '';
}

class StatsData {
  pv: number = 0;
  uv: number = 0;
  uip: number = 0;
  daily: Array<DailyStats> = [];
  localeCnts: Array<CountStats> = [];
  browserCnts: Array<CountStats> = [];
  osCnts: Array<CountStats> = [];
  deviceCnts: Array<CountStats> = [];
  networkCnts: Array<CountStats> = [];
  hourStats: Array<number> = [];
  weekdayStats: Array<number> = [];
}

// 历史记录类型定义
class HistoryRecord {
  createTime: string = '';
  ip: string = '';
  locale: string = '';
  browser: string = '';
  os: string = '';
  device: string = '';
  network: string = '';
  uvType: string = '';
}

class TableData {
  records: Array<HistoryRecord> = [];
  total: number = 0;
}

// 分页参数类型定义
interface PageParams {
  current: number;
  size: number;
}

@CustomDialog
@Component
export struct ChartsInfo {
  @Link isStatsDrawerOpening: boolean;
  @Link statsDrawerWidth: number;
  controller: CustomDialogController;
  shortLink?: ShortLink;

  @State showPane: string = '访问数据';
  @State dateValue: [string, string] = ['', ''];
  @State statsData: StatsData = new StatsData();
  @State tableInfo: TableData = new TableData();
  @State pageParams: PageParams = {
    current: 1,
    size: 10
  };

  aboutToAppear() {
    // 初始化日期范围为最近7天
    const end = new Date();
    const start = new Date();
    start.setDate(start.getDate() - 7);
    this.dateValue = [this.formatDate(start), this.formatDate(end)];
    
    // 获取数据
    this.fetchStatsData();
  }

  private formatDate(value: DatePickerResult | Date): string {
    if (value instanceof Date) {
      const year = value.getFullYear();
      const month = String(value.getMonth() + 1).padStart(2, '0');
      const day = String(value.getDate()).padStart(2, '0');
      return `${year}-${month}-${day}`;
    } else if (value) {
      // 使用类型断言处理 DatePickerResult
      const result = value as DatePickerResult;
      if (result.year !== undefined && result.month !== undefined && result.day !== undefined) {
        const month = String(result.month + 1).padStart(2, '0');
        const day = String(result.day).padStart(2, '0');
        return `${result.year}-${month}-${day}`;
      }
    }
    
    // 提供默认值
    const today = new Date();
    const year = today.getFullYear();
    const month = String(today.getMonth() + 1).padStart(2, '0');
    const day = String(today.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  private async fetchStatsData() {
    // ... 实现数据获取逻辑
  }

  build() {
    Stack() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
        .opacity(0.6)
        .onClick(() => this.closeDrawer())

      // 内容区域
      Column() {
        // 头部
        Row() {
          Column({ space: 4 }) {
            Text(this.shortLink?.description || '暂无描述')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
            Text((this.shortLink?.domain || '') + (this.shortLink?.shortUri || ''))
              .fontSize(14)
              .fontColor('#86909C')
          }
          .layoutWeight(1)

          // 日期选择
          Row({ space: 8 }) {
            // 开始日期选择器
            Row() {
              Text(this.dateValue[0])
                .fontSize(14)
                .fontColor('#1D2129')
            }
            .width(100)
            .height(32)
            .backgroundColor('#F2F3F5')
            .borderRadius(4)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              DatePickerDialog.show({
                selected: new Date(this.dateValue[0]),
                onAccept: (value: DatePickerResult) => {
                  this.dateValue = [this.formatDate(value), this.dateValue[1]];
                  this.fetchStatsData();
                }
              })
            })

            Text('至')
              .fontSize(14)
              .fontColor('#1D2129')

            // 结束日期选择器
            Row() {
              Text(this.dateValue[1])
                .fontSize(14)
                .fontColor('#1D2129')
            }
            .width(100)
            .height(32)
            .backgroundColor('#F2F3F5')
            .borderRadius(4)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              DatePickerDialog.show({
                selected: new Date(this.dateValue[1]),
                onAccept: (value: DatePickerResult) => {
                  this.dateValue = [this.dateValue[0], this.formatDate(value)];
                  this.fetchStatsData();
                }
              })
            })
          }
        }
        .width('100%')
        .padding(24)

        // 内容区域
        Tabs() {
          TabContent() {
            Scroll() {
              Column() {
                // 访问曲线
                TitleContent({ title: '访问曲线' }) {
                  DailyChart({ statsData: this.statsData })
                }

                // 24小时分布
                TitleContent({ title: '24小时分布' }) {
                  BarChart({
                    chartData: {
                      xAxis: Array(24).fill(0).map((item: number, index: number): number => index),
                      value: this.statsData?.hourStats || new Array(24).fill(0)
                    }
                  })
                }

                // 一周分布
                TitleContent({ title: '一周分布' }) {
                  BarChart({
                    chartData: {
                      xAxis: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
                      value: this.statsData?.weekdayStats || new Array(7).fill(0)
                    }
                  })
                }

                // ... 其他图表组件
              }
              .padding(16)
            }
          }
          .tabBar('访问数据')

          TabContent() {
            // 历史记录表格
            List() {
              ForEach(this.tableInfo?.records || [], (item: HistoryRecord) => {
                ListItem() {
                  Row() {
                    Text(item.createTime)
                    Text(item.ip)
                    Text(item.locale)
                    // ... 其他列
                  }
                  .width('100%')
                  .padding(16)
                }
              })
            }
          }
          .tabBar('历史记录')
        }
        .onChange(index => {
          this.showPane = index === 0 ? '访问数据' : '历史记录';
        })
      }
      .width(1000)
      .height('100%')
      .backgroundColor(Color.White)
      .position({ x: '100%' })
      .translate({ x: -this.statsDrawerWidth })
      .animation({
        duration: 250,
        curve: Curve.EaseOut
      })
    }
    .width('100%')
    .height('100%')
    .zIndex(999)
  }

  closeDrawer() {
    animateTo({
      duration: 250,
      curve: Curve.EaseOut,
      delay: 0,
      onFinish: () => {
        this.isStatsDrawerOpening = false;
        this.controller?.close();
      }
    }, () => {
      this.statsDrawerWidth = 0;
    })
  }
} 