//
//  NearActivity2TableViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import KSPhotoBrowser
import SDWebImage
class NearActivity2TableViewCell: UITableViewCell {
    @IBOutlet weak var lb_title: UILabel!
    @IBOutlet weak var lb_subTitle: UILabel!
    @IBOutlet weak var img_icon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        img_icon.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action:#selector(tap_img_icon(tap:)))
        img_icon.addGestureRecognizer(tap)
        /*
         
         NSMutableArray * items = [NSMutableArray array];
         
         //    __weak typeof(self) weakSelf = self;
         [self.picUrlArray enumerateObjectsUsingBlock:^(NSString * _Nonnull url, NSUInteger idx, BOOL * _Nonnull stop) {
         KSPhotoItem *item = [KSPhotoItem itemWithSourceView:(UIImageView *)tap.view imageUrl:[NSURL URLWithString:url]];
         [items addObject:item];
         }];
         KSPhotoBrowser *browser = [KSPhotoBrowser browserWithPhotoItems:items selectedIndex:tap.view.tag];
         browser.dismissalStyle = KSPhotoBrowserInteractiveDismissalStyleRotation;
         browser.backgroundStyle = KSPhotoBrowserBackgroundStyleBlur;
         browser.loadingStyle = KSPhotoBrowserImageLoadingStyleIndeterminate;
         browser.pageindicatorStyle = KSPhotoBrowserPageIndicatorStyleDot;
         browser.bounces = YES;
         [browser showFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
         */
//        let collectionView = cycleScrollView.subviews.first  as! UICollectionView
//        let cell  = collectionView.cellForItem(at: IndexPath(item: index, section: 1)) as? SDCollectionViewCell
//        if let cell = cell {
//      //        }

    }
    func tap_img_icon(tap:UITapGestureRecognizer){
        let item = [KSPhotoItem(sourceView: tap.view as! UIImageView, image: (tap.view as! UIImageView).image)!]
        let browser = KSPhotoBrowser(photoItems: item, selectedIndex:0)
            browser?.dismissalStyle = .rotation
            browser?.backgroundStyle = .blur
            browser?.loadingStyle = .indeterminate
            browser?.pageindicatorStyle = .dot
            browser?.bounces = true
            browser?.show(from: self.viewController)
    }
}
