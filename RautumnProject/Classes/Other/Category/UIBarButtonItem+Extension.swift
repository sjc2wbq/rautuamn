//
//  UIBarButtonItem+Extension.swift
//  QizhonghuiProject
//
//  Created by Raychen on 2016/6/28.
//  Copyright © 2016年 raychen. All rights reserved.
//

import UIKit

extension UIBarButtonItem{
    public static func itemWithTitle(title:String) -> UIBarButtonItem {
        let item = UIBarButtonItem()
        item.title = title
        item.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.black,NSFontAttributeName:UIFont.systemFont(ofSize: 14)], for: .normal)
        item.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.gray,NSFontAttributeName:UIFont.systemFont(ofSize: 14)], for: .disabled)
        return item
    }
    public static func itemWithImageNamed(imageNamed:String) -> UIBarButtonItem{
             let item = UIBarButtonItem()
                item.image = UIImage(named:imageNamed)
                return item
            }

}
