
//
//  RauVideoUsefulComModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/9.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper

struct RauVideoUsefulComModel {
    var rauVideoUsefulComs: [Rautumnfriendscirclecom] = []
    
    init?( map: Map) {}
}

extension RauVideoUsefulComModel: Mappable {
    mutating func mapping(map: Map) {
        rauVideoUsefulComs <- map["rauVideoUsefulComs"]
    }
}

