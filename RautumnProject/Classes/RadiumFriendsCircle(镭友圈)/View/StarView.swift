//
//  StarView.swift
//  RautumnProject
//
//  Created by 陈雷 on 1817/1/11.
//  Copyright © 1817年 Rautumn. All rights reserved.
//

import UIKit
import SDAutoLayout
class StarView: UIView {
    public var star: Int = 0{
        didSet{
            if star > 0 {
               self.subviews.forEach({ (view) in
                view.removeFromSuperview()
               })
                for i in 0..<star{
                    let imageView = UIImageView()
                    imageView.image = UIImage(named:"star")
                    imageView.contentMode = .center
                    imageView.frame = CGRect(x: CGFloat(i) * 18, y: 0, width: 18, height: 18)
                    addSubview(imageView)
                }
                let height:CGFloat = 18
                let width:CGFloat  = CGFloat(star) * height
                width_sd = width
                fixedWidth = NSNumber(value: Float(width))
                height_sd = CGFloat(height)
                fixedHeight = NSNumber(value: Float(height))
            }else{
                width_sd = 0
                fixedWidth = NSNumber(value: Float(0))
                height_sd = CGFloat(0)
                fixedHeight = NSNumber(value: Float(0))
            }
        }
    }
}
