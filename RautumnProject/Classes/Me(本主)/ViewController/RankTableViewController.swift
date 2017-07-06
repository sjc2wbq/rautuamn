//
//  RankTableViewController.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/13.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

class RankTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = bgColor
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1{
            if UserModel.shared.inApp{
                let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "InAppOpeningMemberTableViewController") as! InAppOpeningMemberTableViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                let vc = UIStoryboard(name: "Me", bundle: nil).instantiateViewController(withIdentifier: "OpeningMemberTableViewController") as! OpeningMemberTableViewController
                vc.type = 2
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            if UserModel.shared.rank.value == "U"{
                return "您目前的等级是 注册用户"
            }else if UserModel.shared.rank.value == "M"{
                return "您目前的等级是 注册会员"
            }
            return "您目前的等级是 VIP会员"
        }
           return nil   
    }
}
