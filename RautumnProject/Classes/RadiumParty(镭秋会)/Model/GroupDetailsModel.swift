//
//  GroupDetailsModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
import RxDataSources

struct GroupDetailsModel {
    var name = ""
    var introduce = ""
    var id = 0
    var address = ""
    var distance:Double = 0
    var rauGroupUserCount = 0
    var createDate = ""
    var coverPhotoUrl = ""
    var jion = false
    var rauGroupUsers: [Raugroupuser] = []
    var rguOnlineCount = 0
    var rauGroupAlbums : [RauGroupAlbum] = []
    var mainGroup = false
    init?( map: Map) {}
}
struct RauGroupAlbum : Mappable{
    var url = ""
    var id = 0
    init?( map: Map) {}
    
    mutating func mapping(map: Map) {
        
        id <- map["id"]
        url <- map["url"]
    }
}
extension GroupDetailsModel: Mappable {
    mutating func mapping(map: Map) {
        name <- map["name"]
        introduce <- map["introduce"]
        id <- map["id"]
        address <- map["address"]
        distance <- map["distance"]
        rauGroupUserCount <- map["rauGroupUserCount"]
        createDate <- map["createDate"]
        coverPhotoUrl <- map["coverPhotoUrl"]
        jion <- map["jion"]
        rauGroupUsers <- map["rauGroupUsers"]
        rguOnlineCount <- map["rguOnlineCount"]
        rauGroupAlbums <- map["rauGroupAlbums"]
        mainGroup <- map["mainGroup"]
    }
}

// MARK: - Raugroupuser

struct Raugroupuser {
    var headPortUrl = ""
    var nickname = ""
    var userId = 0
    
    init?( map: Map) {}
}

extension Raugroupuser: Mappable {
    mutating func mapping(map: Map) {
        headPortUrl <- map["headPortUrl"]
        nickname <- map["nickname"]
        userId <- map["userId"]
    }
}

extension Raugroupuser: IdentifiableType,Equatable {
    var identity: Int {
        return Int(userId)
    }
}
func ==(lhs: Raugroupuser, rhs: Raugroupuser) -> Bool {
    return lhs.userId == rhs.userId
}
