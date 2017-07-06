//
//  FriendInfoModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/12.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
struct FriendInfoModel {
    var rautumnId = ""
    var changeJob = false
    var registerDate = ""
    var emotion = ""
    var mutualTourism = false
    var hobby = ""
    var dateOfBirth = ""
    var motto = ""
    var height = 0
    var rauFriCount = 0
    var userPhotos: [Userphoto] = []
    var licenseStatus = 0
    var starLevel = 0
    var vcr = ""
    var perfectDegreeOfData = 0
    var autograph = ""
    var vocationalCertificate = ""
    var vcrCoverUrl = ""
    var permanentCity = ""
    var nickName = ""
    var friend = false
    var friendState = 0
    var constellation = ""
    var occupation = ""
    var language = ""
    var headPortUrl = ""
    var rank = "M"
    var sex = 0
    init?( map: Map) {}
}

extension FriendInfoModel: Mappable {
    mutating func mapping(map: Map) {
        language <- map["language"]
        occupation <- map["occupation"]
        constellation <- map["constellation"]
        permanentCity <- map["permanentCity"]
        friendState <- map["friendState"]
        friend <- map["friend"]
        nickName <- map["nickName"]
        vcrCoverUrl <- map["vcrCoverUrl"]
        rautumnId <- map["rautumnId"]
        changeJob <- map["changeJob"]
        registerDate <- map["registerDate"]
        emotion <- map["emotion"]
        mutualTourism <- map["mutualTourism"]
        hobby <- map["hobby"]
        dateOfBirth <- map["dateOfBirth"]
        motto <- map["motto"]
        height <- map["height"]
        rauFriCount <- map["rauFriCount"]
        userPhotos <- map["userPhotos"]
        licenseStatus <- map["licenseStatus"]
        starLevel <- map["starLevel"]
        vcr <- map["vcrUrl"]
        perfectDegreeOfData <- map["perfectDegreeOfData"]
        autograph <- map["autograph"]
        vocationalCertificate <- map["vocationalCertificate"]
        headPortUrl <- map["headPortUrl"]
        rank <- map["rank"]
        sex <- map["sex"]
    }
}

// MARK: - Userphoto

struct Userphoto {
    var url = ""
    
    init?( map: Map) {}
}

extension Userphoto: Mappable {
    mutating func mapping(map: Map) {
        url <- map["url"]
    }
}
