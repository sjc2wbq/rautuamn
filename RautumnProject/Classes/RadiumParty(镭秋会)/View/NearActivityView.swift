
//
//  NearActivityHeaderView.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import SDAutoLayout
import RxDataSources
import LTInfiniteScrollViewSwift
import SDCycleScrollView
import RxSwift
import KSPhotoBrowser
class NearActivityHeaderView: UIView {
    
    typealias TableSectionModel = AnimatableSectionModel<String, RauActivityEnroll>
    let dataSource = RxCollectionViewSectionedAnimatedDataSource<TableSectionModel>()
    let sections = Variable([TableSectionModel]())
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout!{
        didSet{
            layout.itemSize = CGSize(width: (screenW - 28 - 5 * (4 - 1)) / 4, height: (screenW - 28 - 5 * (4 - 1)) / 4 + 30)
            layout.minimumLineSpacing = 5
            layout.minimumInteritemSpacing = 0
        }
    }
    //
    @IBOutlet weak var placeholderImageView: UIImageView!
    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageContentView: SDCycleScrollView!{
        didSet{
            imageContentView.bannerImageViewContentMode = .scaleAspectFit
            imageContentView.delegate = self
            imageContentView.placeholderImage = placeHolderImage
            imageContentView.showPageControl = false
            imageContentView.pageControlStyle = SDCycleScrollViewPageContolStyleNone

        }
    }
    @IBOutlet weak var lb_registrationCount: UILabel!
    @IBOutlet weak var scrollView: LTInfiniteScrollView!
    static func headerView() -> NearActivityHeaderView{
        return Bundle.main.loadNibNamed("NearActivityHeaderView", owner: nil, options: nil)!.first as! NearActivityHeaderView
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        imageContentView.bannerImageViewContentMode = .scaleAspectFit
//        imageContentView.delegate = self
//        imageContentView.placeholderImage = placeHolderImage
//        imageContentView.showPageControl = false
//        imageContentView.pageControlStyle = SDCycleScrollViewPageContolStyleNone
            bindViewModel()

           }
     var model:NearActivityDetailModel?{
        didSet{
            if let model = model{
                imageContentView.imageURLStringsGroup = model.rauActivityPictures.map{$0.url}
                 lb_registrationCount.text = "\(model.raeCount)"
                sections.value = [TableSectionModel(model: "", items: model.rauActivityEnrolls)];
                lb_title.text  = model.name
            }
        }
    }
    func bindViewModel() {
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.register(UINib(nibName: "NearActivityHeaderCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NearActivityHeaderCollectionViewCell")
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .top,
                                                                   reloadAnimation: .fade,
                                                                   deleteAnimation: .left)

        dataSource.configureCell =  {(ds, collectionView, indexPath, rauActivityEnroll) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NearActivityHeaderCollectionViewCell", for: indexPath) as! NearActivityHeaderCollectionViewCell
            cell.rauActivityEnroll = rauActivityEnroll
            return cell
        }
        
        dataSource.supplementaryViewFactory =  {_,collectionView ,kind ,indexPath in
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Section", for: indexPath)
        }
        
        sections.asObservable().bindTo(collectionView.rx.items(dataSource: dataSource)).addDisposableTo(rx_disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext: {[unowned self] (indexPath) in
            let rauActivityEnroll  = self.dataSource.sectionModels[indexPath.section].items[indexPath.item]
            let vc = UserInfoViewController()
            vc.visitorUserId = Int(rauActivityEnroll.id)
//            vc.title = rauActivityEnroll.nickName
            self.viewController?.navigationController?.pushViewController(vc, animated: true)

                    }).addDisposableTo(rx_disposeBag)
    }

    
}
extension NearActivityHeaderView : SDCycleScrollViewDelegate{
    func cycleScrollView(_ cycleScrollView: SDCycleScrollView!, didSelectItemAt index: Int) {
        let browser = KSPhotoBrowser(photoItems: cycleScrollView.imageURLStringsGroup.map{KSPhotoItem(sourceView: placeholderImageView, imageUrl: URL(string:$0 as! String))}, selectedIndex: UInt(index))
        browser?.show(from: self.viewController)

        
    }
}
extension NearActivityHeaderView:LTInfiniteScrollViewDataSource , LTInfiniteScrollViewDelegate{
    func viewAtIndex(_ index: Int, reusingView view: UIView?) -> UIView {
        let rauActivityEnroll  = self.model?.rauActivityEnrolls[index]
        if let scrollViewContentView = view as? ScrollViewContentView {
            if let rauActivityEnroll = rauActivityEnroll{
                scrollViewContentView.img_icon.sd_setImage(with: URL(string:rauActivityEnroll.headPortUrl), placeholderImage: placeHolderImage)
            }
            scrollViewContentView.lb_title.text = rauActivityEnroll?.nickName
            return scrollViewContentView
        }
        else {
            let size = (screenW - 50) / CGFloat(numberOfVisibleViews())
            let scrollViewContentView = ScrollViewContentView.contentView()
            scrollViewContentView.frame = CGRect(x: 0, y: 0, width: 90, height: size + 30)
            if let rauActivityEnroll = rauActivityEnroll{
                scrollViewContentView.img_icon.sd_setImage(with: URL(string:rauActivityEnroll.headPortUrl), placeholderImage: placeHolderImage)
            }
            scrollViewContentView.lb_title.text = rauActivityEnroll?.nickName
            return scrollViewContentView
        }
    }
    func numberOfViews() -> Int {
        if let model = model {
            return model.rauActivityEnrolls.count
        }
        return 0
    }
    
    func numberOfVisibleViews() -> Int {
        return 4
    }

    func updateView(_ view: UIView, withProgress progress: CGFloat, scrollDirection direction: LTInfiniteScrollView.ScrollDirection) {
        let size = screenW / CGFloat(numberOfVisibleViews())
        var transform = CGAffineTransform.identity
        // scale
        let scale = (1.4 - 0.3 * (fabs(progress)))
        transform = transform.scaledBy(x: scale, y: scale)
        // translate
        var translate = size / 4 * progress
        if progress > 1 {
            translate = size / 4
        }
        else if progress < -1 {
            translate = -size / 4
        }
        transform = transform.translatedBy(x: translate, y: 0)
        view.transform = transform
    }
    func scrollViewDidScrollToIndex(_ scrollView: LTInfiniteScrollView, index: Int) {
        print("scroll to index: \(index)")
    }
}
class ScrollViewContentView: UIView {
    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var img_icon: UIImageView!
    static func contentView() -> ScrollViewContentView{
        return Bundle.main.loadNibNamed("ScrollViewContentView", owner: nil, options: nil)!.first as! ScrollViewContentView
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class NearActivityFooterView: UIView {
    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var lb_subTitle: UILabel!
    static func footerView() -> NearActivityFooterView{
        return Bundle.main.loadNibNamed("NearActivityFooterView", owner: nil, options: nil)![0] as! NearActivityFooterView
    }
    override func awakeFromNib() {
        super.awakeFromNib()
      _ = lb_title.sd_layout().leftSpaceToView(self,10)?.topSpaceToView(self,15)?.widthIs(200)?.heightIs(15)
       _ = lb_subTitle.sd_layout().leftEqualToView(lb_title)?.topSpaceToView(lb_title,10)?.rightSpaceToView(self,10)?.autoHeightRatio(0)
        setupAutoHeight(withBottomView: lb_subTitle, bottomMargin: 15)
    }
    var model:NearActivityDetailModel?{
        didSet{
            if let model = model{
          lb_subTitle.text = model.activityDetails
            }
        }
    }
}
