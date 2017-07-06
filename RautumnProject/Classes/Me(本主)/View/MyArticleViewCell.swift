
//
//  MyArticleViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/17.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
import SwiftyDrop
//import UShareUI
import SDWebImage
protocol MyArticleViewCellDelegate : NSObjectProtocol {
    func zanButtonClickedOperationWithCell(cell:MyArticleViewCell)
    func commentButtonClickedOperationWithCell(cell:MyArticleViewCell)
    func huluClickedOperationWithCell(cell:MyArticleViewCell)
    
}

class MyArticleViewCell: UITableViewCell {

    var delegate : MyArticleViewCellDelegate?
    public var moreButtonClickedBlock:((_ indexPath:IndexPath?) -> ())?
    public var huluButtonClickedBlock:((_ indexPath:IndexPath?) -> ())?
    public var audioBttonClickedBlock:((_ sender:UIButton, _ timeLabel:UILabel,_ indexPath:IndexPath?) -> Void)?
    public var indexPath:IndexPath?
    
    @IBOutlet weak var lb_content: UILabel!
    @IBOutlet weak var btn_fullText: UIButton!
    @IBOutlet weak var lb_time: UILabel!
    @IBOutlet weak var lb_bigTime: UILabel!
    
    @IBOutlet weak var btn_hulu: UIButton!
    
    @IBOutlet weak var lb_address: UILabel!
    
    @IBOutlet weak var btn_hongbao: UIButton!


    @IBOutlet weak var btn_comment: UIButton!

    @IBOutlet weak var btn_delete: UIButton!
    
    
    let photoContainerView = PhotoContainerView()
    let vedioContainerView = UIImageView()
    let img_palyVideo = UIImageView()
    let audioButton = UIButton.init(type: .custom)
    let audioTimeLabel = UILabel()
    
    let menu = RadiumFriendsCircleCellOperationMenu()
    override func awakeFromNib() {
        super.awakeFromNib()

        photoContainerView.contentMode = .scaleAspectFit
        selectionStyle = .none
        
        audioButton.setImage(UIImage.init(named: "Free_Play"), for: .normal)
        audioButton.setImage(UIImage.init(named: "zanting"), for: .selected)
        audioButton.imageView?.contentMode = .scaleAspectFill
        
        audioTimeLabel.textColor = UIColor.colorWithHexString("ff8300")
        audioTimeLabel.font = UIFont.systemFont(ofSize: 17)
        audioTimeLabel.textAlignment = .center
        audioTimeLabel.text = "0"
        
        vedioContainerView.isUserInteractionEnabled = true
        img_palyVideo.contentMode = .center
        img_palyVideo.image = UIImage(named:"playBtn")
//        do {
//            NotificationCenter.default.rx.notification(NSNotification.Name(rawValue: RadiumFriendsCircleViewCellOperationButtonClickedNotification), object: nil)
//                .subscribe(onNext: {[unowned self] (notification) in
//                    let object = notification.object as! UIButton
//                    if object != self.btn_hulu && self.menu.isShowing{
//                        self.menu.isShowing = false
//                    }
//                })
//                .addDisposableTo(rx_reusableDisposeBag)
//        }
        
        maxContentLabelHeight = lb_content.font.lineHeight * CGFloat(maxLineNumber)
        
        btn_fullText.addTarget(self, action: #selector(moreButtonClicked), for: .touchUpInside)
//        btn_hulu.addTarget(self, action: #selector(MyArticleViewCell.huluButtonClicked(button:)), for: .touchUpInside)
        audioButton.addTarget(self, action: #selector(audioButtonEvent(sender:)), for: .touchUpInside)
        
        contentView.addSubview(vedioContainerView)
        contentView.addSubview(photoContainerView)
        vedioContainerView.addSubview(img_palyVideo)
        contentView.addSubview(audioButton)
        contentView.addSubview(audioTimeLabel)
        
//        contentView.insertSubview(menu, belowSubview: btn_hulu)
        
        
        _ = menu.sd_layout().rightSpaceToView(btn_hulu,2)?.heightIs(36)?.widthIs(0)?.centerYEqualToView(btn_hulu)
        
        
        menu.commentButtonClickedOperation = {
            self.delegate?.commentButtonClickedOperationWithCell(cell: self)
        }
        menu.likeButtonClickedOperation = {
            self.delegate?.zanButtonClickedOperationWithCell(cell: self)
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
    }

    
    var rautumnFriendsCircleFrame : MyArticleFrame!{
        didSet{
            
            guard let rautumnFriendsCircle = rautumnFriendsCircleFrame.rautumnFriendsCircle else {
                return
            }
            lb_bigTime.frame = rautumnFriendsCircleFrame.bigTimeLabelFrame
            
            btn_delete.frame = rautumnFriendsCircleFrame.deleteBtnFrame
            
            btn_comment.frame = rautumnFriendsCircleFrame.commentBtnFrame
           
            btn_hongbao.frame = rautumnFriendsCircleFrame.dashangBtnFrame

            lb_content.frame = rautumnFriendsCircleFrame.contentLabelFrame
            
            photoContainerView.frame = rautumnFriendsCircleFrame.imageContentViewFrame
            
            vedioContainerView.frame = rautumnFriendsCircleFrame.videoImgViewViewFrame
            
            img_palyVideo.frame = rautumnFriendsCircleFrame.videoPlayImgViewFrame
            
            audioButton.frame = rautumnFriendsCircleFrame.audioButtonFrame
            audioTimeLabel.frame = rautumnFriendsCircleFrame.audioTimeLabelFrame
            
            lb_address.frame = rautumnFriendsCircleFrame.addressLabelFrame
            
            lb_time.frame = rautumnFriendsCircleFrame.timeLabelFrame
            
//            btn_hulu.frame = rautumnFriendsCircleFrame.huluBtnFrame
            
            btn_fullText.frame = rautumnFriendsCircleFrame.fullTextLabelFrame
            
            
            lb_address.text = rautumnFriendsCircle.positionName
            
            lb_address.isHidden = rautumnFriendsCircle.positionName == ""
            
            
            
//            lb_content.text = rautumnFriendsCircle.narrativeContent
            lb_content.attributedText = rautumnFriendsCircle.attrContent

            rautumnFriendsCircle.isOpening.asObservable().subscribe(onNext: {[unowned self] (isOpening) in
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
                
            }else if rautumnFriendsCircle.type == 2 { //视频
                photoContainerView.isHidden = true
                vedioContainerView.isHidden = false
                img_palyVideo.isHidden = false
                audioButton.isHidden = true
                audioTimeLabel.isHidden = true
                
                rautumnFriendsCircle.coverUrl.asObservable().map{URL(string:$0)}.subscribe(onNext: {[unowned self] (url) in
                    if url?.absoluteString == ""{
                        self.vedioContainerView.sd_setImage(with: URL(string:rautumnFriendsCircle.rfcPhotosOrSmallVideos.first!.coverUrl), placeholderImage: placeHolderImage, options: [.retryFailed])
                       
                    }else{
                        self.vedioContainerView.sd_setImage(with: url, placeholderImage: placeHolderImage, options: [.retryFailed])
                    }
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
            } else { // 音频
                
                photoContainerView.isHidden = true
                vedioContainerView.isHidden = true
                img_palyVideo.isHidden = true
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
                
//                audioButton.setTitle("\(audioTime!)'", for: .normal)
                    audioTimeLabel.text = "\(audioTime!)'"
//                audioButton.setTitleColor(UIColor.colorWithHexString("ff8300"), for: .normal)
//                audioButton.titleEdgeInsets = UIEdgeInsets.init(top: (audioButton.imageView?.height)!+5.0, left: -(audioButton.imageView?.width)!, bottom: 0.0, right: -10.0)
//                audioButton.imageEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: -(audioButton.titleLabel?.width)!)
                
            }
            
            rautumnFriendsCircle.isShowMenu.asObservable()
                .subscribe(onNext: {[unowned self] (isShowMenu) in
                    self.menu.isShowing = isShowMenu
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_reusableDisposeBag)
            
            lb_bigTime.text = rautumnFriendsCircleFrame.rautumnFriendsCircle.dateTime
            
            rautumnFriendsCircleFrame.rautumnFriendsCircle.commentCount.asObservable().map{"\($0)"}.bindTo(btn_comment.rx.title())
        .addDisposableTo(rx_disposeBag)
            
            rautumnFriendsCircleFrame.rautumnFriendsCircle.countRC.asObservable().map{"\($0)"}.bindTo(btn_hongbao.rx.title())
                .addDisposableTo(rx_disposeBag)

         
            
        }
    }
    
//    override var frame: CGRect{
//        didSet{
//            if (menu.isShowing) {
//                menu.isShowing = false
//            }
//        }
//    }
    
    @objc fileprivate func audioButtonEvent(sender: UIButton) {
        audioBttonClickedBlock?(sender,audioTimeLabel,indexPath)
    }
    
    @objc fileprivate func moreButtonClicked(){
        moreButtonClickedBlock?(indexPath)
    }
    @objc fileprivate func huluButtonClicked(button:Any?){
        //        huluButtonClickedBlock?(indexPath)
        //        self.delegate?.huluClickedOperationWithradiumFriendsCircleViewCell(cell: self)
        
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RadiumFriendsCircleViewCellOperationButtonClickedNotification), object: btn_hulu as Any?)
//        menu.isShowing = !menu.isShowing
        self.delegate?.huluClickedOperationWithCell(cell: self)
    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        super.touchesBegan(touches, with: event)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: RadiumFriendsCircleViewCellOperationButtonClickedNotification), object: btn_hulu as Any?)
//        if menu.isShowing {
//            menu.isShowing = false
//        }
//    }
  
}
