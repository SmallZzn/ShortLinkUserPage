<!-- 调用工具类发送示例 -->
  clickLogin() {
    const params: object = Object({ 'userName': this.name, 'pwd': this.pwd })
    HttpUtils.post(APIs.login, params, '正在登录...').then((res: ResType) => {
      console.log('登录返回数据：', JSON.stringify(res))
      JhProgressHUD.showSuccess(res.msg)
      JhAESPreferencesUtils.saveModel(kUserDefault_UserInfo, res.data)
      router.replaceUrl({ url: 'pages/Index' })
    })
  }