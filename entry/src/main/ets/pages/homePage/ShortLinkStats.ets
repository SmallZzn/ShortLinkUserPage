import { JhProgressHUD } from '../../JhCommon/components/JhProgressHUD';
import { APIs } from '../../JhCommon/http/APIs';
import { HttpUtils } from '../../JhCommon/http/HttpUtils';
import { ShortLinkStatsData, AccessRecord } from '../../model/ChartInterfacses';
import { ShortLink } from '../../model/LoginInterfaces';
import { TitleContent } from '../statistics/components/TitleContent';
import { DailyChart } from '../statistics/DailyChart';
import { HighFreqIpList } from '../statistics/HighFreqIpList';
import { MapChart } from '../statistics/MapChart';
import { HoursChart } from '../statistics/HoursChart';
import { WeekChart } from '../statistics/WeekChart';
import { UvTypeStatsList } from '../statistics/UvTypeStatsList';
import { NetworkStatsList } from '../statistics/NetworkStatsList';
import { DeviceStatsList } from '../statistics/DeviceStatsList';

// 添加图标映射定义
class IconMap {
  // 操作系统图标映射
  static readonly OS_ICONS: Record<string, Resource> = {
    'windows': $r('app.media.windows'),
    'linux': $r('app.media.linux'),
    'mac': $r('app.media.mac')
  };
  // 浏览器图标映射
  static readonly BROWSER_ICONS: Record<string, Resource> = {
    'chrome': $r('app.media.Chrome'),
    'edge': $r('app.media.Edge'),
    'ie': $r('app.media.IE'),
    'firefox': $r('app.media.firefox')
  };
  // 网络类型图标映射
  static readonly NETWORK_ICONS: Record<string, Resource> = {
    'mobile': $r('app.media.Mobile'),
    'wifi': $r('app.media.WIFI')
  };
  // 设备类型图标映射
  static readonly DEVICE_ICONS: Record<string, Resource> = {
    'pc': $r('app.media.computer'),
    'mobile': $r('app.media.Phone')
  };
  static readonly OTHER: Record<string, Resource> = {
    'unknown': $r("app.media.unknown"),
    'search': $r("app.media.select"),
  };

  // 获取操作系统图标
  static getOsIcon(os: string): Resource | null {
    if (!os) {
      return null;
    }
    const osLower = os.toLowerCase();
    if (osLower.includes('windows')) {
      return IconMap.OS_ICONS.windows;
    } else if (osLower.includes('linux')) {
      return IconMap.OS_ICONS.linux;
    } else if (osLower.includes('mac os')) {
      return IconMap.OS_ICONS.mac;
    } else {
      return IconMap.OTHER.unknown;
    }
  }

  // 获取浏览器图标
  static getBrowserIcon(browser: string): Resource | null {
    if (!browser) {
      return null;
    }
    const browserLower = browser.toLowerCase();
    if (browserLower.includes('google chrome')) {
      return IconMap.BROWSER_ICONS.chrome;
    } else if (browserLower.includes('microsoft edge')) {
      return IconMap.BROWSER_ICONS.edge;
    } else if (browserLower.includes('ie')) {
      return IconMap.BROWSER_ICONS.ie;
    } else if (browserLower.includes('firefox')) {
      return IconMap.BROWSER_ICONS.firefox;
    } else {
      return IconMap.OTHER.unknown;
    }
  }

  // 获取网络类型图标
  static getNetworkIcon(network: string): Resource | null {
    if (!network) {
      return null;
    }
    const networkLower = network.toLowerCase();
    if (networkLower.includes('wifi')) {
      return IconMap.NETWORK_ICONS.wifi;
    } else if (networkLower.includes('mobile') || networkLower.includes('cellular')) {
      return IconMap.NETWORK_ICONS.mobile;
    } else {
      return IconMap.OTHER.unknown;
    }
  }

  // 获取设备类型图标
  static getDeviceIcon(device: string): Resource | null {
    if (!device) {
      return null;
    }
    const deviceLower = device.toLowerCase();
    if (deviceLower.includes('pc')) {
      return IconMap.DEVICE_ICONS.computer;
    } else if (deviceLower.includes('mobile') || deviceLower.includes('phone')) {
      return IconMap.DEVICE_ICONS.mobile;
    } else {
      return IconMap.OTHER.unknown;
    }
  }
}

@CustomDialog
@Component
export struct ShortLinkStats {
  @Link isStatsDrawerOpening: boolean;
  @Link statsDrawerWidth: number;
  shortLink!: ShortLink; // 当前查看的短链接
  controller: CustomDialogController;
  isGroupStats: boolean = false; // 是否为分组统计
  onSuccess: () => void = () => {
  };
  // 主题色常量
  readonly themeColor: string = '#4080FF';
  readonly themeColorLight: string = '#F2F3F5';
  readonly textColor: string = '#1D2129';
  readonly textColorSecondary: string = '#86909C';
  readonly themeBorderColor: string = '#E5E6EB';
  // 统计数据状态
  @State startDate: string = '';
  @State endDate: string = '';
  @State statsData: ShortLinkStatsData | null = null;
  @State selectedStartDate: Date = new Date(new Date().setDate(new Date().getDate() - 7));
  @State selectedEndDate: Date = new Date();
  // 添加当前显示的视图类型状态
  @State currentView: string = 'stats'; // 'stats'表示统计数据, 'record'表示访问记录
  // 添加访问记录相关状态
  @State accessRecords: Array<AccessRecord> = [];
  @State totalPages: number = 1;
  @State currentPage: number = 1;
  @State pageSize: number = 10; // 每页显示10条记录
  @State inputPage: string = ''; // 用于存储输入的页码
  // 添加页码范围状态，用于存储计算结果
  @State pageRangeStart: number = 1;
  @State pageRangeEnd: number = 1;
  // 添加图表更新计数器
  @State updateCounter: number = 0;

  aboutToAppear() {
    // 检查是否为分组统计，根据shortLink的describe字段判断
    if (this.shortLink && this.shortLink.describe && this.shortLink.describe.includes('分组统计')) {
      this.isGroupStats = true;
    }

    // 默认查询最近7天的数据
    const end = new Date();
    const start = new Date();
    start.setDate(start.getDate() - 7);

    this.startDate = this.formatDate(start);
    this.endDate = this.formatDate(end);

    // 获取统计数据
    this.fetchStatsData();
  }

  // 格式化日期
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  // 格式化日期（添加时分秒）
  private formatDateTime(date: Date, isStart: boolean = true): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    // 开始时间设为当天 00:00:00，结束时间设为当天 23:59:59
    const time = isStart ? '00:00:00' : '23:59:59';
    return `${year}-${month}-${day} ${time}`;
  }

  // 获取统计数据
  private async fetchStatsData() {
    try {
      // 根据是否为分组统计选择不同的API
      const api = this.isGroupStats ? APIs.groupShortLinkStats : APIs.shortLinkStats;

      console.info(`[统计] 开始获取统计数据，API: ${api}, isGroupStats: ${this.isGroupStats}`);

      // 定义请求参数接口
      interface StatsRequestParams {
        gid: string;
        fullShortUrl?: string;
        startDate: string;
        endDate: string;
        size: number;
        count: number;
      }

      // 构建请求参数
      const params: StatsRequestParams = {
        gid: this.shortLink.gid,
        startDate: this.formatDateTime(new Date(this.startDate), true),
        endDate: this.formatDateTime(new Date(this.endDate), false),
        size: 10, // 分页大小
        count: 1  // 添加count参数
      };

      // 根据统计类型添加不同的参数
      if (!this.isGroupStats) {
        // 只有短链接统计需要fullShortUrl
        params.fullShortUrl = this.shortLink.fullShortUrl;
      }

      console.info(`[统计] 请求参数: ${JSON.stringify(params)}`);

      const res = await HttpUtils.get(api, params);
      console.info(`[统计] 响应结果: ${JSON.stringify(res)}`);

      if (res.code === '0') {
        // 先设置数据
        this.statsData = res.data;

        // 处理daily数据，确保count字段存在
        if (this.statsData?.daily) {
          for (let i = 0; i < this.statsData.daily.length; i++) {
            // 如果没有count字段，将pv值赋给count字段
            if (this.statsData.daily[i].count === undefined) {
              this.statsData.daily[i].count = this.statsData.daily[i].pv;
            }
          }
        }

        // 隐藏加载提示
        JhProgressHUD.hide();
        
        // 设置视图类型
        this.currentView = 'stats';
        
        // 更新计数器，触发图表更新
        this.updateCounter++;
        console.info(`[统计] 更新计数器，新值: ${this.updateCounter}, 有小时数据: ${this.statsData?.hourStats ? this.statsData.hourStats.length : 0}个`);
      } else {
        // 显示错误提示
        console.error(`[统计] 获取数据失败: ${res.message}`);
        JhProgressHUD.showError('获取统计数据失败');
      }
    } catch (error) {
      console.error('获取统计数据失败:', error);
      JhProgressHUD.showError('获取统计数据失败');
    }
  }

  // 获取访问记录数据
  private async fetchAccessRecords() {
    try {
      // 根据是否为分组统计选择不同的API
      const api = this.isGroupStats ? APIs.groupShortLinkStatsAccessRecord : APIs.shortLinkStatsAccessRecord;

      // 定义请求参数接口
      interface AccessRecordRequestParams {
        gid: string;
        fullShortUrl?: string;
        startDate: string;
        endDate: string;
        size: number;
        current: number;
        count: number;
      }

      // 构建请求参数
      const params: AccessRecordRequestParams = {
        gid: this.shortLink.gid,
        startDate: this.formatDateTime(new Date(this.startDate), true),
        endDate: this.formatDateTime(new Date(this.endDate), false),
        size: this.pageSize, // 每页显示条数
        current: this.currentPage, // 当前页码
        count: this.currentPage  // 当前页码，使用count字段
      };

      // 根据统计类型添加不同的参数
      if (!this.isGroupStats) {
        // 只有短链接统计需要fullShortUrl
        params.fullShortUrl = this.shortLink.fullShortUrl;
      }

      const res = await HttpUtils.get(api, params);
      if (res.code === '0') {
        this.accessRecords = res.data.records || [];
        this.totalPages = res.data.pages || 1;
        // 计算页码范围
        this.calculatePageRange();
        // 隐藏加载提示
        JhProgressHUD.hide();
        // 重新渲染页面
        this.currentView = 'record';
      } else {
        // 显示错误提示
        JhProgressHUD.showError('获取访问记录失败');
      }
    } catch (error) {
      console.error('获取访问记录失败:', error);
      JhProgressHUD.showError('获取访问记录失败');
    }
  }

  // 计算页码范围
  private calculatePageRange(): Array<number> {
    // 计算要显示的页码范围
    this.pageRangeStart = Math.max(1, this.currentPage - 2);
    this.pageRangeEnd = Math.min(this.totalPages, this.pageRangeStart + 4);

    // 调整pageRangeStart，确保显示5个页码（如果总页数足够）
    if (this.pageRangeEnd - this.pageRangeStart < 4 && this.totalPages >= 5) {
      this.pageRangeStart = Math.max(1, this.pageRangeEnd - 4);
    }

    // 返回页码数组
    const pageNumbers: Array<number> = [];
    for (let i = this.pageRangeStart; i <= this.pageRangeEnd; i++) {
      pageNumbers.push(i);
    }
    return pageNumbers;
  }

  build() {
    Stack() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
        .opacity(0.6)
        .onClick(() => {
          this.closeDrawer()
        })

      // 弹窗内容
      Column() {
        // 弹窗头部
        Column() {
          // 标题和关闭按钮行
          Row() {
            // 左侧标题和描述
            Column({ space: 4 }) {
              Text(this.shortLink.description || this.shortLink.describe || '暂无描述')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.textColor)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)

              Text(this.shortLink.domain + this.shortLink.shortUri)
                .fontSize(14)
                .fontColor(this.textColorSecondary)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            // 关闭按钮
            Button() {
              Text('×')
                .fontSize(24)
                .fontColor(this.textColorSecondary)
            }
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.closeDrawer()
            })
          }

          // 日期选择行
          Row() {
            Blank() // 添加空白占位，将日期选择推到右侧

            // 日期选择器和搜索按钮
            Row({ space: 8 }) {
              // 开始日期
              Row() {
                Text(this.startDate || '点击选择日期')
                  .fontSize(14)
                  .fontColor(this.startDate ? this.textColor : this.textColorSecondary)
              }
              .width(100)
              .height(32)
              .backgroundColor(this.themeColorLight)
              .borderRadius(4)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                CalendarPickerDialog.show({
                  selected: this.selectedStartDate || new Date(),
                  onAccept: (value: Date) => {
                    // 验证日期范围：开始日期不能晚于结束日期
                    if (this.endDate) {
                      // 使用年月日进行比较，而不是直接比较Date对象
                      const startDateStr = this.formatDate(value);
                      if (startDateStr > this.endDate) {
                        JhProgressHUD.showText('开始日期不能晚于结束日期');
                        return;
                      }
                    }

                    this.selectedStartDate = value;
                    this.startDate = this.formatDate(this.selectedStartDate);
                  }
                })
              })

              Text('至')
                .fontSize(14)
                .fontColor(this.textColor)

              // 结束日期
              Row() {
                Text(this.endDate || '点击选择日期')
                  .fontSize(14)
                  .fontColor(this.endDate ? this.textColor : this.textColorSecondary)
              }
              .width(100)
              .height(32)
              .backgroundColor(this.themeColorLight)
              .borderRadius(4)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                CalendarPickerDialog.show({
                  selected: this.selectedEndDate || new Date(),
                  onAccept: (value: Date) => {
                    // 验证日期范围：结束日期不能早于开始日期
                    if (this.startDate) {
                      // 使用年月日进行比较，而不是直接比较Date对象
                      const endDateStr = this.formatDate(value);
                      if (endDateStr < this.startDate) {
                        JhProgressHUD.showText('结束日期不能早于开始日期');
                        return;
                      }
                    }

                    this.selectedEndDate = value;
                    this.endDate = this.formatDate(this.selectedEndDate);
                  }
                })
              })

              // 搜索按钮
              Button() {
                Row({ space: 4 }) {
                  Image($r('app.media.select'))
                    .width(16)
                    .height(16)
                    .objectFit(ImageFit.Contain)
                  Text('搜索')
                    .fontSize(14)
                    .fontColor(Color.White)
                }
              }
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor(this.themeColor)
              .borderRadius(4)
              .height(32)
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                // 重置页码为1，确保从第一页开始查询
                this.currentPage = 1;
                // 显示加载提示
                JhProgressHUD.showLoadingText('正在查询...');
                console.info(`[统计] 点击搜索按钮，日期范围: ${this.startDate} 至 ${this.endDate}`);
                
                // 先查询数据，不依赖计数器更新
                if (this.currentView === 'stats') {
                  this.fetchStatsData();
                } else {
                  this.fetchAccessRecords();
                }
              })
            }
          }
          .width('100%')
          .margin({ top: 12 })
          .justifyContent(FlexAlign.End)
          .padding({ right: 0 })

          // 添加数据视图切换行
          Row({ space: 20 }) {
            // 访问数据按钮
            Text('访问数据')
              .fontSize(16)
              .fontColor(this.currentView === 'stats' ? this.themeColor : this.textColorSecondary)
              .fontWeight(this.currentView === 'stats' ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                if (this.currentView !== 'stats') {
                  this.currentView = 'stats';
                  // 切换到统计页面时，获取数据并更新图表
                  this.fetchStatsData();
                } else {
                  // 如果已经是统计页面，递增更新计数器触发图表更新
                  this.updateCounter++;
                  console.info(`[统计] 当前已是统计页面，递增更新计数器: ${this.updateCounter}`);
                }
              })

            // 访问记录按钮
            Text('访问记录')
              .fontSize(16)
              .fontColor(this.currentView === 'record' ? this.themeColor : this.textColorSecondary)
              .fontWeight(this.currentView === 'record' ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                if (this.currentView !== 'record') {
                  this.currentView = 'record';
                  this.fetchAccessRecords();
                }
              })

            Blank() // 空白占位，让按钮靠左显示
          }
          .width('100%')
          .margin({ top: 16 })
          .padding({ left: 0 })
          .justifyContent(FlexAlign.Start)
        }
        .width('100%')
        .padding({
          left: 24,
          right: 24,
          top: 30,
          bottom: 24
        })
        .backgroundColor(Color.White) // 添加白色背景
        .border({ width: { bottom: 1 }, color: this.themeBorderColor })

        // 内容区域
        Scroll() {
          Column() {
            if (this.currentView === 'stats') {
              // 统计数据视图

              // 访问曲线
              Column() {
                TitleContent({ title: '访问曲线' }) {
                  Row() {
                    // 左侧统计数据
                    Column() {
                      Row() {
                        Text('访问次数')
                          .fontSize(14)
                          .fontColor(this.textColorSecondary)
                        Text(this.statsData?.pv?.toString() || '0')
                          .fontSize(14)
                          .fontColor(this.textColor)
                          .margin({ left: 8 })
                      }
                      .margin({ bottom: 20, top: -110 })
                      .width('100%')

                      Row() {
                        Text('访问人数')
                          .fontSize(14)
                          .fontColor(this.textColorSecondary)
                        Text(this.statsData?.uv?.toString() || '0')
                          .fontSize(14)
                          .fontColor(this.textColor)
                          .margin({ left: 8 })
                      }
                      .margin({ bottom: 20 })
                      .width('100%')

                      Row() {
                        Text('访问IP数')
                          .fontSize(14)
                          .fontColor(this.textColorSecondary)
                        Text(this.statsData?.uip?.toString() || '0')
                          .fontSize(14)
                          .fontColor(this.textColor)
                          .margin({ left: 8 })
                      }
                      .margin({ bottom: 20 })
                      .width('100%')
                    }
                    .width('15%')
                    .padding({ left: 15 })

                    DailyChart({
                      statsData: this.statsData || new ShortLinkStatsData(),
                      startDate: this.startDate,
                      endDate: this.endDate,
                      updateCounter: this.updateCounter
                    })
                    .width('85%')
                    .id('dailyChart')
                  }
                  .width('100%')
                }
              }
              .margin({ left: 25, right: 25, bottom: 16 })

              // 添加地图组件
              Column() {
                MapChart({
                  localeCnts: this.statsData?.localeCnStats || [],
                  updateCounter: this.updateCounter
                })
              }
              .margin({ left: 25, right: 25, bottom: 16 })

              // 24小时分布
              Column() {
                TitleContent({ title: '24小时分布' }) {
                  HoursChart({
                    hourStats: this.statsData?.hourStats || new Array(24).fill(0),
                    updateCounter: this.updateCounter
                  })
                }
              }
              .margin({ left: 25, right: 25, bottom: 16 })

              // 高频访问IP和一周分布（并排显示）
              Row() {
                // 高频访问IP列表
                Column() {
                  TitleContent({ title: '高频访问IP' }) {
                    HighFreqIpList({
                      ipStats: this.statsData?.topIpStats || []
                    })
                      .height(300)
                  }
                }
                .width('30%')
                .margin({ left: 25 })

                // 一周分布图表
                Column() {
                  TitleContent({ title: '一周分布' }) {
                    WeekChart({
                      weekdayStats: this.statsData?.weekdayStats || new Array(7).fill(0),
                      updateCounter: this.updateCounter
                    })
                  }
                }
                .width('65%')
              }
              .width('100%')
              .padding(0)
              .margin({ bottom: 16 })

              // 访客类型和访问网络（并排显示）
              Row() {
                // 访客类型统计 - 只在非分组统计时显示
                if (!this.isGroupStats) {
                  Column() {
                    TitleContent({ title: '访客类型' }) {
                      UvTypeStatsList({
                        uvTypeStats: this.statsData?.uvTypeStats || []
                      })
                    }
                  }
                  .width('47%')
                  .margin({ left: 25 })
                }

                // 访问网络统计
                if (!this.isGroupStats) {
                  Column() {
                    TitleContent({ title: '访问网络' }) {
                      NetworkStatsList({
                        networkStats: this.statsData?.networkStats || []
                      })
                    }
                  }
                  .width('47%')
                  .margin({ left: 10 })
                }
              }
              .width('100%')
              .margin({ bottom: this.isGroupStats ? 0 : 16 })
              .height(this.isGroupStats ? 0 : 'auto')

              // 访问设备（分组统计时与访问网络并排显示）
              Row() {
                // 访问设备统计
                Column() {
                  TitleContent({ title: '访问设备' }) {
                    DeviceStatsList({
                      deviceStats: this.statsData?.deviceStats || []
                    })
                  }
                }
                .width('47%')
                .margin({ left: 25 })

                // 分组统计时，访问网络显示在这里
                if (this.isGroupStats) {
                  Column() {
                    TitleContent({ title: '访问网络' }) {
                      NetworkStatsList({
                        networkStats: this.statsData?.networkStats || []
                      })
                    }
                  }
                  .width('47%')
                  .margin({ left: 10 })
                } else {
                  // 非分组统计时，右侧空白占位
                  Column() {
                  }
                  .width('47%')
                  .margin({ left: 10 })
                }
              }
              .width('100%')
              .margin({ bottom: 40 })
            } else {
              // 访问记录视图
              Column() {
                // 访问记录内容
                Column() {
                  // 表头
                  Row() {
                    Text('访问时间')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.textColor)
                      .width('22%')
                      .textAlign(TextAlign.Center)

                    Text('访问IP')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.textColor)
                      .width('18%')
                      .textAlign(TextAlign.Center)

                    Text('访客地区')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.textColor)
                      .width('32%')
                      .textAlign(TextAlign.Center)

                    Text('设备信息')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.textColor)
                      .width('18%')
                      .textAlign(TextAlign.Center)

                    Text('访客类型')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.textColor)
                      .width('10%')
                      .textAlign(TextAlign.Center)
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor(Color.White)
                  .borderRadius({ topLeft: 8, topRight: 8 })
                  .zIndex(2) // 确保表头在顶部且总是可见

                  // 表格内容 - 使用Scroll使内容可滚动
                  Scroll() {
                    Column() {
                      List() {
                        ForEach(this.accessRecords, (item: AccessRecord) => {
                          ListItem() {
                            Row() {
                              Text(item.createTime || '-')
                                .fontSize(14)
                                .fontColor(this.textColor)
                                .width('22%')
                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                                .maxLines(1)
                                .textAlign(TextAlign.Center)

                              Text(item.ip || '-')
                                .fontSize(14)
                                .fontColor(this.textColor)
                                .width('18%')
                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                                .maxLines(1)
                                .textAlign(TextAlign.Center)

                              Text(this.formatLocale(item))
                                .fontSize(14)
                                .fontColor(this.textColor)
                                .width('32%')
                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                                .maxLines(1)
                                .textAlign(TextAlign.Center)

                              // 设备信息（图标）
                              Row({ space: 4 }) {
                                // 操作系统图标
                                if (item.os) {
                                  Column() {
                                    Image(IconMap.getOsIcon(item.os) || $r('app.media.windows'))
                                      .width(20)
                                      .height(20)
                                      .objectFit(ImageFit.Contain)
                                  }
                                }

                                // 浏览器图标
                                if (item.browser) {
                                  Column() {
                                    Image(IconMap.getBrowserIcon(item.browser) || $r('app.media.Chrome'))
                                      .width(20)
                                      .height(20)
                                      .objectFit(ImageFit.Contain)
                                  }
                                }

                                // 网络类型图标
                                if (item.network) {
                                  Column() {
                                    Image(IconMap.getNetworkIcon(item.network) || $r('app.media.WIFI'))
                                      .width(20)
                                      .height(20)
                                      .objectFit(ImageFit.Contain)
                                  }
                                }

                                // 设备类型图标
                                if (item.device) {
                                  Column() {
                                    Image(IconMap.getDeviceIcon(item.device) || $r('app.media.computer'))
                                      .width(20)
                                      .height(20)
                                      .objectFit(ImageFit.Contain)
                                  }
                                }
                              }
                              .width('18%')
                              .justifyContent(FlexAlign.Center)
                              .borderRadius(4)
                              .padding(4)
                              .onClick(() => {
                                const deviceInfo = `${item.os || '-'} / ${item.browser || '-'} / ${item.network ||
                                  '-'} / ${item.device || '-'}`;
                                JhProgressHUD.showText(deviceInfo);
                              })

                              Text(item.user === 'newUser' ? '新访客' : '老访客')
                                .fontSize(14)
                                .fontColor(this.textColor)
                                .width('10%')
                                .textOverflow({ overflow: TextOverflow.Ellipsis })
                                .maxLines(1)
                                .textAlign(TextAlign.Center)
                            }
                            .width('100%')
                            .padding(16)
                            .borderRadius(0)
                          }
                          .backgroundColor(Color.White)
                          .border({
                            width: { top: 1 },
                            color: this.themeBorderColor,
                            style: BorderStyle.Solid
                          })
                        })
                      }
                      .width('100%')

                      // 无数据提示
                      if (this.accessRecords.length === 0) {
                        Column() {
                          Text('暂无访问记录')
                            .fontSize(16)
                            .fontColor(this.textColorSecondary)
                        }
                        .width('100%')
                        .height(100)
                        .backgroundColor(Color.White)
                        .justifyContent(FlexAlign.Center)
                        .border({
                          width: { top: 1 },
                          color: this.themeBorderColor,
                          style: BorderStyle.Solid
                        })
                      }
                    }
                    .width('100%')
                  }
                  .scrollBar(BarState.Auto)
                  .scrollBarColor(Color.Gray)
                  .scrollBarWidth(4)
                  .edgeEffect(EdgeEffect.Spring)
                  .width('100%')
                  .height('calc(100% - 170px)') // 调整高度，留出表头和分页的空间，考虑分页底部增加的间距

                  // 分页控制
                  Row() {
                    // 所有分页元素放在同一个Row中
                    Row({ space: 8 }) {
                      // 上一页按钮
                      Row() {
                        Text('<')
                          .fontSize(14)
                          .fontColor(this.currentPage > 1 ? this.themeColor : this.textColorSecondary)
                      }
                      .padding(8)
                      .backgroundColor(this.themeColorLight)
                      .borderRadius(4)
                      .enabled(this.currentPage > 1)
                      .onClick(() => {
                        if (this.currentPage > 1) {
                          this.currentPage--;
                          this.fetchAccessRecords();
                        }
                      })

                      // 页码按钮
                      ForEach(this.calculatePageRange(), (page: number) => {
                        Row() {
                          Text(`${page}`)
                            .fontSize(14)
                            .fontColor(page === this.currentPage ? Color.White : this.themeColor)
                        }
                        .padding(8)
                        .backgroundColor(page === this.currentPage ? this.themeColor : this.themeColorLight)
                        .borderRadius(4)
                        .onClick(() => {
                          if (page !== this.currentPage) {
                            this.currentPage = page;
                            this.fetchAccessRecords();
                          }
                        })
                      })

                      // 下一页按钮
                      Row() {
                        Text('>')
                          .fontSize(14)
                          .fontColor(this.currentPage < this.totalPages ? this.themeColor : this.textColorSecondary)
                      }
                      .padding(8)
                      .backgroundColor(this.themeColorLight)
                      .borderRadius(4)
                      .enabled(this.currentPage < this.totalPages)
                      .onClick(() => {
                        if (this.currentPage < this.totalPages) {
                          this.currentPage++;
                          this.fetchAccessRecords();
                        }
                      })

                      // 页数信息
                      Text(`${this.currentPage}/${this.totalPages}页`)
                        .fontSize(14)
                        .fontColor(this.textColor)
                        .margin({ left: 8, right: 8 })

                      // 跳转页码输入
                      Text('跳至')
                        .fontSize(14)
                        .fontColor(this.textColor)

                      TextInput({ text: this.inputPage })
                        .width(40)
                        .height(32)
                        .backgroundColor(this.themeColorLight)
                        .borderRadius(4)
                        .type(InputType.Number)
                        .onChange((value: string) => {
                          this.inputPage = value;
                        })

                      Text('页')
                        .fontSize(14)
                        .fontColor(this.textColor)

                      Button('确定')
                        .fontSize(14)
                        .fontColor(Color.White)
                        .backgroundColor(this.themeColor)
                        .borderRadius(4)
                        .height(32)
                        .onClick(() => {
                          let pageNum = 0;
                          try {
                            pageNum = parseInt(this.inputPage.trim());
                          } catch (e) {
                            pageNum = 0;
                          }

                          if (pageNum >= 1 && pageNum <= this.totalPages) {
                            this.currentPage = pageNum;
                            this.fetchAccessRecords();
                            this.inputPage = '';
                          } else {
                            JhProgressHUD.showText('请输入有效页码');
                          }
                        })
                    }
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Center)
                  .padding({
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 20
                  })
                  .backgroundColor(Color.White)
                  .borderRadius({ bottomLeft: 8, bottomRight: 8 })
                  .shadow({ radius: 2, color: this.themeBorderColor, offsetY: 1 })
                  .zIndex(2) // 确保分页工具始终可见
                }
                .width('100%')
                .height('100%')
                .backgroundColor(Color.White)
                .borderRadius(8)
              }
              .margin({ left: 25, right: 25, bottom: 40 })
            }
          }
        }
        .layoutWeight(1)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .backgroundColor('#F2F3F5') // 添加浅灰色背景
      }
    }
    .width(1000)
    .height('100%')
    .backgroundColor(Color.White)
    .position({ x: '100%' }) // 设置初始位置在屏幕右侧
    .translate({ x: -this.statsDrawerWidth }) // 向左移动显示
    .animation({
      duration: 250,
      curve: Curve.EaseOut
    })
  }

  // 关闭抽屉
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

  // 格式化访问记录中的地区
  private formatLocale(item: AccessRecord): string {
    if (item.locale) {
      const parts = item.locale.split(',');
      if (parts.length > 1) {
        return parts[0].trim() + ', ' + parts[1].trim();
      }
    }
    return item.locale || '-';
  }
}
