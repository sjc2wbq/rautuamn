//
//  RadiumVedioRSVViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
//import UShareUI
import IBAnimatable
import SDAutoLayout
import SwiftyDrop
protocol RadiumVedioRSVViewCellDelegate : NSObjectProtocol {
    func zanButtonClickedOperationWithCell(cell:RadiumVedioRSVViewCell)
    func commentButtonClickedOperationWithCell(cell:RadiumVedioRSVViewCell)
    func leitaButtonClickedOperationWithCell(cell:RadiumVedioRSVViewCell)
    func huluClickedOperationWithCell(cell:RadiumVedioRSVViewCell)
    
}
class RadiumVedioRSVViewCell: UITableViewCell {
    var delegate : RadiumVedioRSVViewCellDelegate?

    
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

    
    @IBOutlet weak var img_vedio: AnimatableImageView!
    let img_palyVideo = UIImageView()

    let menu = RadiumFriendsCircleCellOperationMenu()


    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        img_palyVideo.contentMode = .center
        img_palyVideo.image = UIImage(named:"playBtn")
        
                img_vedio.addSubview(img_palyVideo)
        
        contentView.insertSubview(menu, belowSubview: btn_hulu)
        _ = menu.sd_layout().rightSpaceToView(btn_hulu,2)?.heightIs(36)?.widthIs(0)?.centerYEqualToView(btn_hulu)

        do {
  
            
            
            maxContentLabelHeight = lb_content.font.lineHeight * CGFloat(maxLineNumber)
            
            btn_hulu.addTarget(self, action: #selector(RadiumVedioRSVViewCell.huluButtonClicked(button:)), for: .touchUpInside)
        }

        
        btn_lei.addTarget(self, action: #selector(leiTaAction), for: .touchUpInside)
        menu.commentButtonClickedOperation = {
            self.delegate?.commentButtonClickedOperationWithCell(cell: self)
        }
        menu.likeButtonClickedOperation = {
            self.delegate?.zanButtonClickedOperationWithCell(cell: self)
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
        img_icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.img_iconAction(tap:))))

        
    }
    @objc fileprivate func img_iconAction(tap:UITapGestureRecognizer)  {
        let vc = UserInfoViewController()
        vc.visitorUserId = Int(self.rvUsefulFrame.rvUseful.userId)
        vc.title = self.rvUsefulFrame.rvUseful.nickName
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    var rvUsefulFrame:RvUsefulFrame!{
        didSet{
            
            img_icon.frame = rvUsefulFrame.avatarImgViewFrame
            
            img_rank.frame = rvUsefulFrame.rankImgViewFrame
            
            lb_name.frame = rvUsefulFrame.nameLabelFrame
            
            starView.frame = rvUsefulFrame.starViewFrame
            
            starView.isHidden = rvUsefulFrame.rvUseful.starLevel == 0
            
            lb_tag1.frame = rvUsefulFrame.tag1LabelFrame
            
            lb_tag2.frame = rvUsefulFrame.tag2LabelFrame
            
            lb_huzhu.frame = rvUsefulFrame.huzhuImgViewFrame
            
            btn_city.frame = rvUsefulFrame.cityBtnFrame
            
            btn_distance.frame = rvUsefulFrame.distanceBtnFrame
            
            btn_lei.frame = rvUsefulFrame.leiTaBtnFrame
            
            lb_content.frame = rvUsefulFrame.contentLabelFrame
            
            
            img_vedio.frame = rvUsefulFrame.videoImgViewViewFrame
            
            img_palyVideo.frame = rvUsefulFrame.videoPlayImgViewFrame
            
            lb_address.frame = rvUsefulFrame.addressLabelFrame
            
            lb_time.frame = rvUsefulFrame.timeLabelFrame
            
            btn_hulu.frame = rvUsefulFrame.huluBtnFrame
            
//            btn_fullText.frame = rvUsefulFrame.fullTextLabelFrame
            
            starView.star = rvUsefulFrame.rvUseful.starLevel
            
            img_icon.sd_setImage(with: URL(string:rvUsefulFrame.rvUseful.headPortUrl), placeholderImage: defaultHeaderImage)
            
            img_rank.image = UIImage(named:"isCertification_\(rvUsefulFrame.rvUseful.rank)")
            
            
            lb_name.text = rvUsefulFrame.rvUseful.nickName
            
            lb_huzhu.isHidden = !rvUsefulFrame.rvUseful.mutualTourism
            lb_tag1.backgroundColor = UIColor.colorWithHexString(rvUsefulFrame.rvUseful.emotion == "找女友" ? "#84E941" : "#FD6BA7")

            if rvUsefulFrame.rvUseful.emotion == "找女友" {
                lb_tag1.isHidden = false
                lb_tag1.text = "FG"
            }else if rvUsefulFrame.rvUseful.emotion == "找男友" {
                lb_tag1.isHidden = false
                lb_tag1.text = "FB"
            }else{
                lb_tag1.isHidden = true
            }
            
            if rvUsefulFrame.rvUseful.changeJob {
                lb_tag2.isHidden = false
            }else{
                lb_tag2.isHidden = true
            }
            if rvUsefulFrame.rvUseful.distanceOff{
                btn_distance.setTitle("关闭距离", for: .normal)
            }else{
                btn_distance.setTitle("\(rvUsefulFrame.rvUseful.distance)km", for: .normal)
            }
            btn_city.setTitle(rvUsefulFrame.rvUseful.permanentCity, for: .normal)
            
            lb_address.text = rvUsefulFrame.rvUseful.position
            
            lb_address.isHidden = rvUsefulFrame.rvUseful.position == ""
            
            lb_content.text = rvUsefulFrame.rvUseful.title

            img_vedio.sd_setImage(with: URL(string:rvUsefulFrame.rvUseful.coverPhotoUrl), placeholderImage: placeHolderImage)
            
            btn_lei.setTitle(rvUsefulFrame.rvUseful.friend == true ? "发消息" : "镭Ta", for: .normal)
            
            rvUsefulFrame.rvUseful.isShowMenu.asObservable()
                .subscribe(onNext: {[unowned self] (isShowMenu) in
                    self.menu.isShowing = isShowMenu
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_reusableDisposeBag)
            lb_time.text = rvUsefulFrame.rvUseful.time
        }
    }

    @objc fileprivate func moreButtonClicked(){
//        moreButtonClickedBlock?(indexPath)
    }
    @objc fileprivate func huluButtonClicked(button:Any?){
        //        huluButtonClickedBlock?(indexPath)
        self.delegate?.huluClickedOperationWithCell(cell: self)
        
          }

    @objc fileprivate func leiTaAction(){
        self.delegate?.leitaButtonClickedOperationWithCell(cell: self)
    
    }
}
