import { IBestButton } from "@ibestservices/ibest-ui-v2"
import { GlobalState, PreferenceManager } from "common"
import { AppStorageV2, router } from "@kit.ArkUI"
import { common, UIAbility } from "@kit.AbilityKit"

@Entry
@ComponentV2
struct PrivacyPage {
  @Local state: GlobalState = AppStorageV2.connect(GlobalState)!

  build() {
    Column() {
      Text('温馨提示')
        .textAlign(TextAlign.Center)
        .fontSize(18)
        .fontColor('#000')
        .fontWeight(FontWeight.Bold)

      Row() {
        Text("我们深知个人信息对您的重要性，我们将按法律法规要求，采取相应安全措施，尽全力保护您的个人信息安全可控。")
          .textAlign(TextAlign.Start)
          .fontSize(14)
          .fontColor('#333')
          .margin({ top: 16 })
      }.width('100%')

      Row() {
        Text() {
          Span('在使用 ECY-APP 产品或服务前，请您务必同意')
            .fontSize(14)
            .fontColor('#333')

          Span('《ECY-APP服务协议》')
            .fontColor('#ff1e90de')
            .fontSize(14)
            .onClick(() => {
              // todo 跳转到浏览器
            })
          Span('《隐私政策》')
            .fontColor('#ff1e90de')
            .fontSize(14)
            .onClick(() => {
              // todo 跳转到浏览器
            })

          Span('。若您仍不同意本隐私政策，很遗憾我们将无法为你提供服务。')
            .fontSize(14)
            .fontColor('#333')
        }
        .textAlign(TextAlign.Start)
        .fontSize(14)
        .fontColor("#333333")
        .margin({ top: 8 })
      }.width('100%')

      Column({ space: 10 }) {
        IBestButton({
          text: '同意',
          type: 'primary',
          btnWidth: '100%',
          onBtnClick: () => {
            PreferenceManager.putSync('agreePrivacy', true)
            router.push({ url: 'pages/Index' })
          }
        })
        IBestButton({
          btnWidth: '100%',
          text: '不同意',
          onBtnClick: () => {
            const context = this.getUIContext().getHostContext() as common.UIAbilityContext
            context.terminateSelf()
          }
        })
      }.margin({
        top: 24,
        bottom: 24
      })
    }
    .padding({ left: 20, right: 20, top: 30 + this.state.topRectHeight })
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}