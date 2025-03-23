import webview from '@ohos.web.webview';

/** 
 * 小时数据接口
 */
class HourChartData {
  hours: number[] = Array(24).fill(0);
}

/**
 * 小时分布图组件
 * 用于显示24小时访问量分布
 */
@Component
export struct HoursChart {
  @Prop @Watch('onHourStatsChange') hourStats: Array<number> = [];
  @Prop @Watch('onUpdateCounterChange') updateCounter: number = 0;
  private controller: webview.WebviewController = new webview.WebviewController();
  @State isLoaded: boolean = false;
  private chartInitialized: boolean = false;
  
  // 监听hourStats属性变化
  onHourStatsChange() {
    console.info(`[HoursChart] 检测到hourStats变化，数据长度: ${this.hourStats.length}`);
    if (this.chartInitialized) {
      console.info('[HoursChart] 因数据变化开始更新图表');
      this.updateChart();
    }
  }
  
  // 添加对updateCounter的监听
  onUpdateCounterChange() {
    console.info(`[HoursChart] 检测到updateCounter变化: ${this.updateCounter}`);
    if (this.chartInitialized) {
      this.updateChart();
    } else {
      console.info(`[HoursChart] 图表尚未初始化，忽略更新`);
    }
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
        src: $rawfile('hours-chart.html'),
        controller: this.controller
      })
        .width('100%')
        .height(260)
        .backgroundColor('#fff')
        .onPageEnd(() => {
          console.info('[HoursChart] 网页加载完成');
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
      console.info('[HoursChart] 图表尚未初始化，无法更新');
      return;
    }
    
    console.info('[HoursChart] 开始更新小时分布图表');
    console.info(`[HoursChart] 当前数据长度: ${this.hourStats.length}`);
    if (this.hourStats.length > 0) {
      console.info(`[HoursChart] 数据样本: ${this.hourStats[0]}, ${this.hourStats[1]}...`);
    }
    
    // 使用原有的updateChartData方法
    this.updateChartData();
  }
  
  // 原有的更新图表数据方法
  private updateChartData() {
    // 确保数据有效
    let hourData = this.hourStats;
    if (!Array.isArray(hourData) || hourData.length === 0) {
      hourData = Array(24).fill(0);
    } else if (hourData.length < 24) {
      // 如果数据不足24小时，进行填充
      hourData = [...hourData, ...Array(24 - hourData.length).fill(0)];
    }

    // 将数据转换为JavaScript对象
    const data = new HourChartData();
    data.hours = hourData;

    // 使用JavaScript注入更新图表
    try {
      this.controller.runJavaScript(`setChartData(${JSON.stringify(data)})`);
    } catch (error) {
      console.error('更新小时图表数据失败:', error);
    }
  }
} 