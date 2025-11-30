import { geoLocationManager } from "@kit.LocationKit";
import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { PermissionManager } from "../../utils";
import { AppStorageV2 } from "@kit.ArkUI";
import { GlobalState } from "./..";

export class LocationManager {
  private static DEFAULT_LAT: number = 39.904989;
  private static DEFAULT_LNG: number = 116.405285;
  private static DEFAULT_CITY_CODE: string = "110100";
  private static DEFAULT_CITY_NAME: string = "北京市";
  private static DEFAULT_ADDRESS: string = "北京市";
  private static DEFAULT_PROVINCE: string = "北京市";
  private static instance: LocationManager;

  private constructor() {
  }

  locationRequest: geoLocationManager.SingleLocationRequest = {
    // 快速定位策略(PRIORITY_LOCATING_SPEED)
    'locatingPriority': geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
    // 超时时间设置为10秒
    'locatingTimeoutMs': 10000
  }

  public static getInstance(): LocationManager {
    if (!LocationManager.instance) {
      LocationManager.instance = new LocationManager();
    }
    return LocationManager.instance;
  }


  /**
   * 检查权限与定位开关
   * @throws
   */
  async check(): Promise<void> {
    // 请求权限
    let res = await PermissionManager.requestPermissions(
      ["ohos.permission.APPROXIMATELY_LOCATION", "ohos.permission.LOCATION"],
      '无法获取定位权限，请前往系统设置中开启')
    if (!res) {
      return Promise.reject()
    }
    let locationEnabled = geoLocationManager.isLocationEnabled();
    if (!locationEnabled) {
      // 打开定位设置
      res = await this.openSet()
      if (!res) {
        return Promise.reject()
      }
    }
    return Promise.resolve()
  }

  /**
   * 逆地理编码
   * @throws
   */
  async getAddressByLatLon(lat: number, lon: number): Promise<geoLocationManager.GeoAddress> {
    // 判断服务可用
    let isAvailable = geoLocationManager.isGeocoderAvailable();
    if (isAvailable) {
      let res = await geoLocationManager.getAddressesFromLocation({ "latitude": lat, "longitude": lon, "maxItems": 1 })
      if (res.length > 0) {
        return res[0]
      }
    }
    return Promise.reject()
  }

  /**
   * 地理编码
   * @throws
   */
  async getAddressesFromName(addressName: string) {
    // 判断服务可用
    let isAvailable = geoLocationManager.isGeocoderAvailable();
    if (isAvailable) {
      let res = await geoLocationManager.getAddressesFromLocationName({ "description": addressName, "maxItems": 1 })
      if (res.length > 0) {
        return res[0]
      }
    }
    return Promise.reject()
  }

  /**
   * 打开定位
   * @throws
   */
  private openSet(): Promise<boolean> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const state = AppStorageV2.connect(GlobalState)!;
    return atManager.requestGlobalSwitch(state.uiAbilityContext, abilityAccessCtrl.SwitchType.LOCATION)
  }
}
