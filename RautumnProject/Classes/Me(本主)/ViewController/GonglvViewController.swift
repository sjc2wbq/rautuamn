
//
//  GonglvViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/3/14.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

class GonglvViewController: UITableViewController {

    @IBOutlet weak var lb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return lb.text!.height(14, wight: screenW - 16) + 50
    }

}
class GonglvViewController2: UITableViewController {
    
    @IBOutlet weak var lb: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return lb.text!.height(14, wight: screenW - 16) + 50
    }
    
}
