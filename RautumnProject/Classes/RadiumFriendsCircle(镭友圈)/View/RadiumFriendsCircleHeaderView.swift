
//
//  RadiumFriendsCircleHeaderView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/10.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDWebImage
import IBAnimatable
import RxSwift
class RadiumFriendsCircleHeaderView: UIView {

    @IBOutlet weak var img_bg: UIImageView!
    @IBOutlet weak var img_header: AnimatableImageView!
    @IBOutlet weak var img_isCertification: UIImageView!
    @IBOutlet weak var lb_name: UILabel!
    @IBOutlet weak var lb_subTitle: UILabel!
    
    static func headerView() -> RadiumFriendsCircleHeaderView{
        return Bundle.main.loadNibNamed("RadiumFriendsCircleHeaderView", owner: nil, options: nil)!.first as! RadiumFriendsCircleHeaderView
    }
    
    @IBAction func headerAction(_ sender: Any) {
        let vc = UserInfoViewController()
        vc.visitorUserId = UserModel.shared.id
        vc.title = UserModel.shared.nickName.value
//        UserModel.shared.nickName.asObservable().bindTo(vc.rx.title).addDisposableTo(rx_disposeBag)
        viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        UserModel.shared.nickName.asObservable().bindTo(lb_name.rx.text).addDisposableTo(rx_disposeBag)
        UserModel.shared.headPortUrl.asObservable().subscribe(onNext: {[unowned self] (url) in
            self.img_header.sd_setImage(with: URL(string:url), placeholderImage: defaultHeaderImage)
        }, onError: nil, onCompleted: nil, onDisposed: nil).addDisposableTo(rx_disposeBag)
        
        
        UserModel.shared.rank.asObservable().map{UIImage(named:"isCertification_\($0)")}.bindTo(img_isCertification.rx.image).addDisposableTo(rx_disposeBag)
        UserModel.shared.userCount.asObservable()
        .map{"镭秋实时全球用户数: \($0)"}
        .bindTo(lb_subTitle.rx.text)
        .addDisposableTo(rx_disposeBag)
        
        UserModel.shared.nickName.asObservable().bindTo(lb_name.rx.text).addDisposableTo(rx_disposeBag)
        
        UserModel.shared.headPortUrl.asObservable().subscribe(onNext: {[unowned self] (url) in
            self.img_header.sd_setImage(with: URL(string:url), placeholderImage: defaultHeaderImage)
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .addDisposableTo(rx_disposeBag)
        
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "UpdateUserInfoSuccessNotifation"))
            .subscribe(onNext: {[unowned self] (_) in
                self.img_header.sd_setImage(with: URL(string:UserModel.shared.headPortUrl.value), placeholderImage: defaultHeaderImage)
                self.lb_name.text = UserModel.shared.nickName.value
                self.img_isCertification.image = UIImage(named:"isCertification_\(UserModel.shared.rank)")
                }, onError: nil, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(rx_disposeBag)
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    var userModel:UserModel?{
        didSet{
            guard let userModel = userModel else {
                return
            }
            img_header.sd_setImage(with: URL(string:userModel.headPortUrl.value), placeholderImage: defaultHeaderImage)
            lb_name.text = userModel.nickName.value

            img_isCertification.image = UIImage(named:"isCertification_\(userModel.rank.value)")

        }
    }
}
