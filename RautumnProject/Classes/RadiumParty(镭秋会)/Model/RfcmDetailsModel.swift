
//
//  RfcmDetailsModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/6.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
//镭友民调详情
struct RfcmDetailsModel {
    var permanentCity = ""
    var changeJob = false
    var headPortUrl = ""
    var emotion = ""
    var closingDateTime = ""
    var optionB = ""
    var mutualTourism = false
    var userId = 0
    var distanceOff = false
    var option = ""
    var vote = false
    var optionC = ""
    var starLevel = 0
    var nickName = ""
    var distance = 0
    var title = ""
    var rank = ""
    var optionA = ""
    var answer = ""
    init?( map: Map) {}
}

extension RfcmDetailsModel: Mappable {
    mutating func mapping(map: Map) {
        permanentCity <- map["permanentCity"]
        changeJob <- map["changeJob"]
        headPortUrl <- map["headPortUrl"]
        emotion <- map["emotion"]
        closingDateTime <- map["closingDateTime"]
        optionB <- map["optionB"]
        mutualTourism <- map["mutualTourism"]
        userId <- map["userId"]
        distanceOff <- map["distanceOff"]
        option <- map["option"]
        vote <- map["vote"]
        optionC <- map["optionC"]
        starLevel <- map["starLevel"]
        nickName <- map["nickName"]
        distance <- map["distance"]
        title <- map["title"]
        rank <- map["rank"]
        optionA <- map["optionA"]
    }
}


//镭友民调投票统计
struct StatisticalModel {
    var optionBCount : Float = 0
    var optionACount : Float = 0
    var optionC = ""
    var optionCCount : Float = 0
    var optionB = ""
    var title = ""
    var optionA = ""
    var optionABCCount : Float = 0
    
    init?( map: Map) {}
}

extension StatisticalModel: Mappable {
    mutating func mapping(map: Map) {
        optionBCount <- map["optionBCount"]
        optionACount <- map["optionACount"]
        optionC <- map["optionC"]
        optionCCount <- map["optionCCount"]
        optionB <- map["optionB"]
        title <- map["title"]
        optionA <- map["optionA"]
        optionABCCount <- map["optionABCCount"]
    }
}
