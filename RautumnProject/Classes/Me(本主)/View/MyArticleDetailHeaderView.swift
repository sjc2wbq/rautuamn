

//
//  MyArticleDetailHeaderView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/17.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDAutoLayout
import SDWebImage
import IBAnimatable
import SwiftyDrop
//import UShareUI

protocol MyArticleDetailHeaderViewDelegate : NSObjectProtocol {
    func zanButtonClickedOperationWithHeaderView(headerView:MyArticleDetailHeaderView)
    func commentButtonClickedOperationWithHeaderView(headerView:MyArticleDetailHeaderView)
    func leitaButtonClickedOperationWithHeaderView(headerView:MyArticleDetailHeaderView)
    
}

class MyArticleDetailHeaderView: UIView {
    static func headerView() -> MyArticleDetailHeaderView{
        return Bundle.main.loadNibNamed("MyArticleDetailHeaderView", owner: nil, options: nil)![0] as! MyArticleDetailHeaderView
    }
    

    let lineLayer = CALayer()
    let lineViewLayer = CALayer()

    var delegate : MyArticleDetailHeaderViewDelegate?

    public var moreButtonClickedBlock:((_ indexPath:IndexPath?) -> ())?
    public var huluButtonClickedBlock:((_ indexPath:IndexPath?) -> ())?
    public var indexPath:IndexPath?
    @IBOutlet weak var lb_bigTime: UILabel!

    @IBOutlet weak var lb_content: UILabel!
    @IBOutlet weak var lb_time: UILabel!
    
    
    @IBOutlet weak var lb_address: UILabel!
    
    @IBOutlet weak var btn_hongbao: UIButton!
    
    
    @IBOutlet weak var btn_comment: UIButton!
    

    
    let photoContainerView = PhotoContainerView()
    let vedioContainerView = UIImageView()
    let img_palyVideo = UIImageView()
    let audioButton = UIButton.init(type: .custom)
    let audioTimeLabel = UILabel()
    
    var audioPlayer = HKPlayerAudio()
    var audioPlayer1 = HKPlayer.instance
    
    let menu = RadiumFriendsCircleCellOperationMenu()
    override func awakeFromNib() {
        super.awakeFromNib()
        lineViewLayer.backgroundColor = bgColor.cgColor
        layer.addSublayer(lineViewLayer)

        if maxContentLabelHeight == 0{
            maxContentLabelHeight = lb_content.font.lineHeight * CGFloat(maxLineNumber)
        }
        

        photoContainerView.contentMode = .scaleAspectFit
        addSubview(vedioContainerView)
        addSubview(photoContainerView)
        addSubview(audioButton)
        addSubview(audioTimeLabel)
        
        vedioContainerView.isUserInteractionEnabled = true
        img_palyVideo.contentMode = .center
        img_palyVideo.image = UIImage(named:"playBtn")
        
        audioButton.setImage(UIImage.init(named: "Free_Play"), for: .normal)
        audioButton.setImage(UIImage.init(named: "zanting"), for: .selected)
        audioButton.imageView?.contentMode = .scaleAspectFill
        audioButton.contentVerticalAlignment = .center
        
        audioTimeLabel.textColor = UIColor.colorWithHexString("ff8300")
        audioTimeLabel.font = UIFont.systemFont(ofSize: 15)
        audioTimeLabel.textAlignment = .center
        audioTimeLabel.text = "0"
        
        vedioContainerView.addSubview(img_palyVideo)
        
        
        _ = lb_bigTime.sd_layout().leftSpaceToView(self,10)?.topSpaceToView(self,10)?.rightSpaceToView(self,10)?.heightIs(40)

        _ = lb_content.sd_layout().leftSpaceToView(self,10)?.topSpaceToView(lb_bigTime,10)?.rightSpaceToView(self,10)
    
        
        _ = photoContainerView.sd_layout().leftEqualToView(lb_content)?.topSpaceToView(lb_content,10)
        
        _ =  vedioContainerView.sd_layout().leftEqualToView(lb_content)?.topSpaceToView(lb_content,10)?.rightEqualToView(lb_content)
        _ = audioButton.sd_layout().leftEqualToView(lb_content)?.topSpaceToView(lb_content,10)?.heightIs(55.0)?.widthIs(55.0)
        _ = audioTimeLabel.sd_layout().leftEqualToView(lb_content)?.topSpaceToView(audioButton,0.0)?.heightIs(21.0)?.widthIs(55.0)
        
        _ = img_palyVideo.sd_layout().widthIs(100)?.heightIs(80)?.centerXEqualToView(vedioContainerView)?.centerYEqualToView(vedioContainerView)
        
        
        _ = lb_address.sd_layout().leftEqualToView(lb_content)?.heightIs(15)
        
        _ = lb_time.sd_layout().leftEqualToView(lb_content)?.heightIs(15)?.topSpaceToView(lb_address,5)
        
        _ = btn_comment.sd_layout().leftSpaceToView(lb_time,5)?.centerYEqualToView(lb_time)?.heightIs(15)
        
        _ = btn_hongbao.sd_layout().leftSpaceToView(btn_comment,5)?.centerYEqualToView(btn_comment)?.heightIs(15)
        
        
        setupAutoHeight(withBottomView: lb_time, bottomMargin: 20)
        
        
        menu.commentButtonClickedOperation = {[unowned self] in
            self.delegate?.commentButtonClickedOperationWithHeaderView(headerView: self)
        }
        menu.likeButtonClickedOperation = {[unowned self] in
            self.delegate?.zanButtonClickedOperationWithHeaderView(headerView: self)
        }
        menu.shareButtonClickedOperation = { [unowned self] in
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
        
        audioButton.addTarget(self, action: #selector(audioButtonEvent), for: .touchUpInside)
        
    }
    
    @objc fileprivate func audioButtonEvent() {
        
        audioButton.isSelected = !audioButton.isSelected
        
        let url = rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.url}
        
        let audioTime = rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.audio_length}
        if audioButton.isSelected {
            if (url?.hasSuffix(".aac"))! {
               
                self.audioPlayer1.playMusic(urlString: url)
                self.audioPlayer1.playScale = {(currentTime) in
                    self.audioTimeLabel.text = "\(currentTime)'"
                }
                self.audioPlayer1.playEnd = {_ in
                    self.audioTimeLabel.text = "\(audioTime!)'"
                    self.audioButton.isSelected = false
                }
                
            } else {

                self.audioPlayer.startPlay(withUrlString: url, updateMeters: { (time) in
                    
                    self.audioTimeLabel.text = "\(time)'"
                }, success: {
                    self.audioButton.isSelected = false
                    
                    self.audioTimeLabel.text = "\(audioTime!)'"
                }, failed: { (error) in
                    print("playError = \(error)")
                    self.audioTimeLabel.text = "\(audioTime!)'"
                })
            }
            

        } else {
//
            self.audioPlayer.endPlay()
            self.audioPlayer1.stopPlay()
            self.audioTimeLabel.text = "\(audioTime!)'"
        }
    }
    
    @objc fileprivate func showVideoPlayer(tap:UITapGestureRecognizer){
        let view = tap.view
        let vc = PlayVideoViewController()
        vc.videoUrl = URL(string:rautumnFriendsCircle.rfcPhotosOrSmallVideos.first.map{$0.url}!)
        self.viewController?.present(vc, animated: true, completion: nil)

    }
    override func layoutSubviews() {
        super.layoutSubviews()
        lineViewLayer.frame = CGRect(x: 0, y: self.bounds.size.height - 10, width: screenW, height: 10)
    }
    var rautumnFriendsCircle:RautumnFriendsCircle!{
        didSet{
            
          
            
            rautumnFriendsCircle.commentCount.asObservable().map{"\($0)"}.bindTo(btn_comment.rx.title())
                .addDisposableTo(rx_disposeBag)
            
            rautumnFriendsCircle.countRC.asObservable().map{"\($0)"}.bindTo(btn_hongbao.rx.title())
                .addDisposableTo(rx_disposeBag)

            
            rautumnFriendsCircle.isShowMenu.asObservable()
                .subscribe(onNext: {[unowned self] (isShowMenu) in
                    self.menu.isShowing = isShowMenu
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            

            
            lb_address.text = rautumnFriendsCircle.positionName
            
            lb_address.isHidden = rautumnFriendsCircle.positionName == ""
            
            _ = lb_address.sd_layout().heightIs(rautumnFriendsCircle.positionName == "" ? 0 : 15)
            
            
//            lb_content.text = rautumnFriendsCircle.narrativeContent
            lb_content.attributedText = rautumnFriendsCircle.attrContent
            _ = lb_content.sd_layout().heightIs((lb_content.attributedText?.boundingRect(with: CGSize(width: screenW - 28, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size.height)! + 15)

            
            
            lb_time.text = rautumnFriendsCircle.time
            lb_bigTime.text = rautumnFriendsCircle.time
            if  rautumnFriendsCircle.type == 0 { //纯文本
                photoContainerView.isHidden = true
                vedioContainerView.isHidden = true
                audioButton.isHidden = true
                audioTimeLabel.isHidden = true

                _ = vedioContainerView.sd_layout().heightIs(0)
                _ = photoContainerView.sd_layout().heightIs(0)
                _ = audioButton.sd_layout().heightIs(0)
                _ = audioTimeLabel.sd_layout().heightIs(0)
                _ = lb_address.sd_layout().topSpaceToView(lb_content,10)
                
            }else if  rautumnFriendsCircle.type == 1 { //图片
                photoContainerView.isHidden = false
                vedioContainerView.isHidden = true
                audioButton.isHidden = true
                audioTimeLabel.isHidden = true
                _ = vedioContainerView.sd_layout().heightIs(0)
                _ = audioButton.sd_layout().heightIs(0)
                _ = audioTimeLabel.sd_layout().heightIs(0)
                photoContainerView.picUrlArray =  rautumnFriendsCircle.rfcPhotosOrSmallVideos.map{$0.url}
                
                _ = lb_address.sd_layout().topSpaceToView(photoContainerView,10)
                
            }else if rautumnFriendsCircle.type == 2 { //视频
                photoContainerView.isHidden = true
                vedioContainerView.isHidden = false
                audioButton.isHidden = true
                audioTimeLabel.isHidden = true
                rautumnFriendsCircle.coverUrl.asObservable().map{URL(string:$0)}.subscribe(onNext: {[unowned self] (url) in
                    self.vedioContainerView.sd_setImage(with: url, placeholderImage: placeHolderImage)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
                
                _ = photoContainerView.sd_layout().heightIs(0)
                _ = audioButton.sd_layout().heightIs(0)
                _ = audioTimeLabel.sd_layout().heightIs(0)
                _ = vedioContainerView.sd_layout().heightIs(screenW / 2)
                _ = lb_address.sd_layout().topSpaceToView(vedioContainerView,10)
                
            } else { // 音频
                photoContainerView.isHidden = true
                vedioContainerView.isHidden = true
                audioButton.isHidden = false
                audioTimeLabel.isHidden = false
                
                _ = photoContainerView.sd_layout().heightIs(0)
                _ = vedioContainerView.sd_layout().heightIs(0)
                _ = audioButton.sd_layout().heightIs(55)
                _ = audioTimeLabel.sd_layout().heightIs(21)
                _ = lb_address.sd_layout().topSpaceToView(audioTimeLabel,10)
                
                let audioTime = rautumnFriendsCircle.rfcPhotosOrSmallVideos.map{$0.audio_length}.first
                
//                let second = audioTime!%60
//                let minute = audioTime!/60
//                if minute == 0 {
//                    audioButton.setTitle("\(second)\"", for: .normal)
//                } else {
//                    audioButton.setTitle("\(minute)'\(second)\"", for: .normal)
//                }
                
//               audioButton.setTitle("\(audioTime!)'", for: .normal)
                audioTimeLabel.text = "\(audioTime!)'"
                
//                audioButton.setTitleColor(UIColor.colorWithHexString("ff8300"), for: .normal)
//                audioButton.titleEdgeInsets = UIEdgeInsets.init(top: (audioButton.imageView?.height)!+5.0, left: -(audioButton.imageView?.width)!, bottom: 0.0, right: -10.0)
//                audioButton.imageEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: -(audioButton.titleLabel?.width)!)
                
            }
            _ = btn_hongbao.sd_layout().widthIs("\(rautumnFriendsCircle.countRC.value)".width(13, height: 15) + 40)
            _ = btn_comment.sd_layout().widthIs("\(rautumnFriendsCircle.commentCount.value)".width(13, height: 15) + 40)

}
    }

    @objc fileprivate func moreButtonClicked(){
        moreButtonClickedBlock?(indexPath)
    }

    @objc fileprivate func leiTaAction(){
        self.delegate?.leitaButtonClickedOperationWithHeaderView(headerView: self)
    }

}
