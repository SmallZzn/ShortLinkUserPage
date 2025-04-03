import { promptAction, router } from '@kit.ArkUI';
import { APIs } from '../../JhCommon/http/APIs';
import { HttpUtils } from '../../JhCommon/http/HttpUtils';
import { JhProgressHUD } from '../../JhCommon/components/JhProgressHUD';
import { JhAESPreferencesUtils } from '../../JhCommon/utils/JhPreferencesUtils';
import { GateWayAPIs } from '../../JhCommon/http/GateWayAPIs';

@Entry
@Component
struct AuthPage {
  // 登录相关状态
  @State loginUsername: string = '';
  @State loginPassword: string = '';
  // 注册相关状态
  @State regUsername: string = '';
  @State regPassword: string = '';
  @State regConfirmPassword: string = '';
  @State regPhone: string = '';
  @State regEmail: string = '';
  @State regUserType: number = 1; // 默认选择公司(1)，个人用户为0
  @State regRealName: string = ''; // 添加负责人姓名字段
  @State isLoading: boolean = false;
  @State activeTab: string = 'login'; // 当前激活的选项卡

  aboutToAppear() {
    // 获取UI上下文并初始化JhProgressHUD
    let uiContext: UIContext = this.getUIContext() as UIContext
    JhProgressHUD.initUIConfig(uiContext)
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景图层
      Image($r('app.media.LoginBackground'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .blur(8)// 添加虚化效果
        .opacity(0.8) // 降低不透明度使其更柔和

      // 主要内容
      Column() {
        // 顶部标题
        Text('短链接服务平台')
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ bottom: 60 })

        // 登录/注册容器
        Row() {
          // 左侧区域 - 登录/注册表单
          Column() {
            if (this.activeTab === 'login') {
              this.buildLoginForm()
            } else {
              this.buildRegisterForm()
            }
          }
          .width('50%')
          .height('100%')
          .padding(40)
          .backgroundColor('rgba(255, 255, 255, 0.95)') // 半透明白色背景
          .borderRadius({ topLeft: 16, bottomLeft: 16 })
          .backdropBlur(24) // 玻璃拟态效果

          // 右侧区域 - 提示信息
          Column() {
            if (this.activeTab === 'login') {
              this.buildRegisterPrompt()
            } else {
              this.buildLoginPrompt()
            }
          }
          .width('50%')
          .height('100%')
          .padding(40)
          .backgroundColor('rgba(0, 122, 255, 0.1)') // 半透明主题色背景
          .borderRadius({ topRight: 16, bottomRight: 16 })
          .backdropBlur(24) // 玻璃拟态效果
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width('70%')
        .height('75%')
        .shadow({
          radius: 24,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 4
        })
      }
      .width('100%')
    }
    .width('100%')
    .height('111%')
    .margin({ top: -39 }) // 需要添加此设置
  }

  @Builder
  private buildInput(placeholder: string, value: string, onChange: (v: string) => void, marginBottom: number = 15,
    isPassword = false) {
    Column() {
      TextInput({ text: value, placeholder: placeholder })
        .width('100%')
        .height(45)
        .fontSize(16)
        .placeholderColor('rgba(0, 0, 0, 0.4)')
        .padding({ left: 16, right: 16 })
        .backgroundColor('rgba(255, 255, 255, 0.8)')
        .borderRadius(8)
        .border({ width: 1, color: 'rgba(0, 0, 0, 0.1)' })
        .type(isPassword ? InputType.Password : InputType.Normal)
        .onChange((v: string) => onChange(v))
    }
    .margin({ bottom: marginBottom })
    .width('100%')
  }

  // 登录表单
  @Builder
  private buildLoginForm() {
    Column() {
      Text('欢迎回来')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })
        .fontColor('#333333')

      Text('请登录您的账号')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 40 })

      this.buildInput('请输入用户名', this.loginUsername, (v) => this.loginUsername = v)
      this.buildInput('请输入密码', this.loginPassword, (v) => this.loginPassword = v, 40, true)

      Button('登 录', { stateEffect: true })
        .width('100%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .backgroundColor('#007AFF')
        .borderRadius(25)
        .shadow({ radius: 8, color: 'rgba(0, 122, 255, 0.3)', offsetY: 4 })
        .onClick(() => this.login())
        .enabled(!this.isLoading)
    }
    .width('80%')
    .alignItems(HorizontalAlign.Start)
  }

  // 注册表单
  @Builder
  private buildRegisterForm() {
    Column() {
      // 用户类型选择按钮，宽度100%
      Row() {
        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Text('个人用户')
            .fontSize(18)
            .fontWeight(this.regUserType === 0 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.regUserType === 0 ? Color.White : '#007AFF')
        }
        .backgroundColor(this.regUserType === 0 ? '#007AFF' : 'rgba(0, 122, 255, 0.1)')
        .height(50)
        .width('50%')
        .onClick(() => {
          this.regUserType = 0;
        })

        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Text('公司')
            .fontSize(18)
            .fontWeight(this.regUserType === 1 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.regUserType === 1 ? Color.White : '#007AFF')
        }
        .backgroundColor(this.regUserType === 1 ? '#007AFF' : 'rgba(0, 122, 255, 0.1)')
        .height(50)
        .width('50%')
        .onClick(() => {
          this.regUserType = 1;
        })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 根据用户类型显示不同的表单
      if (this.regUserType === 1) { // 公司
        this.buildInput('公司名称', this.regUsername, (v) => this.regUsername = v)
        this.buildInput('负责人姓名', this.regRealName, (v) => this.regRealName = v)
      } else { // 个人用户
        this.buildInput('用户名', this.regUsername, (v) => this.regUsername = v)
      }

      this.buildInput('密码', this.regPassword, (v) => this.regPassword = v, 15, true)
      this.buildInput('确认密码', this.regConfirmPassword, (v) => this.regConfirmPassword = v, 15, true)
      this.buildInput('手机号', this.regPhone, (v) => this.regPhone = v)
      this.buildInput('邮箱', this.regEmail, (v) => this.regEmail = v, 15)

      Button('注 册', { stateEffect: true })
        .width('100%')
        .height(45)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#007AFF')
        .borderRadius(8)
        .onClick(() => this.handleRegister())
        .enabled(!this.isLoading)
    }
    .width('80%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }

  // 构建注册提示
  @Builder
  private buildRegisterPrompt() {
    Column() {
      Text('还没有账号？')
        .fontSize(24)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 16 })
        .fontColor(Color.White)

      Text('立即注册享受完整服务')
        .fontSize(16)
        .margin({ bottom: 40 })
        .fontColor('rgba(255, 255, 255, 0.8)')

      Button('立即注册', { stateEffect: true })
        .width(200)
        .height(50)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#007AFF')
        .backgroundColor(Color.White)
        .borderRadius(25)
        .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.1)', offsetY: 4 })
        .onClick(() => this.activeTab = 'register')
    }
    .alignItems(HorizontalAlign.Center)
  }

  // 构建登录提示
  @Builder
  private buildLoginPrompt() {
    Column() {
      Text('已有账号？')
        .fontSize(20)
        .margin({ bottom: 15 })
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)


      Text('立即登录查看个人数据')
        .fontSize(16)
        .margin({ bottom: 30 })
        .fontColor(Color.White)


      Button('立即登录', { stateEffect: true })
        .width(200)
        .height(50)
        .fontSize(16)
        .fontColor('#007AFF')
        .backgroundColor(Color.White)
        .borderRadius(25)
        .onClick(() => this.activeTab = 'login')
    }
    .alignItems(HorizontalAlign.Center)
  }

  // 处理登录
  private async login() {
    // 验证登录表单
    if (!this.validateLoginForm()) {
      return;
    }

    const params: object = Object({
      username: this.loginUsername,
      password: this.loginPassword
    });

    try {
      // 设置请求头，对用户名进行URL编码以防止中文乱码
      const headers: Record<string, string> = {
        'username': encodeURIComponent(this.loginUsername)
      };

      // 发送登录请求并等待响应
      const res = await HttpUtils.post(GateWayAPIs.login, params, '正在登录...', headers);
      console.log('登录返回数据：', JSON.stringify(res));

      if (res.code === "0") {
        const token: string = res.data.token;
        // 使用 JhPreferencesUtils 存储 token 和 username
        JhAESPreferencesUtils.saveString('token', token);
        JhAESPreferencesUtils.saveString('username', this.loginUsername);

        promptAction.showToast({ message: '登录成功！' });
        // 跳转到主页时传递用户名
        router.replaceUrl({
          url: 'pages/homePage/Main',
          params: {
            username: this.loginUsername
          }
        });
      } else if (res.message === '用户已登录') {
        const cookiesUsername: string | null = JhAESPreferencesUtils.getString('username');
        if (cookiesUsername === this.loginUsername) {
          promptAction.showToast({ message: '登录成功！' });
          router.replaceUrl({ url: 'pages/Index' });
        } else {
          promptAction.showToast({ message: '用户已在别处登录，请勿重复登录！' });
        }
      } else if (res.message === '用户不存在') {
        promptAction.showToast({ message: '请输入正确的账号密码!' });
      }
    } catch (error) {
    }
  }

  // 处理注册
  private async handleRegister() {
    if (!this.validateRegisterForm()) {
      return;
    }

    this.isLoading = true;
    try {
      interface RegisterParams {
        username: string;
        password: string;
        phone: string;
        mail: string;
        userType: number;
        realName?: string;
      }

      const params: RegisterParams = this.regUserType === 1 ? 
        {
          username: this.regUsername,
          realName: this.regRealName,
          password: this.regPassword,
          phone: this.regPhone,
          mail: this.regEmail,
          userType: this.regUserType
        } : 
        {
          username: this.regUsername,
          password: this.regPassword,
          phone: this.regPhone,
          mail: this.regEmail,
          userType: this.regUserType
        };

      const response = await HttpUtils.post(APIs.register, params);

      if (response.code === '0') {
        promptAction.showToast({ message: '注册成功' });
        // 保存注册的用户名，切换到登录页面后自动填充
        this.loginUsername = this.regUsername;
        // 切换到登录页面
        this.activeTab = 'login';
        // 清空注册表单数据
        this.resetRegisterForm();
      } else {
        promptAction.showToast({ message: response.message || '注册失败' });
      }
    } catch (error) {
      promptAction.showToast({ message: `注册失败: ${(error as Error).message}` });
    } finally {
      this.isLoading = false;
    }
  }

  // 重置注册表单
  private resetRegisterForm() {
    this.regUsername = '';
    this.regPassword = '';
    this.regConfirmPassword = '';
    this.regPhone = '';
    this.regEmail = '';
    this.regRealName = '';
    this.regUserType = 1; // 重置为默认公司
  }

  // 登录表单验证
  private validateLoginForm(): boolean {
    if (!this.loginUsername.trim()) {
      promptAction.showToast({ message: '请输入用户名' });
      return false;
    }
    if (!this.loginPassword.trim()) {
      promptAction.showToast({ message: '请输入密码' });
      return false;
    }
    return true;
  }

  // 注册表单验证
  private validateRegisterForm(): boolean {
    if (!this.regUsername.trim()) {
      promptAction.showToast({ message: this.regUserType === 1 ? '请输入公司名称' : '请输入用户名' });
      return false;
    }
    if (this.regUserType === 1 && !this.regRealName.trim()) {
      promptAction.showToast({ message: '请输入负责人姓名' });
      return false;
    }
    if (!this.regPassword) {
      promptAction.showToast({ message: '请输入密码' });
      return false;
    }
    if (this.regPassword !== this.regConfirmPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致' });
      return false;
    }
    if (!/^1[3-9]\d{9}$/.test(this.regPhone)) {
      promptAction.showToast({ message: '请输入有效的手机号' });
      return false;
    }
    if (!/^\w+([-+.]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$/.test(this.regEmail)) {
      promptAction.showToast({ message: '请输入有效的邮箱地址' });
      return false;
    }
    return true;
  }
}
