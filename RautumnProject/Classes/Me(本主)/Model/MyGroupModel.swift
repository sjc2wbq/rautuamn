//
//  MyGroupModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
import RxDataSources
import RxSwift
struct MyGroupModel {
    var rauGroups: [Raugroup] = []
    
    init?( map: Map) {}
}

extension MyGroupModel: Mappable {
    mutating func mapping(map: Map) {
        rauGroups <- map["rauGroups"]
    }
}

// MARK: - Raugroup

struct Raugroup {
    var rguCount = 0
    var name = ""
    var coverPhotoUrl = ""
    var id = 0
    var distance : Int  = 0
    var jion  = Variable(false)
    var rauGroupUserCount = 1
    var groupType = "0"
    init() {}
    init?( map: Map) {}
}

extension Raugroup: Mappable {
    mutating func mapping(map: Map) {
        rauGroupUserCount <- map["rauGroupUserCount"]
        jion.value <- map["jion"]
        distance <- map["distance"]
        rguCount <- map["rguCount"]
        name <- map["name"]
        coverPhotoUrl <- map["coverPhotoUrl"]
        id <- map["id"]
        groupType <- map["groupType"]
    }
}
extension Raugroup: IdentifiableType,Equatable {
    var identity: Int {
        return id
    }
}
func ==(lhs: Raugroup, rhs: Raugroup) -> Bool {
    return lhs.id == rhs.id
}
