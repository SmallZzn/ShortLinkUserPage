import { Group } from '../../model/LoginInterfaces';

@Component
export struct GroupPicker {
  @Prop showGroupPicker: boolean;
  @Prop selectedGroup: string;
  @Link groups: Group[];
  public onGroupSelect?: (groupName: string) => void;
  public onClose?: () => void;

  build() {
    if (this.showGroupPicker) {
      Column() {
        // 蒙层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .onClick(() => this.onClose?.())

        // 弹窗主体
        Column() {
          Text('选择分组')
            .fontSize(18)
            .margin({ bottom: 16 })

          List({ space: 8 }) {
            ForEach(this.groups, (group: Group) => {
              ListItem() {
                Text(group.name)
                  .fontSize(16)
                  .fontColor(this.selectedGroup === group.name ? '#007AFF' : '#000000')
                  .padding(12)
                  .onClick(() => {
                    this.onGroupSelect?.(group.name);
                    this.onClose?.();
                  })
              }
              .borderRadius(8)
              .backgroundColor('#FFFFFF')
            })
          }
          .height(400)
          .width('100%')

          Button('取消')
            .width('100%')
            .margin({ top: 16 })
            .onClick(() => this.onClose?.())
        }
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .width('80%')
      }
    }
  }
}