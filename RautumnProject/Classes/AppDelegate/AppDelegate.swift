//
//  AppDelegate.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/19.
//  Copyright © 2016年 Rautumn. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import IQKeyboardManager
import AliyunOSSiOS
import SwiftLocation
import AliyunPlayerSDK
import SDWebImage

//import UMSocialCore
let UMENG_APPKEY = "58afcd384544cb6ab30007bd"
/*sina*/
let K_Sina_AppKey = "810727211"
let K_Sina_AppSecret = "f813d47b305b8588f77098c7dbeb453e"
/*QQ*/
let K_QQ_AppId = "1105870192"
let K_QQ_AppKey = "ZU17hzUQHYXzq0oP"
/*微信*/
let K_WX_AppID = "wx6307ff32bc2ff75f"
let K_WX_AppSecret = "e78bae8921437ee8ed6861e1e655dd21"

let K_Share_Url = "http://mobile.umeng.com/social"

let OSS_AccessKeyID = "LTAIK4xR3rHP7PmZ"
let OSS_AccessKeySecret = "mFYuVlWVbMjWuPyOdJdIxnfSVWQS08"
let OSS_endPoint = "http://oss-cn-shanghai.aliyuncs.com"
//let  OSS_endPoint = "https://oss-cn-shanghai-internal.aliyuncs.com"
let accessKeyID = "LTAIJsvkiSzW349g"
let accessKeySecret = "ASnkQdZr74k6wnnTxUFeP9BjyoiE34"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,AliVcAccessKeyProtocol {
    var ossClient :OSSClient?
    var window: UIWindow?
    let documentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()
    let cacheDirectory: URL = {
        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[urls.endIndex - 1]
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        application.statusBarStyle = .lightContent
        Thread.sleep(forTimeInterval: 1)
        application.isStatusBarHidden = false
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
    
        getAppImg()
        initUmShared()
        umengTrack()
        setupEnvironment()
        setUpKeyboardManager()
        IMHelper.shareInstance().setUpRongYunIM(launchOptions)
        AliVcMediaPlayer.setAccessKeyDelegate(self)
           log.info("documentsDirectory---\(self.documentsDirectory)")
        do{
            var r = Location.getLocation(withAccuracy: .city, frequency: .continuous, timeout: nil, onSuccess: { (loc) in
                _ =  Location.reverse(location: loc, onSuccess: { (placemark) in
                    if let city =  placemark.locality{
                        UserModel.shared.city = city
                    }
                }, onError: { (_) in
                    
                })
            }) { (last, err) in
            }
            r.onAuthorizationDidChange = { newStatus in
            }
        }
        
        // 注册通知
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        return true
    }
    
    func getAppImg() {
        let request =  RequestProvider.request(api: ParametersAPI.getAppImg()).mapObject(type: AppImg.self)
            .shareReplay(1)
        
        request.flatMap{$0.unwarp()}.map{$0.result_data}.unwrap()
            .subscribe(onNext: {[unowned self] (model) in
//                self.friendsCircleHeaderView.img_bg.sd_setImage(with: URL(string:model.coverImageUrl), placeholderImage: placeHolderImage, options: [.retryFailed])
                
                
                UserDefaults.standard.set(model.coverImageUrl, forKey: "Rautum_GetAppImg_urlString")
                UserDefaults.standard.synchronize()
                
                let url = URL.init(string: model.coverImageUrl)
                SDWebImageManager.shared().downloadImage(with: url, options: .retryFailed, progress: nil, completed: { (image, error, cachetype, finish, aUrl) in
                    
                    
                    SDImageCache.shared().store(image, forKey: "Rautum_GetAppImg")
                })
                
                
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
    }
    
    // 通知处理
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        application.registerForRemoteNotifications()
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let data:NSData = deviceToken as NSData
        var token: String = data.description
        token = token.replacingOccurrences(of: "<", with: "")
        token = token.replacingOccurrences(of: ">", with: "")
        token = token.replacingOccurrences(of: " ", with: "")
        
        print("token = \(token), deviceToken = \(deviceToken.description)")
        
        RCIMClient.shared().setDeviceToken(token)
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("获取DeviceToken失败！！\nerror = \(error)")
    }
    
    /**
     * 推送处理4
     * userInfo内容请参考官网文档
     */
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        /**
         * 统计推送打开率2
         */
        RCIMClient.shared().recordRemoteNotificationEvent(userInfo)
        /**
         * 获取融云推送服务扩展字段2
         */
        
        let pushServiceData = RCIMClient.shared().getPushExtra(fromRemoteNotification: userInfo)
        if (pushServiceData != nil) {
            print("该远程推送包含来自融云的推送服务")
            //            for key in (pushServiceData?.keys)! {
            //                print("ey = \(key), value =\(String(describing: pushServiceData?[key]))")
            //            }
        } else {
            print("该远程推送不包含来自融云的推送服务")
        }
        
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        /**
         * 统计推送打开率3
         */
        RCIMClient.shared().recordLocalNotificationEvent(notification)
        //  //震动
        //  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        //  AudioServicesPlaySystemSound(1007);
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        let status = RCIMClient.shared().getConnectionStatus()
        
        if status != .ConnectionStatus_SignUp {
            
            let unreadMsgCount = RCIMClient.shared()
                .getUnreadCount([RCConversationType.ConversationType_PRIVATE,
                                 RCConversationType.ConversationType_DISCUSSION,
                                 RCConversationType.ConversationType_APPSERVICE,
                                 RCConversationType.ConversationType_PUBLICSERVICE,
                                 RCConversationType.ConversationType_GROUP])
            
            application.applicationIconBadgeNumber = Int(unreadMsgCount)
            
        }
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        IMHelper.shareInstance().saveConversationInfoForMessageShare()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if RCIMClient.shared().getConnectionStatus() == .ConnectionStatus_Connected {
            IMHelper.shareInstance().insertSharedMessageIfNeed()
        }
    }
    
    // MARK: -- 友盟初始化
    func initUmShared() {

        UMSocialManager.default().openLog(true)
        UMSocialManager.default().umSocialAppkey = UMENG_APPKEY
        
        UMSocialManager.default().setPlaform(UMSocialPlatformType.wechatSession, appKey: K_WX_AppID, appSecret: K_WX_AppSecret, redirectURL: K_Share_Url)
        UMSocialManager.default().setPlaform(UMSocialPlatformType.wechatTimeLine, appKey: K_WX_AppID, appSecret: K_WX_AppSecret, redirectURL: K_Share_Url)
        
        UMSocialManager.default().setPlaform(UMSocialPlatformType.QQ, appKey: K_QQ_AppId, appSecret: K_QQ_AppKey, redirectURL: K_Share_Url)
        UMSocialManager.default().setPlaform(UMSocialPlatformType.qzone, appKey: K_QQ_AppId, appSecret: K_QQ_AppKey, redirectURL: K_Share_Url)
        
        UMSocialManager.default().setPlaform(UMSocialPlatformType.sina, appKey: K_Sina_AppKey, appSecret: K_Sina_AppSecret, redirectURL: K_Share_Url)
    
    }
    func setUpKeyboardManager() {
        let  keyboardManager = IQKeyboardManager.shared()
        keyboardManager.isEnabled = true
        keyboardManager.isEnableAutoToolbar = false
        keyboardManager.keyboardDistanceFromTextField = 0
        keyboardManager.disabledDistanceHandlingClasses.addObjects(from: [RCDChatViewController.self,Register2ViewController.self,CreateGroupViewController.self,CreateActivtyViewController.self,LiveViewController.self,PostDynamicController.self])
        }
    
    // http://www.rautumn.com:8070/appserver/api
    ///初始化阿里云OSS
    fileprivate func setupEnvironment(){
//        OSSLog.enable()
        let credential = OSSPlainTextAKSKPairCredentialProvider(plainTextAccessKey: OSS_AccessKeyID, secretKey: OSS_AccessKeySecret)
        let config = OSSClientConfiguration()
        config.maxRetryCount = 2
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = TimeInterval(24 * 60 * 60)
        ossClient = OSSClient(endpoint: OSS_endPoint, credentialProvider: credential!, clientConfiguration: config)
    }
    fileprivate func umengTrack(){
        // 如果不需要捕捉异常，注释掉此行
        MobClick.setCrashReportEnabled(true)
        // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
//        MobClick.setLogEnabled(true)
    
        MobClick.setAppVersion(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)
        
        MobClick.start(withAppkey: UMENG_APPKEY, reportPolicy: ReportPolicy.init(0), channelId: nil)
        MobClick.updateOnlineConfig()
        
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: UMOnlineConfigDidFinishedNotification)).subscribe(onNext: { (noti) in
//         log.info("online config has fininshed and note = \(noti.userInfo)")
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
    }
    func getAccessKeyIDSecret() -> AliVcAccesskey! {
        let accessKey = AliVcAccesskey()
        accessKey.accessKeyId = accessKeyID
        accessKey.accessKeySecret = accessKeySecret
        return accessKey
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        AISharedPay.handleOpen(url)
        UMSocialManager.default().handleOpen(url)
        
        
        
        return true
    }
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        UMSocialManager.default().handleOpen(url)
        AISharedPay.handleOpen(url)
        return true
    }
}

