import { webview } from "@kit.ArkWeb"

/** Demo
WebComponent({
src: this.src,
loadProgress: this.loadProgress!!,
title: this.title!!
})
 */

@ComponentV2
export struct WebComponent {
  @Require @Once @Param src: string = ''
  @Param controller: webview.WebviewController = new webview.WebviewController()
  @Param title: string = ''
  @Event $title: (val: string) => void = (val: string) => {
  };
  // 进度条
  @Param loadProgress: number = 0
  @Event $loadProgress: (val: number) => void = (val: number) => {
  };

  build() {
    Web({
      controller: this.controller, renderMode: RenderMode.SYNC_RENDER,
      src: this.src
    })
      .width('100%')
      .height('100%')
      .javaScriptAccess(true)//允许javascript
      .domStorageAccess(true)//允许dom存放数据
      .geolocationAccess(true)//允许定位
      .cacheMode(CacheMode.Online)//设置缓存模式
      .overScrollMode(OverScrollMode.NEVER)
      .onPageEnd(() => {
        this.$title(this.controller.getTitle())
      })
      .onProgressChange((event) => {
        if (event) {
          this.$loadProgress(event.newProgress)
          if (event.newProgress == 100) {
            this.$loadProgress(0)
          }
        }
      })
  }
}