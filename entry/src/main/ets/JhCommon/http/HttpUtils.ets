///  HttpUtils.ets
///
///  Created by iotjin on 2024/08/09. 
///  description: 网络请求工具类（axios二次封装）

import { AxiosError, AxiosResponse } from '@ohos/axios';
import { JhProgressHUD } from '../components/JhProgressHUD';
import Request from './Request';

// 日志开关
const isOpenLog = true

export enum Method {
  get = 'get',
  post = 'post',
  put = 'put',
  patch = 'patch',
  delete = 'delete',
  head = 'head',
}

export interface ResType {
  code: string
  message: string
  suc: boolean
  data: ESObject
  total: number
}

export interface ErrorType {
  code: number
  msg: string
}

export class HttpUtils {
  public static get(
    url: string,
    params?: Record<string, ESObject>,
    loadingText: string = "",
    headers?: Record<string, string>
  ) {
    return HttpUtils.request(Method.get, url, params, loadingText, headers)
  }

  public static post(
    url: string,
    params?: Record<string, ESObject>,
    loadingText: string = "",
    headers?: Record<string, string>
  ) {
    return HttpUtils.request(Method.post, url, params, loadingText, headers)
  }

  public static put(
    url: string,
    params?: Record<string, ESObject>,
    loadingText: string = "",
    headers?: Record<string, string>
  ) {
    return HttpUtils.request(Method.put, url, params, loadingText, headers)
  }

  public static delete(
    url: string,
    params?: Record<string, ESObject>,
    loadingText: string = "加载中...",
    headers?: Record<string, string>
  ) {
    return HttpUtils.request(Method.delete, url, params, loadingText, headers)
  }

  public static request(
    method: Method,
    url: string,
    params?: Record<string, ESObject>,
    loadingText: string = "",
    headers?: Record<string, string>
  ): Promise<ResType> {
    return new Promise<ResType>((resolve, reject) => {

      // 参数处理（如果需要加密等统一参数）
      if (isOpenLog) {
        console.log('---------- HttpUtils URL ----------')
        console.log(url)
        console.log('---------- HttpUtils params ----------')
        console.log(JSON.stringify(params))
      }

      let queryParameters: ESObject = null
      let data: ESObject = null
      if (method == Method.get || method == Method.delete) {
        queryParameters = params
      }
      if (method == Method.post || method == Method.put) {
        data = params
      }

      if (loadingText != null && loadingText.length > 0) {
        JhProgressHUD.showLoadingText(loadingText)
      }

      Request({
        url: url,
        method: method,
        params: queryParameters,
        data: data,
        headers: headers
      }).then((res: AxiosResponse) => {
        if (isOpenLog) {
          console.log('---------- HttpUtils response ----------')
          console.log(JSON.stringify(res))
        }
        if (loadingText != null && loadingText.length > 0) {
          JhProgressHUD.hide()
        }

        const code: string = res['code']
        const message: string = res['message']
        if (code === "0") {
          let result: ResType = {
            code: code,
            message: message,
            suc: res['suc'],
            data: res['data'],
            total: res['total'],
          }
          resolve(result)
        } else {
          JhProgressHUD.showText(message || '系统错误')
          reject({ code: code, message: message })
        }
      }).catch((err: AxiosError) => {
        console.log("HttpUtils err:" + err.message)
        if (loadingText != null && loadingText.length > 0) {
          JhProgressHUD.hide()
        }
        JhProgressHUD.showText(err.message || '系统错误')
        reject({ code: err.code, msg: err.message })
      })
    })
  }
}