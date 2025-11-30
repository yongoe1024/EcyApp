import { IBestAvatar, IBestButton, IBestCell, IBestCellGroup, IBestToast } from "@ibestservices/ibest-ui-v2";
import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { NetManager, RouteManager, RouteTable, UserManager, UserModel } from "common";


@ComponentV2
export struct Mine {
  @Local user: UserModel | undefined

  async aboutToAppear(): Promise<void> {
    UserManager.getInstance().registerListener({
      onLogin: async () => {
        this.user = await UserManager.getInstance().getUserInfo()
      },
      onLogout: () => {
        this.user = undefined
      }
    })
    this.user = await UserManager.getInstance().getUserInfo()
  }

  async uploadAvatar() {
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    // 过滤选择媒体文件类型为IMAGE
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    photoSelectOptions.maxSelectNumber = 1; // 选择媒体文件的最大数目
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    let photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoViewPicker.select(photoSelectOptions)
    let path = photoSelectResult.photoUris[0]
    NetManager.getInstance().upload({
      url: '/user/avatar',
      filePath: path
    })
  }

  build() {
    Column({ space: 20 }) {
      //1.基本信息
      Column() {
        IBestAvatar({
          avatarSize: 50,
          src: this.user?.avatar,
          onAvatarClick: () => {
            this.uploadAvatar()
          }
        })
        Text(this.user?.name ?? '请登录')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .lineHeight(25)
          .fontColor('#fff')
          .onClick(() => {
            if (!this.user) {
              RouteManager.getInstance().push({ url: RouteTable.ENTRY_LOGIN })
            }
          })
      }
      .backgroundImage($r("app.media.ic_mine_bg"))
      .backgroundImageSize(ImageSize.Cover)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(300)

      Column({ space: 20 }) {
        IBestCellGroup({ inset: true }) {
          IBestCell({
            title: '清理缓存',
            isLink: true,
            cellSize: 'large'
          })
          IBestCell({
            title: '隐私协议',
            isLink: true,
            cellSize: 'large'
          })
          IBestCell({
            title: '系统设置',
            isLink: true,
            hasBorder: false,
            cellSize: 'large'
          })
        }

        IBestButton({
          btnWidth: '80%',
          text: '退出登录',
          type: 'danger',
          onBtnClick: () => {
            UserManager.getInstance().logout()
              .then(() => {
                this.getUIContext().getPromptAction().showToast({ message: '退出成功' })
              }).catch(() => {
              this.getUIContext().getPromptAction().showToast({ message: '退出失败' })
            })
          }
        })

      }
      .width('100%')
      .padding({ left: 18, right: 18 })
      .offset({ x: 0, y: -80 })

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f1f1f1')
  }
}