//
//  CreateActivtyCoverViewCell.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import Eureka
import SwiftyDrop
class CreateActivtyCoverViewCell: Cell<String>,CellType {
    public  var choseImaged = Variable(false)
    private var imagePicker :AIImagePicker?
    private var coverImage: UIImage!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.height = { 55 + screenW / 2 }
        selectionStyle = UITableViewCellSelectionStyle.none
    }
    @IBAction func buttonAction(_ sender: UIButton) {
        self.imagePicker = AIImagePicker()
        self.imagePicker?.allowEditting = true
        self.imagePicker?.imagePickerCompletion = { [unowned self] (image,headerUlr) in
            sender.setImage(image, for: .normal)
            self.coverImage = image
            self.choseImaged.value = true
            self.row.value = headerUlr

        }
        self.imagePicker?.show(in: self.viewController?.view)
        
    }
}
//MARK: CreateActivtyCoverRow
final class CreateActivtyCoverRow: Row<CreateActivtyCoverViewCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<CreateActivtyCoverViewCell>(nibName: "CreateActivtyCoverViewCell")
    }
}
