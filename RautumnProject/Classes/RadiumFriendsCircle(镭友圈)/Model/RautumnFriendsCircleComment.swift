//
//  RautumnFriendsCircleCommentModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/11.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
struct RautumnFriendsCircleComment {
    var rautumnFriendsCircleComs: [Rautumnfriendscirclecom] = []
    var rauVideoUsefulComs: [Rautumnfriendscirclecom] = []
    init?(map: Map) {}
}

extension RautumnFriendsCircleComment: Mappable {
    mutating func mapping(map: Map) {
        rauVideoUsefulComs <- map["rauVideoUsefulComs"]
        rautumnFriendsCircleComs <- map["rautumnFriendsCircleComs"]
    }
}

// MARK: - Rautumnfriendscirclecom

struct Rautumnfriendscirclecom {
    var content = ""
    var userName = ""
    var userId = 0
    var dateTimeStr = ""
    var headPortUrl = ""
    
    init?(map: Map) {}
}

extension Rautumnfriendscirclecom: Mappable {
    mutating func mapping(map: Map) {
        headPortUrl <- map["headPortUrl"]
        content <- map["content"]
        userName <- map["userName"]
        userId <- map["userId"]
        dateTimeStr <- map["dateTimeStr"]
    }
}
