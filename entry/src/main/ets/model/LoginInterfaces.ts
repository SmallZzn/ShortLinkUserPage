// 短链接
export interface ShortLink {
  id: string;
  gid: string;
  originUrl: string;
  title: string;
  description?: string;
  validityType: string;
  validityTime?: string;
  domain: string;       // 域名
  shortUri: string;     // 短链接
  fullShortUrl: string; // 完整短链接
  validDateType: number; // 有效期类型 0：永久有效 1：自定义
  validDate?: string;   // 有效期
  createTime: string;   // 创建时间
  describe?: string;    // 描述
  favicon?: string;     // 网站标识
  totalPv: number;      // 历史PV
  todayPv: number;      // 今日PV
  totalUv: number;      // 历史UV
  todayUv: number;      // 今日UV
  totalUip: number;     // 历史UIP
  todayUip: number;     // 今日UIP
}

// 分组
export interface Group {
  gid: string;      // 分组标识
  name: string;     // 分组名称
  sortOrder?: number;  // 分组排序
  shortLinkCount?: number;  // 分组下短链接数量
}

// 登录校验参数
export interface CheckLoginParams {
  username: string;
  token: string;
}

// 下拉选择器选项
export interface SelectOption {
  value: string;
  text: string;
}

// 分组响应数据接口
export interface GroupResponse {
  gid: string;
  name: string;
  username?: string;
  sortOrder?: number;
  createTime?: string;
  updateTime?: string;
  shortLinkCount?: number;  // 添加分组下短链接数量字段
}

// 退出登录参数接口
export interface LogoutParams {
  username: string;
  token: string;
}

// 菜单项接口
export interface MenuItem {
  title: string;
  onClick: () => void;
}

// 菜单选项接口
export interface UserMenuItem {
  value: string;
  text: string;
}

// 分组数量信息接口
export interface GroupCountInfo {
  gid: string;
  shortLinkCount: number;
}

// 分组排序参数接口
export interface SortGroupParam {
  gid: string;
  sortOrder: number;
}

// 编辑弹窗配置接口
export interface EditDialogConfig {
  builder: object;
  customStyle: boolean;
  alignment: 'Top' | 'Center' | 'Bottom';  // 使用字符串字面量类型
}

// 编辑弹窗参数接口
export interface EditDialogParams {
  shortLinkId: string;
  originUrl: string;
  shortLinkTitle: string;
  shortLinkDesc: string;
  shortLinkGid: string;
  shortLinkValidityType: string;
  shortLinkValidityTime: string;
  groups: Group[];
  username: string;
  controller?: object;  // 使用通用对象类型
  onSuccess: () => void;
}
