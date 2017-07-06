//
//  UserInfoBaseInfoViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/12.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
import RxDataSources
import KSPhotoBrowser
import RxSwift
import SDWebImage

class UserInfoBaseInfoViewCell: UITableViewCell {
    @IBOutlet weak var starView: StarView! //会员等级

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lb_degree: UILabel! //完成度
    @IBOutlet weak var degreeeW: NSLayoutConstraint!  // screenW - 48
    @IBOutlet weak var lb_verification: AnimatableLabel! //身份是否验证
    @IBOutlet weak var lb_number: UILabel! //镭秋号
    @IBOutlet weak var lb_height: UILabel! //身高
    @IBOutlet weak var lb_bir: UILabel! //生日
    @IBOutlet weak var lb_friendCount: UILabel!//镭友数
    @IBOutlet weak var lb_registerTime: UILabel!//注册时间
    @IBOutlet weak var levelH: NSLayoutConstraint!
    
    @IBOutlet weak var starViewH: NSLayoutConstraint!
    @IBOutlet weak var collectionViewH: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTop: NSLayoutConstraint!
    @IBOutlet weak var img_video: AnimatableImageView!
    @IBOutlet weak var lb_verification_w: NSLayoutConstraint!
    @IBOutlet weak var lb_verification_h: NSLayoutConstraint!
    
    @IBOutlet weak var history_h: NSLayoutConstraint!
    @IBOutlet weak var historyView: UIView!
    @IBOutlet weak var img_playVideo: UIImageView!
    
    
    @IBOutlet weak var rankImageView: UIImageView!
    @IBOutlet weak var headImageView: AnimatableImageView! // 头像
    @IBOutlet weak var nameLabel: UILabel! // 昵称
    
    @IBOutlet weak var addressLabel: UIButton!  // 地址
    
    @IBOutlet weak var genderLabel: UILabel! // 性别
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!{
        didSet{
            layout.itemSize = CGSize(width: 80, height: 80)
        layout.minimumLineSpacing = 5
            layout.minimumInteritemSpacing = 0
        }
    }
    
    typealias TableSectionModel = AnimatableSectionModel<String, Photo>
    let dataSource = RxCollectionViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    var items = [Photo]()
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        collectionView.delegate = nil
        collectionView.dataSource = nil
        bindViewModel()
        
        NotificationCenter.default.rx.notification(Notification.Name(rawValue: "UserAuthenticationStatusNotifation"))
            .do(onNext: { (_) in
                UserModel.shared.licenseStatus = 3
            })
            .map{_ in "身份证认证已通过"}.bindTo(self.lb_verification.rx.text)
            .addDisposableTo(rx_disposeBag)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    var userModel: UserModel!
        
        {
        didSet{
            
            history_h.constant = 0.0
            historyView.isHidden = true
    
            starView.star = userModel.starLevel
            headImageView.sd_setImage(with: URL(string:userModel.headPortUrl.value), placeholderImage: defaultHeaderImage)
            nameLabel.text = userModel.nickName.value
            addressLabel.setTitle(userModel.permanentCity, for: .normal)
            rankImageView.image = UIImage.init(named: "isCertification_\(userModel.rank.value)")
            
            starViewH.constant = userModel.starLevel == 0 ? 0 : 20
            
//            levelH.constant = userModel.starLevel == 0 ? 0 : 20
            
            lb_degree.text = "完成度\(userModel.perfectDegreeOfData)%"

            degreeeW.constant =     (CGFloat(userModel.perfectDegreeOfData) / 100.0 ) * (screenW - 50)
            log.info("CGFloat(model.perfectDegreeOfData / 100 ) * (screenW - 50)=====\(CGFloat(self.userModel.perfectDegreeOfData / 100 ) * (screenW - 50))")
            if userModel.licenseStatus == 1{ //认证状态1待认证 2认证不通过 3审核认证通过
                lb_verification.text = "身份证待审核"
//                lb_verification.isHidden = true
//                lb_verification_h.constant = 0
            }else if userModel.licenseStatus == 2{
                lb_verification.text = "身份证认证未通过"
//                lb_verification.isHidden = true
//                lb_verification_h.constant = 30

            }else if userModel.licenseStatus == 3{
//                lb_verification.isHidden = false
//                lb_verification_h.constant = 30
                lb_verification.text = "身份证认证已通过"
            }
            
            if userModel.sex == 1 {
                genderLabel.text = "性别：男"
            } else {
                genderLabel.text = "性别：女"
            }
            
            lb_number.text = "镭秋号：\(userModel.rautumnId)"
            
            lb_height.text = "身高：\(userModel.height)cm"
            
            lb_bir.text = "出生日期：\(userModel.dateOfBirth)"
            
            lb_friendCount.text = "镭友数：\(userModel.rauFriCount)"
            
            lb_registerTime.text = "注册时间：\(userModel.registerDate)"
            collectionViewH.constant = userModel.userPhotos.count == 0 ? 0 : 80
            collectionViewTop.constant = userModel.userPhotos.count == 0 ? 0 : 8
            self.sections.value = [TableSectionModel(model: "", items: userModel.userPhotos.map{Photo(image: nil, imageUrl: $0.url)})];
         
            if userModel.vcrUrl == ""{
                img_video.image = UIImage(named: "noVCR")
                img_playVideo.isHidden = true
            }else{
                
                print("ssssvcrurl = \(userModel.vcrCoverUrl)")
                img_playVideo.isHidden = false
                
                let url = URL.init(string: userModel.vcrCoverUrl)
                
                self.img_video.sd_setImage(with: url, placeholderImage: UIImage(named: "noVCR"), options: [.retryFailed])
            }
        
            lb_verification_w.constant = lb_verification.text!.width(15, height: 30) + 5
        }
    
    }
    var model:FriendInfoModel?{
        didSet{
            guard let model = model else {
                return
            }
            
            history_h.constant = 45
            historyView.isHidden = false
            
            starView.star = model.starLevel
            
            headImageView.sd_setImage(with: URL(string:model.headPortUrl), placeholderImage: defaultHeaderImage)
            nameLabel.text = model.nickName
            addressLabel.setTitle(model.permanentCity, for: .normal)
            rankImageView.image = UIImage.init(named: "isCertification_\(model.rank)")
            
            starViewH.constant = model.starLevel == 0 ? 0 : 20
//
//            levelH.constant = model.starLevel == 0 ? 0 : 20
            
            lb_degree.text = "完成度\(model.perfectDegreeOfData)%"
            
            degreeeW.constant =     (CGFloat(model.perfectDegreeOfData) / 100.0 ) * (screenW - 50)
            log.info("CGFloat(model.perfectDegreeOfData / 100 ) * (screenW - 50)=====\(CGFloat(model.perfectDegreeOfData / 100 ) * (screenW - 50))")
            if model.licenseStatus == 1{ //认证状态1待认证 2认证不通过 3审核认证通过
                lb_verification.text = "身份未验证"
          
            }else if model.licenseStatus == 2{
                
                lb_verification.text = "身份验证不通过"
                
            }else if model.licenseStatus == 3{
                
                lb_verification.text = "身份已验证"
            }
            
            
            lb_number.text = "镭秋号：\(model.rautumnId)"
            

            if model.sex == 2 {
                
                genderLabel.text = "性别：女"
            } else {
                genderLabel.text = "性别：男"
            }
           
            
            lb_height.text = "身高：\(model.height)cm"
            
            lb_bir.text = "出生日期：\(model.dateOfBirth)"

            lb_friendCount.text = "镭友数：\(model.rauFriCount)"

            lb_registerTime.text = "注册时间：\(model.registerDate)"
            collectionViewH.constant = model.userPhotos.count == 0 ? 0 : 80
            collectionViewTop.constant = model.userPhotos.count == 0 ? 0 : 8
            self.sections.value = [TableSectionModel(model: "", items: model.userPhotos.map{Photo(image: nil, imageUrl: $0.url)})];
        
            
            if model.vcr == ""{
                img_video.image = UIImage(named: "noVCR")
                img_playVideo.isHidden = true
            }else{
                
                img_playVideo.isHidden = false
                img_video.sd_setImage(with: URL(string:model.vcrCoverUrl), placeholderImage: UIImage(named: "noVCR"), options: [.retryFailed])
            }
            
            lb_verification_w.constant = lb_verification.text!.width(15, height: 30) + 5
        }
    }
}
extension UserInfoBaseInfoViewCell{
    func bindViewModel() {
        collectionView.register(PostDynamicViewCell.self, forCellWithReuseIdentifier: "PostDynamicViewCell")
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top,
                                                                   reloadAnimation: .fade,
                                                                   deleteAnimation: .left)
        
        sections.value = [TableSectionModel(model: "", items: self.items)];
        
        dataSource.configureCell =  {[unowned self] (ds, collectionView, indexPath, photo) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostDynamicViewCell", for: indexPath) as! PostDynamicViewCell
            cell.showDeleteImage = self.items.count != indexPath.item + 1
            cell.showDeleteImage = false
            cell.photo = photo
            return cell
        }
        dataSource.supplementaryViewFactory =  {_,collectionView ,kind ,indexPath in
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Section", for: indexPath)
        }
        
        sections.asObservable().bindTo(collectionView.rx.items(dataSource: dataSource)).addDisposableTo(rx_disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext: {[unowned self] (indexPath) in
//            let model = self.dataSource.sectionModels[indexPath.section].items[indexPath.item]
            let cell = self.collectionView.cellForItem(at: indexPath) as! PostDynamicViewCell
            let items = self.dataSource.sectionModels[indexPath.section].items.map{KSPhotoItem(sourceView: cell.imageView, thumbImage: cell.imageView.image!, imageUrl: URL(string:$0.imageUrl)!)!}
            let browser = KSPhotoBrowser(photoItems: items, selectedIndex: UInt(indexPath.item))
            browser?.dismissalStyle = KSPhotoBrowserInteractiveDismissalStyle.rotation;
            browser?.backgroundStyle = KSPhotoBrowserBackgroundStyle.blur;
            browser?.loadingStyle = KSPhotoBrowserImageLoadingStyle.indeterminate;
            browser?.pageindicatorStyle = KSPhotoBrowserPageIndicatorStyle.dot;
            browser?.show(from: UIApplication.shared.keyWindow?.rootViewController!)

                  }).addDisposableTo(rx_disposeBag)
    }

}
