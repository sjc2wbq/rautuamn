//
//  AboutWeViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/3/6.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

class AboutWeViewController: UITableViewController {
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return label.text!.height(15, wight: screenW - 16) + 380
    }
}
