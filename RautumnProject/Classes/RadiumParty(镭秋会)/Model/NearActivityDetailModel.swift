//
//  NearActivityDetailModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
import RxDataSources
struct NearActivityDetailModel {
    var rauActivityPictures: [Rauactivitypicture] = []
    var expense = 0
    var publishUserHpu = ""
    var name = ""
    var place = ""
    var activityDateTime = ""
    var publishUserNickName = ""
    var enrollmentCeiling = 0
    var coverPhotoUrl = ""
    var raeCount = 0
    var activityDetails = ""
    var rauActivityEnrolls: [RauActivityEnroll] = []
    var enroll = false
    var userPhone = ""
    var rauActivityUserId = 0
    init?( map: Map) {}
}

extension NearActivityDetailModel: Mappable {
    mutating func mapping(map: Map) {
        rauActivityUserId <- map["rauActivityUserId"]
        userPhone <- map["userPhone"]
        enroll <- map["enroll"]
        rauActivityPictures <- map["rauActivityPictures"]
        expense <- map["expense"]
        publishUserHpu <- map["publishUserHpu"]
        name <- map["name"]
        place <- map["place"]
        activityDateTime <- map["activityDateTime"]
        publishUserNickName <- map["publishUserNickName"]
        enrollmentCeiling <- map["enrollmentCeiling"]
        coverPhotoUrl <- map["coverPhotoUrl"]
        raeCount <- map["raeCount"]
        activityDetails <- map["activityDetails"]
        rauActivityEnrolls <- map["rauActivityEnrolls"]
    }
}

struct RauActivityEnroll {
    var nickName = ""
    var headPortUrl = ""
    var id = 0
    init?( map: Map) {}
}

extension RauActivityEnroll: IdentifiableType,Equatable {
    var identity: Int {
        return 1
    }
}
func ==(lhs: RauActivityEnroll, rhs: RauActivityEnroll) -> Bool {
    return lhs.nickName == rhs.nickName
}

extension RauActivityEnroll: Mappable {
    mutating func mapping(map: Map) {
        id <- map["id"]
        nickName <- map["nickName"]
        headPortUrl <- map["headPortUrl"]
    }
}
// MARK: - Rauactivitypicture

struct Rauactivitypicture {
    var url = ""
    
    init?( map: Map) {}
}

extension Rauactivitypicture: Mappable {
    mutating func mapping(map: Map) {
        url <- map["url"]
    }
}
