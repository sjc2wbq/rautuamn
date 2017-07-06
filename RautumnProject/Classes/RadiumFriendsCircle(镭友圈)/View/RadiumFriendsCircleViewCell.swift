//
//  RadiumFriendsCircleViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/10.
//  Copyright © 2017年 Rautumn. All rights reserved.
//
import UIKit
import IBAnimatable
import SwiftyDrop
//import UShareUI
import SDWebImage
var maxContentLabelHeight:CGFloat = 0
let maxLineNumber = 6
let RadiumFriendsCircleViewCellOperationButtonClickedNotification = "RadiumFriendsCircleViewCellOperationButtonClickedNotification"

protocol RadiumFriendsCircleViewCellDelegate : NSObjectProtocol {
    func zanButtonClickedOperationWithradiumFriendsCircleViewCell(cell:RadiumFriendsCircleViewCell)
    func commentButtonClickedOperationWithradiumFriendsCircleViewCell(cell:RadiumFriendsCircleViewCell)
    func leitaButtonClickedOperationWithradiumFriendsCircleViewCell(cell:RadiumFriendsCircleViewCell)
    func huluClickedOperationWithradiumFriendsCircleViewCell(cell:RadiumFriendsCircleViewCell)
    func complaintsClickedOperationWithradiumFriendsCircleViewCell(cell:RadiumFriendsCircleViewCell)
   
}
class RadiumFriendsCircleViewCell: UITableViewCell {
    
  public  weak var delegate : RadiumFriendsCircleViewCellDelegate?
    public var moreButtonClickedBlock:((_ indexPath:IndexPath?) -> ())?
    public var huluButtonClickedBlock:((_ indexPath:IndexPath?) -> ())?
    public var audionButtonClickedClosure:((_ sender:UIButton, _ timeLabel:UILabel,_ indexPath:IndexPath?) -> Void)?
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
    @IBOutlet weak var btn_fullText: UIButton!
    @IBOutlet weak var lb_time: UILabel!
    
    @IBOutlet weak var btn_lei: AnimatableButton!
    @IBOutlet weak var btn_hulu: UIButton!
    
    @IBOutlet weak var lb_address: UILabel!

    
    
    let photoContainerView = PhotoContainerView()
    let vedioContainerView = UIImageView()
    let img_palyVideo = UIImageView()
    let audioTimeLabel = UILabel()
    let audioButton = UIButton.init(type: UIButtonType.custom)
    
    let menu = RadiumFriendsCircleCellOperationMenu()
    
    let lineViewLayer = CALayer()

    override func awakeFromNib() {
        super.awakeFromNib()
//        btn_hulu.backgroundColor = UIColor.red
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
        audioButton.contentVerticalAlignment = .center
        
        audioTimeLabel.textColor = UIColor.colorWithHexString("ff8300")
        audioTimeLabel.font = UIFont.systemFont(ofSize: 17)
        audioTimeLabel.textAlignment = .center
        audioTimeLabel.text = "0"
        
        photoContainerView.contentMode = .scaleAspectFit
        lineViewLayer.backgroundColor = bgColor.cgColor
        layer.addSublayer(lineViewLayer)
        photoContainerView.contentMode = .scaleAspectFit
            selectionStyle = .none
        vedioContainerView.isUserInteractionEnabled = true
        img_palyVideo.contentMode = .center
        img_palyVideo.image = UIImage(named:"playBtn")
        do {
         NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: RadiumFriendsCircleViewCellOperationButtonClickedNotification), object: nil)
            .subscribe(onNext: {[unowned self] (notification) in
                let object = notification.object as! UIButton
                if object != self.btn_hulu && self.menu.isShowing{
                self.menu.isShowing = false
                }
            })
            .addDisposableTo(rx_reusableDisposeBag)
        }

        maxContentLabelHeight = lb_content.font.lineHeight * CGFloat(maxLineNumber)

        btn_fullText.addTarget(self, action: #selector(moreButtonClicked), for: .touchUpInside)
        btn_hulu.addTarget(self, action: #selector(RadiumFriendsCircleViewCell.huluButtonClicked(button:)), for: .touchUpInside)
        audioButton.addTarget(self, action: #selector(audionButtonEvent), for: .touchUpInside)
        
        contentView.addSubview(vedioContainerView)
        contentView.addSubview(photoContainerView)
        contentView.addSubview(img_palyVideo)
        contentView.addSubview(audioButton)
        contentView.addSubview(audioTimeLabel)
//        vedioContainerView.addSubview(img_palyVideo)
        
        contentView.insertSubview(menu, belowSubview: btn_hulu)
        
        _ = menu.sd_layout().rightSpaceToView(btn_hulu,-8)?.heightIs(36)?.widthIs(0)?.centerYEqualToView(btn_hulu)
        
        btn_lei.addTarget(self, action: #selector(leiTaAction), for: .touchUpInside)
        menu.commentButtonClickedOperation = {
            self.delegate?.commentButtonClickedOperationWithradiumFriendsCircleViewCell(cell: self)
        }
        menu.likeButtonClickedOperation = {
        self.delegate?.zanButtonClickedOperationWithradiumFriendsCircleViewCell(cell: self)
        }
        menu.shareButtonClickedOperation = { //分享
            UMSocialUIManager.showShareMenuViewInWindow(platformSelectionBlock: { (platformType, userInfo) in
                
                var text = "不一样的世界，不一样的自己！"
                let rautumnFriendsCircle = self.rautumnFriendsCircleFrame.rautumnFriendsCircle
                if (rautumnFriendsCircle?.narrativeContent.characters.count)! <= 25 {
                    text = (rautumnFriendsCircle?.narrativeContent)!
                }
                
                if (rautumnFriendsCircle?.narrativeContent.characters.count)! > 25 {
                    
                    let string = rautumnFriendsCircle?.narrativeContent as! NSString
                    text = "\(string.substring(to: 25))..."
                }
                
                let messageObject = UMSocialMessageObject()
                messageObject.text = text
                let shareObject = UMShareWebpageObject()
                shareObject.title = "镭秋:个性化社交分享平台"
                shareObject.descr = text
                shareObject.thumbImage = UIImage(named: "icon")
                shareObject.webpageUrl = "\(PREURL)appserver/api?action=toShare"
//                shareObject.webpageUrl = "https://itunes.apple.com/cn/app/%E9%95%AD%E7%A7%8B/id1187073086?mt=8"
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
        
        menu.complaintsButtonClickedOperation = { // 举报
            self.delegate?.complaintsClickedOperationWithradiumFriendsCircleViewCell(cell: self)
        }
        
        img_icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.img_iconAction(tap:))))
    }
    
    @objc fileprivate func audionButtonEvent() {
        
        
        
        audionButtonClickedClosure?(audioButton,audioTimeLabel,indexPath)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineViewLayer.frame = CGRect(x: 0, y: 0, width: screenW, height: 10)
    }
    @objc fileprivate func img_iconAction(tap:UITapGestureRecognizer)  {
        
        
        let vc = UserInfoViewController()
        vc.visitorUserId = Int(self.rautumnFriendsCircleFrame.rautumnFriendsCircle.userId)
        vc.title = self.rautumnFriendsCircleFrame.rautumnFriendsCircle.nickName
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    var rautumnFriendsCircleFrame : RautumnFriendsCircleFrame!{
        didSet{
            guard let rautumnFriendsCircle = rautumnFriendsCircleFrame.rautumnFriendsCircle else {
                return
            }
          img_icon.frame = rautumnFriendsCircleFrame.avatarImgViewFrame
            
          img_rank.frame = rautumnFriendsCircleFrame.rankImgViewFrame
            
          lb_name.frame = rautumnFriendsCircleFrame.nameLabelFrame
            
          starView.frame = rautumnFriendsCircleFrame.starViewFrame
            
           lb_tag1.frame = rautumnFriendsCircleFrame.tag1LabelFrame
         
            lb_tag2.frame = rautumnFriendsCircleFrame.tag2LabelFrame
   
            lb_huzhu.frame = rautumnFriendsCircleFrame.huzhuImgViewFrame
            
             btn_city.frame = rautumnFriendsCircleFrame.cityBtnFrame
            
            btn_distance.frame = rautumnFriendsCircleFrame.distanceBtnFrame
            
             btn_lei.frame = rautumnFriendsCircleFrame.leiTaBtnFrame
            
             lb_content.frame = rautumnFriendsCircleFrame.contentLabelFrame
            
            photoContainerView.frame = rautumnFriendsCircleFrame.imageContentViewFrame
            
            vedioContainerView.frame = rautumnFriendsCircleFrame.videoImgViewViewFrame
        
             img_palyVideo.frame = rautumnFriendsCircleFrame.videoPlayImgViewFrame
            
            audioButton.frame = rautumnFriendsCircleFrame.audioButtonFrame
            audioTimeLabel.frame = rautumnFriendsCircleFrame.aduioTimeLabelFrame
            
            lb_address.frame = rautumnFriendsCircleFrame.addressLabelFrame
            
            lb_time.frame = rautumnFriendsCircleFrame.timeLabelFrame
            
             btn_hulu.frame = rautumnFriendsCircleFrame.huluBtnFrame
            
            btn_fullText.frame = rautumnFriendsCircleFrame.fullTextLabelFrame
            starView.isHidden = rautumnFriendsCircleFrame.rautumnFriendsCircle.starLevel == 0
            
            starView.star = rautumnFriendsCircleFrame.rautumnFriendsCircle.starLevel
            
            img_icon.sd_setImage(with: URL(string:rautumnFriendsCircle.headUrl), placeholderImage: defaultHeaderImage)
            
            img_rank.image = UIImage(named:"isCertification_\(rautumnFriendsCircle.rank)")
        
            lb_content.attributedText = rautumnFriendsCircle.attrContent
            lb_name.text = rautumnFriendsCircle.nickName
            btn_lei.setTitle(rautumnFriendsCircleFrame.rautumnFriendsCircle.friend == true ? "发消息" : "镭Ta", for: .normal)
            lb_huzhu.isHidden = !rautumnFriendsCircle.mutualTourism
            lb_tag1.backgroundColor = UIColor.colorWithHexString(rautumnFriendsCircle.emotion == "找女友" ? "#84E941" : "#FD6BA7")
            if rautumnFriendsCircle.emotion == "找女友" {
                lb_tag1.isHidden = false
                lb_tag1.text = "FG"
            }else if rautumnFriendsCircle.emotion == "找男友" {
                lb_tag1.isHidden = false
                lb_tag1.text = "FB"
            }else{
                lb_tag1.isHidden = true
            }
        
            if rautumnFriendsCircle.changeJob {
                lb_tag2.isHidden = false
            }else{
                lb_tag2.isHidden = true
            }
            if rautumnFriendsCircle.distanceOff{
                btn_distance.setTitle("关闭距离", for: .normal)
            }else{
                btn_distance.setTitle("\(rautumnFriendsCircle.distance)km", for: .normal)
            }
            btn_city.setTitle(rautumnFriendsCircle.permanentCity, for: .normal)
            
            lb_address.text = rautumnFriendsCircle.positionName
            
            lb_address.isHidden = rautumnFriendsCircle.positionName == ""
            
//            lb_content.text = rautumnFriendsCircle.narrativeContent
            
             rautumnFriendsCircle.isOpening.asObservable().subscribe(onNext: { (isOpening) in
                if isOpening {
                    self.btn_fullText.setTitle("收起", for: .normal)
                }else{
                    self.btn_fullText.setTitle("全文", for: .normal)
                }
             }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_reusableDisposeBag)
          
            if rautumnFriendsCircle.shouldShowMoreButton{
                btn_fullText.isHidden = false
            }else{
                btn_fullText.isHidden = true
            }
            
            lb_time.text = rautumnFriendsCircle.time
            if  rautumnFriendsCircle.type == 0 { //纯文本
                photoContainerView.isHidden = true
                vedioContainerView.isHidden = true
                img_palyVideo.isHidden = true
                audioButton.isHidden = true
                audioTimeLabel.isHidden = true
            
            }else if  rautumnFriendsCircle.type == 1 { //图片
                img_palyVideo.isHidden = true
                photoContainerView.isHidden = false
                vedioContainerView.isHidden = true
                audioButton.isHidden = true
                audioTimeLabel.isHidden = true
                photoContainerView.picUrlArray =  rautumnFriendsCircle.rfcPhotosOrSmallVideos.map{$0.url}
                
            } else if rautumnFriendsCircle.type == 2 { // 视频
                
                photoContainerView.isHidden = true
                audioButton.isHidden = true
                audioTimeLabel.isHidden = true
                vedioContainerView.isHidden = false
                
                img_palyVideo.isHidden = false
                
                rautumnFriendsCircle.coverUrl.asObservable().subscribe(onNext: { (url) in
                    
                    print("url = \(url)\n--------\nnnnnnnn = \(rautumnFriendsCircle.rfcPhotosOrSmallVideos.first!.coverUrl)")
                    
                    if url == "" {
                        
                        self.vedioContainerView.sd_setImage(with: URL(string:rautumnFriendsCircle.rfcPhotosOrSmallVideos.first!.coverUrl), placeholderImage: placeHolderImage, options: [.retryFailed])
                    }else{
                        
                        
                        self.vedioContainerView.sd_setImage(with: URL(string:url), placeholderImage: placeHolderImage, options: [.retryFailed])
                    }
                })
                    .addDisposableTo(rx_disposeBag)
                
            } else{ // 音频
                
                photoContainerView.isHidden = true
                vedioContainerView.isHidden = true
                audioButton.isHidden = false
                audioTimeLabel.isHidden = false
                
                let audioTime = rautumnFriendsCircle.rfcPhotosOrSmallVideos.map{$0.audio_length}.first
//                let second = audioTime!%60
//                let minute = audioTime!/60
//                if minute == 0 {
//                    audioButton.setTitle("\(second)\"", for: .normal)
//                } else {
//                    audioButton.setTitle("\(minute)'\(second)\"", for: .normal)
//                }
                
                audioTimeLabel.text = "\(audioTime!)'"
                
//                audioButton.setTitle("\(audioTime!)'", for: .normal)
//                audioButton.setTitleColor(UIColor.colorWithHexString("ff8300"), for: .normal)
//                audioButton.titleEdgeInsets = UIEdgeInsets.init(top: (audioButton.imageView?.height)!+5.0, left: -(audioButton.imageView?.width)!, bottom: 0.0, right: -10.0)
//                audioButton.imageEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: -(audioButton.titleLabel?.width)!)
                
        }
            rautumnFriendsCircle.isShowMenu.asObservable()
            .subscribe(onNext: {[unowned self] (isShowMenu) in
                self.menu.isShowing = isShowMenu
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_reusableDisposeBag)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc fileprivate func moreButtonClicked(){
    moreButtonClickedBlock?(indexPath)
    }
    @objc fileprivate func huluButtonClicked(button:Any?){
//        postOperationButtonClickedNotification()
//          menu.isShowing = !menu.isShowing
    self.delegate?.huluClickedOperationWithradiumFriendsCircleViewCell(cell: self)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let rautumnFriendsCircle = self.rautumnFriendsCircleFrame.rautumnFriendsCircle{
            if rautumnFriendsCircle.isShowMenu.value{
                rautumnFriendsCircle.isShowMenu.value = false
            }
        }
    }
    @objc fileprivate func leiTaAction(){
        
        
     self.delegate?.leitaButtonClickedOperationWithradiumFriendsCircleViewCell(cell: self)
    }

}



