//
//  MyRSVModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/13.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import ObjectMapper

struct MyRSVModel {
    var rauVideoUsefuls: [MyRSV] = []
    
    init?( map: Map) {}
}

extension MyRSVModel: Mappable {
    mutating func mapping(map: Map) {
        rauVideoUsefuls <- map["rauVideoUsefuls"]
    }
}

// MARK: - Rauvideouseful

struct MyRSV {
    var id = 0
    var videoUrl = ""
    var rvucCount = 0
    var commentCount = 0
    var title = ""
    var coverPhotoUrl = ""
    var time = ""
    var rcCount = 0
    var countRC: Variable<String> = Variable("0")
    var playTimes = Variable(0)
    
    init?( map: Map) {}
}

extension MyRSV: Mappable {
    mutating func mapping(map: Map) {
        id <- map["id"]
        commentCount <- map["commentCount"]
        countRC.value <- map["countRC"]
        videoUrl <- map["videoUrl"]
        rvucCount <- map["rvucCount"]
        title <- map["title"]
        coverPhotoUrl <- map["coverPhotoUrl"]
        time <- map["time"]
        rcCount <- map["rcCount"]
        playTimes.value <- map["playTimes"]
    }
}

extension MyRSV: IdentifiableType,Equatable {
    var identity: Int {
        return id
    }
}
func ==(lhs: MyRSV, rhs: MyRSV) -> Bool {
    return lhs.id == rhs.id
}
