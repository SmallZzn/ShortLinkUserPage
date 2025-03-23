import webview from '@ohos.web.webview';

/**
 * 周数据接口
 */
class WeekChartData {
  weekdays: number[] = Array(7).fill(0);
}

/**
 * 一周分布图组件
 * 用于显示一周访问量分布
 */
@Component
export struct WeekChart {
  @Prop @Watch('onWeekdayStatsChange') weekdayStats: Array<number> = [];
  @Prop @Watch('onUpdateCounterChange') updateCounter: number = 0;
  private controller: webview.WebviewController = new webview.WebviewController();
  private chartInitialized: boolean = false;
  @State isLoaded: boolean = false;
  
  // 监听weekdayStats属性变化
  onWeekdayStatsChange() {
    console.info(`[WeekChart] 检测到weekdayStats变化，数据长度: ${this.weekdayStats.length}`);
    if (this.chartInitialized) {
      console.info('[WeekChart] 因数据变化开始更新图表');
      this.updateChart();
    }
  }

  // 添加对updateCounter的监听
  onUpdateCounterChange() {
    console.info(`[WeekChart] 检测到updateCounter变化: ${this.updateCounter}`);
    if (this.chartInitialized) {
      this.updateChart();
    } else {
      console.info(`[WeekChart] 图表尚未初始化，忽略更新`);
    }
  }

  aboutToAppear() {
    // 初始化
  }

  build() {
    Stack() {
      // 添加加载提示
      if (!this.isLoaded) {
        Column() {
          LoadingProgress()
            .width(30)
            .height(30)
          Text('加载中...')
            .fontSize(14)
            .margin({ top: 10 })
            .fontColor('#999')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      
      Web({ 
        src: $rawfile('week-chart.html'), 
        controller: this.controller 
      })
        .width('100%')
        .height(300)
        .backgroundColor('#fff')
        .onPageEnd(() => {
          // 页面加载完成后更新数据
          this.isLoaded = true;
          this.chartInitialized = true;
          this.updateChart();
        })
    }
    .width('100%')
    .height(300)
  }
  
  // 更新图表方法
  public updateChart() {
    if (!this.chartInitialized) {
      console.info('[WeekChart] 图表尚未初始化，无法更新');
      return;
    }
    
    console.info('[WeekChart] 开始更新周分布图表');
    console.info(`[WeekChart] 当前数据长度: ${this.weekdayStats.length}`);
    if (this.weekdayStats.length > 0) {
      console.info(`[WeekChart] 数据样本: ${this.weekdayStats[0]}, ${this.weekdayStats[1]}...`);
    }
    
    // 使用原有的updateChartData方法
    this.updateChartData();
  }

  // 更新图表数据
  private updateChartData() {
    // 确保数据有效
    let weekData = this.weekdayStats;
    if (!Array.isArray(weekData) || weekData.length === 0) {
      weekData = Array(7).fill(0);
    } else if (weekData.length < 7) {
      // 如果数据不足7天，进行填充
      weekData = [...weekData, ...Array(7 - weekData.length).fill(0)];
    }

    // 将数据转换为JavaScript对象
    const data = new WeekChartData();
    data.weekdays = weekData;

    // 使用JavaScript注入更新图表
    try {
      this.controller.runJavaScript(`setChartData(${JSON.stringify(data)})`);
    } catch (error) {
      console.error('更新周图表数据失败:', error);
    }
  }
} 