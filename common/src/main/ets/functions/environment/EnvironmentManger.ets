import { PreferenceManager } from "../../utils";
import { EnvEnum, GlobalState } from "./GlobalModel";
import { AppStorageV2 } from "@kit.ArkUI";

/**
 * app环境管理器
 */

export class EnvironmentManger {
  private static instance: EnvironmentManger | undefined;
  private env: EnvEnum | undefined
  state: GlobalState = AppStorageV2.connect(GlobalState)!

  private constructor() {
  }

  public static getInstance(): EnvironmentManger {
    if (!EnvironmentManger.instance) {
      EnvironmentManger.instance = new EnvironmentManger()
    }
    return EnvironmentManger.instance
  }

  getEnv(): EnvEnum {
    if (this.env) {
      return this.env
    }
    let last = PreferenceManager.getSync('env', EnvEnum.DEV) as EnvEnum
    this.env = last
    return this.env
  }

  setEnv(e: EnvEnum) {
    if (this.env !== e) {
      PreferenceManager.putSync('env', e)
      // 设置环境后重启应用
      this.restartApp()
    }
  }

  /**
   * 重启应用
   */
  private restartApp(): void {
    let applicationContext = this.state.uiAbilityContext!.getApplicationContext();
    applicationContext.killAllProcesses();
  }

  getBaseUrl(): string {
    switch (this.env) {
      case EnvEnum.DEV:
        return "http://172.20.22.57:8081"
      case EnvEnum.PRD:
        return "http://myprod.com"
      case EnvEnum.TEST:
        return "http://mytest.com"
      default:
        return ''
    }
  }
}