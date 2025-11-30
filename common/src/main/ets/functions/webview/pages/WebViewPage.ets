import { webview } from "@kit.ArkWeb"
import { BusinessError } from "@kit.BasicServicesKit"
import { IBestIcon, IBestNavBar } from "@ibestservices/ibest-ui-v2"
import { WebComponent } from "../components/WebComponent"
import { GlobalState, RouteManager } from "../.."
import { AppStorageV2 } from "@kit.ArkUI"

@Builder
export function WebViewPageBuilder() {
  WebViewPage()
}

/**
 * web框架
 */
@ComponentV2
export struct WebViewPage {
  @Local src: string = ''
  @Local loadProgress: number = 0
  @Local title: string = ''
  controller: webview.WebviewController = new webview.WebviewController()
  @Local state: GlobalState = AppStorageV2.connect(GlobalState)!

  pop() {
    try {
      let result = this.controller.accessBackward();
      if (result) {
        this.controller.backward();
      } else {
        RouteManager.getInstance().pop()
      }
    } catch (error) {
      console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
    }
  }

  @Builder
  leftBuilder() {
    Row({ space: 10 }) {
      IBestIcon({
        name: 'arrow-left', iconSize: 20, onIconClick: () => {
          this.pop()
        }
      })

      IBestIcon({
        name: 'cross', iconSize: 20, onIconClick: () => {
          RouteManager.getInstance().pop()
        }
      })
    }
  }

  build() {
    NavDestination() {
      IBestNavBar({
        leftBuilder: (): void => this.leftBuilder(),
        isShowStatusBar: true,
        title: this.title,
        onLeftClick: () => {
          this.pop()
        }
      })
      Stack({ alignContent: Alignment.Top }) {
        WebComponent({
          src: this.src,
          loadProgress: this.loadProgress!!,
          title: this.title!!,
          controller: this.controller
        })
        Progress({ value: 0, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(2)
          .value(this.loadProgress)
          .visibility(this.loadProgress == 100 || this.loadProgress == 0 ? Visibility.Hidden : Visibility.Visible)
      }
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      let params = context.pathInfo.param as Record<string, string>
      if (params) {
        this.src = params.src
      }
    })
    .onBackPressed(() => {
      this.pop()
      return true
    })
  }
}

