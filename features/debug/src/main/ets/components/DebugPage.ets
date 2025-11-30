import { EnvEnum, EnvironmentManger, GlobalState } from "common"
import { AppStorageV2 } from "@kit.ArkUI"

@Builder
export function DebugPageBuilder() {
  DebugPage()
}

@ComponentV2
struct DebugPage {
  @Local state: GlobalState = AppStorageV2.connect(GlobalState)!

  @Builder
  card(str: string, event: () => void) {
    GridItem() {
      // 正方形 Row 容器
      Row() {
        Text(str)
          .fontColor('#fff')
          .fontSize(14)
          .textAlign(TextAlign.Center)
          .flexGrow(1)
      }
      .backgroundColor('#ff0399ff')
      .borderRadius(8)
      .aspectRatio(1)
      .width('100%')
    }
    .onClick(event)
  }

  build() {
    NavDestination() {
      Grid() {
        this.card('环境切换', () => {
          this.getUIContext().showTextPickerDialog({
            range: Object.values(EnvEnum),
            onAccept: (value: TextPickerResult) => {
              EnvironmentManger.getInstance().setEnv(value.value! as EnvEnum)
            }
          });
        })
      }
      .padding({ left: 20, right: 20 })
      .columnsTemplate('1fr 1fr 1fr 1fr') // 4列等分
      .columnsGap(8) // 列间距
      .rowsGap(8) // 行间距（若有多行）
      .width('100%')
      .padding(16)
    }
    .padding({ top: this.state.topRectHeight })
    .title('调试工具')
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }
}