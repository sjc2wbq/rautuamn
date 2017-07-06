//
//  GroupInfoTableViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
class GroupInfoTableViewCell: UITableViewCell {
    var groupId = 0
    typealias TableSectionModel = AnimatableSectionModel<String, Raugroupuser>
    let dataSource = RxCollectionViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    
    
    @IBOutlet weak var lb_createTime: UILabel!
    @IBOutlet weak var lb_personCount: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = nil
            collectionView.dataSource = nil
            collectionView.register(UINib(nibName: "NearActivityHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NearActivityHeaderCollectionViewCell")
            
        }
    }
    @IBOutlet weak var lb_introduce: UILabel!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!{
        didSet{
            layout.itemSize = CGSize(width: 80, height: 100)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 5
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
       bindViewModel()
        collectionView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCollectionView(tap:)))
        collectionView.addGestureRecognizer(tap)
    }
    func tapCollectionView(tap:UITapGestureRecognizer )  {
        let vc = GroupListViewController()
        vc.groupId = self.groupId
        vc.mainGroup = self.model!.mainGroup
        self.viewController?.navigationController?.pushViewController(vc, animated: true)
    }
    func bindViewModel() {

        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top,
                                                                   reloadAnimation: .fade,
                                                                   deleteAnimation: .left)
        
        dataSource.configureCell =  { (ds, collectionView, indexPath, model) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearActivityHeaderCollectionViewCell", for: indexPath) as! NearActivityHeaderCollectionViewCell
//            cell.rauActivityEnroll = rauActivityEnroll
            cell.img_icon.sd_setImage(with: URL(string:model.headPortUrl), placeholderImage: placeHolderImage)
            cell.lb_title.text = model.nickname
            cell.lb_tag.isHidden = indexPath.row != 0
            return cell
        }
        dataSource.supplementaryViewFactory =  {_,collectionView ,kind ,indexPath in
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Section", for: indexPath)
        }
        sections.asObservable().bindTo(collectionView.rx.items(dataSource: dataSource)).addDisposableTo(rx_disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext: {[unowned self] (indexPath) in
//            let model  = self.dataSource.sectionModels[indexPath.section].items[indexPath.item]
//            let vc = UserInfoViewController()
//            vc.visitorUserId = Int(model.userId)
//            vc.title = model.nickname
             let vc = GroupListViewController()
            vc.groupId = self.groupId
            vc.mainGroup = self.model!.mainGroup
            self.viewController?.navigationController?.pushViewController(vc, animated: true)
        }).addDisposableTo(rx_disposeBag)
    }
    
    var model:GroupDetailsModel?{
        didSet{
            guard let model = model  else {
                return
            }
            lb_createTime.text = "创建时间：\(model.createDate)"
            lb_personCount.text = "群成员（\(model.rguOnlineCount)/\(model.rauGroupUserCount)）"
            lb_introduce.text = model.introduce
            
            sections.value = [TableSectionModel(model: "", items: model.rauGroupUsers)];

        }
    }

    
}
