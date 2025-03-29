///  APIs.ets
///
///  Created by iotjin on 2024/08/08.
///  description: api管理

export class APIs {
  // url 前缀
  static readonly apiPrefix: string = '172.24.192.1:8003'


  //=====================用户模块=============================
  //注册接口
  static readonly register: string = '/short-link/admin/v1/user'

  //退出登录
  static readonly logout: string = '/short-link/admin/v1/user/logout'

  // 分页查询用户列表
  static readonly pageUserList: string = '/short-link/admin/v1/user/page'

  // 添加用户
  static readonly addUser: string = '/short-link/admin/v1/user/add'

  // 编辑用户
  static readonly editUser: string = '/short-link/admin/v1/user/edit'

  // 删除用户
  static readonly deleteUser: string = '/short-link/admin/v1/user/delete'

  static readonly getUserByUsername: string = '/short-link/admin/v1/user/' // 需要在后面加上username
  static readonly getActualUserByUsername: string = '/short-link/admin/v1/actual/user/' // 需要在后面加上username
  static readonly hasUsername: string = '/short-link/admin/v1/user/has-username'
  static readonly updateUser: string = '/short-link/admin/v1/user'
  static readonly userLogin: string = '/short-link/admin/v1/user/login'
  static readonly checkLogin: string = '/short-link/admin/v1/user/check-login'

  //校验旧密码是否正确
  static readonly checkPassword: string = '/short-link/admin/v1/checkPassword'


  //=====================分组模块=============================
  // 新增短链接分组
  static readonly saveGroup: string = '/short-link/admin/v1/group'

  // 查询短链接分组集合
  static readonly listGroup: string = '/short-link/admin/v1/group'

  // 修改短链接分组名称
  static readonly updateGroup: string = '/short-link/admin/v1/group'

  // 删除短链接分组
  static readonly deleteGroup: string = '/short-link/admin/v1/group'

  // 排序短链接分组
  static readonly sortGroup: string = '/short-link/admin/v1/group/sort'

  // 分页查询短链接
  static readonly pageShortLink: string = '/short-link/v1/page';



  //=====================短链接模块=============================
  // 创建短链接
  static readonly createShortLink: string = '/short-link/v1/create'

  // 批量创建短链接
  static readonly batchCreateShortLink: string = '/short-link/v1/create/batch'

  // 修改短链接
  static readonly updateShortLink: string = '/short-link/v1/update'

  // 查询短链接分组内数量
  static readonly listGroupShortLinkCount: string = '/short-link/v1/count'

  // 短链接跳转原始链接
  static readonly restoreUrl: string = '/{short-uri}'  // 需要替换 {short-uri} 为实际的短链接


  //=====================回收站模块=============================
  // 保存到回收站
  static readonly saveRecycleBin: string = '/short-link/v1/recycle-bin/save'

  // 分页查询回收站短链接
  static readonly pageRecycleBin: string = '/short-link/v1/recycle-bin/page'

  // 恢复短链接
  static readonly recoverRecycleBin: string = '/short-link/v1/recycle-bin/recover'

  // 移除短链接
  static readonly removeRecycleBin: string = '/short-link/v1/recycle-bin/remove'


  //=====================统计模块=============================
  // 访问单个短链接指定时间内监控数据
  static readonly shortLinkStats: string = '/short-link/admin/v1/stats';

  // 访问分组短链接指定时间内监控数据
  static readonly groupShortLinkStats: string = '/short-link/v1/stats/group';

  // 访问单个短链接指定时间内访问记录监控数据
  static readonly shortLinkStatsAccessRecord: string = '/short-link/v1/stats/access-record';

  // 访问分组短链接指定时间内访问记录监控数据
  static readonly groupShortLinkStatsAccessRecord: string = '/short-link/v1/stats/access-record/group';


  //=====================其它=============================
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