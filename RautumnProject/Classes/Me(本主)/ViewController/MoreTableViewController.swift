//
//  MoreTableViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/14.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
//import UShareUI
import SwiftyDrop
import ObjectMapper
class MoreTableViewController: UITableViewController {

    @IBOutlet weak var lb_version: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lb_version.text = "V\(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)"
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = bgColor
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
        //GonglvViewController
        if indexPath.row == 2{
            if UserModel.shared.inApp{
                let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "GonglvViewController2")
                navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "GonglvViewController")
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.row == 3{ //分享镭秋
            UMSocialUIManager.showShareMenuViewInWindow(platformSelectionBlock: { (platformType, userInfo) in
                
                
                let messageObject = UMSocialMessageObject()
                messageObject.text = "不一样的世界，不一样的自己！"
                let shareObject = UMShareWebpageObject()
                shareObject.title = "镭秋:个性化社交分享平台"
                shareObject.descr = "不一样的世界，不一样的自己！"
                shareObject.thumbImage = UIImage(named: "icon")
                shareObject.webpageUrl = "\(PREURL)appserver/api?action=toShare"
                messageObject.shareObject = shareObject

                UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: self , completion: { (shareResponse, error) in
                    if error == nil{
                        Drop.down("分享成功！", state: .success)
                    }else{
                        Drop.down("分享失败！", state: .error)
                    }
                })
            })
        }else if indexPath.row == 4 { //清除缓存
             let av = UIAlertController(title: "清除缓存", message: "确实要清除本地缓存数据？（包括本地图片、缓存数据和消息列表)", preferredStyle: .alert)
            av.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
                
            }))
            
            av.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
                DBTool.shared.clearCache()
            }))
            present(av, animated: true, completion: nil)
            
            //
        }else if indexPath.row == 6 { //平台协议
            let activityIndicator = ActivityIndicator()
            activityIndicator.asObservable().bindTo(isLoading(showTitle: "", for: view)).addDisposableTo(rx_disposeBag)
               let reqeust =  RequestProvider.request(api: ParametersAPI.getPlatformProtocol).mapObject(type: PlatformProtocol.self)
                    .trackActivity(activityIndicator)
                    .shareReplay(1)
            reqeust.flatMap{$0.unwarp()}.map{$0.result_data?.html}.unwrap()
            .subscribe(onNext: {[unowned self] (url) in
                let vc = WebViewViewController()
                vc.title = "用户协议"
                vc.urlStr = url
                self.navigationController?.pushViewController(vc, animated: true)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
            
        }
        else if indexPath.section == 1 && indexPath.row == 0 {//退出登录
            let av = UIAlertController(title: "退出登录", message: "确定要退出登录吗", preferredStyle: .alert)
            av.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
                
            }))
            
            av.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
                RCIM.shared().logout()
                UserDefaults.standard.removeObject(forKey: "userPwd")
                UserDefaults.standard.removeObject(forKey: "userToken")
                UserDefaults.standard.removeObject(forKey: "userId")
                UserModel.shared.id = 0
                DBTool.shared.removeUserModel()
                 UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController()
            }))
            present(av, animated: true, completion: nil)
        
        }
    }
}
struct PlatformProtocol {
    var html = ""
    
    init?( map: Map) {}
}

extension PlatformProtocol: Mappable {
    mutating func mapping(map: Map) {
        html <- map["html"]
    }
}
