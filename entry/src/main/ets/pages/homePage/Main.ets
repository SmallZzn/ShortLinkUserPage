import { promptAction, router } from '@kit.ArkUI';
import {
  ShortLink,
  Group,
  CheckLoginParams,
  GroupResponse,
  LogoutParams,
  UserMenuItem,
  SortGroupParam,
} from '../../model/LoginInterfaces';
import { AddShortLink } from './AddPopup';
import { AddBatchLinks } from './BatchAddPopup';
import { EditShortLink } from './EditPopup';
import { HttpUtils } from '../../JhCommon/http/HttpUtils';
import { APIs } from '../../JhCommon/http/APIs';
import { JhAESPreferencesUtils } from '../../JhCommon/utils/JhPreferencesUtils';
import { JhProgressHUD } from '../../JhCommon/components/JhProgressHUD';
import clipboard from '@ohos.pasteboard';
import { ShortLinkStats } from './ShortLinkStats';
import { UserInfoPopup } from './UserInfo';

@Entry
@Component
struct Main {
  // 添加用户相关状态
  @State username: string = ''; // 添加用户名状态
  // 使用接口声明数组
  @State shortLinks: ShortLink[] = [];
  @State groups: Group[] = [];
  @State currentGroup: string = '默认分组';
  @State showAddGroupModal: boolean = false; // 控制新增分组弹窗显示
  @State showAddLinkModal: boolean = false; // 控制新增短链接弹窗显示
  @State newGroupName: string = ''; // 新增分组名称
  @State newLinkUrl: string = ''; // 新增短链接URL
  @State newLinkTitle: string = ''; // 新增短链接标题
  @State searchText: string = ''
  @State currentPage: number = 1; // 当前页码
  @State pageSize: number = 6; // 每页显示的短链接数量
  @State jumpToPage: string = ''; // 跳转到指定页数
  @State isNightMode: boolean = false; // 夜间模式状态
  @State selectedValidity: string = '永久'; // 有效期选择
  @State customDate: string = ''; // 自定义日期
  @State selectedGroup: string = '默认分组'; // 选中分组
  @State newLinkDescription: string = ''; // 描述信息
  @State showGroupPicker: boolean = false
  @State hoverIndex: number = -1
  @State showDatePicker: boolean = false
  @State selectedDate: string = ''
  @State isDrawerOpening: boolean = false; // 新建短链弹窗状态
  @State drawerWidth: number = 0; // 新建短链弹窗宽度
  @State isBatchDrawerOpening: boolean = false;
  @State batchDrawerWidth: number = 0;
  // 更新主题色常量
  readonly themeColor: string = '#4080FF' // 主题蓝色
  readonly themeColorLight: string = '#F2F3F5' // 浅色背景
  readonly pageBgColor: string = '#FFFFFF' // 页面背景色改为白色
  readonly textColor: string = '#1D2129' // 主要文字颜色
  readonly textColorSecondary: string = '#86909C' // 次要文字颜色
  readonly themeBorderColor: string = '#E5E6EB' // 边框颜色
  readonly headerBgColor: string = '#FFFFFF' // 头部背景色
  // 定义表头数据类型
  @State tableHeaders: string[] = ['短链接信息', '短链接', '访问次数', '访问人数', 'IP数', '操作']
  @State showUserMenu: boolean = false; // 控制用户菜单显示
  @State hoveredItemIndex: number = -1; // 添加悬停项的索引状态
  @State selectedUserMenuIndex: number = 0; // 添加选中索引状态
  @State showLogoutMask: boolean = false;
  @State shortLinkCount: number = 0;
  @State showAddGroupMask: boolean = false; // 控制添加分组遮罩层
  @State inputGroupName: string = '';
  @State showInputDialog: boolean = false;
  @State isDragging: boolean = false;
  @State draggedGroup: Group | null = null;
  @State draggedIndex: number = -1;
  @State itemOpacity: number = 1;
  @State dragY: number = 0;
  @State dragStartY: number = 0;
  @State dragOffsetY: number = 0;
  @State currentTouchEvent: TouchEvent | null = null;
  @State indicatorPosition: number = -1; // 指示器位置
  @State lastOffset: number = 0; // 记录上次的偏移量
  private lastSwapTime: number = 0; // 记录上次交换的时间
  @State scaleValue: number = 1.0;
  @State elevation: number = 0;
  @State targetIndex: number | undefined = undefined;
  @State shortLinkId: string = '';
  @State originUrl: string = '';
  @State title: string = '';
  @State description: string = '';
  @State gid: string = '';
  @State validityType: string = '';
  @State validityTime: string = '';
  // 添加当前编辑的短链接状态
  @State currentEditLink: ShortLink | null = null;
  // 添加统计抽屉状态
  @State isStatsDrawerOpening: boolean = false;
  @State statsDrawerWidth: number = 0;
  @State isAddDrawerOpening: boolean = false; // 新建短链弹窗状态
  @State addDrawerWidth: number = 0; // 新建短链弹窗宽度
  @State addLinkUrl: string = ''; // 新建短链URL
  @State addLinkDescription: string = ''; // 新建短链描述
  @State addSelectedGroup: string = '默认分组'; // 新建短链选中分组
  @State addSelectedValidity: string = '永久'; // 新建短链有效期
  @State addCustomDate: string = ''; // 新建短链自定义日期
  @State isRecycleBin: boolean = false; // 新增回收站状态
  @State isEditDrawerOpening: boolean = false; // 编辑抽屉状态
  @State editDrawerWidth: number = 0; // 编辑抽屉宽度
  // 添加用户信息弹窗状态
  @State isUserInfoDrawerOpening: boolean = false;
  @State userInfoDrawerWidth: number = 0;
  // 在class Main的State部分添加一个新的状态变量来跟踪当前显示的分组菜单
  @State showGroupMenuForGid: string = ''; // 用于跟踪当前显示分组菜单的gid
  // 在State部分添加新的状态变量
  @State showEditGroupMask: boolean = false; // 控制编辑分组遮罩层
  @State showEditGroupDialog: boolean = false; // 控制编辑分组对话框
  @State editingGroup: Group | null = null; // 当前正在编辑的分组
  @State editGroupName: string = ''; // 编辑后的分组名称

  aboutToAppear() {
    // 获取路由参数中的用户名
    const params = router.getParams() as Record<string, string>;
    if (params?.username !== undefined) {
      this.username = params.username;
      console.info('获取到用户名:', this.username);
    }

    // 获取UI上下文并初始化JhProgressHUD
    let uiContext: UIContext = this.getUIContext() as UIContext;
    JhProgressHUD.initUIConfig(uiContext);

    // 初始化完成后再检查登录状态
    this.checkLoginStatus();
  }

  // 检查登录状态
  private async checkLoginStatus() {
    try {
      console.info('开始检查登录状态');
      // 优先使用路由传递的用户名，如果没有则从存储中获取
      const storedUsername = JhAESPreferencesUtils.getString("username") || '';
      const username: string = this.username || storedUsername;
      const token: string = JhAESPreferencesUtils.getString("token") || '';

      console.info('获取到存储的用户信息:', username, token);

      if (!username || !token) {
        console.info('未找到登录信息，跳转到登录页');
        this.redirectToLogin();
        return;
      }

      // 更新用户名状态
      this.username = username;

      // 发送检查登录状态的请求
      const params: CheckLoginParams = {
        username: username,
        token: token
      };

      console.info('发送登录检查请求:', params);
      const checkLoginRes = await HttpUtils.get(APIs.checkLogin, params, "检查是否登录...");
      console.info('登录检查响应:', JSON.stringify(checkLoginRes));

      if (checkLoginRes.code === '0' && checkLoginRes.data) {
        console.info('登录状态有效');
        JhAESPreferencesUtils.saveString('username', this.username);
        await this.fetchGroupList();
      } else {
        console.info('登录状态无效');
        JhProgressHUD.showError('登录已过期，请重新登录');
        this.redirectToLogin();
      }
    } catch (error) {
      console.error('检查登录状态失败:', error);
      JhProgressHUD.showText('网络异常，请稍后重试');
      this.redirectToLogin();
    }
  }

  // 获取分组列表
  private async fetchGroupList() {
    try {
      console.info('开始获取分组列表');

      const headers: Record<string, string> = {
        'username': encodeURIComponent(this.username)
      };

      const res = await HttpUtils.get(APIs.listGroup, undefined, "", headers);
      console.log('获取分组列表返回数据：', JSON.stringify(res));

      if (res.code === '0') {
        // 更新分组列表，反转顺序
        const groupData = res.data as GroupResponse[];
        this.groups = groupData.reverse().map((item: GroupResponse): Group => ({
          gid: item.gid,
          name: item.name,
          sortOrder: item.sortOrder,
          shortLinkCount: item.shortLinkCount
        }));

        // 如果有分组，设置当前选中的分组为第一个，并查询该分组的短链接
        if (this.groups.length > 0) {
          this.currentGroup = this.groups[0].name;
          // 查询第一个分组的短链接
          await this.fetchShortLinksByGroup(this.groups[0].gid);
        }

        console.info('获取分组列表成功:', this.groups);
      } else {
        JhProgressHUD.showText('获取分组列表失败');
      }
    } catch (error) {
      console.error('获取分组列表失败:', error);
      JhProgressHUD.showText('获取分组列表失败');
    }
  }

  // 跳转到登录页
  private redirectToLogin() {
    // 显示提示信息

    // 3秒后跳转
    setTimeout(() => {
      router.replaceUrl({ url: 'pages/loginPage/Login' });
    }, 3000);
  }

  // 获取当前页的短链接数据
  getCurrentPageData(): ShortLink[] {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = startIndex + this.pageSize;
    return this.shortLinks
      .filter(item => item.gid === this.currentGroup)
      .slice(startIndex, endIndex);
  }

  build() {
    Stack() {
      Column() {
        Stack() {
          Column() {
            // 顶部导航栏
            Row() {
              Text('短链接服务平台')
                .fontSize(25)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.textColor)

              Blank()

              // 用户信息区域
              Row({ space: 8 }) {
                Text(this.username)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.textColor)
              }
              .alignItems(VerticalAlign.Center)
              .bindPopup(this.showUserMenu, {
                builder: this.UserMenuBuilder,
                placement: Placement.Bottom,
                maskColor: 'rgba(0, 0, 0, 0)',
                popupColor: 'rgba(0, 0, 0, 0)',
                enableArrow: false,
                onStateChange: (e) => {
                  this.showUserMenu = e.isVisible;
                }
              })
              .onClick(() => {
                this.showUserMenu = !this.showUserMenu;
              })
            }
            .width('100%')
            .height(70)
            .padding({ left: 30, right: 50 })
            .backgroundColor(this.headerBgColor)
            .border({ width: { bottom: 1 }, color: this.themeBorderColor })

            Row() {
              // 左侧菜单栏
              Column() {
                // 分组标题
                Row() {
                  Text('短链分组')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.textColor)
                  // .margin({ left: 10 })

                  Button() {
                    Row() {
                      Image($r('app.media.add'))
                        .width(16)
                        .height(16)
                        .fillColor(this.textColor)
                    }
                    .width('100%')
                    .height('100%')
                    .justifyContent(FlexAlign.Center)
                    .alignItems(VerticalAlign.Center)
                    .padding({ right: 30 })
                  }
                  .width(32)
                  .height(32)
                  .backgroundColor(Color.White)
                  .margin({ left: 43 })
                  .onClick(() => {
                    this.showAddGroupMask = true;
                    this.showInputDialog = true;
                  })
                }
                .margin({ top: 15, bottom: 15, left: 15 })
                .alignItems(VerticalAlign.Center)

                // 分组列表
                List() {
                  ForEach(this.groups, (group: Group, index) => {
                    ListItem() {
                      Column() {
                        Stack({ alignContent: Alignment.Top }) {
                          // 移动指示器
                          if (this.isDragging && this.indicatorPosition === index && this.draggedIndex !== index) {
                            Row()
                              .width('100%')
                              .height(47)
                              .backgroundColor('#F5F7FA')
                              .opacity(0.6)
                              .padding({ left: 40, right: 24 })
                              .zIndex(1)
                          }

                          // 最后一个位置的指示器
                          if (this.isDragging && index === this.groups.length - 1 &&
                            this.indicatorPosition === this.groups.length) {
                            Row()
                              .width('100%')
                              .height(47)
                              .backgroundColor('#F5F7FA')
                              .opacity(0.6)
                              .padding({ left: 40, right: 24 })
                              .position({ y: 47 })
                              .zIndex(1)
                          }

                          // 分组内容
                          Row() {
                            Text(group.name)
                              .fontSize(14)
                              .fontColor(this.currentGroup === group.name ? this.themeColor : this.textColorSecondary)
                              .layoutWeight(1)

                            Row({ space: 8 }) {
                              // 统计图标
                              Image($r('app.media.statistics'))
                                .width(16)
                                .height(16)
                                .fillColor(this.currentGroup === group.name ? this.themeColor : this.textColorSecondary)
                                .opacity(0.8)
                                .onClick(() => {
                                  // 查看分组统计
                                  this.showGroupStats(group);
                                  return false; // 阻止事件冒泡
                                })

                              // 删除图标替换为编辑图标
                              Image($r('app.media.setting'))
                                .width(16)
                                .height(16)
                                .fillColor(this.currentGroup === group.name ? this.themeColor : this.textColorSecondary)
                                .opacity(0.8)
                                .bindPopup(this.showGroupMenuForGid === group.gid, {
                                  builder: () => this.GroupMenuBuilder(group),
                                  placement: Placement.Bottom,
                                  maskColor: 'rgba(0, 0, 0, 0)',
                                  popupColor: 'rgba(0, 0, 0, 0)',
                                  enableArrow: false,
                                  onStateChange: (e) => {
                                    if (!e.isVisible) {
                                      this.showGroupMenuForGid = '';
                                    }
                                  }
                                })
                                .onClick(() => {
                                  // 防止点击编辑图标时对默认分组弹出菜单
                                  if (group.name === '默认分组') {
                                    promptAction.showToast({ message: '默认分组不能编辑' });
                                  } else {
                                    // 设置当前显示菜单的分组ID
                                    this.showGroupMenuForGid = this.showGroupMenuForGid === group.gid ? '' : group.gid;
                                  }
                                  return false; // 阻止事件冒泡
                                })
                            }
                          }
                          .width('100%')
                          .height(47)
                          .padding({ left: 20, right: 24 })
                          .backgroundColor(this.draggedGroup?.gid === group.gid ? '#E5E6EB' :
                            (this.currentGroup === group.name ? this.themeColorLight : Color.White))
                          .shadow(this.draggedGroup?.gid === group.gid ? {
                            radius: 16,
                            color: '#0000001A',
                            offsetX: 0,
                            offsetY: 8
                          } : undefined)
                          .translate({
                            y: this.draggedGroup?.gid === group.gid ? this.dragOffsetY : 0
                          })
                          .scale({
                            x: this.draggedGroup?.gid === group.gid ? this.scaleValue : 1,
                            y: this.draggedGroup?.gid === group.gid ? this.scaleValue : 1
                          })
                          .opacity(this.draggedGroup?.gid === group.gid ? this.itemOpacity : 1)
                          .zIndex(this.draggedGroup?.gid === group.gid ? 999 : 1)
                          .animation({
                            duration: 300,
                            curve: Curve.EaseInOut
                          })
                          .onTouch((event: TouchEvent) => {
                            event.stopPropagation();

                            if (event.type === TouchType.Down) {
                              // 记录按下的起始位置和时间
                              this.dragStartY = event.touches[0].y;
                              this.dragY = event.touches[0].y;
                              this.lastSwapTime = Date.now(); // 记录按下时间
                            } else if (event.type === TouchType.Move) {
                              // 只有移动距离超过阈值才开始拖动
                              const moveDistance = Math.abs(event.touches[0].y - this.dragStartY);
                              if (moveDistance > 5) { // 增加移动阈值
                                if (!this.isDragging) {
                                  // 开始拖动时的初始化
                                  this.isDragging = true;
                                  this.draggedGroup = group;
                                  this.draggedIndex = index;

                                  // 按下动画效果
                                  animateTo({
                                    duration: 200,
                                    curve: Curve.EaseInOut
                                  }, () => {
                                    this.itemOpacity = 0.95;
                                    this.scaleValue = 1.02;
                                    this.elevation = 4;
                                  });
                                }

                                // 更新拖动位置
                                this.dragY = event.touches[0].y;
                                const moveY = this.dragY - this.dragStartY;
                                const itemHeight = 47;

                                // 计算目标索引和更新位置
                                const currentItemTop = itemHeight * this.draggedIndex;
                                const currentMouseY = currentItemTop + moveY;
                                const targetIndex = Math.round(currentMouseY / itemHeight);
                                const boundedIndex = Math.max(0, Math.min(targetIndex, this.groups.length));

                                // 更新拖动偏移
                                this.dragOffsetY = moveY;

                                // 只更新指示器位置，不移动其他分组
                                if (boundedIndex !== this.draggedIndex) {
                                  this.indicatorPosition = boundedIndex;
                                }

                                // 只在移动超过阈值时才准备交换位置
                                if (boundedIndex !== this.draggedIndex &&
                                  Math.abs(moveY) >= itemHeight * 0.7) {

                                  // 防抖：确保两次交换之间有足够的时间间隔
                                  const now = Date.now();
                                  if (now - this.lastSwapTime < 500) {
                                    return;
                                  }
                                  this.lastSwapTime = now;

                                  // 记录目标位置，但不立即更新分组顺序
                                  this.targetIndex = boundedIndex;
                                }
                              }
                            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                              const moveDistance = Math.abs(event.touches[0].y - this.dragStartY);
                              const timeElapsed = Date.now() - this.lastSwapTime;

                              // 判断是否为点击事件：移动距离小且时间短
                              if (moveDistance < 5 && timeElapsed < 200) {
                                this.currentGroup = group.name;
                                this.fetchShortLinksByGroup(group.gid);
                                // 如果在回收站视图中，则退出回收站
                                if (this.isRecycleBin) {
                                  this.isRecycleBin = false;
                                }
                              } else if (this.isDragging && this.targetIndex !== undefined) {
                                // 处理拖动结束
                                const finalTargetIndex = this.targetIndex; // 保存目标索引的值
                                animateTo({
                                  duration: 300,
                                  curve: Curve.EaseInOut
                                }, () => {
                                  const newGroups = [...this.groups];
                                  const removed = newGroups.splice(this.draggedIndex, 1)[0];
                                  newGroups.splice(finalTargetIndex, 0, removed);
                                  this.groups = newGroups;

                                  // 重置状态
                                  this.draggedIndex = finalTargetIndex;
                                  this.targetIndex = undefined;

                                  // 处理拖动结束
                                  this.handleDragEnd();
                                });
                              } else {
                                // 如果没有有效的目标位置，直接重置状态
                                animateTo({
                                  duration: 300,
                                  curve: Curve.EaseOut
                                }, () => {
                                  this.scaleValue = 1.0;
                                  this.elevation = 0;
                                  this.dragOffsetY = 0;
                                });
                              }

                              // 重置状态
                              this.isDragging = false;
                              this.draggedGroup = null;
                              this.itemOpacity = 1;
                              this.indicatorPosition = -1;
                              this.scaleValue = 1.0;
                              this.elevation = 0;
                              this.dragOffsetY = 0;
                            }
                          });
                        }
                        .width('100%')
                        .height(47)
                        .margin({ top: 2, bottom: 2 })
                        .clip(false) // 禁用裁剪
                      }
                    }
                    .zIndex(this.draggedGroup?.gid === group.gid ? 999 : 1) // 为 ListItem 添加 zIndex
                  })
                }
                .width('100%')
                .layoutWeight(1)
                .clip(false) // 禁用 List 的裁剪
                .zIndex(1)

                // 回收站按钮
                Button() {
                  Text('回收站')
                    .fontSize(14)
                    .fontColor(this.isRecycleBin ? Color.White : this.textColorSecondary)
                }
                .width('100%')
                .height(40)
                .backgroundColor(this.isRecycleBin ? this.themeColor : Color.White)
                .padding({ left: 32, right: 24 })
                .margin({ bottom: 30 }) // 添加底部边距
                .onClick(() => this.fetchRecycleBin())
              }
              .width(170)
              .height('100%')
              .backgroundColor(Color.White)
              .padding({ left: 15 })

              // 分割线
              Divider()
                .vertical(true)
                .height('100%')
                .color(this.themeBorderColor)
                .opacity(0.6)

              // 右侧内容区
              Column() {
                // 操作区
                Row({ space: 16 }) {
                  // 搜索框部分
                  Row({ space: 8 }) {
                    Search({ value: this.searchText, placeholder: '请输入描述信息、短链接或原始链接' })
                      .width('100%')
                      .height(36)
                      .backgroundColor(Color.White)
                      .placeholderColor(this.textColorSecondary)
                      .textFont({ size: 14 })
                      .borderRadius(4)
                      .border({ width: 1, color: this.themeBorderColor })
                      .onChange((value: string) => {
                        this.searchText = value
                      })
                      .onSubmit(() => {
                        this.searchShortLinks()
                      })
                  }
                  .width('80%')
                  .alignItems(VerticalAlign.Center)

                  if (!this.isRecycleBin) {
                    // 在普通视图中显示新建短链和批量创建按钮
                    Row({ space: 24 }) {
                      Button('新建短链')// 简化按钮结构
                        .width(100)
                        .height(36)
                        .fontSize(14)
                        .fontColor(Color.White)
                        .backgroundColor(this.themeColor)
                        .borderRadius(4)
                        .onClick(() => {
                          this.isAddDrawerOpening = true;
                          this.addDrawerWidth = 500;
                        })

                      // Button('批量创建')
                      //   .width(100)
                      //   .height(36)
                      //   .fontSize(14)
                      //   .fontColor(Color.White)
                      //   .backgroundColor(this.themeColor)
                      //   .borderRadius(4)
                      //   .onClick(() => {
                      //     this.openBatchDrawer()
                      //   })
                    }
                  }
                }
                .width('95%')
                .margin({ top: 24, bottom: 24 })

                // 数据表格
                Column() {
                  // 表头
                  Row() {
                    // 短链接信息列
                    Text('短链接信息')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.textColorSecondary)
                      .layoutWeight(2)
                      .margin({ left: 24 })

                    // 短链接列
                    Text('短链接')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.textColorSecondary)
                      .layoutWeight(3)
                      .margin({ left: 90 })

                    // 访问次数列
                    Text('访问次数')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.textColorSecondary)
                      .layoutWeight(1)
                      .textAlign(TextAlign.Center)
                      .margin({ left: 15 })


                    // 访问人数列
                    Text('访问人数')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.textColorSecondary)
                      .layoutWeight(1)
                      .textAlign(TextAlign.Center)
                      .margin({ left: 10 })

                    // IP数列
                    Text('IP数')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.textColorSecondary)
                      .layoutWeight(1)
                      .textAlign(TextAlign.Center)

                    // 操作列
                    Text('操作')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.textColorSecondary)
                      .layoutWeight(1)
                      .textAlign(TextAlign.Center)
                  }
                  .width('100%')
                  .height(48)
                  .backgroundColor(this.themeColorLight)
                  .padding({ right: 24 })

                  // 数据列表
                  List({ space: 1 }) {
                    ForEach(this.shortLinks, (item: ShortLink) => {
                      ListItem() {
                        Row() {
                          // 检查链接是否过期

                          // 短链接信息
                          Column() {
                            if (item.describe) {
                              Text(item.describe)
                                .fontSize(13)
                                .fontColor(this.isLinkExpired(item) ? this.textColorSecondary : this.textColor)
                                .margin({ bottom: 4 })
                                .opacity(this.isLinkExpired(item) ? 0.6 : 1)
                            }

                            Row() {
                              Text(this.formatDate(item.createTime))
                                .fontSize(11)
                                .fontColor(this.textColorSecondary)
                                .opacity(this.isLinkExpired(item) ? 0.6 : 1)

                              // 添加过期标签
                              if (this.isLinkExpired(item)) {
                                Text('已失效')
                                  .fontSize(10)
                                  .backgroundColor('#ff4d4f')
                                  .fontColor(Color.White)
                                  .borderRadius(2)
                                  .padding({
                                    left: 4,
                                    right: 4,
                                    top: 1,
                                    bottom: 1
                                  })
                                  .margin({ left: 6 })
                              }
                            }
                          }
                          .layoutWeight(2)
                          .alignItems(HorizontalAlign.Start)

                          // 短链接
                          Column() {
                            Row() {
                              Text(item.domain + "/" + item.shortUri)
                                .fontSize(13)
                                .fontColor(this.isLinkExpired(item) ? this.textColorSecondary : '#007AFF')
                                .margin({ bottom: 4 })
                                .opacity(this.isLinkExpired(item) ? 0.6 : 1)

                              Button({ type: ButtonType.Circle }) {
                                Image($r('app.media.share'))
                                  .width(16)
                                  .height(16)
                                  .fillColor(this.textColorSecondary)
                              }
                              .width(32)
                              .height(32)
                              .backgroundColor(Color.White)
                              .enabled(!this.isLinkExpired(item)) // 禁用过期链接的复制按钮
                              .opacity(this.isLinkExpired(item) ? 0.5 : 1)
                              .onClick(() => {
                                if (!this.isLinkExpired(item)) {
                                  this.copyToClipboard(item.domain + "/" + item.shortUri || '');
                                }
                              })
                            }

                            Text(item.originUrl)
                              .fontSize(11)
                              .fontColor(this.textColorSecondary)
                              .textOverflow({ overflow: TextOverflow.Ellipsis })
                              .maxLines(1)
                              .opacity(this.isLinkExpired(item) ? 0.6 : 1)
                          }
                          .layoutWeight(3)
                          .alignItems(HorizontalAlign.Start)

                          // 访问量(PV)
                          Column() {
                            Text('今日：' + (item.todayPv || 0))
                              .fontSize(13)
                              .fontColor(this.isLinkExpired(item) ? this.textColorSecondary : this.textColor)
                              .margin({ bottom: 4 })
                              .opacity(this.isLinkExpired(item) ? 0.6 : 1)

                            Text('总计：' + (item.totalPv || 0))
                              .fontSize(13)
                              .fontColor(this.textColorSecondary)
                              .opacity(this.isLinkExpired(item) ? 0.6 : 1)
                          }
                          .layoutWeight(1)
                          .alignItems(HorizontalAlign.Center)

                          // 访客数(UV)
                          Column() {
                            Text('今日：' + (item.todayUv || 0))
                              .fontSize(13)
                              .fontColor(this.isLinkExpired(item) ? this.textColorSecondary : this.textColor)
                              .margin({ bottom: 4 })
                              .opacity(this.isLinkExpired(item) ? 0.6 : 1)

                            Text('总计：' + (item.totalUv || 0))
                              .fontSize(13)
                              .fontColor(this.textColorSecondary)
                              .opacity(this.isLinkExpired(item) ? 0.6 : 1)
                          }
                          .layoutWeight(1)
                          .alignItems(HorizontalAlign.Center)

                          // 访问IP数
                          Column() {
                            Text('今日：' + (item.todayUip || 0))
                              .fontSize(13)
                              .fontColor(this.isLinkExpired(item) ? this.textColorSecondary : this.textColor)
                              .margin({ bottom: 4 })
                              .opacity(this.isLinkExpired(item) ? 0.6 : 1)

                            Text('总计：' + (item.totalUip || 0))
                              .fontSize(13)
                              .fontColor(this.textColorSecondary)
                              .opacity(this.isLinkExpired(item) ? 0.6 : 1)
                          }
                          .layoutWeight(1)
                          .alignItems(HorizontalAlign.Center)

                          // 操作列
                          Row({ space: 12 }) {
                            if (!this.isRecycleBin) {
                              // 普通视图中的操作图标
                              // 统计图标
                              Image($r("app.media.statistics"))
                                .width(16)
                                .height(16)
                                .fillColor(this.textColor)
                                .onClick(() => this.showStats(item))

                              // 设置图标
                              Image($r("app.media.setting"))
                                .width(16)
                                .height(16)
                                .fillColor(this.textColor)
                                .onClick(() => this.editLink(item))

                              // 删除图标
                              Image($r("app.media.delete"))
                                .width(16)
                                .height(16)
                                .fillColor(this.textColor)
                                .onClick(() => this.deleteLink(item))
                            } else {
                              // 回收站视图中的操作图标
                              // 统计图标
                              Image($r("app.media.statistics"))
                                .width(16)
                                .height(16)
                                .fillColor(this.textColor)
                                .onClick(() => this.showStats(item))

                              // 恢复图标
                              Image($r("app.media.restore"))
                                .width(16)
                                .height(16)
                                .fillColor(this.textColor)
                                .onClick(() => this.restoreLink(item))

                              // 彻底删除图标
                              Image($r("app.media.delete"))
                                .width(16)
                                .height(16)
                                .fillColor('#FF4D4F')
                                .onClick(() => this.permanentDeleteLink(item))
                            }
                          }
                          .layoutWeight(1)
                          .justifyContent(FlexAlign.Center)
                        }
                        .width('100%')
                        .padding({
                          left: 24,
                          right: 24,
                          top: 12,
                          bottom: 12
                        })
                        .backgroundColor(Color.White)
                        .borderRadius(8)
                        // 为过期的链接添加灰色背景
                        .opacity(this.isLinkExpired(item) ? 0.9 : 1)
                      }
                    })
                  }
                  .width('100%')
                  .layoutWeight(1)

                  // 修改分页器部分
                  if (this.shortLinks && this.shortLinks.length > 0) {
                    Row() {
                      // 分页控制区（居中）
                      Row({ space: 8 }) {
                        // 左侧翻页按钮
                        Button({ type: ButtonType.Normal }) {
                          Text('<')
                            .fontSize(14)
                            .fontColor(this.currentPage <= 1 ? this.textColorSecondary : this.textColor)
                        }
                        .width(32)
                        .height(32)
                        .backgroundColor(Color.White)
                        .borderRadius(4)
                        .enabled(this.currentPage > 1)
                        .onClick(() => {
                          if (this.currentPage > 1) {
                            this.currentPage--;
                            if (this.isRecycleBin) {
                              this.fetchRecycleBin();
                            } else {
                              const currentGroupObj = this.groups.find(group => group.name === this.currentGroup);
                              if (currentGroupObj) {
                                this.fetchShortLinksByGroup(currentGroupObj.gid);
                              }
                            }
                          }
                        })

                        // 页码按钮
                        ForEach(this.generatePageNumbers(this.currentPage,
                          Math.ceil(this.shortLinkCount / this.pageSize)),
                          (page: string) => {
                            if (page === '...') {
                              Text(page)
                                .fontSize(13)
                                .fontColor(this.textColorSecondary)
                                .width(32)
                                .height(32)
                                .textAlign(TextAlign.Center)
                            } else if (page !== '<' && page !== '>') {
                              Button({ type: ButtonType.Normal }) {
                                Text(page)
                                  .fontSize(13)
                                  .fontColor(page === this.currentPage.toString() ? Color.White : this.textColor)
                              }
                              .width(32)
                              .height(32)
                              .backgroundColor(page === this.currentPage.toString() ? this.themeColor : Color.White)
                              .border({
                                width: 1,
                                color: page === this.currentPage.toString() ? this.themeColor : this.themeBorderColor
                              })
                              .borderRadius(4)
                              .onClick(() => this.handlePageClick(page))
                            }
                          })

                        // 右侧翻页按钮
                        Button({ type: ButtonType.Normal }) {
                          Text('>')
                            .fontSize(14)
                            .fontColor(this.currentPage >= Math.ceil(this.shortLinkCount / this.pageSize) ?
                            this.textColorSecondary : this.textColor)
                        }
                        .width(32)
                        .height(32)
                        .backgroundColor(Color.White)
                        .borderRadius(4)
                        .enabled(this.currentPage < Math.ceil(this.shortLinkCount / this.pageSize))
                        .onClick(() => {
                          const totalPages = Math.ceil(this.shortLinkCount / this.pageSize);
                          if (this.currentPage < totalPages) {
                            this.currentPage++;
                            if (this.isRecycleBin) {
                              this.fetchRecycleBin();
                            } else {
                              const currentGroupObj = this.groups.find(group => group.name === this.currentGroup);
                              if (currentGroupObj) {
                                this.fetchShortLinksByGroup(currentGroupObj.gid);
                              }
                            }
                          }
                        })
                      }
                      .layoutWeight(1) // 添加布局权重
                      .justifyContent(FlexAlign.Center) // 居中对齐

                      // 总条数显示
                      Text(`共 ${this.shortLinkCount} 条`)
                        .fontSize(13)
                        .fontColor(this.textColorSecondary)
                        .margin({ right: 24 }) // 添加右边距
                    }
                    .width('100%')
                    .height(40)
                    .padding({ left: 24, right: 24 })
                    .backgroundColor(Color.White)
                    .margin({ bottom: 110 })
                  }
                }
                .width('95%')
                .backgroundColor(Color.White)
                .borderRadius(8)
                .border({ width: 1, color: this.themeBorderColor })
              }
              .layoutWeight(1)
              .height('100%')
              .backgroundColor(Color.White)
              .padding({ top: 0, bottom: 24 })
            }
            .layoutWeight(1)
            .width('100%')
          }
          .width('100%')
          .height('100%')
          .padding({ top: 20 })
          .shadow(this.isAddDrawerOpening ? {
            radius: 24,
            color: 'rgba(0, 0, 0, 0.12)',
            offsetX: -8,
            offsetY: 0
          } : {
            radius: 0,
            color: 'rgba(0, 0, 0, 0)',
            offsetX: 0,
            offsetY: 0
          })

          // 添加遮罩层
          if (this.isAddDrawerOpening) {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('rgba(0, 0, 0, 0.4)')
              .position({ x: 0, y: 0 })
              .onClick(() => {
                this.closeAddDrawer()
              })
          }

          // 添加批量创建的遮罩层
          if (this.isBatchDrawerOpening) {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('rgba(0, 0, 0, 0.4)')
              .position({ x: 0, y: 0 })
              .onClick(() => {
                this.closeBatchDrawer()
              })
          }

          // 添加编辑弹窗的遮罩层
          if (this.isEditDrawerOpening) {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('rgba(0, 0, 0, 0.4)')
              .position({ x: 0, y: 0 })
              .onClick(() => {
                this.isEditDrawerOpening = false;
                this.editDrawerWidth = 0;
              })
          }

          // 添加统计弹窗的遮罩层
          if (this.isStatsDrawerOpening) {
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('rgba(0, 0, 0, 0.4)')
              .position({ x: 0, y: 0 })
              .onClick(() => {
                this.isStatsDrawerOpening = false;
                this.statsDrawerWidth = 0;
              })
          }

          // 添加用户信息弹窗的遮罩层
          if (this.isUserInfoDrawerOpening) {
            // 添加遮罩层
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('rgba(0, 0, 0, 0.4)')
              .position({ x: 0, y: 0 })
              .onClick(() => {
                this.isUserInfoDrawerOpening = false;
              })

            UserInfoPopup({
              isDrawerOpening: $isUserInfoDrawerOpening,
              drawerWidth: $userInfoDrawerWidth
            })
          }

          // 统计抽屉
          if (this.isStatsDrawerOpening && this.currentEditLink) {
            ShortLinkStats({
              isStatsDrawerOpening: $isStatsDrawerOpening,
              statsDrawerWidth: $statsDrawerWidth,
              shortLink: this.currentEditLink,
              onSuccess: () => {
                // 关闭后的回调
              }
            })
          }

          // 在 Stack 的最后添加新建短链弹窗
          if (this.isAddDrawerOpening) {
            AddShortLink({
              isDrawerOpening: $isAddDrawerOpening,
              drawerWidth: $addDrawerWidth,
              newLinkUrl: $addLinkUrl,
              newLinkDescription: $addLinkDescription,
              selectedGroup: $selectedGroup,
              selectedValidity: $selectedValidity,
              customDate: $customDate,
              showGroupPicker: $showGroupPicker,
              showDatePicker: $showDatePicker,
              groups: $groups,
              onSuccess: () => {
                // 刷新列表
                const currentGroupObj = this.groups.find(group => group.name === this.currentGroup);
                if (currentGroupObj) {
                  this.fetchShortLinksByGroup(currentGroupObj.gid);
                }
              }
            })
          }

          // 在 Stack 的最后添加批量创建弹窗
          if (this.isBatchDrawerOpening) {
            AddBatchLinks({
              isDrawerOpening: $isBatchDrawerOpening,
              drawerWidth: $batchDrawerWidth,
              newLinkUrl: $newLinkUrl,
              newLinkDescription: $newLinkDescription,
              selectedGroup: $selectedGroup,
              selectedValidity: $selectedValidity,
              customDate: $customDate,
              showGroupPicker: $showGroupPicker,
              showDatePicker: $showDatePicker,
              groups: $groups,
              onSuccess: () => {
                // 刷新列表
                const currentGroupObj = this.groups.find(group => group.name === this.currentGroup);
                if (currentGroupObj) {
                  this.fetchShortLinksByGroup(currentGroupObj.gid);
                }
              }
            })
          }

          // 编辑抽屉
          if (this.isEditDrawerOpening && this.currentEditLink) {
            EditShortLink({
              shortLink: this.currentEditLink,
              isDrawerOpening: $isEditDrawerOpening,
              drawerWidth: $editDrawerWidth,
              newLinkUrl: $newLinkUrl,
              newLinkDescription: $newLinkDescription,
              selectedGroup: $selectedGroup,
              selectedValidity: $selectedValidity,
              customDate: $customDate,
              showGroupPicker: $showGroupPicker,
              showDatePicker: $showDatePicker,
              groups: $groups,
              onSuccess: () => {
                // 刷新当前分组的短链列表
                const currentGroupObj = this.groups.find(group => group.name === this.currentGroup);
                if (currentGroupObj) {
                  this.fetchShortLinksByGroup(currentGroupObj.gid);
                }
              }
            })
          }
        }
      }
      .width('100%')
      .height('113%')
      .margin({ top: -40, bottom: -40 }) // 需要添加此设置
      .onClick(() => {
        if (this.showGroupPicker) {
          this.showGroupPicker = false;
        }
        if (this.showUserMenu) {
          this.showUserMenu = false;
        }
        if (this.showGroupMenuForGid !== '') {
          this.showGroupMenuForGid = '';
        }
      })

      // 退出登录的遮罩层
      if (this.showLogoutMask) {
        Column()
          .width('100%')
          .height('113%')
          .backgroundColor('rgba(0, 0, 0, 0.4)')
          .position({ x: 0, y: -40 })
          .onClick(() => {
            this.showLogoutMask = false;
            // 点击遮罩层不做任何操作，保持弹窗显示
          })
      }

      // 添加分组的遮罩层
      if (this.showAddGroupMask) {
        Column()
          .width('100%')
          .height('113%')
          .backgroundColor('rgba(0, 0, 0, 0.4)')
          .position({ x: 0, y: -40 })
          .onClick(() => {
            // 点击遮罩层不做任何操作，保持弹窗显示
          })
      }

      if (this.showInputDialog) {
        Column() {
          // 对话框内容
          Column() {
            Text('新增分组')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 20, bottom: 16 })

            TextInput({ placeholder: '请输入分组名称' })
              .width('90%')
              .height(40)
              .margin({ bottom: 20 })
              .onChange((value: string) => {
                this.newGroupName = value;
              })

            Row() {
              Button('取消')
                .width(100)
                .height(36)
                .backgroundColor(Color.White)
                .fontColor(this.textColor)
                .borderRadius(4)
                .border({ width: 1, color: this.themeBorderColor })
                .margin({ right: 12 })
                .onClick(() => {
                  this.showInputDialog = false;
                  this.showAddGroupMask = false;
                })

              Button('确定')
                .width(100)
                .height(36)
                .backgroundColor(this.themeColor)
                .fontColor(Color.White)
                .borderRadius(4)
                .onClick(async () => {
                  if (!this.newGroupName || this.newGroupName.trim() === '') {
                    JhProgressHUD.showError('请输入分组名称');
                    return;
                  }

                  try {
                    const params: Object = Object({
                      name: this.newGroupName.trim()
                    });

                    const headers: Record<string, string> = {
                      'username': this.username
                    };

                    const res = await HttpUtils.post(APIs.saveGroup, params, '创建分组...', headers);
                    if (res.code === '0') {
                      JhProgressHUD.showSuccess('创建成功');
                      await this.fetchGroupList();
                      this.showInputDialog = false;
                      this.showAddGroupMask = false;
                      this.newGroupName = '';
                    } else {
                      JhProgressHUD.showError('创建失败');
                    }
                  } catch (error) {
                    console.error('创建分组失败:', error);
                    JhProgressHUD.showError('创建失败');
                  }
                })
            }
            .margin({ bottom: 20 })
          }
          .width(320)
          .backgroundColor(Color.White)
          .borderRadius(8)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('transparent')
      }

      // 编辑分组的遮罩层
      if (this.showEditGroupMask) {
        Column()
          .width('100%')
          .height('113%')
          .backgroundColor('rgba(0, 0, 0, 0.4)')
          .position({ x: 0, y: -40 })
          .onClick(() => {
            // 点击遮罩层不做任何操作，保持弹窗显示
          })
      }

      // 编辑分组对话框
      if (this.showEditGroupDialog && this.editingGroup) {
        Column() {
          // 对话框内容
          Column() {
            Text('编辑分组')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 20, bottom: 16 })

            TextInput({ text: this.editGroupName, placeholder: '请输入分组名称' })
              .width('90%')
              .height(40)
              .margin({ bottom: 20 })
              .onChange((value: string) => {
                this.editGroupName = value;
              })

            Row() {
              Button('取消')
                .width(100)
                .height(36)
                .backgroundColor(Color.White)
                .fontColor(this.textColor)
                .borderRadius(4)
                .border({ width: 1, color: this.themeBorderColor })
                .margin({ right: 12 })
                .onClick(() => {
                  this.showEditGroupDialog = false;
                  this.showEditGroupMask = false;
                  this.editingGroup = null;
                })

              Button('确定')
                .width(100)
                .height(36)
                .backgroundColor(this.themeColor)
                .fontColor(Color.White)
                .borderRadius(4)
                .onClick(async () => {
                  if (!this.editGroupName || this.editGroupName.trim() === '') {
                    JhProgressHUD.showError('请输入分组名称');
                    return;
                  }

                  if (this.editingGroup) {
                    await this.updateGroupName(this.editingGroup, this.editGroupName.trim());
                  }
                })
            }
            .margin({ bottom: 20 })
          }
          .width(320)
          .backgroundColor(Color.White)
          .borderRadius(8)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('transparent')
      }
    }
    .width('100%')
    .height('100%')
  }

  // 复制链接到剪贴板
  private async copyToClipboard(text: string) {
    try {
      // 获取系统剪贴板实例
      const pasteboard: clipboard.SystemPasteboard = clipboard.getSystemPasteboard();

      // 创建 PasteData 对象并写入文本
      const pasteData: clipboard.PasteData = clipboard.createData(clipboard.MIMETYPE_TEXT_PLAIN, text);

      // 写入剪贴板
      await pasteboard.setData(pasteData);

      // 显示成功提示
      JhProgressHUD.showSuccess('链接已复制');
    } catch (error) {
      console.error('复制失败:', error);
      JhProgressHUD.showError('复制失败');
    }
  }

  // 删除短链
  private async deleteLink(item: ShortLink) {
    try {
      AlertDialog.show({
        title: '删除确认',
        message: '\n是否确定将该链接移入回收站？\n\n',
        primaryButton: {
          value: '取消',
          action: () => {
            console.info('取消删除');
          }
        },
        secondaryButton: {
          value: '确定',
          action: async () => {
            console.info('确认删除');
            const params: object = Object({
              gid: item.gid,
              fullShortUrl: item.fullShortUrl
            });

            const res = await HttpUtils.post(APIs.saveRecycleBin, params, '移入回收站...');
            if (res.code === '0') {
              JhProgressHUD.showSuccess('已移入回收站');
              // 重新查询当前分组的短链接
              const currentGroupObj = this.groups.find(group => group.name === this.currentGroup);
              if (currentGroupObj) {
                this.fetchShortLinksByGroup(currentGroupObj.gid);
                // 更新分组数量和分组列表
                await this.fetchGroupList();
                // await this.updateGroupLinkCount();
              }
            } else {
              JhProgressHUD.showError('操作失败');
            }
          }
        },
        alignment: DialogAlignment.Center,
        offset: { dx: 0, dy: -20 }
      })
    } catch (error) {
      console.error('移入回收站失败:', error);
      JhProgressHUD.showError('操作失败');
    }
  }

  // 编辑短链
  private editLink(item: ShortLink): void {
    // 先设置当前编辑的短链
    this.currentEditLink = item;

    // 初始化编辑弹窗所需的值
    this.newLinkUrl = item.originUrl;
    this.newLinkDescription = item.description || item.describe || '';
    this.selectedGroup = this.groups.find(g => g.gid === item.gid)?.name || '默认分组';

    // 设置有效期
    if (item.validityType === 'PERMANENT') {
      this.selectedValidity = '永久';
      this.customDate = '';
    } else {
      this.selectedValidity = '自定义';
      // 设置日期
      if (item.validityTime) {
        this.customDate = item.validityTime.split(' ')[0]; // 只保留年月日
      } else if (item.validDate) {
        this.customDate = item.validDate.split(' ')[0];
      }
    }

    // 设置抽屉打开状态和宽度
    this.isEditDrawerOpening = true;
    this.editDrawerWidth = 500;
  }

  // 打开抽屉
  openDrawer() {
    this.isAddDrawerOpening = true
    this.addDrawerWidth = 500 // 设置抽屉宽度
  }

  // 关闭抽屉
  closeAddDrawer() {
    // 重置所有状态
    this.addLinkUrl = '';
    this.addLinkDescription = '';
    this.addSelectedGroup = '默认分组';
    this.addSelectedValidity = '永久';
    this.addCustomDate = '';
    this.addDrawerWidth = 0;

    setTimeout(() => {
      this.isAddDrawerOpening = false;
    }, 250);
  }

  // 计算下拉框位置的方法
  private getDropdownPosition(): number {
    return 200
  }

  // 根据表头内容计算布局权重
  private getColumnWeight(title: string): number {
    const weightMap = new Map<string, number>([
      ['短链接信息', 2],
      ['短链接', 3],
      ['访问次数', 1],
      ['访问人数', 1],
      ['IP数', 1],
      ['操作', 1]
    ])
    return weightMap.get(title) || 1
  }

  // 智能左边距计算
  private calculateLeftMargin(title: string, index: number): number | string {
    // 首列特殊处理
    if (index === 0) {
      return 30
    }

    // 数值型列居中对齐
    if (title === '访问次数' || title === '访问人数' || title === 'IP数') {
      return '35%' // 调整居中位置
    }

    // 操作列居中对齐
    if (title === '操作') {
      return '35%' // 调整居中位置
    }

    // 默认间距
    return 55
  }

  // 添加文本对齐方式计算方法
  private getTextAlign(title: string): TextAlign {
    if (title === '访问次数' || title === '访问人数' || title === 'IP数' || title === '操作') {
      return TextAlign.Center
    }
    return TextAlign.Start
  }

  // 添加批量创建抽屉的打开和关闭方法
  openBatchDrawer() {
    this.isBatchDrawerOpening = true;
    this.batchDrawerWidth = 500;
  }

  closeBatchDrawer() {
    this.batchDrawerWidth = 0;
    setTimeout(() => {
      this.isBatchDrawerOpening = false;
    }, 250);
  }

  // 显示用户信息
  private showUserInfo() {
    console.info("打开用户信息弹窗");
    // 打开用户信息弹窗
    this.userInfoDrawerWidth = 450;
    this.isUserInfoDrawerOpening = true;
  }

  // 退出登录
  private async logout() {
    try {

      // 获取用户名和token
      const username = this.username;
      const token = JhAESPreferencesUtils.getString('token');

      // 检查token是否存在
      if (!token) {
        JhProgressHUD.showError('登录信息已失效');
        // 清除本地存储并跳转到登录页
        JhAESPreferencesUtils.delete('username');
        JhAESPreferencesUtils.delete('token');
        setTimeout(() => {
          router.replaceUrl({ url: 'pages/loginPage/Login' });
        }, 1000);
        return;
      }

      // 设置请求参数
      const params: LogoutParams = {
        username: username,
        token: token as string
      };

      // 发送退出登录请求
      const res = await HttpUtils.delete(APIs.logout, params);

      if (res.code === '0') {
        // 清除本地存储的用户信息
        JhAESPreferencesUtils.delete('username');
        JhAESPreferencesUtils.delete('token');

        JhProgressHUD.showSuccess('退出登录成功');

        // 跳转到登录页
        setTimeout(() => {
          router.replaceUrl({ url: 'pages/loginPage/Login' });
        }, 1000);
      } else {
        JhProgressHUD.showError('退出登录失败');
      }
    } catch (error) {
      console.error('退出登录失败:', error);
      JhProgressHUD.showError('退出登录失败');
    }
  }

  // 添加用户菜单构建器
  @Builder
  UserMenuBuilder() {
    Column() {
      Button('用户信息', { type: ButtonType.Normal })
        .width('100%')
        .height(40)
        .fontSize(14)
        .fontColor(this.textColor)
        .backgroundColor(Color.White)
        .onClick(() => {
          // 打开用户信息弹窗
          this.showUserInfo();
          this.showUserMenu = false;
        })

      Divider().color(this.themeBorderColor).opacity(0.6)

      Button('退出登录', { type: ButtonType.Normal })
        .width('100%')
        .height(40)
        .fontSize(14)
        .fontColor(this.textColor)
        .backgroundColor(Color.White)
        .onClick(() => {
          this.showLogoutConfirmDialog();
          this.showUserMenu = false;
        })
    }
    .width(120)
    .padding(4)
    .backgroundColor(Color.White)
    .border({
      width: 1,
      color: this.themeBorderColor,
      style: BorderStyle.Solid
    })
    .borderRadius(8)
  }

  // 修改确认对话框方法
  private showLogoutConfirmDialog() {
    this.showLogoutMask = true;
    AlertDialog.show({
      title: '退出登录',
      message: '\n确定要退出登录吗？\n\n', // 使用换行符添加间距
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('取消退出登录');
          this.showLogoutMask = false;
        }
      },
      secondaryButton: {
        value: '确定',
        action: () => {
          console.info('确认退出登录');
          this.showLogoutMask = false;
          this.logout();
        }
      },
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: -20 }
    })
  }

  // 分页查询短链接
  private async fetchShortLinksByGroup(gid: string) {
    try {
      const params: Object = Object({
        gid: gid,
        current: this.currentPage,
        size: this.pageSize
      });

      const res = await HttpUtils.get(APIs.pageShortLink, params);

      if (res.code === '0') {
        // 更新短链接列表和总条数
        this.shortLinks = res.data.records || [];
        this.shortLinkCount = res.data.total || 0;

        // 如果当前页没有数据但总条数大于0，自动跳转到第一页
        if (this.shortLinks.length === 0 && this.shortLinkCount > 0) {
          this.currentPage = 1;
          await this.fetchShortLinksByGroup(gid); // 重新获取第一页数据
          return;
        }
      } else {
        JhProgressHUD.showError('获取失败');
      }
    } catch (error) {
      console.error('获取分组短链接失败:', error);
      JhProgressHUD.showError('获取失败');
    }
  }

  // 添加日期格式化方法
  private formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');

    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  }

  // 修改统计方法
  private showStats(item: ShortLink) {
    this.currentEditLink = item; // 保存当前查看的短链接
    this.isStatsDrawerOpening = true;
    this.statsDrawerWidth = 1000; // 使用与其他弹窗相同的宽度
  }

  // 修改生成页码的方法
  private generatePageNumbers(currentPage: number, totalPages: number): Array<string> {
    const result: Array<string> = [];
    const pagesToDisplay = 5; // 修改为显示5个页码

    // 计算起始和结束页码
    let startPage = currentPage - Math.floor((pagesToDisplay - 1) / 2);
    let endPage = currentPage + Math.floor((pagesToDisplay - 1) / 2);

    // 调整起始和结束页码
    if (startPage < 1) {
      startPage = 1;
      endPage = Math.min(pagesToDisplay, totalPages);
    }

    if (endPage > totalPages) {
      endPage = totalPages;
      startPage = Math.max(1, totalPages - pagesToDisplay + 1);
    }

    // 如果总页数小于等于5，直接显示所有页码
    if (totalPages <= pagesToDisplay) {
      for (let i = 1; i <= totalPages; i++) {
        result.push(i.toString());
      }
    } else {
      // 添加首页链接
      result.push("<");

      // 添加第一页和省略号
      if (startPage > 1) {
        result.push("1");
        if (startPage > 2) {
          result.push("...");
        }
      }

      // 添加中间页码
      for (let i = startPage; i <= endPage; i++) {
        result.push(i.toString());
      }

      // 添加省略号和最后一页
      if (endPage < totalPages) {
        if (endPage < totalPages - 1) {
          result.push("...");
        }
        result.push(totalPages.toString());
      }

      // 添加尾页链接
      result.push(">");
    }

    return result;
  }

  // 修改分页器按钮的点击事件处理
  private handlePageClick(page: string) {
    if (this.isRecycleBin) {
      // 回收站视图
      if (page === '<') {
        // 点击首页链接
        if (this.currentPage > 1) {
          this.currentPage = 1;
          this.fetchRecycleBin();
        }
      } else if (page === '>') {
        // 点击尾页链接
        const totalPages = Math.ceil(this.shortLinkCount / this.pageSize);
        if (this.currentPage < totalPages) {
          this.currentPage = totalPages;
          this.fetchRecycleBin();
        }
      } else if (page !== '...') {
        // 点击数字页码
        this.currentPage = parseInt(page);
        this.fetchRecycleBin();
      }
    } else {
      // 普通视图
      const currentGroupObj = this.groups.find(group => group.name === this.currentGroup);
      if (!currentGroupObj) {
        return;
      }

      if (page === '<') {
        // 点击首页链接
        if (this.currentPage > 1) {
          this.currentPage = 1;
          this.fetchShortLinksByGroup(currentGroupObj.gid);
        }
      } else if (page === '>') {
        // 点击尾页链接
        const totalPages = Math.ceil(this.shortLinkCount / this.pageSize);
        if (this.currentPage < totalPages) {
          this.currentPage = totalPages;
          this.fetchShortLinksByGroup(currentGroupObj.gid);
        }
      } else if (page !== '...') {
        // 点击数字页码
        this.currentPage = parseInt(page);
        this.fetchShortLinksByGroup(currentGroupObj.gid);
      }
    }
  }

  // 修改透明度设置方法
  private setItemOpacity(value: number) {
    animateTo({
      duration: 200,
      curve: Curve.EaseInOut, // 添加动画曲线
      delay: 0, // 添加延迟时间
      iterations: 1, // 添加迭代次数
      playMode: PlayMode.Normal, // 添加播放模式
    }, () => {
      this.itemOpacity = value;
    })
  }

  // 修改拖动结束处理方法
  private async handleDragEnd() {
    if (this.isDragging && this.draggedGroup) {
      try {
        const sortParams: SortGroupParam[] = this.groups.map((group, index) => {
          const param: SortGroupParam = {
            gid: group.gid,
            sortOrder: index + 1
          };
          return param;
        });

        const headers: Record<string, string> = {
          'username': encodeURIComponent(this.username)
        };

        const res = await HttpUtils.post(APIs.sortGroup, sortParams, '更新排序...', headers);
        if (res.code === '0') {
          JhProgressHUD.showSuccess('分组排序成功');
          await this.fetchGroupList();
        } else {
          JhProgressHUD.showError('分组排序失败');
          await this.fetchGroupList();
        }
      } catch (error) {
        console.error('更新分组排序失败:', error);
        JhProgressHUD.showError('分组排序失败');
        await this.fetchGroupList();
      } finally {
        this.isDragging = false;
        this.draggedGroup = null;
        this.draggedIndex = -1;
        this.setItemOpacity(1);
      }
    }
  }

  // 查询回收站短链接
  private async fetchRecycleBin() {
    try {
      // 切换当前状态
      this.isRecycleBin = true;
      this.currentGroup = '回收站';

      // 删除下面这行代码，不再强制重置页码
      // this.currentPage = 1;

      // 获取所有分组ID
      const gidList = this.groups.map(group => group.gid);

      // const params: Object = Object({
      //   current: this.currentPage,
      //   size: this.pageSize,
      //   gidList: gidList // 添加分组ID集合参数
      // });
      // const res = await HttpUtils.get(APIs.pageRecycleBin, params);

      // 构建基础查询参数
      let queryParams = `current=${this.currentPage}&size=${this.pageSize}`;

      // 添加gidList参数
      if (gidList && gidList.length > 0) {
        // 遍历每个gid，添加到查询参数中
        gidList.forEach(gid => {
          queryParams += `&gidList=${gid}`;
        });
      }

      // 完整URL
      const url = 'http://' + APIs.apiPrefix + APIs.pageRecycleBin + `?${queryParams}`;

      // 直接发送GET请求，不通过params传递gidList
      const res = await HttpUtils.get(url);

      if (res.code === '0') {
        // 更新短链接列表和总条数
        this.shortLinks = res.data.records || [];
        this.shortLinkCount = res.data.total || 0;

        // 隐藏加载提示
        JhProgressHUD.hide();
      } else {
        JhProgressHUD.showError('获取回收站数据失败');
      }
    } catch (error) {
      console.error('获取回收站数据失败:', error);
      JhProgressHUD.showError('获取回收站数据失败');
    }
  }

  // 从回收站恢复链接
  private async restoreLink(item: ShortLink) {
    try {
      AlertDialog.show({
        title: '恢复确认',
        message: '\n是否确定恢复该短链接？\n\n',
        primaryButton: {
          value: '取消',
          action: () => {
            console.info('取消恢复');
          }
        },
        secondaryButton: {
          value: '确定',
          action: async () => {
            console.info('确认恢复');


            const params: object = Object({
              gid: item.gid,
              fullShortUrl: item.fullShortUrl
            });

            const res = await HttpUtils.post(APIs.recoverRecycleBin, params);
            if (res.code === '0') {
              JhProgressHUD.showSuccess('恢复成功');
              // 重新查询回收站数据
              this.fetchRecycleBin();
            } else {
              JhProgressHUD.showError('恢复失败');
            }
          }
        },
        alignment: DialogAlignment.Center,
        offset: { dx: 0, dy: -20 }
      })
    } catch (error) {
      console.error('恢复链接失败:', error);
      JhProgressHUD.showError('恢复失败');
    }
  }

  // 彻底删除链接
  private async permanentDeleteLink(item: ShortLink) {
    try {
      AlertDialog.show({
        title: '永久删除确认',
        message: '\n该操作将永久删除该短链接，无法恢复！\n是否确定永久删除？\n\n',
        primaryButton: {
          value: '取消',
          action: () => {
            console.info('取消删除');
          }
        },
        secondaryButton: {
          value: '确定删除',
          action: async () => {
            console.info('确认永久删除');


            const params: object = Object({
              gid: item.gid,
              fullShortUrl: item.fullShortUrl
            });

            const res = await HttpUtils.post(APIs.removeRecycleBin, params);
            if (res.code === '0') {
              JhProgressHUD.showSuccess('删除成功');
              // 重新查询回收站数据
              this.fetchRecycleBin();
            } else {
              JhProgressHUD.showError('删除失败');
            }
          }
        },
        alignment: DialogAlignment.Center,
        offset: { dx: 0, dy: -20 }
      })
    } catch (error) {
      console.error('永久删除链接失败:', error);
      JhProgressHUD.showError('删除失败');
    }
  }

  // 退出回收站，返回正常视图
  private exitRecycleBin() {
    this.isRecycleBin = false;

    // 重置为第一个分组
    if (this.groups.length > 0) {
      this.currentGroup = this.groups[0].name;
      this.fetchShortLinksByGroup(this.groups[0].gid);
    }
  }

  // 搜索短链接
  private async searchShortLinks() {
    try {
      // 如果在回收站视图中，执行回收站搜索
      if (this.isRecycleBin) {
        await this.searchRecycleBinLinks();
        return;
      }

      // 重置页码
      this.currentPage = 1;

      // 显示加载中提示
      JhProgressHUD.showLoadingText('搜索中...');

      // 获取当前分组
      const currentGroupObj = this.groups.find(group => group.name === this.currentGroup);
      if (!currentGroupObj) {
        JhProgressHUD.showError('分组不存在');
        return;
      }

      const params: Object = Object({
        gid: currentGroupObj.gid,
        current: this.currentPage,
        size: this.pageSize,
        likeShortLink: this.searchText || null // 添加搜索关键词参数
      });

      const res = await HttpUtils.get(APIs.pageShortLink, params);

      if (res.code === '0') {
        // 更新短链接列表和总条数
        this.shortLinks = res.data.records || [];
        this.shortLinkCount = res.data.total || 0;

        // 隐藏加载提示
        JhProgressHUD.hide();

        // 显示搜索结果提示
        if (this.shortLinks.length === 0) {
          JhProgressHUD.showText('未找到匹配的短链接');
        }
      } else {
        JhProgressHUD.showError('搜索失败');
      }
    } catch (error) {
      console.error('搜索短链接失败:', error);
      JhProgressHUD.showError('搜索失败');
    }
  }

  // 搜索回收站短链接
  private async searchRecycleBinLinks() {
    try {
      // 重置页码
      this.currentPage = 1;

      // 显示加载中提示
      JhProgressHUD.showLoadingText('搜索中...');

      // 获取所有分组ID
      const gidList = this.groups.map(group => group.gid);

      // 构建基础查询参数
      let queryParams = `current=${this.currentPage}&size=${this.pageSize}`;

      // 添加gidList参数
      if (gidList && gidList.length > 0) {
        gidList.forEach(gid => {
          queryParams += `&gidList=${gid}`;
        });
      }

      // 添加搜索关键词参数
      if (this.searchText) {
        queryParams += `&likeShortLink=${encodeURIComponent(this.searchText)}`;
      }

      // 完整URL
      const url = 'http://' + APIs.apiPrefix + APIs.pageRecycleBin + `?${queryParams}`;

      // 发送GET请求
      const res = await HttpUtils.get(url);

      if (res.code === '0') {
        // 更新短链接列表和总条数
        this.shortLinks = res.data.records || [];
        this.shortLinkCount = res.data.total || 0;

        // 隐藏加载提示
        JhProgressHUD.hide();

        // 显示搜索结果提示
        if (this.shortLinks.length === 0) {
          JhProgressHUD.showText('未找到匹配的短链接');
        }
      } else {
        JhProgressHUD.showError('搜索失败');
      }
    } catch (error) {
      console.error('搜索回收站短链接失败:', error);
      JhProgressHUD.showError('搜索失败');
    }
  }

  // 显示删除分组确认对话框
  private showDeleteGroupDialog(group: Group) {
    // 防止删除默认分组
    if (group.name === '默认分组') {
      promptAction.showToast({ message: '默认分组不能删除' });
      return;
    }

    AlertDialog.show({
      title: '删除分组',
      message: `确定要删除"${group.name}"分组吗？\n`,
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('取消删除分组');
        }
      },
      secondaryButton: {
        value: '确定',
        action: () => {
          console.info('确认删除分组');
          this.deleteGroup(group);
        }
      },
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: -20 }
    });
  }

  // 删除分组
  private async deleteGroup(group: Group) {
    try {
      interface DeleteGroupParams {
        gid: string;
      }

      const params: DeleteGroupParams = {
        gid: group.gid
      };

      const headers: Record<string, string> = {
        'username': encodeURIComponent(this.username)
      };

      const res = await HttpUtils.delete(APIs.deleteGroup, params, '', headers);

      if (res.code === '0') {
        JhProgressHUD.showSuccess('删除成功');
        await this.fetchGroupList(); // 重新获取分组列表
      } else {
        JhProgressHUD.showError(res.message || '删除失败');
      }
    } catch (error) {
      console.error('删除分组失败:', error);
      JhProgressHUD.showError('删除失败');
    }
  }

  /**
   * 显示分组统计信息
   *
   * @param group 分组对象
   */
  showGroupStats(group: Group) {
    // 创建一个虚拟的短链接对象，用于显示分组统计
    const virtualLink: ShortLink = {
      id: '0',
      gid: group.gid,
      domain: '',
      shortUri: '',
      fullShortUrl: '',
      originUrl: '',
      describe: `${group.name}分组统计`,
      createTime: new Date().getTime().toString(),
      todayPv: 0,
      todayUv: 0,
      todayUip: 0,
      totalPv: group.shortLinkCount || 0,
      totalUv: 0,
      totalUip: 0,
      validityType: 'PERMANENT',
      title: '',
      validDateType: 0
    };

    // 保存当前查看的短链接并开启统计抽屉
    this.currentEditLink = virtualLink;
    this.isStatsDrawerOpening = true;
    this.statsDrawerWidth = 1000; // 使用与其他弹窗相同的宽度
  }

  // 添加检查短链接是否过期的方法
  private isLinkExpired(item: ShortLink): boolean {
    // 永久有效的链接永远不会过期
    if (item.validDateType === 0) {
      return false;
    }

    // 获取当前日期
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate()); // 设置为今天的0点0分0秒

    // 获取有效期日期字符串
    const validDateStr = item.validDate;
    if (!validDateStr) {
      return false; // 没有有效期信息，当作未过期
    }

    // 解析有效期日期
    const validDate = new Date(validDateStr);
    // 将validDate也设置为其当天的0点0分0秒，用于比较日期
    const validDay = new Date(validDate.getFullYear(), validDate.getMonth(), validDate.getDate());

    // 比较当前日期与有效期，如果validDay等于today，不算过期
    // 只有当today大于validDay时才算过期
    return today > validDay;
  }

  // 添加分组菜单构建器
  @Builder
  GroupMenuBuilder(group: Group) {
    Column() {
      Button('编辑分组', { type: ButtonType.Normal })
        .width('100%')
        .height(40)
        .fontSize(14)
        .fontColor(this.textColor)
        .backgroundColor(Color.White)
        .onClick(() => {
          // 设置当前编辑的分组并显示编辑弹窗
          this.editingGroup = group;
          this.editGroupName = group.name;
          this.showEditGroupMask = true;
          this.showEditGroupDialog = true;
          this.showGroupMenuForGid = ''; // 关闭菜单弹窗
        })

      Divider().color(this.themeBorderColor).opacity(0.6)

      Button('删除分组', { type: ButtonType.Normal })
        .width('100%')
        .height(40)
        .fontSize(14)
        .fontColor('#FF4D4F')
        .backgroundColor(Color.White)
        .onClick(() => {
          this.showGroupMenuForGid = ''; // 关闭弹窗
          this.showDeleteGroupDialog(group);
        })
    }
    .width(120)
    .padding(4)
    .backgroundColor(Color.White)
    .border({
      width: 1,
      color: this.themeBorderColor,
      style: BorderStyle.Solid
    })
    .borderRadius(8)
  }

  // 添加更新分组名称的方法
  // 更新分组名称
  private async updateGroupName(group: Group, newName: string) {
    try {
      // 构造请求参数
      const params: object = Object({
        gid: group.gid,
        name: newName
      });

      const headers: Record<string, string> = {
        'username': encodeURIComponent(this.username)
      };

      const res = await HttpUtils.put(APIs.updateGroup, params, '', headers);

      if (res.code === '0') {
        JhProgressHUD.showSuccess('更新成功');
        // 关闭弹窗
        this.showEditGroupDialog = false;
        this.showEditGroupMask = false;
        this.editingGroup = null;
        // 重新获取分组列表
        await this.fetchGroupList();
      } else {
        JhProgressHUD.showError(res.message || '更新失败');
      }
    } catch (error) {
      console.error('更新分组名称失败:', error);
      JhProgressHUD.showError('更新失败');
    }
  }
}