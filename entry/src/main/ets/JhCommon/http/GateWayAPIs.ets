
export class GateWayAPIs {
  // url 前缀
  static readonly apiPrefix: string = '172.30.176.1:8003'


  //=====================用户模块=============================
  // 登录接口
  static readonly login: string = '/short-link/admin/v1/user/login'



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
}