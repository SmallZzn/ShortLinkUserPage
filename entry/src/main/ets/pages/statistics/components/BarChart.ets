import webview from '@ohos.web.webview';

interface ChartDataType {
  xAxis: Array<string | number>;
  value: Array<number>;
}

@Component
export struct BarChart {
  private controller: webview.WebviewController = new webview.WebviewController();
  chartData: ChartDataType = {
    xAxis: [],
    value: []
  };

  build() {
    Web({ src: $rawfile('bar-chart.html'), controller: this.controller })
      .width('100%')
      .height('100%')
      .onPageEnd(() => {
        this.controller.runJavaScript(`setChartData(${JSON.stringify(this.chartData)})`);
      })
  }
} 