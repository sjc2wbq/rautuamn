//
//  GroupListModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxDataSources
import ObjectMapper

struct GroupListModel {
    var rauGroupUsers: [Friend] = []
    
    init?( map: Map) {}
}

extension GroupListModel: Mappable {
    mutating func mapping(map: Map) {
        rauGroupUsers <- map["rauGroupUsers"]
    }
}
