//
//  RfcDetailsModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/12.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
struct RfcDetailsModel {
    var countRC = ""
    var narrativeContent = ""
    var commentCount = 0
    var rfcPhotosOrSmallVideos: [Rfcphotosorsmallvideo] = []
    var rautumnFriendsCircleComs: [Rautumnfriendscirclecom] = []
    var dateTimeStr = ""
    
    init?(map: Map) {}
}

extension RfcDetailsModel: Mappable {
    mutating func mapping(map: Map) {
        countRC <- map["countRC"]
        narrativeContent <- map["narrativeContent"]
        commentCount <- map["commentCount"]
        rfcPhotosOrSmallVideos <- map["rfcPhotosOrSmallVideos"]
        rautumnFriendsCircleComs <- map["rautumnFriendsCircleComs"]
        dateTimeStr <- map["dateTimeStr"]
    }
}

// MARK: - Rfcphotosorsmallvideo

struct Rfcphotosorsmallvideo {
    var url = ""
    
    init?(map: Map) {}
}

extension Rfcphotosorsmallvideo: Mappable {
    mutating func mapping(map: Map) {
        url <- map["url"]
    }
}

