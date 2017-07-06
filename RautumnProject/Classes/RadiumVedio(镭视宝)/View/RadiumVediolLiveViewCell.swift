
//
//  RadiumVediolLiveViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/10.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
import SDWebImage
class RadiumVediolLiveViewCell: UITableViewCell {
    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var img_cover: AnimatableImageView!
    @IBOutlet weak var btn_enterLiveRoom: AnimatableButton!
    @IBOutlet weak var lb_onlinePersonCount: UILabel!
//    @IBOutlet weak var lb_commentCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    var rvUseful:RvUseful!{
        didSet{
            lb_title.text = rvUseful.title
            img_cover.sd_setImage(with: URL(string:rvUseful.coverPhotoUrl), placeholderImage: nil, options:[.retryFailed])
            
            self.lb_onlinePersonCount.text = "观看人数：\(rvUseful.userCount)人"
//            lb_commentCount.text = "\(rvUseful.commentCount)"
//            DispatchQueue.main.async {[unowned self] in
//                RCIMClient.shared().getChatRoomInfo("\(self.rvUseful.id)", count: 0, order: RCChatRoomMemberOrder.chatRoom_Member_Asc, success: {[unowned self] (info) in
//                    self.lb_onlinePersonCount.text = "观看人数：\(info!.totalMemberCount)人"
//                    }, error: {_ in
//                })
//            }
           
        }
    }
}
