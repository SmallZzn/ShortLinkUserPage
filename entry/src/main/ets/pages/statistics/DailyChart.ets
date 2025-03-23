import webview from '@ohos.web.webview';

// 添加类型定义
class DailyStats {
  date: string = '';
  pv: number = 0;
  uv: number = 0;
  uip: number = 0;
}

class ShortLinkStatsData {
  pv: number = 0; // 访问量
  uv: number = 0; // 独立访客数
  uip: number = 0; // 独立IP数
  daily: Array<DailyStats> = [];
}

// 添加类型定义
interface TooltipParam {
  axisValue: string;
  marker: string;
  seriesName: string;
  value: number;
}

// 添加更新属性的接口定义
interface ChartProps {
  statsData: ShortLinkStatsData;
  startDate: string;
  endDate: string;
  updateCounter: number;
}

@Component
export struct DailyChart {
  @Prop statsData: ShortLinkStatsData;
  @Prop startDate: string = '';
  @Prop endDate: string = '';
  @Prop @Watch('onUpdateCounterChange') updateCounter: number = 0;
  
  private controller: webview.WebviewController = new webview.WebviewController();
  private chartInitialized: boolean = false;
  
  aboutToAppear() {
    console.info(`[DailyChart] 组件初始化`);
  }

  // 添加对updateCounter的监听
  onUpdateCounterChange() {
    console.info(`[DailyChart] 检测到updateCounter变化: ${this.updateCounter}`);
    if (this.chartInitialized) {
      this.updateChart();
    } else {
      console.info(`[DailyChart] 图表尚未初始化，忽略更新`);
    }
  }

  // 提供一个公开方法供外部直接调用来刷新图表
  public updateChart(): void {
    const timestamp = new Date().getTime();
    console.info(`[DailyChart] 手动刷新图表，日期范围: ${this.startDate} 至 ${this.endDate}，时间戳: ${timestamp}`);
    
    // 确保Web组件已经初始化
    if (!this.chartInitialized) {
      console.info(`[DailyChart] 图表尚未初始化，等待页面加载完成`);
      return;
    }
    
    // 生成图表选项
    const option = this.getChartOption();
    
    console.info(`[DailyChart] 图表选项已生成，开始更新图表，时间戳: ${timestamp}`);
    
    // 强制更新图表，第二个参数设为true表示完全重建图表
    this.controller.runJavaScript(`
      console.log('接收到手动更新请求，时间戳: ${timestamp}');
      console.log('X轴数据:', JSON.stringify(${JSON.stringify(this.getDatesBetween(this.startDate, this.endDate))}));
      setOption(${option}, true);
      console.log('图表完全重建完成，时间戳: ${timestamp}');
    `);
    
    console.info(`[DailyChart] 图表重建命令已发送，时间戳: ${timestamp}`);
  }

  build() {
    Column() {
      Web({ src: $rawfile('echarts.html'), controller: this.controller })
        .width('100%')
        .height(300)
        .onPageEnd(() => {
          console.info(`[DailyChart] 网页加载完成，标记图表已初始化`);
          this.chartInitialized = true;
          // 初始加载图表
          this.updateChart();
        })
    }
    .width('100%')
    .onClick(() => {
      // 添加点击事件，便于测试手动刷新
      console.info(`[DailyChart] 图表被点击，手动触发刷新`);
      this.updateChart();
    })
  }

  // 获取日期范围内的所有日期
  private getDatesBetween(startDate: string, endDate: string): Array<string> {
    if (!startDate || !endDate) {
      return this.getDefaultDates();
    }

    const dates: Array<string> = [];
    const start = new Date(startDate);
    const end = new Date(endDate);
    
    // 确保开始日期不晚于结束日期
    if (start > end) {
      return this.getDefaultDates();
    }

    let current = new Date(start);
    while (current <= end) {
      dates.push(`${current.getFullYear()}-${String(current.getMonth() + 1).padStart(2, '0')}-${String(current.getDate()).padStart(2, '0')}`);
      current.setDate(current.getDate() + 1);
    }
    
    return dates;
  }

  // 获取最近7天的日期作为默认数据
  private getDefaultDates(): Array<string> {
    const dates: Array<string> = [];
    const today = new Date();
    for (let i = 6; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      dates.push(`${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`);
    }
    return dates;
  }

  // 格式化图表数据
  private getChartOption(): string {
    // 使用日期范围获取所有日期
    const allDates: Array<string> = this.getDatesBetween(this.startDate, this.endDate);
    console.info(`[DailyChart] 图表X轴日期生成完成，共${allDates.length}天: ${JSON.stringify(allDates)}`);
    
    // 为所有日期准备数据，如果某天没有数据则为0
    const pvData: Array<number> = [];
    const uvData: Array<number> = [];
    const uipData: Array<number> = [];
    
    // 创建日期到数据的映射
    const dailyMap = new Map<string, DailyStats>();
    if (this.statsData?.daily?.length > 0) {
      this.statsData.daily.forEach(item => {
        dailyMap.set(item.date, item);
      });
    }
    
    // 为每个日期填充数据
    allDates.forEach(date => {
      const dayData = dailyMap.get(date);
      pvData.push(dayData ? dayData.pv : 0);
      uvData.push(dayData ? dayData.uv : 0);
      uipData.push(dayData ? dayData.uip : 0);
    });

    const option: object = Object({
      tooltip: Object({
        trigger: 'axis',
        axisPointer: Object({
          type: 'shadow'
        }),
        enterable: true,
        confine: true,
        backgroundColor: 'rgba(255, 255, 255, 0.9)',
        borderColor: '#E5E6EB',
        textStyle: Object({
          color: '#1D2129'
        }),
        formatter: (params: Array<TooltipParam>) => {
          let result = `${params[0].axisValue}<br/>`;
          params.forEach(param => {
            result += `${param.marker}${param.seriesName}：${param.value}<br/>`;
          });
          return result;
        }
      }),
      legend: Object({
        data: ['访问次数', '访问人数', '访问IP数'],
        top: 0,
        right: 0,
        itemWidth: 12,
        itemHeight: 12,
        textStyle: Object({
          color: '#86909C',
          fontSize: 12
        })
      }),
      grid: Object({
        left: '3%',
        right: '4%',
        bottom: '3%',
        top: '40px',
        containLabel: true
      }),
      xAxis: Object({
        type: 'category',
        data: allDates,
        axisLine: Object({
          lineStyle: Object({
            color: '#E5E6EB'
          })
        }),
        axisTick: Object({
          show: true,
          alignWithLabel: true
        }),
        axisLabel: Object({
          interval: 0,
          rotate: 40,
          color: '#86909C',
          fontSize: 12
        })
      }),
      yAxis: Object({
        type: 'value',
        minInterval: 1,
        min: 0,
        splitLine: Object({
          lineStyle: Object({
            color: '#E5E6EB',
            type: 'dashed'
          })
        }),
        axisLine: Object({
          show: false
        }),
        axisTick: Object({
          show: false
        }),
        axisLabel: Object({
          color: '#86909C',
          fontSize: 12
        })
      }),
      series: Object([
        {
          name: '访问次数',
          type: 'line',
          data: pvData,
          smooth: true,
          symbol: 'circle',
          showSymbol: true,
          symbolSize: 6,
          itemStyle: Object({
            color: '#4080FF'
          }),
          lineStyle: Object({
            width: 2
          }),
          areaStyle: Object({
            color: Object({
              type: 'linear',
              x: 0,
              y: 0,
              x2: 0,
              y2: 1,
              colorStops: Object([
                {
                  offset: 0,
                  color: 'rgba(64,128,255,0.2)'
                },
                {
                  offset: 1,
                  color: 'rgba(64,128,255,0)'
                }
              ])
            })
          })
        },
        {
          name: '访问人数',
          type: 'line',
          data: uvData,
          smooth: true,
          symbol: 'circle',
          showSymbol: true,
          symbolSize: 6,
          itemStyle: Object({
            color: '#00B42A'
          }),
          lineStyle: Object({
            width: 2
          }),
          areaStyle: Object({
            color: Object({
              type: 'linear',
              x: 0,
              y: 0,
              x2: 0,
              y2: 1,
              colorStops: Object([
                {
                  offset: 0,
                  color: 'rgba(0,180,42,0.2)'
                },
                {
                  offset: 1,
                  color: 'rgba(0,180,42,0)'
                }
              ])
            })
          })
        },
        {
          name: '访问IP数',
          type: 'line',
          data: uipData,
          smooth: true,
          symbol: 'circle',
          showSymbol: true,
          symbolSize: 6,
          itemStyle: Object({
            color: '#F7BA1E'
          }),
          lineStyle: Object({
            width: 2
          }),
          areaStyle: Object({
            color: Object({
              type: 'linear',
              x: 0,
              y: 0,
              x2: 0,
              y2: 1,
              colorStops: Object([
                {
                  offset: 0,
                  color: 'rgba(247,186,30,0.2)'
                },
                {
                  offset: 1,
                  color: 'rgba(247,186,30,0)'
                }
              ])
            })
          })
        }
      ])
    });

    return JSON.stringify(option);
  }
}
