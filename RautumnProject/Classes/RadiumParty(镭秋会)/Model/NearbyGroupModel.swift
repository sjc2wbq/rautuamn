
//
//  NearbyGroupModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
import RxDataSources
struct NearbyGroupModel {
    var rauGroups: [Raugroup] = []
    
    init?( map: Map) {}
}

extension NearbyGroupModel: Mappable {
    mutating func mapping(map: Map) {
        rauGroups <- map["rauGroups"]
    }
}

