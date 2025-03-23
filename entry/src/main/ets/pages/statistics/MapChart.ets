import webview from '@ohos.web.webview';
import {
  CountStats,
  MapDataPoint
} from '../../model/ChartInterfacses';
import { TitleContent } from './components/TitleContent';

@Component
export struct MapChart {
  @Prop @Watch('onLocaleCntsChange') localeCnts: Array<CountStats> = [];
  @Prop @Watch('onUpdateCounterChange') updateCounter: number = 0;
  private controller: webview.WebviewController = new webview.WebviewController();
  @State isWebLoaded: boolean = false;
  @State webLoadError: string = '';
  private isInitialized: boolean = false;

  // 修正后的省份名称（与地图数据完全一致）
  private readonly defaultProvinces: Array<string> = [
    '北京市', '天津市', '上海市', '重庆市', '河北省', '河南省', '云南省', '辽宁省',
    '黑龙江省', '湖南省', '安徽省', '山东省', '新疆维吾尔自治区', '江苏省', '浙江省', '江西省',
    '湖北省', '广西壮族自治区', '甘肃省', '山西省', '内蒙古自治区', '陕西省', '吉林省', '福建省',
    '贵州省', '广东省', '青海省', '西藏自治区', '四川省', '宁夏回族自治区', '海南省', '台湾省',
    '香港特别行政区', '澳门特别行政区'
  ];

  // 监听localeCnts属性变化
  onLocaleCntsChange() {
    console.info(`[MapChart] 检测到localeCnts变化，数量: ${this.localeCnts.length}`);
    if (this.isWebLoaded) {
      console.info('[MapChart] 因数据变化开始更新地图');
      this.updateMap();
    }
  }

  // 添加对updateCounter的监听
  onUpdateCounterChange() {
    console.info(`[MapChart] 检测到updateCounter变化: ${this.updateCounter}`);
    if (this.isWebLoaded) {
      console.info('[MapChart] 开始重新加载地图数据');
      this.updateMap();
    } else {
      console.info(`[MapChart] 地图尚未初始化，忽略更新`);
    }
  }

  // 初始化WebView通信
  private initWebView() {
    console.info('[MapChart] 开始初始化 WebView');
    try {
      // 先注册 JavaScript 代理
      this.controller.registerJavaScriptProxy({
        onJSReady: () => {
          console.info('[MapChart] JavaScript bridge ready - onJSReady 被调用');
          this.isWebLoaded = true;
          this.webLoadError = '';
          console.info('[MapChart] 准备更新地图数据');
          this.updateMap();
        },
        onError: (error: string) => {
          console.info('[MapChart] 收到错误:', error);
          this.webLoadError = error;
        }
      }, "webController", ["onJSReady", "onError"]);

      // 等待一段时间后强制触发更新
      setTimeout(() => {
        console.info('[MapChart] 强制更新地图数据');
        this.isWebLoaded = true;
        this.updateMap();
      }, 5000);
    } catch (error) {
      const errorMsg = `初始化WebView失败: ${error.toString()}`;
      console.error('[MapChart]', errorMsg);
      this.webLoadError = errorMsg;
    }
  }

  // 更新地图配置
  private updateMap() {
    console.info('[MapChart] 进入 updateMap 方法');
    console.info(`[MapChart] 当前数据点数量: ${this.localeCnts.length}`);
    
    try {
      // 处理数据
      const mapData = this.defaultProvinces.map(province => {
        // 查找匹配
        const found = this.localeCnts.find(item => {
          if (!item || !item.locale) return false;
          
          const normalizedProvince = province.replace('省', '').replace('市', '')
            .replace('自治区', '').replace('特别行政区', '');
          const normalizedLocale = item.locale.replace('省', '').replace('市', '')
            .replace('自治区', '').replace('特别行政区', '');
          
          return normalizedProvince === normalizedLocale;
        });
        
        const point = new MapDataPoint();
        point.name = province;
        point.value = found ? found.cnt : 0;
        
        return point;
      });
      
      // 找出有数据的点
      const dataWithValues = mapData.filter(item => item.value > 0);
      console.info('[MapChart] 有数据的点数量:', dataWithValues.length);
      if (dataWithValues.length > 0) {
        console.info('[MapChart] 第一个数据点:', JSON.stringify(dataWithValues[0]));
      }
      
      // 使用字符串拼接构建 JSON 数组
      let dataJson = '[';
      for (let i = 0; i < mapData.length; i++) {
        if (i > 0) {
          dataJson += ',';
        }
        dataJson += `{"name":"${mapData[i].name}","value":${mapData[i].value}}`;
      }
      dataJson += ']';
      
      // 简化调用
      this.controller.runJavaScript(`
        console.log('[MapChart] 开始执行JavaScript更新...');
        if (typeof updateMapData === 'function') {
          console.log('[MapChart] 调用updateMapData函数');
          updateMapData(${dataJson});
          console.log('[MapChart] updateMapData调用完成');
        } else {
          console.error('[MapChart] updateMapData 函数未定义');
        }
      `);
    } catch (error) {
      const errorMsg = `更新地图失败: ${error.toString()}`;
      console.error('[MapChart]', errorMsg);
      this.webLoadError = errorMsg;
    }
  }

  build() {
    Column() {
      TitleContent({ title: '访问地区' }) {
        Row() {
          // 左侧TOP 10列表
          Column() {
            Stack() {
              Column() {
                Text('TOP 10 省份')
                  .fontSize(14)
                  .position({ x: 16, y: 0 })

                Scroll() {
                  Column() {
                    List() {
                      ForEach(this.localeCnts
                        .sort((a, b) => (b.ratio || 0) - (a.ratio || 0))
                        .slice(0, 10),
                        (item: CountStats, index: number) => {
                          ListItem() {
                            Row() {
                              Text(`${index + 1}. ${item.locale}`)
                                .fontSize(14)
                                .maxLines(1)
                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                                .width('25%')
                                .margin({ right: 16 })

                              Text(`${((item.ratio || 0) * 100).toFixed(2)}%`)
                                .fontSize(14)
                                .margin({ right: 16 })

                              Text(`${item.cnt}次`)
                                .fontSize(14)
                            }
                            .width('100%')
                            .padding(8)
                          }
                        })
                    }
                    .width('100%')
                    .margin({ top: 8 })
                    .position({ y: 24 })
                  }
                }
                .scrollBar(BarState.Off)
                .width('100%')
                .height('100%')
              }
              .width('100%')
              .height(400)
            }
          }
          .width('30%')

          // 右侧地图容器
          Column() {
            if (this.webLoadError) {
              Text(this.webLoadError)
                .fontSize(14)
                .fontColor(Color.Red)
                .padding(16)
                .backgroundColor('#FFEBEE')
                .borderRadius(4)
                .margin(8)
            }
            
            Web({
              src: $rawfile('china-map.html'),
              controller: this.controller
            })
              .width('100%')
              .height(400)
              .backgroundColor('#f5f5f5')
              .onPageEnd(() => {
                console.info('[MapChart] Web页面加载完成');
                this.isWebLoaded = true;
                // 直接调用更新，无需等待
                console.info('[MapChart] 开始初始化地图数据');
                this.updateMap();
                // 初始化JavaScript代理
                this.initWebView();
              })
              .onErrorReceive(event => {
                const errorMsg = `加载错误: ${event?.error || '未知错误'}`;
                console.error('[MapChart]', errorMsg);
                this.webLoadError = errorMsg;
              })
          }
          .width('70%')
        }
        .width('100%')
      }
    }
    .width('100%')
  }
}