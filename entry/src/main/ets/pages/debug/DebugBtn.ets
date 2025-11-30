import { AppStorageV2, window } from '@kit.ArkUI';
import { EnvironmentManger, GlobalState, RouteManager } from 'common';

// 加载工具球子窗口
export async function showToolBall() {
  // 创建子窗口
  let state: GlobalState = AppStorageV2.connect(GlobalState)!
  state.windowStage!.createSubWindow('debugPage', (err, windowClass) => {
    if (err.code > 0) {
      return;
    }
    try {
      // 设置子窗口加载页
      windowClass.setUIContent('pages/debug/DebugBtn', () => {
        // windowClass.setWindowBackgroundColor('#ff0399ff');
      });
      // 设置子窗口右下坐标
      windowClass.moveWindowTo(vp2px(state.windowWidth * 0.8), vp2px(state.windowHeight * 0.8));
      // 设置子窗口大小
      windowClass.resize(vp2px(40), vp2px(40));
      // 展示子窗口
      windowClass.showWindow();
    } catch (err) {
      console.log('')
    }
  })
}

@Entry
@ComponentV2
struct DebugBtn {
  private floatWindow: window.Window | null = null;
  @Local state: GlobalState = AppStorageV2.connect(GlobalState)!
  @Local offsetX: number = 0
  @Local offsetY: number = 0;

  async aboutToAppear() {
    this.offsetX = vp2px(this.state.windowWidth * 0.8)
    this.offsetY = vp2px(this.state.windowHeight * 0.8)
    // 获取当前悬浮窗实例（用于调整位置）
    this.floatWindow = await window.getLastWindow(getContext(this));
  }

  build() {
    // 可拖动的圆形悬浮内容（示例）
    Text(EnvironmentManger.getInstance().getEnv())
      .textAlign(TextAlign.Center)
      .width('100%')
      .height('100%')
      .fontColor(Color.White)
      .fontSize(12)
      .fontWeight(FontWeight.Bold)
      .borderRadius('50%')
      .backgroundColor('#ff0399ff')
      .onClick(() => {
        RouteManager.getInstance().push({ url: 'ecy://debug' })
      })
      .gesture(
        // 平移手势实现拖动
        PanGesture()
          .onActionUpdate(async (event: GestureEvent) => {
            if (this.floatWindow) {
              // 更新偏移量并移动窗口
              this.offsetX += event.offsetX;
              this.offsetY += event.offsetY;
              this.floatWindow.moveTo(this.offsetX, this.offsetY);
              console.log(this.offsetX + '   ' + this.offsetY)
            }
          })
      )
  }
}