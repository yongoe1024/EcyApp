import { GlobalState, RouteManager, RouteTable } from 'common';
import { AppStorageV2 } from '@kit.ArkUI';
import { showToolBall } from './debug/DebugBtn';

@Entry
@ComponentV2
struct Index {
  @Local state: GlobalState = AppStorageV2.connect(GlobalState)!
  @Local offsetX: number = 0;
  @Local offsetY: number = 0;

  aboutToAppear(): void {
    showToolBall()
  }

  build() {
    Navigation(RouteManager.getInstance().getStack()) {
    }
    .mode(NavigationMode.Stack)
    .onAppear(() => {
      RouteManager.getInstance().push({ url: RouteTable.ENTRY_MAIN, animated: false })
    })
  }
}