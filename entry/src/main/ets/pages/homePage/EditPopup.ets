import { JhProgressHUD } from "../../JhCommon/components/JhProgressHUD";
import { APIs } from "../../JhCommon/http/APIs";
import { HttpUtils } from "../../JhCommon/http/HttpUtils";
import { JhAESPreferencesUtils } from "../../JhCommon/utils/JhPreferencesUtils";
import { Group, SelectOption, ShortLink } from "../../model/LoginInterfaces";

@Component
export struct EditShortLink {
  @Link isDrawerOpening: boolean;
  @Link drawerWidth: number;
  @Link newLinkUrl: string;
  @Link newLinkDescription: string;
  @Link selectedGroup: string;
  @Link selectedValidity: string;
  @Link customDate: string;
  @Link showGroupPicker: boolean;
  @Link showDatePicker: boolean;
  @Link groups: Group[];
  
  // 短链信息对象
  shortLink: ShortLink = {
    id: '0',
    gid: '',
    originUrl: '',
    title: '',
    description: '',
    validityType: '',
    validityTime: '',
    domain: '',
    shortUri: '',
    fullShortUrl: '',
    validDateType: 0,
    validDate: '',
    createTime: '',
    describe: '',
    favicon: '',
    totalPv: 0,
    todayPv: 0,
    totalUv: 0,
    todayUv: 0,
    totalUip: 0,
    todayUip: 0
  };
  
  // 成功回调
  onSuccess: () => void = () => {};
  
  // 主题色常量
  readonly themeColor: string = '#4080FF';
  readonly themeColorLight: string = '#F2F3F5';
  readonly textColor: string = '#1D2129';
  readonly textColorSecondary: string = '#86909C';
  readonly themeBorderColor: string = '#E5E6EB';
  
  @State selectedDate: Date | null = null;
  @State selectedGroupIndex: number = 0;
  @State groupOptions: SelectOption[] = [];

  // 格式化日期
  private formatDate(date: Date, withTime: boolean = false): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');

    if (withTime) {
      return `${year}-${month}-${day} 00:00:00`;
    }
    return `${year}-${month}-${day}`;
  }

  // 创建 SelectOption 的辅助函数
  private createSelectOption(value: string, text: string): SelectOption {
    return {
      value: value,
      text: text
    };
  }

  aboutToAppear() {
    // 初始化表单数据
    this.newLinkUrl = this.shortLink.originUrl;
    this.newLinkDescription = this.shortLink.description || this.shortLink.describe || ''; // 同时检查两个描述字段
    this.selectedGroup = this.groups.find(g => g.gid === this.shortLink.gid)?.name || '默认分组';

    // 设置有效期类型
    if (this.shortLink.validityType === 'PERMANENT') {
      this.selectedValidity = '永久';
      this.customDate = '';
      this.selectedDate = null;
    } else {
      this.selectedValidity = '自定义';
      // 设置日期
      if (this.shortLink.validityTime) {
        const date = new Date(this.shortLink.validityTime);
        this.selectedDate = date;
        this.customDate = this.formatDate(date);
      } else if (this.shortLink.validDate) {
        const date = new Date(this.shortLink.validDate);
        this.selectedDate = date;
        this.customDate = this.formatDate(date);
      }
    }

    // 初始化分组选项
    this.groupOptions = this.groups.map(group => this.createSelectOption(group.name, group.name));
    
    // 设置初始抽屉状态
    this.drawerWidth = 500;
    this.isDrawerOpening = true;
  }

  // 添加链接格式校验方法
  private validateUrl(url: string): boolean {
    // 检查是否为http或https链接
    const webUrlPattern = /^https?:\/\/.+/;
    // 检查是否为应用跳转链接（示例：market://details?id=xxx 或 tel:xxx）
    const appUrlPattern = /^[a-zA-Z]+:\/\/.+/;

    return webUrlPattern.test(url) || appUrlPattern.test(url);
  }

  // 修改表单校验方法
  private validateForm(): boolean {
    // 校验跳转链接
    if (!this.newLinkUrl || this.newLinkUrl.trim() === '') {
      JhProgressHUD.showError('请输入需要转换的链接');
      return false;
    }

    // 校验链接格式
    if (!this.validateUrl(this.newLinkUrl.trim())) {
      JhProgressHUD.showError('请输入正确的链接格式');
      return false;
    }

    // 校验描述信息
    if (!this.newLinkDescription || this.newLinkDescription.trim() === '') {
      JhProgressHUD.showError('请输入描述信息');
      return false;
    }

    // 校验有效期
    if (this.selectedValidity === '自定义') {
      if (!this.customDate || this.customDate.trim() === '') {
        JhProgressHUD.showError('请选择有效期');
        return false;
      }

      // 校验选择的日期是否大于当前日期
      const selectedDate = new Date(this.customDate);
      const currentDate = new Date();
      currentDate.setHours(0, 0, 0, 0); // 设置时分秒为0，只比较日期

      if (selectedDate <= currentDate) {
        JhProgressHUD.showError('有效期必须大于当前日期');
        return false;
      }
    }

    return true;
  }

  // 修改关闭抽屉方法
  closeDrawer() {
    animateTo({
      duration: 250,
      curve: Curve.EaseOut,
      delay: 0,
      onFinish: () => {
        this.isDrawerOpening = false;
        // 重置表单
        this.resetForm();
      }
    }, () => {
      this.drawerWidth = 0;
    })
  }

  // 修改重置表单方法
  private resetForm() {
    this.newLinkUrl = this.shortLink.originUrl;
    this.newLinkDescription = this.shortLink.description || this.shortLink.describe || '';
    this.selectedGroup = this.groups.find(g => g.gid === this.shortLink.gid)?.name || '默认分组';
    
    // 设置有效期
    if (this.shortLink.validityType === 'PERMANENT') {
      this.selectedValidity = '永久';
      this.customDate = '';
      this.selectedDate = null;
    } else {
      this.selectedValidity = '自定义';
      // 设置日期
      if (this.shortLink.validityTime) {
        const date = new Date(this.shortLink.validityTime);
        this.selectedDate = date;
        this.customDate = this.formatDate(date);
      } else if (this.shortLink.validDate) {
        const date = new Date(this.shortLink.validDate);
        this.selectedDate = date;
        this.customDate = this.formatDate(date);
      } else {
        this.customDate = '';
        this.selectedDate = null;
      }
    }
    
    this.selectedGroupIndex = this.groups.findIndex(g => g.gid === this.shortLink.gid);
  }

  // 修改更新方法
  private async updateShortLink() {
    try {
      // 根据 ShortLinkUpdateReqDTO 的定义构造参数
      const params: object = Object({
        originUrl: this.newLinkUrl,
        fullShortUrl: this.shortLink.fullShortUrl,
        originGid: this.shortLink.gid,  // 原始分组标识
        gid: this.groups.find(g => g.name === this.selectedGroup)?.gid,  // 新的分组标识
        validDateType: this.selectedValidity === '永久' ? 0 : 1,  // 0：永久有效 1：自定义
        validDate: this.selectedValidity === '自定义' ? this.customDate + ' 00:00:00' : null,
        describe: this.newLinkDescription  // 使用 describe 而不是 description
      })

      const headers: Record<string, string> = {
        'username': encodeURIComponent(JhAESPreferencesUtils.getString('username') || '')
      };

      const res = await HttpUtils.post(APIs.updateShortLink, params, '', headers)
      if (res.code === '0') {
        JhProgressHUD.showSuccess('短链接编辑成功')
        this.closeDrawer()
        this.onSuccess()
      } else {
        JhProgressHUD.showError('短链接编辑失败')
      }
    } catch (error) {
      JhProgressHUD.showError('短链接编辑失败')
    }
  }

  build() {
    Column() {
      // 弹窗头部
      Row() {
        Text('编辑短链')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textColor)

        Blank()

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
      .width('100%')
      .height(80)
      .padding({ left: 24, right: 24, top: 30, bottom: 24 })
      .border({ width: { bottom: 1 }, color: this.themeBorderColor })

      // 内容区域
      Scroll() {
        Column() {
          // 跳转链接输入
          Row() {
            Text('跳转链接')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColor)
              .width('20%')

            TextInput({
              text: this.newLinkUrl,
              placeholder: '请输入http://或https://开头的链接或者应用跳转链接'
            })
              .placeholderColor('#C9CDD4')
              .width('80%')
              .height(40)
              .backgroundColor(this.themeColorLight)
              .borderRadius(4)
              .border({ width: 1, color: this.themeBorderColor })
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.newLinkUrl = value;
              })
          }
          .width('100%')
          .margin({ top: 24, bottom: 24 })
          .alignItems(VerticalAlign.Center)

          // 描述信息输入
          Row() {
            Text('描述信息')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColor)
              .width('20%')
              .margin({ top: 8 })

            TextArea({
              text: this.newLinkDescription,
              placeholder: '请输入描述信息'
            })
              .placeholderColor('#C9CDD4')
              .width('80%')
              .height(120)
              .backgroundColor(this.themeColorLight)
              .borderRadius(4)
              .border({ width: 1, color: this.themeBorderColor })
              .padding(12)
              .onChange((value: string) => {
                this.newLinkDescription = value;
              })
          }
          .width('100%')
          .margin({ bottom: 24 })
          .alignItems(VerticalAlign.Top)

          // 修改短链分组选择
          Row() {
            Text('短链分组')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColor)
              .width('20%')

            Select(this.groupOptions)
              .selected(this.selectedGroupIndex)
              .value(this.selectedGroup)
              .font({ size: 14, weight: 400 })
              .fontColor(this.textColor)
              .selectedOptionFont({ size: 14, weight: 400 })
              .optionFont({ size: 14, weight: 400 })
              .space(8)
              .arrowPosition(ArrowPosition.END)
              .menuAlign(MenuAlignType.END, { dx: 0, dy: 0 })
              .optionWidth(200)
              .optionHeight(200)
              .width('80%')
              .height(40)
              .backgroundColor(this.themeColorLight)
              .border({ width: 1, color: this.themeBorderColor })
              .borderRadius(4)
              .onSelect((index: number, text?: string) => {
                this.selectedGroupIndex = index;
                if (text) {
                  this.selectedGroup = text;
                }
              })
          }
          .width('100%')
          .margin({ bottom: 24 })
          .alignItems(VerticalAlign.Center)

          // 有效期选择
          Row() {
            Text('有效期')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColor)
              .width('20%')

            Column() {
              Row({ space: 32 }) {
                Row({ space: 4 }) {
                  Radio({ value: '永久', group: 'validity' })
                    .checked(this.selectedValidity === '永久')
                    .onChange((isChecked: boolean) => {
                      if (isChecked) {
                        this.selectedValidity = '永久'
                      }
                    })
                  Text('永久有效')
                    .fontSize(14)
                    .fontColor(this.textColor)
                }

                Row({ space: 4 }) {
                  Radio({ value: '自定义', group: 'validity' })
                    .checked(this.selectedValidity === '自定义')
                    .onChange((isChecked: boolean) => {
                      if (isChecked) {
                        this.selectedValidity = '自定义'
                      }
                    })
                  Text('自定义')
                    .fontSize(14)
                    .fontColor(this.textColor)
                }
              }
              .margin({ left: -8 })

              if (this.selectedValidity === '自定义') {
                Row() {
                  Text('选择日期')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.textColor)
                    .width('20%')
                    .margin({ left: -90, right: 23 })

                  Row() {
                    Text(this.selectedDate ?
                    this.formatDate(this.selectedDate) :
                      '点击选择日期'
                    )
                      .fontSize(14)
                      .fontColor(this.selectedDate ? this.textColor : this.textColorSecondary)
                  }
                  .width('100%')
                  .height(40)
                  .backgroundColor(this.themeColorLight)
                  .border({ width: 1, color: this.themeBorderColor })
                  .borderRadius(4)
                  .padding({ left: 12, right: 12 })
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .onClick(() => {
                    CalendarPickerDialog.show({
                      selected: this.selectedDate || new Date(),
                      onAccept: (value) => {
                        console.info("calendar onAccept:" + JSON.stringify(value));
                        // 更新选中的日期
                        this.selectedDate = new Date(value);
                        this.customDate = this.formatDate(this.selectedDate);
                      },
                      onCancel: () => {
                        console.info("calendar onCancel");
                      },
                      onChange: (value) => {
                        console.info("calendar onChange:" + JSON.stringify(value));
                      },
                      onDidAppear: () => {
                        console.info("calendar onDidAppear");
                      },
                      onDidDisappear: () => {
                        console.info("calendar onDidDisappear");
                      },
                      onWillAppear: () => {
                        console.info("calendar onWillAppear");
                      },
                      onWillDisappear: () => {
                        console.info("calendar onWillDisappear");
                      }
                    })
                  })
                }
                .width('100%')
                .margin({ top: 16 })
                .alignItems(VerticalAlign.Center)
              }
            }
            .width('80%')
          }
          .width('100%')
          .margin({ bottom: 24 })
          .alignItems(VerticalAlign.Top)
        }
        .padding({ left: 24, right: 24, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .padding({ top: 20 })

      // 底部按钮
      Row() {
        Button('取消')
          .width('30%')
          .height(36)
          .fontSize(14)
          .fontColor(this.textColor)
          .backgroundColor(Color.White)
          .borderRadius(4)
          .border({ width: 1, color: this.themeBorderColor })
          .onClick(() => {
            this.closeDrawer();
          })

        Button('确定')
          .width('30%')
          .height(36)
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(this.themeColor)
          .borderRadius(4)
          .onClick(() => {
            if (this.validateForm()) {
              AlertDialog.show({
                title: '编辑确认',
                message: '\n是否确定编辑链接？\n\n',
                primaryButton: {
                  value: '取消',
                  action: () => {
                    console.info('取消编辑');
                  }
                },
                secondaryButton: {
                  value: '确定',
                  action: () => {
                    console.info('编辑成功');
                    this.updateShortLink();
                  }
                },
                alignment: DialogAlignment.Center,
                offset: { dx: 0, dy: -20 }
              })
            }
          })
      }
      .width('100%')
      .padding({
        left: 24,
        right: 24,
        top: 24,
        bottom: 40
      })
      .justifyContent(FlexAlign.SpaceEvenly)
      .backgroundColor(Color.White)
      .border({ width: { top: 1 }, color: this.themeBorderColor })
    }
    .width(500)
    .height('100%')
    .backgroundColor(Color.White)
    .position({ x: '100%' })
    .translate({ x: -this.drawerWidth })
    .animation({
      duration: 250,
      curve: Curve.EaseOut
    })
  }
}