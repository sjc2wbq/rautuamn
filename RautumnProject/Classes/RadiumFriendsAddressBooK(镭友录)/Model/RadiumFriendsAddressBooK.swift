//
//  adiumFriendsAddressBooK.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/16.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
import RxSwift
import RxDataSources
//import GRDB

struct RadiumFriendsAddressBooK {
    var friends: [Friend] = []
    
    init(map: Map) {}
}

extension RadiumFriendsAddressBooK: Mappable {
    mutating func mapping(map: Map) {
        friends <- map["friends"]
    }
}

// MARK: - Friend
//class Friend : Record{

class Friend {

    var isCheck = Variable(false)
    var isShowCheck = Variable(false)
    var loginId:Int64 = Int64(UserModel.shared.id)
    var permanentCity = ""
    var changeJob = false
    var headPortUrl = ""
    var starLevel = 0
    var nickName = ""
    var distance = 0
    var emotion = ""
    var userId:Int64 = 0
    var mutualTourism = false
    var rank = ""
    var distanceOff = false
    var friend = false
    var isFriends = false
    var autograph = ""
    var lat = 0.0
    var lng = 0.0
    var degree_of_intimacy = 0

//    override init() {
//    super.init()
//    }
         init() { }
    required init(map: Map) {
//    super.init()
    }
    

}

extension Friend: Mappable {
    func mapping(map: Map) {
        isFriends <- map["isFriends"]
        friend <- map["friend"]
        permanentCity <- map["permanentCity"]
        changeJob <- map["changeJob"]
        headPortUrl <- map["headPortUrl"]
        starLevel <- map["starLevel"]
        nickName <- map["nickName"]
        distance <- map["distance"]
        emotion <- map["emotion"]
        userId <- map["userId"]
        mutualTourism <- map["mutualTourism"]
        rank <- map["rank"]
        distanceOff <- map["distanceOff"]
        autograph <- map["autograph"]
        degree_of_intimacy <- map["degree_of_intimacy"]
        lat <- map["latitude"]
        lng <- map["longitude"]
        
    }
}
extension Friend: IdentifiableType,Equatable {
    var identity: Int {
        return Int(userId)
    }
}
func ==(lhs: Friend, rhs: Friend) -> Bool {
    return lhs.userId == rhs.userId
}


