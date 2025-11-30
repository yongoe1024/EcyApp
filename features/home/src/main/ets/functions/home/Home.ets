import { GlobalState, RouteManager } from "common"
import { common, wantAgent } from "@kit.AbilityKit"
import { notificationManager } from "@kit.NotificationKit"
import { AppStorageV2 } from "@kit.ArkUI"


@ComponentV2
export struct Home {
  @Local state: GlobalState = AppStorageV2.connect(GlobalState)!

  build() {
    Column() {
      Text(this.state.widthBreakpoint.toString())
      Text(this.state.heightBreakpoint.toString())

      Button('测试音视频').onClick((event: ClickEvent) => {
        RouteManager.getInstance().push({ url: 'ecy://demo/media' })
      })
      Button('去web页').onClick((event: ClickEvent) => {
        RouteManager.getInstance()
          .push({
            url: 'https://developer.huawei.com/consumer/cn/doc/best-practices/bpta-multi-device-responsive-layout'
          })
      })
      Button('登陆').onClick((event: ClickEvent) => {
        RouteManager.getInstance().push({ url: 'ecy://mine/login' })
      })
      Button('通知权限').onClick((event: ClickEvent) => {
        let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
        notificationManager.isNotificationEnabled().then((data: boolean) => {
          if(!data){
            notificationManager.requestEnableNotification(context)
          }
        }).catch((err: BusinessError) => {
        });
      })
      Button('发送通知').onClick((event: ClickEvent) => {
        // 创建跳转意图
        let wantAgentInfo: wantAgent.WantAgentInfo = {
          wants: [
            {
              parameters: {
                'toUrl': 'ecy://mine/login'
              },
              deviceId: "", // 空字符串表示当前设备
              bundleName: "com.yongoe.ecy", // 当前应用包名
              abilityName: "EntryAbility", // 目标UIAbility名称
            }
          ],
          operationType: wantAgent.OperationType.START_ABILITY,
          requestCode: 0
        };
        // 创建WantAgent对象
        wantAgent.getWantAgent(wantAgentInfo).then((agent) => {
          // 通知Request对象
          let notificationRequest: notificationManager.NotificationRequest = {
            id: Math.floor(Math.random() * 100),
            tapDismissed: true,
            wantAgent: agent,
            notificationSlotType: notificationManager.SlotType.SERVICE_INFORMATION,
            content: {
              notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
              normal: {
                title: '测试通知',
                text: `请及时处理。`,
              }
            }
          };
          // publish回调
          let publishCallback = (err: BusinessError): void => {
            if (err) {
              console.log(`在线消息发布失败. Code is ${err.code}, message is ${err.message}`)
            } else {
              console.log("在线消息发布成功!")
            }
          }
          notificationManager.publish(notificationRequest, publishCallback);
        });
      })
    }
  }
}