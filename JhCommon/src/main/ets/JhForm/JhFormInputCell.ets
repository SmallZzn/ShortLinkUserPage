///  JhFormInputCell.ets
///
///  Created by iotjin on 2024/08/19. 
///  description: 输入行样式（左侧title,右侧输入框(默认多行可换行)，可加自定义widget）

import { KColors } from '../JhCommon/configs/Colors'
import { JhTextArea } from './JhTextArea'
import { JhTextInput } from './JhTextInput'

const _maxLength = 100
const _titleFontSize = 15.0
const _textFontSize = 15.0
const _hintFontSize = 15.0
const _titleColor = KColors.kFormTitleColor
const _textColor = KColors.kFormInfoColor
const _hintColor = KColors.kFormHintColor
const _themeColor = KColors.kThemeColor
const _lineColor = KColors.kFormLineColor

const _titleWidth = 100 // 左侧title默认宽
const _cellHeight = 45 // 设置label高度为55，否则是45


@Preview
@Component
export struct JhFormInputCell {
  @Prop public title?: ResourceStr = ''
  @Prop public labelText?: ResourceStr = '' // top提示文字
  @Prop public showRedStar: boolean = false // 显示左侧小红星，默认不显示
  @Prop public titleWidth: number = _titleWidth // 标题宽度
  @Prop public titleStyle: TextStyle = { fontSize: _titleFontSize, fontColor: _titleColor }
  @Prop public labelTextStyle: TextStyle = { fontSize: _hintFontSize, fontColor: _hintColor }
  @Prop public borderAnimation: boolean = false // 下划线动画，默认false
  @Prop public borderHighlight: boolean = false // 下划线高亮，默认false
  @Prop public hiddenLine: boolean = false // 隐藏底部下划线，默认false
  @BuilderParam leftWidget?: () => void // 左侧自定义组件，默认隐藏，优先级高于title，高度为cellHeight,宽度为titleWidth
  @BuilderParam rightWidget?: () => void // 右侧自定义组件，默认隐藏，高度为cellHeight，设置宽度会压缩录入框的宽度
  @Prop public isTextArea: boolean = true // 是否是多行录入框(多行没有右侧删除按钮和密码模式)
  // JhTextInput / JhTextArea 属性
  @Prop public text?: ResourceStr = ''
  @Prop public placeholder?: ResourceStr = '请输入'
  @Prop public errorText?: ResourceStr | undefined = '' // 错误提示文字
  @Prop public textStyle: TextStyle = { fontSize: _textFontSize, fontColor: _textColor }
  @Prop public hintTextStyle: TextStyle = { fontSize: _hintFontSize, fontColor: _hintColor }
  @Prop public inputType: InputType | TextAreaType = InputType.Normal // 输入框类型
  @Prop public enterKeyType: EnterKeyType = EnterKeyType.Done // 输入法回车键类型
  @Prop public textAlign: TextAlign = TextAlign.Start // 输入文字对齐方式，默认左对齐
  @Prop public maxLength: number = _maxLength // 最大长度，默认_maxLength
  @Prop public isShowBorder: boolean = false // 是否显示边框，默认不显示
  @Prop public isPwd: boolean = false // 是否是密文，默认不是(单行生效)
  @Prop public isShowDeleteBtn: boolean = true // 是否显示右侧删除按钮，默认不显示(单行生效)
  @Prop public showCounter: boolean = false // 是否显示右下角计数器, 配合maxLength使用(多行生效)
  @Prop public inputFilter: ResourceStr = '' // 通过正则表达式设置输入过滤器
  public inputCallBack?: (value: ResourceStr) => void // 录入改变回调
  public inputDoneCallBack?: (value: ResourceStr, isEditing: boolean) => void // 录入完成回调（失去焦点或者点击键盘右下角按钮触发）
  // private
  @State private isEditing: boolean = false
  @State private activeColor: ResourceColor = _themeColor
  @State private cellHeight: number = _cellHeight // 右侧录入框的高度，单行高度为_cellHeight，多行最小为_cellHeight

  build() {
    Stack({ alignContent: Alignment.TopStart }) {

      Row() {
        // left
        if (this.isShowLeftWidget()) {
          Row() {
            if (this.leftWidget) {
              this.leftWidget()
            } else {
              Text(this.showRedStar ? '*' : '')
                .fontColor(Color.Red)
                .fontSize(18)
                .width(8)
              Text(this.title)
                .fontColor(this.titleStyle.fontColor)
                .fontSize(this.titleStyle.fontSize)
                .textAlign(TextAlign.Start)
            }
          }
          .justifyContent(FlexAlign.Start)
          .margin({ top: this.getTopMargin() })
          .padding({ left: 5, right: 5 })
          .width(this.titleWidth)
          .height(this.cellHeight)
        }

        // center
        Row() {
          this.inputBuilder()
        }
        .layoutWeight(1)

        // right
        Row() {
          if (this.rightWidget) {
            this.rightWidget()
          }
        }
        .margin({ top: this.isActivated() ? 0 : this.getTopMargin() })
        .height(this.cellHeight)
      }

      // label text
      if (this.isActivated()) {
        Text(this.labelText)
          .fontColor(this.isEditing ? this.activeColor : this.labelTextStyle.fontColor)
          .fontSize(this.labelTextStyle.fontSize)
          .margin({ left: this.isShowLeftWidget() ? this.titleWidth : 0 })
          .position({ x: 0, y: this.isActivated() ? 0 : this.getTopMargin() + 8 })
          .translate({ x: 0, y: -0 })
          .animation({ duration: 100, curve: Curve.Linear })
      }

      // bottom line
      this.lineBuilder()
    }
    // .align(Alignment.TopStart)
    .width('100%')
    .constraintSize({ minHeight: this.getCellHeight() })
  }

  isShowLeftWidget() {
    return this.leftWidget || this.title
  }

  isActivated() {
    return this.isEditing || this.text !== ''
  }

  getCellHeight() {
    return this.labelText ? this.cellHeight + 10 : this.cellHeight
  }

  getTopMargin() {
    return this.labelText ? 10 : 0
  }

  @Builder
  inputBuilder() {
    if (!this.isTextArea) {
      JhTextInput({
        text: this.text,
        placeholder: this.placeholder,
        // placeholder: this.isEditing ? '' : this.placeholder,
        textStyle: this.textStyle,
        hintTextStyle: this.hintTextStyle,
        inputType: this.inputType as InputType,
        enterKeyType: this.enterKeyType,
        textAlign: this.textAlign,
        cursorColor: this.activeColor,
        bottomLineColor: this.activeColor,
        maxLength: this.maxLength,
        isShowBorder: this.isShowBorder,
        isPwd: this.isPwd,
        isShowDeleteBtn: this.isShowDeleteBtn,
        inputFilter: this.inputFilter,
        inputCallBack: (value: ResourceStr) => {
          this.text = value
          this.inputCallBack?.(value)
        },
        inputDoneCallBack: (value: ResourceStr, isEditing: boolean) => {
          this.isEditing = isEditing
          this.inputDoneCallBack?.(value, isEditing)
        },
      })
        .id('JhTextInputId')
        .width('100%')
        .height(_cellHeight)
        .margin({ top: this.getTopMargin() })
    } else {
      JhTextArea({
        text: this.text,
        placeholder: this.placeholder,
        // placeholder: this.isEditing ? '' : this.placeholder,
        textStyle: this.textStyle,
        hintTextStyle: this.hintTextStyle,
        inputType: this.inputType as TextAreaType,
        enterKeyType: this.enterKeyType,
        textAlign: this.textAlign,
        cursorColor: this.activeColor,
        bottomLineColor: this.activeColor,
        maxLength: this.maxLength,
        isShowBorder: this.isShowBorder,
        showCounter: this.showCounter,
        inputFilter: this.inputFilter,
        inputCallBack: (value: ResourceStr) => {
          this.text = value
          this.inputCallBack?.(value)
        },
        inputDoneCallBack: (value: ResourceStr, isEditing: boolean) => {
          this.isEditing = isEditing
          this.inputDoneCallBack?.(value, isEditing)
        },
      })
        .id('JhTextAreaId')
        .width('100%')
        .constraintSize({ minHeight: _cellHeight })
        .margin({ top: this.getTopMargin() })
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          this.cellHeight = newValue.height as number
        })
    }
  }

  @Builder
  lineBuilder() {
    if (!this.hiddenLine) {
      Line()
        .width('100%')
        .height(1)
        .backgroundColor(this.borderHighlight ? this.activeColor : _lineColor)
        .position({ x: 0, y: this.getCellHeight() - 1 })
        .scale({ x: this.isEditing ? 1 : 0, centerX: 0 })
        .animation(this.borderAnimation ? { duration: 100, curve: Curve.Linear } : null)
      if (!this.isEditing) {
        Line()
          .width('100%')
          .height(1)
          .backgroundColor(_lineColor)
          .position({ x: 0, y: this.getCellHeight() - 1 })
      }
    }
  }
}