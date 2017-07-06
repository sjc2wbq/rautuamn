//
//  NearbyActivityModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/22.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
import RxDataSources

struct NearbyActivityModel {
    var rauActivities: [Rauactivitie] = []
    
    init?( map: Map) {}
}

extension NearbyActivityModel: Mappable {
    mutating func mapping(map: Map) {
        rauActivities <- map["rauActivities"]
    }
}

// MARK: - Rauactivitie

struct Rauactivitie {
    var label = ""
    var expense = 0
    var name = ""
    var id = 0
    var distance : Float = 0
    var activityDateTime = ""
    var place = ""
    var coverPhotoUrl = ""
    
    init?( map: Map) {}
}

extension Rauactivitie: Mappable {
    mutating func mapping(map: Map) {
        label <- map["label"]
        expense <- map["expense"]
        name <- map["name"]
        id <- map["id"]
        distance <- map["distance"]
        activityDateTime <- map["activityDateTime"]
        place <- map["place"]
        coverPhotoUrl <- map["coverPhotoUrl"]
    }
}
extension Rauactivitie: IdentifiableType,Equatable {
    var identity: Int {
        return Int(id)
    }
}
func ==(lhs: Rauactivitie, rhs: Rauactivitie) -> Bool {
    return lhs.id == rhs.id
}
