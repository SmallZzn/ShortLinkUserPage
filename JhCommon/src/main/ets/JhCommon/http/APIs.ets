///  APIs.ets
///
///  Created by iotjin on 2024/08/08.
///  description: api管理

export class APIs {
  /// url 前缀
  static readonly apiPrefix: string = 'https://console-mock.apipost.cn/mock/e7a66e3e-1b07-4902-9beb-366dd35ae67d/v1/api'
  /// 登录接口
  static readonly login: string = '/mock/login'
  /// 刷新token
  static readonly refreshToken: string = '/mock/refreshToken'
  /// 获取分页数据
  static readonly getPage: string = '/mock/pages'
  /// 获取分页分组数据
  static readonly getGroupPage: string = '/mock/groupPages'
  /// 获取固定数据
  static readonly getSimpleDictList: string = '/mock/simpleDictList'
  /// 获取固定数据
  static readonly getSimpleDict: string = '/mock/dict'
  /// 微信朋友圈
  static readonly getFriendsCircleList: string = '/mock/wx/moments'
  /// 用户相关接口
  static readonly getUserByUsername: string = '/api/short-url/admin/v1/user/' // 需要在后面加上username
  static readonly getActualUserByUsername: string = '/api/short-url/admin/v1/actual/user/' // 需要在后面加上username
  static readonly hasUsername: string = '/api/short-url/admin/v1/user/has-username'
  static readonly register: string = '/api/short-url/admin/v1/user'
  static readonly updateUser: string = '/api/short-url/admin/v1/user'
  static readonly userLogin: string = '/api/short-url/admin/v1/user/login'
  static readonly checkLogin: string = '/api/short-url/admin/v1/user/check-login'
  static readonly logout: string = '/api/short-url/admin/v1/user/logout'
}