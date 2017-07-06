//
//  RadiumFriendsCircleDetailHeaderView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/13.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDAutoLayout
import SDWebImage
import IBAnimatable
import SwiftyDrop
//import UShareUI
class RadiumFriendsCircleDetailSectionHeaderView: UIView {
    let lineLayer = CALayer()
    static func sectionHeaderView() -> RadiumFriendsCircleDetailSectionHeaderView{
        return Bundle.main.loadNibNamed("RadiumFriendsCircleDetailHeaderView", owner: nil, options: nil)![1] as! RadiumFriendsCircleDetailSectionHeaderView
    }
    @IBOutlet weak var btn_Comment: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
//        backgroundColor = UIColor.white
        lineLayer.backgroundColor = bgColor.cgColor
        layer.addSublayer(lineLayer)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.frame = CGRect(x: 14, y: bounds.size.height - 1, width: bounds.size.width, height: 1)
    }
}

protocol RadiumFriendsCircleDetailHeaderViewDelegate : NSObjectProtocol {
    func zanButtonClickedOperationWithRadiumFriendsCircleDetailHeaderView(headerView:RadiumFriendsCircleDetailHeaderView)
    func commentButtonClickedOperationWithRadiumFriendsCircleDetailHeaderView(headerView:RadiumFriendsCircleDetailHeaderView)
    func leitaButtonClickedOperationWithRadiumFriendsCircleDetailHeaderView(headerView:RadiumFriendsCircleDetailHeaderView)
    
}


class RadiumFriendsCircleDetailHeaderView: UIView {

    var delegate : RadiumFriendsCircleDetailHeaderViewDelegate?
    public var moreButtonClickedBlock:((_ indexPath:IndexPath?) -> ())?
    public var huluButtonClickedBlock:((_ indexPath:IndexPath?) -> ())?

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
    
    @IBOutlet weak var img_dashang: UIImageView!
    @IBOutlet weak var img_comment: UIImageView!

    let photoContainerView = PhotoContainerView()
    let vedioContainerView = UIImageView()
    let audioButton = UIButton.init(type: UIButtonType.custom)
    let audioTimeLabel = UILabel()
    
    var audioPlayer = HKPlayerAudio()
    var audioPlayer1 = HKPlayer.instance
    
    let img_palyVideo = UIImageView()
    let menu = RadiumFriendsCircleCellOperationMenu()
    
    let lineViewLayer = CALayer()

    static func headerView() -> RadiumFriendsCircleDetailHeaderView{
        return Bundle.main.loadNibNamed("RadiumFriendsCircleDetailHeaderView", owner: nil, options: nil)!.first as! RadiumFriendsCircleDetailHeaderView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        vedioContainerView.backgroundColor = palceHolderColor

        vedioContainerView.clipsToBounds = true
        vedioContainerView.layer.cornerRadius = 4
        
        img_palyVideo.clipsToBounds = true
        img_palyVideo.layer.cornerRadius = 4
        
        audioButton.clipsToBounds = true
        audioButton.layer.cornerRadius = 4
        audioButton.setImage(UIImage.init(named: "Free_Play"), for: .normal)
        audioButton.setImage(UIImage.init(named: "zanting"), for: .selected)
        audioButton.imageView?.contentMode = .scaleAspectFill
        
        audioTimeLabel.textColor = UIColor.colorWithHexString("ff8300")
        audioTimeLabel.font = UIFont.systemFont(ofSize: 17)
        audioTimeLabel.textAlignment = .center
        audioTimeLabel.text = "0"
        
        photoContainerView.contentMode = .scaleAspectFit
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
        audioButton.addTarget(self, action: #selector(audioButtonEvent(sender:)), for: .touchUpInside)
        
        
        addSubview(vedioContainerView)
        addSubview(photoContainerView)
        addSubview(audioButton)
        addSubview(audioTimeLabel)
        
        vedioContainerView.isUserInteractionEnabled = true
        img_palyVideo.contentMode = .center
        img_palyVideo.image = UIImage(named:"playBtn")
        
        vedioContainerView.addSubview(img_palyVideo)

        insertSubview(menu, belowSubview: btn_hulu)
        
        _ =  img_icon.sd_layout().leftSpaceToView(self,14)?.topSpaceToView(self,10)?.widthIs(50)?.heightIs(50)
        
        _ = img_rank.sd_layout().rightEqualToView(img_icon)?.bottomEqualToView(img_icon)?.widthIs(16)?.heightIs(16)
        
        _ = lb_name.sd_layout().leftSpaceToView(img_icon,10)?.heightIs(20)?.topSpaceToView(self,10)
        
        _ = starView.sd_layout().leftSpaceToView(lb_name,2)?.heightIs(20)?.centerYEqualToView(lb_name)
        
        _ = lb_tag1.sd_layout().leftSpaceToView(starView,5)?.widthIs(24)?.heightIs(17)?.centerYEqualToView(starView)
        
        _ = lb_tag2.sd_layout().leftSpaceToView(lb_tag1,2)?.widthIs(24)?.heightIs(17)?.centerYEqualToView(lb_tag1)
        
        _ = lb_huzhu.sd_layout().leftSpaceToView(lb_tag2,2)?.widthIs(24)?.heightIs(17)?.centerYEqualToView(lb_tag2)
        
        _ = btn_city.sd_layout().leftEqualToView(lb_name)?.widthIs(100)?.heightIs(20)?.bottomEqualToView(img_icon)
        
        _ = btn_distance.sd_layout().leftSpaceToView(btn_city,10)?.heightIs(20)?.widthIs(100)?.centerYEqualToView(btn_city)
        
        _ = btn_lei.sd_layout().rightSpaceToView(self,14)?.widthIs(66)?.heightIs(26)?.centerYEqualToView(btn_distance)
        
        _ = lb_content.sd_layout().leftEqualToView(img_icon)?.topSpaceToView(img_icon,10)?.rightEqualToView(btn_lei)
    
        
        _ = photoContainerView.sd_layout().leftEqualToView(lb_content)?.topSpaceToView(lb_content,10)
        
        _ =  vedioContainerView.sd_layout().leftEqualToView(lb_content)?.topSpaceToView(lb_content,10)?.rightEqualToView(lb_content)
        _ = audioButton.sd_layout().leftEqualToView(lb_content)?.topSpaceToView(lb_content,10)?.heightIs(55.0)?.widthIs(55.0)
        _ = audioTimeLabel.sd_layout().leftEqualToView(lb_content)?.topSpaceToView(audioButton,0.0)?.heightIs(21.0)?.widthIs(55.0)
        
        _ = img_palyVideo.sd_layout().widthIs(100)?.heightIs(80)?.centerXEqualToView(vedioContainerView)?.centerYEqualToView(vedioContainerView)

        
        _ = lb_address.sd_layout().leftEqualToView(lb_content)?.heightIs(15)?.widthIs(screenW - 28)
        
        _ = lb_time.sd_layout().leftEqualToView(lb_content)?.heightIs(15)?.topSpaceToView(lb_address,10)
        
        _ = img_dashang.sd_layout().leftSpaceToView(lb_time,5)?.centerYEqualToView(lb_time)?.heightIs(25)?.widthEqualToHeight()

        
        _ = lb_exceptionalCount.sd_layout().leftSpaceToView(img_dashang,5)?.centerYEqualToView(lb_time)?.heightIs(15)
        
        _ = img_comment.sd_layout().leftSpaceToView(lb_exceptionalCount,5)?.centerYEqualToView(lb_time)?.heightIs(25)?.widthEqualToHeight()

        _ = lb_commentCount.sd_layout().leftSpaceToView(img_comment,5)?.centerYEqualToView(lb_exceptionalCount)?.heightIs(15)
        
        _ = btn_hulu.sd_layout().rightEqualToView(lb_content)?.centerYEqualToView(lb_time)?.widthIs(50)?.heightIs(36)
        
        _ = menu.sd_layout().rightSpaceToView(btn_hulu,2)?.heightIs(36)?.widthIs(0)?.centerYEqualToView(btn_hulu)
        
        setupAutoHeight(withBottomView: lb_time, bottomMargin: 20)
        img_icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.img_iconAction(tap:))))

        
        btn_lei.addTarget(self, action: #selector(leiTaAction), for: .touchUpInside)
        menu.commentButtonClickedOperation = {
            self.delegate?.commentButtonClickedOperationWithRadiumFriendsCircleDetailHeaderView(headerView: self)
        }
        menu.likeButtonClickedOperation = {
            self.delegate?.zanButtonClickedOperationWithRadiumFriendsCircleDetailHeaderView(headerView: self)
        }
        menu.shareButtonClickedOperation = { //分享
            UMSocialUIManager.showShareMenuViewInWindow(platformSelectionBlock: { (platformType, userInfo) in
                var text = "不一样的世界，不一样的自己！"
                if self.rautumnFriendsCircle.narrativeContent.characters.count <= 25 {
                    text = self.rautumnFriendsCircle.narrativeContent
                }
                
                if self.rautumnFriendsCircle.narrativeContent.characters.count > 25 {
                    
                    let string = self.rautumnFriendsCircle.narrativeContent as NSString
                    text = "\(string.substring(to: 25))..."
                }
                
                let messageObject = UMSocialMessageObject()
                messageObject.text = text
                let shareObject = UMShareWebpageObject()
                shareObject.title = "镭秋:个性化社交分享平台"
                shareObject.descr = text
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showVideoPlayer(tap:)))
        vedioContainerView.addGestureRecognizer(tap)
    }
    
    @objc fileprivate func img_iconAction(tap:UITapGestureRecognizer)  {
        let vc = UserInfoViewController()
        vc.visitorUserId = Int(self.rautumnFriendsCircle.userId)
//        vc.title = self.rautumnFriendsCircle.nickName
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func showVideoPlayer(tap:UITapGestureRecognizer){
        let view = tap.view
        let vc = PlayVideoViewController()
        vc.videoUrl = URL(string:rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.url.replacingOccurrences(of: "%2F", with: "/")}!)

        self.viewController?.present(vc, animated: true, completion: nil)

    }
    override func layoutSubviews() {
        super.layoutSubviews()
        lineViewLayer.frame = CGRect(x: 0, y: self.bounds.size.height - 10, width: screenW, height: 10)
    }
    var rautumnFriendsCircle:RautumnFriendsCircle!{
        didSet{

            
            rautumnFriendsCircle.commentCount.asObservable().map{"\($0)"}.bindTo(lb_commentCount.rx.text).addDisposableTo(rx_disposeBag)
            
            rautumnFriendsCircle.countRC.asObservable().map{"￥\($0)"}.bindTo(lb_exceptionalCount.rx.text).addDisposableTo(rx_disposeBag)
            
            rautumnFriendsCircle.isShowMenu.asObservable()
                .subscribe(onNext: {[unowned self] (isShowMenu) in
                    self.menu.isShowing = isShowMenu
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            
            starView.star = rautumnFriendsCircle.starLevel
            
            img_icon.sd_setImage(with: URL(string:rautumnFriendsCircle.headUrl), placeholderImage: defaultHeaderImage)
            
            img_rank.image = UIImage(named:"isCertification_\(rautumnFriendsCircle.rank)")
            
            lb_name.text = rautumnFriendsCircle.nickName
            
            lb_huzhu.isHidden = !rautumnFriendsCircle.mutualTourism
            lb_tag1.backgroundColor = UIColor.colorWithHexString(rautumnFriendsCircle.emotion == "找女友" ? "#84E941" : "#FD6BA7")

            if rautumnFriendsCircle.emotion == "找女友" {
                lb_tag1.text = "FG"
                lb_tag1.isHidden = false
                _ = lb_tag1.sd_layout().widthIs(24)
            }else if rautumnFriendsCircle.emotion == "找男友" {
                lb_tag1.text = "FB"
                lb_tag1.isHidden = false
                _ = lb_tag1.sd_layout().widthIs(24)
                
            }else{
                lb_tag1.isHidden = true
                _ = lb_tag1.sd_layout().widthIs(0)
            }
            
            
            if rautumnFriendsCircle.changeJob {
                lb_tag2.isHidden = false
                _ = lb_tag2.sd_layout().widthIs(24)
                
            }else{
                lb_tag2.isHidden = true
                _ = lb_tag2.sd_layout().widthIs(0)
            }
            if rautumnFriendsCircle.distanceOff{
                btn_distance.setTitle("关闭距离", for: .normal)
            }else{
                btn_distance.setTitle("\(rautumnFriendsCircle.distance)km", for: .normal)
            }
            btn_city.setTitle(rautumnFriendsCircle.permanentCity, for: .normal)
            
            lb_address.text = rautumnFriendsCircle.positionName
            
            lb_address.isHidden = rautumnFriendsCircle.positionName == ""
            
            _ = lb_address.sd_layout().heightIs(rautumnFriendsCircle.positionName == "" ? 0 : 15)
            lb_content.attributedText = rautumnFriendsCircle.attrContent
//            lb_content.text = rautumnFriendsCircle.narrativeContent
            
        _ = lb_content.sd_layout().heightIs((lb_content.attributedText?.boundingRect(with: CGSize(width: screenW - 28, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size.height)! + 15)
            
            lb_time.text = rautumnFriendsCircle.time
            if  rautumnFriendsCircle.type == 0 { //纯文本
                photoContainerView.isHidden = true
                vedioContainerView.isHidden = true
                audioButton.isHidden = true
                audioTimeLabel.isHidden = true
                _ = audioTimeLabel.sd_layout().heightIs(0)
                _ = vedioContainerView.sd_layout().heightIs(0)
                _ = photoContainerView.sd_layout().heightIs(0)
                _ = audioButton.sd_layout().heightIs(0)
                _ = lb_address.sd_layout().topSpaceToView(lb_content,5)

            }else if  rautumnFriendsCircle.type == 1 { //图片
                photoContainerView.isHidden = false
                vedioContainerView.isHidden = true
                audioButton.isHidden = true
                audioTimeLabel.isHidden = true
                _ = audioTimeLabel.sd_layout().heightIs(0)
                _ = vedioContainerView.sd_layout().heightIs(0)
                photoContainerView.picUrlArray =  rautumnFriendsCircle.rfcPhotosOrSmallVideos.map{$0.url}

                _ = lb_address.sd_layout().topSpaceToView(photoContainerView,5)
                
            }else if rautumnFriendsCircle.type == 2 { //视频
                photoContainerView.isHidden = true
                vedioContainerView.isHidden = false
                audioButton.isHidden = true
                audioTimeLabel.isHidden = true
                _ = audioTimeLabel.sd_layout().heightIs(0)
                rautumnFriendsCircle.coverUrl.asObservable().map{URL(string:$0)}.subscribe(onNext: {[unowned self] (url) in
                    self.vedioContainerView.sd_setImage(with: url, placeholderImage: placeHolderImage)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)

                _ = photoContainerView.sd_layout().heightIs(0)
                _ = audioButton.sd_layout().heightIs(0)
                _ = vedioContainerView.sd_layout().heightIs(screenW / 2)
                _ = lb_address.sd_layout().topSpaceToView(vedioContainerView,5)
                
            } else {// 音频
                photoContainerView.isHidden = false
                vedioContainerView.isHidden = false
                audioButton.isHidden = false
                audioTimeLabel.isHidden = false
                
                
                let audioTime = rautumnFriendsCircle.rfcPhotosOrSmallVideos.map{$0.audio_length}.first
                

                audioTimeLabel.text = "\(audioTime!)'"

                
                _ = photoContainerView.sd_layout().heightIs(0)
                _ = vedioContainerView.sd_layout().heightIs(0)
                _ = audioButton.sd_layout().heightIs(55)
                _ = audioTimeLabel.sd_layout().heightIs(21)
                _ = lb_address.sd_layout().topSpaceToView(audioTimeLabel,5)
                
            }
            if let text = btn_city.titleLabel?.text{
                _ = btn_city.sd_layout().widthIs(text.width(15, height: 20) + 20)
            }
            if let text = btn_distance.titleLabel?.text{
                _ = btn_distance.sd_layout().widthIs(text.width(14, height: 20) + 20)
            }
            
            _ =  lb_name.sd_layout().widthIs(lb_name.text!.width(15, height: 20) + 5)
            
            btn_lei.setTitle(rautumnFriendsCircle.friend == true ? "发消息" : "镭Ta", for: .normal)
            
            _ = lb_exceptionalCount.sd_layout().widthIs(lb_exceptionalCount.text!.width(12, height: 15) + 10)
            
        }
    }
    
    override var frame: CGRect{
        didSet{
            if (menu.isShowing) {
                menu.isShowing = false
            }
        }
    }
    
    @objc fileprivate func moreButtonClicked(){
        moreButtonClickedBlock?(indexPath)
    }
    
    @objc fileprivate func audioButtonEvent(sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
         let audioTime = rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.audio_length}
        let url = rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.url}!
        
        if sender.isSelected {
            if (url.hasSuffix(".aac")) {
               
             
                self.audioPlayer1.playMusic(urlString: url)
                self.audioPlayer1.playScale = {(currentTime) in
            
                    self.audioTimeLabel.text = "\(currentTime)'"
                }
                self.audioPlayer1.playEnd = {_ in

                    self.audioTimeLabel.text = "\(audioTime!)'"
                    sender.isSelected = false
                }
                
                
            } else {
                self.audioPlayer1.stopPlay()
                self.audioPlayer.startPlay(withUrlString: url, updateMeters: { (time) in
                    
                    self.audioTimeLabel.text = "\(time)'"
                }, success: {
                    sender.isSelected = false
                    
                    self.audioTimeLabel.text = "\(audioTime!)'"
                }, failed: { (error) in
                    print("playError = \(error)")
                    self.audioTimeLabel.text = "\(audioTime!)'"
                })
            }

        } else {
            self.audioTimeLabel.text = "\(audioTime!)'"
            self.audioPlayer.endPlay()
            self.audioPlayer1.stopPlay()
        }
        
    }
    
    @objc fileprivate func huluButtonClicked(button:Any?){
        huluButtonClickedBlock?(indexPath)
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
        self.delegate?.leitaButtonClickedOperationWithRadiumFriendsCircleDetailHeaderView(headerView: self)
    }

}


