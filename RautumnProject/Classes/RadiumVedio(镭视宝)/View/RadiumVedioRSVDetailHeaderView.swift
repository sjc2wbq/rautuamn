
//
//  RadiumHotVedioRSVDetailHeaderView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDAutoLayout
import SDWebImage
import IBAnimatable
import SwiftyDrop
//import UShareUI

protocol RadiumVedioRSVDetailHeaderViewDelegate : NSObjectProtocol {
    func zanButtonClickedOperationWithRadiumVedioRSVDetailHeaderView(headerView:RadiumVedioRSVDetailHeaderView)
    func commentButtonClickedOperationWithRadiumVedioRSVDetailHeaderView(headerView:RadiumVedioRSVDetailHeaderView)
    func leitaButtonClickedOperationWithRadiumVedioRSVDetailHeaderView(headerView:RadiumVedioRSVDetailHeaderView)
}

class RadiumVedioRSVDetailHeaderView: UIView {

    var delegate : RadiumVedioRSVDetailHeaderViewDelegate?

    fileprivate var videoUrl = ""
    public var indexPath:IndexPath?
    @IBOutlet weak var img_icon: AnimatableImageView!
    @IBOutlet weak var img_rank: UIImageView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_huzhu: UILabel!
    @IBOutlet weak var starView: StarView!
    @IBOutlet weak var lb_tag1: AnimatableLabel!
    @IBOutlet weak var lb_tag2: AnimatableLabel!
    
    @IBOutlet weak var btn_city: UIButton!
    @IBOutlet weak var btn_distance: UIButton!
    
    @IBOutlet weak var lb_content: UILabel!
    @IBOutlet weak var lb_time: UILabel!
    
    @IBOutlet weak var btn_lei: AnimatableButton!
    @IBOutlet weak var btn_hulu: UIButton!
    
    @IBOutlet weak var lb_address: UILabel!
    
    @IBOutlet weak var lb_commentCount: UILabel!
    @IBOutlet weak var lb_exceptionalCount: UILabel!

    @IBOutlet weak var img_vedio: UIImageView!
    
    @IBOutlet weak var img_dashang: UIImageView!
    @IBOutlet weak var img_comment: UIImageView!
    
    let img_palyVideo = UIImageView()
    
    let menu = RadiumFriendsCircleCellOperationMenu()
    
    let lineViewLayer = CALayer()

    
    static func headerView() -> RadiumVedioRSVDetailHeaderView{
        return Bundle.main.loadNibNamed("RadiumVedioRSVDetailHeaderView", owner: nil, options: nil)!.first as! RadiumVedioRSVDetailHeaderView
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        img_palyVideo.contentMode = .center
        img_palyVideo.image = UIImage(named:"playBtn")
        
        img_vedio.addSubview(img_palyVideo)
        addSubview(menu)
        lineViewLayer.backgroundColor = bgColor.cgColor
        layer.addSublayer(lineViewLayer)
        do {
            NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: RadiumFriendsCircleViewCellOperationButtonClickedNotification), object: nil)
                .subscribe(onNext: {[unowned self] (notification) in
                    let object = notification.object as! UIButton
                    if object != self.btn_hulu && self.menu.isShowing{
                        self.menu.isShowing = false
                    }
                })
                .addDisposableTo(rx_disposeBag)
        }
        if maxContentLabelHeight == 0{
            maxContentLabelHeight = lb_content.font.lineHeight * CGFloat(maxLineNumber)
        }
        
        btn_hulu.addTarget(self, action: #selector(huluButtonClicked), for: .touchUpInside)

        _ =  img_icon.sd_layout().leftSpaceToView(self,10)?.topSpaceToView(self,10)?.widthIs(50)?.heightIs(50)
        
        _ = img_rank.sd_layout().rightEqualToView(img_icon)?.bottomEqualToView(img_icon)?.widthIs(16)?.heightIs(16)
        
        _ = lb_name.sd_layout().leftSpaceToView(img_icon,5)?.heightIs(20)?.topSpaceToView(self,10)
        
        _ = starView.sd_layout().leftSpaceToView(lb_name,2)?.heightIs(20)?.centerYEqualToView(lb_name)
        
        _ = lb_tag1.sd_layout().leftSpaceToView(starView,5)?.widthIs(24)?.heightIs(17)?.centerYEqualToView(starView)
        
        _ = lb_tag2.sd_layout().leftSpaceToView(lb_tag1,2)?.widthIs(24)?.heightIs(17)?.centerYEqualToView(lb_tag1)
        
        _ = lb_huzhu.sd_layout().leftSpaceToView(lb_tag2,2)?.widthIs(24)?.heightIs(17)?.centerYEqualToView(lb_tag2)
        
        _ = btn_city.sd_layout().leftEqualToView(lb_name)?.widthIs(100)?.heightIs(20)?.bottomEqualToView(img_icon)
        
        _ = btn_distance.sd_layout().leftSpaceToView(btn_city,10)?.heightIs(20)?.widthIs(100)?.centerYEqualToView(btn_city)
        
        _ = btn_lei.sd_layout().rightSpaceToView(self,10)?.widthIs(66)?.heightIs(26)?.centerYEqualToView(btn_distance)
        
        _ = lb_content.sd_layout().leftEqualToView(img_icon)?.topSpaceToView(img_icon,10)?.rightEqualToView(btn_lei)?.autoHeightRatio(0)
        
        _ =  img_vedio.sd_layout().leftEqualToView(lb_content)?.topSpaceToView(lb_content,10)?.rightEqualToView(lb_content)
        
        _ = img_palyVideo.sd_layout().widthIs(100)?.heightIs(80)?.centerXEqualToView(img_vedio)?.centerYEqualToView(img_vedio)
        
        _ = lb_address.sd_layout().leftEqualToView(lb_content)?.heightIs(15)?.widthIs(screenW - 20)
        
        _ = lb_time.sd_layout().leftEqualToView(lb_content)?.heightIs(15)?.topSpaceToView(lb_address,5)
        
        _ = img_dashang.sd_layout().leftSpaceToView(lb_time,5)?.centerYEqualToView(lb_time)?.heightIs(25)?.widthEqualToHeight()
        
        
        _ = lb_exceptionalCount.sd_layout().leftSpaceToView(img_dashang,5)?.centerYEqualToView(lb_time)?.heightIs(15)
        
        _ = img_comment.sd_layout().leftSpaceToView(lb_exceptionalCount,5)?.centerYEqualToView(lb_time)?.heightIs(25)?.widthEqualToHeight()
        
        _ = lb_commentCount.sd_layout().leftSpaceToView(img_comment,5)?.centerYEqualToView(lb_exceptionalCount)?.heightIs(15)
        
        _ = btn_hulu.sd_layout().rightEqualToView(lb_content)?.centerYEqualToView(lb_time)?.widthIs(36)?.heightIs(36)
        
        _ = menu.sd_layout().rightSpaceToView(btn_hulu,2)?.heightIs(36)?.widthIs(0)?.centerYEqualToView(btn_hulu)
        
        
        _ = img_vedio.sd_layout().heightIs(screenW / 2)
        _ = lb_address.sd_layout().topSpaceToView(img_vedio,10)
        setupAutoHeight(withBottomView: lb_time, bottomMargin: 20)
        

        
        
        menu.commentButtonClickedOperation = {
            self.delegate?.commentButtonClickedOperationWithRadiumVedioRSVDetailHeaderView(headerView: self)
        }
        menu.likeButtonClickedOperation = {
            self.delegate?.zanButtonClickedOperationWithRadiumVedioRSVDetailHeaderView(headerView: self)
        }
        menu.shareButtonClickedOperation = { //分享
            UMSocialUIManager.showShareMenuViewInWindow(platformSelectionBlock: { (platformType, userInfo) in
                let messageObject = UMSocialMessageObject()
                messageObject.text = "不一样的世界，不一样的自己！"
                let shareObject = UMShareWebpageObject()
                shareObject.title = "镭秋:个性化社交分享平台"
                shareObject.descr = "不一样的世界，不一样的自己！"
                shareObject.thumbImage = UIImage(named: "icon")
                shareObject.webpageUrl = "\(PREURL)appserver/api?action=toShare"
                messageObject.shareObject = shareObject
                UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: self.viewController, completion: { (shareResponse, error) in
                    if error == nil{
                        Drop.down("分享成功！", state: .success)
                    }else{
                        Drop.down("分享失败！", state: .error)
                    }
                })
            })
            
        }

        btn_lei.addTarget(self, action: #selector(leiTaAction), for: .touchUpInside)

        img_icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.img_iconAction(tap:))))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showVideoPlayer(tap:)))
        img_vedio.addGestureRecognizer(tap)
    }
    @objc fileprivate func img_iconAction(tap:UITapGestureRecognizer)  {
        let vc = UserInfoViewController()
        vc.visitorUserId = self.rvUseful.userId
        vc.title = self.rvUseful.nickName
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    @objc fileprivate func showVideoPlayer(tap:UITapGestureRecognizer){
        
        let vc = PlayVideoViewController()
        vc.videoUrl = URL(string:videoUrl)
        self.viewController?.present(vc, animated: true, completion: nil)
        
        let request = RequestProvider.request(api: ParametersAPI.rsvPlayTimes(rsvId: "\(self.rvUseful.id)"))
            .mapObject(type: EmptyModel.self)
            .shareReplay(1)
        request.flatMap{$0.unwarp()}.subscribe(onNext: { (_) in
            self.rvUseful.playTimes.value = self.rvUseful.playTimes.value + 1
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
        request.flatMap{$0.error}.subscribe(onNext: { (_) in
            
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)

        

    }
    
    @objc fileprivate func huluButtonClicked(button:Any?){
//        huluButtonClickedBlock?(indexPath)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RadiumFriendsCircleViewCellOperationButtonClickedNotification), object: btn_hulu as Any?)
        menu.isShowing = !menu.isShowing
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RadiumFriendsCircleViewCellOperationButtonClickedNotification), object: btn_hulu as Any?)
        if menu.isShowing {
            menu.isShowing = false
        }
    }
    @objc fileprivate func leiTaAction(){
        self.delegate?.leitaButtonClickedOperationWithRadiumVedioRSVDetailHeaderView(headerView: self)
    }
    
    var rvUseful:RvUseful!{
        didSet{
            videoUrl = rvUseful.videoUrl

            rvUseful.commentCount.asObservable().map{"\($0)"}.bindTo(lb_commentCount.rx.text).addDisposableTo(rx_disposeBag)
            
            rvUseful.countRC.asObservable().map{"￥\($0)"}.bindTo(lb_exceptionalCount.rx.text).addDisposableTo(rx_disposeBag)
            
            //            rvUseful.isShowMenu.asObservable()
//                .subscribe(onNext: {[unowned self] (isShowMenu) in
//                    self.menu.isShowing = isShowMenu
//                    }, onError: nil, onCompleted: nil, onDisposed: nil)
//                .addDisposableTo(rx_disposeBag)
            
            starView.star = rvUseful.starLevel
            
            img_icon.sd_setImage(with: URL(string:rvUseful.headPortUrl), placeholderImage: defaultHeaderImage)
            
            img_rank.image = UIImage(named:"isCertification_\(rvUseful.rank)")
            
            lb_name.text = rvUseful.nickName
            
            lb_huzhu.isHidden = !rvUseful.mutualTourism
            lb_tag1.backgroundColor = UIColor.colorWithHexString(rvUseful.emotion == "找女友" ? "#84E941" : "#FD6BA7")

            if rvUseful.emotion == "找女友" {
                lb_tag1.text = "FG"
                lb_tag1.isHidden = false
                _ = lb_tag1.sd_layout().widthIs(24)
            }else if rvUseful.emotion == "找男友" {
                lb_tag1.text = "FB"
                lb_tag1.isHidden = false
                _ = lb_tag1.sd_layout().widthIs(24)
            }else{
                lb_tag1.isHidden = true
                _ = lb_tag1.sd_layout().widthIs(0)
            }
        
            if rvUseful.changeJob {
                lb_tag2.isHidden = false
                _ = lb_tag2.sd_layout().widthIs(24)
                
            }else{
                lb_tag2.isHidden = true
                _ = lb_tag2.sd_layout().widthIs(0)
            }
            if rvUseful.distanceOff{
                btn_distance.setTitle("关闭距离", for: .normal)
            }else{
                btn_distance.setTitle("\(rvUseful.distance)km", for: .normal)
            }
            btn_city.setTitle(rvUseful.permanentCity, for: .normal)
            
            lb_address.text = rvUseful.position
            
            lb_address.isHidden = rvUseful.position == ""
            
            _ = lb_address.sd_layout().heightIs(rvUseful.position == "" ? 0 : 15)
            
            
            lb_content.text = rvUseful.title
            
            lb_time.text = rvUseful.time

            img_vedio.sd_setImage(with: URL(string:rvUseful.coverPhotoUrl), placeholderImage: placeHolderImage)
            
            btn_lei.setTitle(rvUseful.friend == true ? "发消息" : "镭Ta", for: .normal)


            if let text = btn_city.titleLabel?.text{
                _ = btn_city.sd_layout().widthIs(text.width(15, height: 20) + 20)
            }
            if let text = btn_distance.titleLabel?.text{
                _ = btn_distance.sd_layout().widthIs(text.width(14, height: 20) + 20)
            }
            
            _ =  lb_name.sd_layout().widthIs(lb_name.text!.width(15, height: 20) + 5)
            
            _ = lb_exceptionalCount.sd_layout().widthIs(lb_exceptionalCount.text!.width(12, height: 15) + 10)

        }
    }
}
