//
//  HUD.swift
//  ObjectsProject
//
//  Created by 陈雷 on 2016/12/10.
//  Copyright © 2016年 raychen. All rights reserved.
//

import UIKit

class HUD: UIView {
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    static func hud() -> HUD{
        return Bundle.main.loadNibNamed("HUD", owner: nil, options: nil)!.first as! HUD
    }
    func show(_ viewController:UIViewController) {
        self.frame = UIApplication.shared.keyWindow!.bounds
        viewController.view.addSubview(self)
        activityView.startAnimating()
        self.alpha = 1
        UIView.animate(withDuration: 0.25, animations: {
        })
    }
    func dismiss()  {
        UIView.animate(withDuration: 0.25, animations: {[unowned self] in
            self.activityView.stopAnimating()
            self.alpha = 0
        }, completion: {_ in
        self.removeFromSuperview()
        })
    }
}
