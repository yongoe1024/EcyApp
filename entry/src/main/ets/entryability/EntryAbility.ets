import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { IBestInit } from '@ibestservices/ibest-ui-v2/Index';
import { GlobalState, PreferenceManager, RouteManager } from 'common';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    const stage = AppStorageV2.connect(GlobalState)!;
    stage.uiAbilityContext = this.context
    stage.wantParameters = want.parameters
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onCreate');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    const stage = AppStorageV2.connect(GlobalState)!;
    stage.wantParameters = want.parameters
    if (stage.wantParameters && stage.wantParameters.toUrl) {
      RouteManager.getInstance().push({ url: stage.wantParameters.toUrl, params: stage.wantParameters?.params })
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    const stage = AppStorageV2.connect(GlobalState)!;
    stage.windowStage = windowStage
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageCreate');
    let page = ''
    try {
      if (PreferenceManager.hasSync('agreePrivacy')) {
        page = 'pages/Index'
      } else {
        page = 'pages/PrivacyPage'
      }
    } catch (e) {
    }
    windowStage.loadContent(page, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      // 初始化UI组件库
      IBestInit(windowStage, this.context)
      windowStage.getMainWindow()
        .then(win => {
          this.updateWinInfo(win)
        })
        .catch(() => {
          hilog.error(DOMAIN, TAG, 'Failed to get MainWindow');
        })
      hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onBackground');
  }

  /**
   * 存储窗口高度
   */
  updateWinInfo(windowClass: window.Window) {
    const state = AppStorageV2.connect(GlobalState)!;
    let uiContext = windowClass.getUIContext()
    // 设置窗口全屏
    windowClass.setWindowLayoutFullScreen(true)
      .catch(() => {
        hilog.error(DOMAIN, TAG, 'Failed to 设置窗口全屏');
      })
    try {
      // 获取避让区域、窗口高度
      const statusBar = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
      const navigationArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      // 获取状态栏高度
      state.topRectHeight = uiContext.px2vp(statusBar.topRect.height)
      // 获取导航条高度
      state.bottomRectHeight = uiContext.px2vp(navigationArea.bottomRect.height)
      // 获取窗口高度
      const props = windowClass.getWindowProperties()
      state.windowWidth = uiContext.px2vp(props.windowRect.width)
      state.windowHeight = uiContext.px2vp(props.windowRect.height)
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'Failed to 获取避让区域、窗口高度');
    }
    // 注册监听避让区
    windowClass.on('avoidAreaChange', (data) => {
      if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
        const topRectHeight = data.area.topRect.height;
        state.topRectHeight = uiContext.px2vp(topRectHeight)
      } else if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        const bottomRectHeight = data.area.bottomRect.height;
        state.bottomRectHeight = uiContext.px2vp(bottomRectHeight)
      }
    })
    // 监听窗口高度
    windowClass.on('windowSizeChange', (data) => {
      state.windowWidth = uiContext.px2vp(data.width)
      state.windowHeight = uiContext.px2vp(data.height)
      state.widthBreakpoint = uiContext.getWindowWidthBreakpoint();
      state.heightBreakpoint = uiContext.getWindowHeightBreakpoint();
    });
    // 监听键盘高度
    windowClass.on('keyboardHeightChange', (data: number) => {
      AppStorage.setOrCreate('keyboardHeight', px2vp(data))
    })
  }
}
