import { Group, SelectOption } from "../../model/LoginInterfaces";

@Component
export struct AddBatchLinks {
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
  // 添加onSuccess回调函数
  onSuccess?: () => void;

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
  private formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
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
    // 使用辅助函数创建选项
    this.groupOptions = this.groups.map(group => 
      this.createSelectOption(group.name, group.name)
    );
  }

  // 关闭抽屉
  closeDrawer() {
    animateTo({
      duration: 250,
      curve: Curve.EaseOut,
      delay: 0,
      onFinish: () => {
        this.isDrawerOpening = false;
        // 重置所有状态
        this.newLinkUrl = '';
        this.newLinkDescription = '';
        this.selectedValidity = '永久';
        this.customDate = '';
        this.selectedDate = null;
        this.selectedGroup = this.groups.length > 0 ? this.groups[0].name : '默认分组';
        this.selectedGroupIndex = 0;
      }
    }, () => {
      this.drawerWidth = 0;
    })
  }

  build() {
    Column() {
      // 弹窗头部
      Row() {
        Text('批量新建短链')
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
          // 跳转链接输入 - 高度增加为三倍
          Row() {
            Text('跳转链接')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.textColor)
              .width('20%')

            TextArea({
              text: this.newLinkUrl,
              placeholder: '请输入http://或https://开头的链接或应用跳转链接，一行一个，最多100行'
            })
              .placeholderColor('#C9CDD4')
              .width('80%')
              .height(120)  // 设置为原来的三倍
              .backgroundColor(this.themeColorLight)
              .borderRadius(4)
              .border({ width: 1, color: this.themeBorderColor })
              .padding({ left: 12, right: 12 })
          }
          .width('100%')
          .margin({ bottom: 24 })
          .alignItems(VerticalAlign.Top)

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
              placeholder: '请输入描述信息，一行一个，描述信息行数请与链接行数相等'
            })
              .placeholderColor('#C9CDD4')
              .width('80%')
              .height(120)
              .backgroundColor(this.themeColorLight)
              .borderRadius(4)
              .border({ width: 1, color: this.themeBorderColor })
              .padding(12)
          }
          .width('100%')
          .margin({ bottom: 24 })
          .alignItems(VerticalAlign.Top)

          // 短链分组选择
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
                  .padding({ left: 12, right: 12 })
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .onClick(() => {
                    CalendarPickerDialog.show({
                      selected: this.selectedDate || new Date(),
                      onAccept: (value) => {
                        this.selectedDate = new Date(value);
                        this.customDate = this.formatDate(this.selectedDate);
                      },
                      onCancel: () => {
                        console.info("calendar onCancel");
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
            this.closeDrawer();
            // 调用成功回调
            this.onSuccess?.();
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