// 添加统计数据类型定义
export class DailyStats {
  date: string = '';
  pv: number = 0;
  uv: number = 0;
  uip: number = 0;
  count: number = 0;
}

export class CountStats {
  cnt: number = 0;
  locale: string = '';
  ratio: number = 0.0;
}

export class TopIpStats {
  ip: string = '';
  cnt: number = 0;
  ratio: number = 0.0;
}

export class BrowserStats {
  browser: string = '';
  cnt: number = 0;
  ratio: number = 0.0;
}

export class OsStats {
  os: string = '';
  cnt: number = 0;
  ratio: number = 0.0;
}

export class UvTypeStats {
  uvType: string = '';
  cnt: number = 0;
  ratio: number = 0.0;
}

export class DeviceStats {
  device: string = '';
  cnt: number = 0;
  ratio: number = 0.0;
}

export class NetworkStats {
  network: string = '';
  cnt: number = 0;
  ratio: number = 0.0;
}

export class ShortLinkStatsData {
  pv: number = 0; // 访问量
  uv: number = 0; // 独立访客数
  uip: number = 0; // 独立IP数
  daily: Array<DailyStats> = [];
  localeCnStats: Array<CountStats> = [];
  hourStats: Array<number> = [];
  topIpStats: Array<TopIpStats> = [];
  weekdayStats: Array<number> = [];
  browserStats: Array<BrowserStats> = [];
  osStats: Array<OsStats> = [];
  uvTypeStats: Array<UvTypeStats> = [];
  deviceStats: Array<DeviceStats> = [];
  networkStats: Array<NetworkStats> = [];
}


// 定义地图配置相关的类型
export class TooltipConfig {
  trigger: string = '';
  formatter: string = '';
}

export class InRangeConfig {
  color: Array<string> = [];
}

export class VisualMapConfig {
  min: number = 0;
  max: number = 0;
  text: Array<string> = [];
  realtime: boolean = false;
  calculable: boolean = false;
  inRange: InRangeConfig = new InRangeConfig();
}

export class LabelConfig {
  show: boolean = false;
}

export class EmphasisConfig {
  label: LabelConfig = new LabelConfig();
}

// 添加地图数据点类型
export class MapDataPoint {
  name: string = '';
  value: number = 0;
}

export class SeriesConfig {
  name: string = '';
  type: string = '';
  map: string = '';
  roam: boolean = false;
  emphasis: EmphasisConfig = new EmphasisConfig();
  data: Array<MapDataPoint> = [];
}

export class MapOption {
  tooltip: TooltipConfig = new TooltipConfig();
  visualMap: VisualMapConfig = new VisualMapConfig();
  series: Array<SeriesConfig> = [];
}


// 添加访问记录数据类型定义
export  interface AccessRecord {
  createTime?: string;
  ip?: string;
  country?: string;
  province?: string;
  city?: string;
  os?: string;
  browser?: string;
  network?: string;
  device?: string;
  user?: string;
  locale?: string
}
