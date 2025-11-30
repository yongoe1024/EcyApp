/** Demo
 @Builder
 function demo(){
 MapContainer({
 adHeight: this.adHeight,
 topEmptyHeight: 10,
 cardOtherHeight: 10,
 winState: this.state,
 snapPagination: 260,
 initialOffset: 260,
 cardHeight: this.cardHeight,
 mapBuilder: this.mapBu,
 cardBuilder: this.cardBu,
 scrollBuilder: this.scrollBu
 })
 }
 */


@Builder
function emptyBuilder() {
}

@Component
export struct MapContainer {
  @Link adHeight: number
  //状态栏
  @StorageProp('topNavbarHeight') topNavbarHeight: number = 38
  //顶部间隙，不算状态栏
  topEmptyHeight: number = 10
  //底部附加距离
  cardOtherHeight: number = 10
  @Link winState: number // 0一半 1拉下来  2  拉上去
  // 滑动偏移
  @State winOffset: number = 0
  //整体高度
  @State winHeight: number = 0
  scroller: Scroller = new Scroller();
  //滑动断点
  snapPagination: number = 300
  //初始化偏移（等于断点）
  initialOffset: number = 300
  //卡片高度
  @Link cardHeight: number

  @Builder
  emptyBuilder() {
  }

  @BuilderParam
  mapBuilder: () => void = emptyBuilder
  @BuilderParam
  cardBuilder: () => void = emptyBuilder
  @BuilderParam
  scrollBuilder: () => void = emptyBuilder

  build() {
    Column() {
      if (this.winHeight > 0) {
        Stack({ alignContent: Alignment.Bottom }) {
          // 背景区
          Column() {
            this.mapBuilder()
          }
          .width('100%')
          .height('100%')
          .id('map')

          // 高度排除顶部留白 和 状态栏
          Scroll(this.scroller) {
            Column() {
              // 留白区
              // 高度排除顶部留白 和 状态栏 和 底部卡片附加高度
              Column()
                .width('100%')
                .height(`calc(100% - ${this.cardHeight}vp - ${this.cardOtherHeight}vp)`)
              // 内容区
              Column() {
                // 卡片区
                Column() {
                  this.cardBuilder()
                }

                // 卡片下面，嵌套滚动
                Scroll() {
                  Column() {
                    this.scrollBuilder()
                  }
                  .constraintSize({
                    minHeight: '100%'
                  })
                  .justifyContent(FlexAlign.Start)
                  .width('100%')
                }
                .padding({ left: 10, right: 10 })
                .backgroundColor('#ffedf0f5')
                .edgeEffect(EdgeEffect.None)
                .scrollBar(BarState.Off)
                .nestedScroll({
                  scrollForward: NestedScrollMode.PARENT_FIRST,
                  scrollBackward: NestedScrollMode.SELF_FIRST
                })
                .height(`calc(100% - ${this.cardHeight}vp)`)
                .width('100%')
              }
              .width('100%')
            }
          }
          .id('list')
          .height(`calc(100% - ${this.topNavbarHeight}vp - ${this.topEmptyHeight}vp)`)
          .width('100%')
          .edgeEffect(EdgeEffect.None)
          .scrollBar(BarState.Off)
          .scrollSnap({
            snapAlign: ScrollSnapAlign.START,
            snapPagination: [this.snapPagination],
            enableSnapToStart: true,
            enableSnapToEnd: true
          })
          .onScrollStop(() => {
            let x = this.scroller.currentOffset()
            if (this.scroller.isAtEnd()) {
              //拉上去
              this.winState = 2
            }
            if (Math.floor(x.yOffset) == Math.floor(this.snapPagination)) {
              // 中间
              this.winState = 0
            }
            if (Math.floor(x.yOffset) < 1) {
              // 拉下来
              this.winState = 1
            }
          })
          .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState) => {
            this.winOffset += yOffset
          })
          .initialOffset({ yOffset: this.initialOffset })
          .id('list')
        }
        .width('100%')
        .height('100%')
        .onChildTouchTest((touchInfo) => {
          // 空白填充区
          let white = this.winHeight - this.cardHeight - this.cardOtherHeight
          // 减去复位键
          white = white - 42
          if (this.winState == 0 && this.adHeight > 1) {
            white = white - this.adHeight
          }
          for (let info of touchInfo) {
            if (info.id == 'list') {
              if (info.parentY < white - this.winOffset) {
                return { id: 'map', strategy: TouchTestStrategy.FORWARD }
              } else {
                return { id: 'list', strategy: TouchTestStrategy.FORWARD }
              }
            }
          }
          return { strategy: TouchTestStrategy.FORWARD }
        })

      }
    }
    .width('100%')
    .height('100%')
    .onAreaChange((o, n) => {
      this.winHeight = n.height as number
    })
  }
}