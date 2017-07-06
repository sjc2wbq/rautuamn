//
//  AddressBookNewFriendViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/17.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import IBAnimatable
class AddressBookNewFriendViewCell: UITableViewCell {
    
    
    @IBOutlet weak var unReadView: UIImageView!


    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var aTitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
