//
//  ApplyGroupModel.swift
//  RautumnProject
//
//  Created by xilaida on 2017/5/25.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper

struct ApplyGroupModel {
    
    var list = [ApplyInfo]()
    
    init( map: Map) {}
    
    
}

extension ApplyGroupModel: Mappable {
    mutating func mapping(map: Map) {
        list <- map["list"]
    }
}

struct ApplyInfo {
    
    var beAddGroupId = 0
    var activeUserInfoId = 0
    var applyJoinGroupId = 0
    var msg = ""
    var headPortUrl = ""
    var nickname = ""
    
    init( map: Map) {}
    
    
}

extension ApplyInfo: Mappable {
    mutating func mapping(map: Map) {
        beAddGroupId <- map["beAddGroupId"]
        activeUserInfoId <- map["activeUserInfoId"]
        msg <- map["msg"]
        headPortUrl <- map["headPortUrl"]
        nickname <- map["nickname"]
        applyJoinGroupId <- map["applyJoinGroupId"]
    }
}
