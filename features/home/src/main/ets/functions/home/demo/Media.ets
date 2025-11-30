import { BusinessError } from '@kit.BasicServicesKit'
import { MediaManager, MediaState } from 'common/src/main/ets/utils/MediaManager'


@Builder
export function MediaBuilder() {
  Media();
}

@Component
struct Media {
  @State state1: MediaState = {} as MediaState
  @State state2: MediaState = {} as MediaState
  manager1 ?: MediaManager
  //为了初始化Xcomp
  @State manager2 ?: MediaManager = undefined
  controller: XComponentController = new XComponentController();

  //毫秒转时间格式
  numberToTime(num: number) {
    const ms = num % 1000 //秒
    const sd = (num - ms) / 1000
    const s = sd % 60
    if (sd > 60) {
      const m = (sd - s) / 60 % 60
      return m.toString().padStart(2, '0') + ':' + s.toString().padStart(2, '0')
    }
    return '00:' + s.toString().padStart(2, '0')
  }

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        Row() {
          Button('创建2个实例').onClick(async (event: ClickEvent) => {
            this.manager1 = await MediaManager.create(getContext(), {
              playMode: 'SINGLE',
              fileList: ['media1.mp3', 'media2.mp3'],
              audioRendererInfo: undefined,
              onChange: (state: MediaState) => {
                this.state1 = state
              }
            })
            this.manager2 = await MediaManager.create(getContext(), {
              playMode: 'ORDER',
              fileList: [],
              audioRendererInfo: undefined,
              onChange: (state: MediaState) => {
                this.state2 = state
              }
            })
          })
        }

        Row() {
          Button(`进度：${this.numberToTime(this.state1.time)}`)
          Button(`时长：${this.numberToTime(this.state1.duration)}`)
        }

        Row() {
          Button('设置音乐1').onClick(async (event: ClickEvent) => {
            try {
              await this.manager1?.setAndPlay(0)
            } catch (e) {
              this.getUIContext().getPromptAction().showToast({ message: e.message });
            }
          })
          Button('设置音乐2').onClick(async (event: ClickEvent) => {
            try {
              await this.manager1?.setAndPlay(1)
            } catch (e) {
              this.getUIContext().getPromptAction().showToast({ message: e.message });
            }
          })
        }

        Button('播放').onClick(async (event: ClickEvent) => {
          this.manager1?.play().catch((e: BusinessError) => {
            this.getUIContext().getPromptAction().showToast({ message: e.message });
          })
        })
        Button('暂停').onClick(async (event: ClickEvent) => {
          this.manager1?.pause().catch((e: BusinessError) => {
            this.getUIContext().getPromptAction().showToast({ message: e.message });
          })
        })

        Button('播放视频').onClick((event: ClickEvent) => {
          this.manager2?.setAndPlay(0, this.controller.getXComponentSurfaceId(),
            ['https://stream7.iqilu.com/10339/upload_transcode/202002/18/20200218114723HDu3hhxqIT.mp4'])
        })

        if (this.manager2) {
          Stack({ alignContent: Alignment.Bottom }) {
            XComponent({
              type: XComponentType.SURFACE,
              controller: this.controller
            }).onLoad(() => {
            })

            Row() {
              Text(this.state2.isPlay ? '暂停' : '播放')
                .fontColor(Color.White)
                .margin({ right: 5 })
                .onClick(async () => {
                  if (this.state2.isPlay) {
                    this.manager2?.pause()
                  } else {
                    this.manager2?.play()
                  }
                })
              //当前进度
              Text(this.numberToTime(this.state2.time))
                .fontColor(Color.White)
                .fontSize(16)
              //滑块
              Slider({
                value: this.state2.time,
                min: 0,
                max: this.state2.duration
              })
                .layoutWeight(1)
                .blockColor(Color.White)
                .selectedColor(Color.White)
                .trackColor('#ccc5c5c5')
                .trackThickness(2)
                .onChange((value) => {
                  this.manager2?.seek(value)
                })
              //时长
              Text(this.numberToTime(this.state2.duration))
                .fontColor(Color.White)
                .fontSize(16)
            }
            .padding({ left: 10, right: 10 })
          }
          .width('70%')
          .aspectRatio((this.state2?.width ?? 1) / (this.state2?.height ?? 1))
          .backgroundColor(Color.Black)
        }

      }
    }.height('100%')
    .width('100%')
  }
}