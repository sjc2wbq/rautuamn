
//
//  RvUsefulModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
import RxDataSources
import RxSwift
struct RvUsefulModel {
    var data: [RvUseful] = []
    
    init?( map: Map) {}
}

extension RvUsefulModel: Mappable {
    mutating func mapping(map: Map) {
        data <- map["data"]
    }
}

// MARK: - RvUseful

struct RvUseful {
    var permanentCity = ""
    var changeJob = false
    var headPortUrl = ""
    var emotion = ""
    var mutualTourism = false
    var coverPhotoUrl = ""
    var userId = 0
    var distanceOff = false
    var position = ""
    var id = 0
    var videoUrl = ""
    var starLevel = 0
    var friend = false
    var nickName = ""
    var distance = 0
    var title = ""
    var rank = ""
    var time = ""
    var playTimes = Variable(0)
    var commentCount = Variable(0)
    var countRC : Variable<String> = Variable("0")
    var userCount = 0
    var userList :[UserList] = []
    var isShowMenu = Variable(false)
    init?( map: Map) {}
}

struct UserListModel: Mappable {
    var userList :[UserList] = []
    var total = 0
    init?( map: Map) {}
    mutating func mapping(map: Map) {
        userList <- map["userList"]
        total <- map["total"]
    }
}
struct UserList:Mappable {
    var userId = ""
    var headPortUrl = ""
    var nickName = ""
    init?( map: Map) {}
    mutating func mapping(map: Map) {
        nickName <- map["nickName"]
        userId <- map["userId"]
        headPortUrl <- map["headPortUrl"]
    }
}
extension RvUseful: Mappable {
    mutating func mapping(map: Map) {
        countRC.value <- map["countRC"]
        commentCount.value <- map["commentCount"]
        permanentCity <- map["permanentCity"]
        changeJob <- map["changeJob"]
        userCount <- map["userCount"]
        headPortUrl <- map["headPortUrl"]
        emotion <- map["emotion"]
        mutualTourism <- map["mutualTourism"]
        coverPhotoUrl <- map["coverPhotoUrl"]
        userId <- map["userId"]
        distanceOff <- map["distanceOff"]
        position <- map["position"]
        id <- map["id"]
        videoUrl <- map["videoUrl"]
        starLevel <- map["starLevel"]
        friend <- map["friend"]
        nickName <- map["nickName"]
        distance <- map["distance"]
        title <- map["title"]
        rank <- map["rank"]
        time <- map["time"]
        playTimes.value <- map["playTimes"]
    }
}
extension RvUseful: IdentifiableType,Equatable {
    var identity: Int {
        return userId
    }
}
func ==(lhs: RvUseful, rhs: RvUseful) -> Bool {
    return lhs.userId == rhs.userId
}
