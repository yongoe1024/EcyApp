import { NetManager } from "../net/NetManager";
import { UserCallback } from "./UserCallback";
import { UserModel } from "./UserModel";
import { IBestToast } from "@ibestservices/ibest-ui-v2";
import { PreferenceManager } from "../../utils";

/**
 * 用户管理器
 */
export class UserManager {
  private static instance: UserManager | undefined;
  private loginListeners: UserCallback[] = []
  private userModel: UserModel | undefined
  private _token: string | undefined

  private constructor() {
  }

  public static getInstance(): UserManager {
    if (!UserManager.instance) {
      UserManager.instance = new UserManager()
    }
    return UserManager.instance
  }

  /**
   * 注册登陆事件
   */
  registerListener(listener: UserCallback): void {
    // 避免重复添加相同回调
    if (!this.loginListeners.includes(listener)) {
      this.loginListeners.push(listener);
    }
  }

  /**
   * 取消注册
   */
  unRegisterListener(listener: UserCallback): void {
    // 找到回调在数组中的索引并删除
    const index = this.loginListeners.findIndex(cb => cb === listener);
    if (index !== -1) {
      this.loginListeners.splice(index, 1);
    }
  }

  /**
   * 获取token，会持久化
   */
  get token(): string {
    if (this._token) {
      return this._token
    }
    let token = PreferenceManager.getSync('token', '') as string
    if (token) {
      this._token = token
      return token
    } else {
      return ''
    }
  }

  /**
   * 设置token，会持久化
   */
  set token(str: string) {
    PreferenceManager.putSync('token', str)
    this._token = str
  }

  /**
   * 登录
   * @param phone 手机号
   * @param code 验证码
   * @returns 登录结果
   */
  async login(phone: string, code: string): Promise<boolean> {
    const res = await NetManager.getInstance().request({
      method: 'post',
      url: 'login',
      data: {
        phone: phone,
        code: code
      }
    })
    if (res.code == 200) {
      this.token = res.data
      let user = await UserManager.getInstance().getUserInfo()
      if (user) {
        this.loginListeners.forEach((item) => {
          item.onLogin?.()
        })
        return true
      }
    } else {
      IBestToast.show('未知错误' + JSON.stringify(res))
    }
    return false
  }

  /**
   * 用户信息
   * @param refresh 是否请求接口刷新
   * @returns 不存在则返回undefined
   */
  async getUserInfo(refresh?: boolean): Promise<UserModel | undefined> {
    if (this.userModel && !refresh) {
      return this.userModel
    }
    let res = await NetManager.getInstance().request({
      method: 'post',
      url: 'getUserInfo',
    })
    if (res.code == 200) {
      this.userModel = res.data
      return this.userModel
    } else if (res.code == 401) {
      this.token = ''
      IBestToast.show('无法获取用户信息，请登录')
    } else {
      IBestToast.show('无法获取用户信息，未知错误')
    }
    this.userModel = undefined
    return undefined
  }

  /**
   * 退出登录
   * @returns
   */
  async logout(): Promise<void> {
    let res = await NetManager.getInstance().request({
      method: 'post',
      url: 'logout',
    })
    if (res.code == 200) {
      this.userModel = undefined
      this.token = ''
      this.loginListeners.forEach((item) => {
        item.onLogout?.()
      })
    } else {
      IBestToast.show('无法退出：' + JSON.stringify(res))
    }
  }

  /**
   * ecy后端特性，获取头像链接
   */
  // getAvatar(): string | undefined {
  //   const avatar = this.userModel?.avatar
  //   if (avatar) {
  //     let url = new uri.URI(EnvironmentManger.getInstance().getBaseUrl())
  //       .addSegment(avatar)
  //     return url.toString()
  //   } else {
  //     return undefined
  //   }
  // }
}