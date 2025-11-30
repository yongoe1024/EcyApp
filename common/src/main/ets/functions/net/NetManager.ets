import { IBestToast } from "@ibestservices/ibest-ui-v2";
import axios, {
  AxiosError,
  AxiosInstance,
  AxiosProgressEvent,
  AxiosRequestConfig,
  AxiosResponse,
  FormData,
  InternalAxiosRequestConfig
} from "@ohos/axios";
import { UserManager } from "../user/UserManager";
import { DownloadParams, ResponseModel, UploadParams } from "./NetModel";
import { fileIo } from "@kit.CoreFileKit";
import { util } from "@kit.ArkTS";
import { EnvironmentManger } from "../environment/EnvironmentManger";
import { AppStorageV2 } from "@kit.ArkUI";
import { GlobalState } from "..";

/**
 * 网络请求管理器
 */
export class NetManager {
  private static instance: NetManager | undefined;
  private axiosInstance: AxiosInstance

  private constructor() {
    this.axiosInstance = axios.create({
      baseURL: EnvironmentManger.getInstance().getBaseUrl(),
      timeout: 5000,
      // headers: {'X-Custom-Header': 'foobar'}
    })
    // 添加请求拦截器
    this.axiosInstance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
      // 对请求数据做点什么
      const token = UserManager.getInstance().token
      if (token) {
        config.headers['Authorization'] = token
      }
      return config;
    }, (error: AxiosError) => {
      // 对请求错误做些什么
      return Promise.reject(error);
    });
    // 添加响应拦截器
    this.axiosInstance.interceptors.response.use((response: AxiosResponse<ResponseModel>) => {
      // 对响应数据做点什么
      const res = response.data
      return Promise.resolve(res as ESObject)
    }, (error: AxiosError) => {
      // 对响应错误做点什么
      IBestToast.show(error.message)
      return Promise.reject(error);
    });
  }

  public static getInstance(): NetManager {
    if (!NetManager.instance) {
      NetManager.instance = new NetManager()
    }
    return NetManager.instance
  }

  /**
   * 自定义请求
   * @param config axios配置
   * @returns 请求结果，只要服务器返回，都算成功，网络错误走catch
   */
  request(config: AxiosRequestConfig): Promise<ResponseModel> {
    return this.axiosInstance.request<ResponseModel, ResponseModel>(config)
  }

  /**
   * 上传文件
   * @throws BusinessError
   * @param context 上下文
   * @param params 上传参数
   * @returns ResponseModel
   */
  async upload(params: UploadParams): Promise<ResponseModel> {
    const state = AppStorageV2.connect(GlobalState)!;
    const cachePath = await this.copyToCache(state.uiAbilityContext!, params.filePath)
    let formData = new FormData()
    formData.append('file', cachePath);
    // 发送请求
    return this.request({
      url: params.url,
      method: 'post',
      data: formData,
      headers: { 'Content-Type': 'multipart/form-data' },
      context: state.uiAbilityContext,
      onUploadProgress: (progressEvent: AxiosProgressEvent): void => {
        if (progressEvent && progressEvent.loaded && progressEvent.total) {
          params.onProgress?.(progressEvent.loaded / progressEvent.total * 100)
        }
      }
    })
  }

  /**
   * 下载，仅能下载到cacheDir目录！,已存在会下载失败
   * @param context 上下文
   * @param params 下载参数
   * @returns ResponseModel
   */
  async download(context: Context, params: DownloadParams): Promise<ResponseModel> {
    context.filesDir
    return this.request({
      url: params.url,
      method: 'get',
      context: context,
      filePath: params.filePath,
      onDownloadProgress: (progressEvent: AxiosProgressEvent): void => {
        if (progressEvent && progressEvent.loaded && progressEvent.total) {
          params.onProgress?.(progressEvent.loaded / progressEvent.total * 100)
        }
      }
    })
  }

  /**
   * 将文件复制到缓存，重命名，得到 internal://cache
   * @throws BusinessError
   */
  private async copyToCache(context: Context, path: string): Promise<string> {
    let dir = context.cacheDir
    let type = path.split('.').pop()
    let uuid = util.generateRandomUUID() + '.' + type
    let pathIO = fileIo.openSync(path, fileIo.OpenMode.READ_ONLY)
    fileIo.copyFileSync(pathIO.fd, `${dir}/${uuid}`)
    fileIo.closeSync(pathIO);
    return `internal://cache/${uuid}`
  }
}