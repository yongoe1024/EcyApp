import { IBestButton, IBestField, IBestIcon, IBestPasswordInput } from '@ibestservices/ibest-ui-v2';
import { GlobalState, NetManager, RouteManager, UserManager } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function LoginBuilder() {
  Login()
}


@ComponentV2
struct Login {
  @Local phone: string = ''
  // @Local code: string = ''
  @Local state: GlobalState = AppStorageV2.connect(GlobalState)!

  async login() {
    if (!this.phone) {
      this.getUIContext().getPromptAction().showToast({ message: '请输入手机号' })
    }
    UserManager.getInstance().login(this.phone, '')
      .then((res: boolean) => {
        if (res) {
          this.getUIContext().getPromptAction().showToast({ message: '登录成功，即将返回' })
          setTimeout(() => {
            RouteManager.getInstance().pop()
          }, 1000)
        }
      })
  }

  build() {
    NavDestination() {
      RelativeContainer() {
        Stack({ alignContent: Alignment.TopStart }) {
          Image($r('app.media.ic_login_back'))
            .width('100%')
          Image($r('app.media.ic_login_back_up'))
            .width('100%')
          IBestIcon({
            name: 'arrow-left', iconSize: 20, onIconClick: () => {
              RouteManager.getInstance().pop()
            }
          })
            .margin({ top: this.state.topRectHeight, left: 20 })
        }.alignRules({
          'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
        })
        .id('stack')

        Column({ space: 20 }) {
          // 手机号
          IBestField({
            value: this.phone!!,
            label: "手机号",
            placeholder: "请输入手机号",
            bgColor: '#fff7f9fa'
          })
          // IBestPasswordInput({
          //   value: this.code!!,
          //   numberKeyboardConfig:{
          //     extraKey: ".",
          //     styleType: "custom"
          //   }
          // })
          IBestButton({
            buttonSize: 'large',
            text: '登录',
            type: 'primary',
            btnBorderRadius: 8,
            onBtnClick: () => {
              this.login()
            }
          })
        }
        .width('100%')
        .borderRadius({ topLeft: 30, topRight: 30 })
        .backgroundColor('#fff')
        .padding({ top: 40, left: 20, right: 20 })
        .alignRules({
          top: { 'anchor': 'stack', 'align': VerticalAlign.Bottom },
        })
        .offset({ top: -100 })
      }
    }
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }
}