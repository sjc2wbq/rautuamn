//
//  NearbyRauFriendModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
struct NearbyRauFriendModel {
    var userInfos: [Friend] = []
    
    init?(map: Map) {}
}

extension NearbyRauFriendModel: Mappable {
    mutating func mapping(map: Map) {
        userInfos <- map["userInfos"]
    }
}
