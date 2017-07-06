
//
//  CreateGroupParam.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/6.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
struct CreateGroupParam {
    /*
     userId 	是 	int 	用户ID
     name 	是 	string 	群名称
     introduce 	是 	string 	群介绍
     coverPhotoUrl 	是 	string 	群封面图片地址
     rauGroupAlbums 	是 	string 	群图片地址（多个以英文逗号隔开“,”）
     address 	是 	string 	群地址
     longitude 	是 	string 	群经度
     latitude 	是 	string 	群纬度
     */
    var action = "createGroup"
    var userId = UserModel.shared.id
    var name = ""
    var introduce = ""
    var coverPhotoUrl = ""
    var rauGroupAlbums = ""
    var address = ""
    var longitude = ""
    var latitude = ""
    var groupType = "0"
    init() {}
}
extension CreateGroupParam:Mappable{
    init?(map: Map){}
    mutating func mapping(map: Map) {
        action    <- map["action"]
        userId    <- map["userId"]
        name    <- map["name"]
        introduce    <- map["introduce"]
        coverPhotoUrl    <- map["coverPhotoUrl"]
        rauGroupAlbums    <- map["rauGroupAlbums"]
        address    <- map["address"]
        longitude    <- map["longitude"]
        latitude    <- map["latitude"]
        groupType <- map["groupType"]
        }
}


struct EditGroupParam {
    var action = "editGroup"
    var userId = UserModel.shared.id
    var name = ""
    var introduce = ""
    var coverPhotoUrl = ""
    var rauGroupAlbums = ""
    var address = ""
    var longitude = ""
    var latitude = ""
    var rgId = 0
    init() {}
}

extension EditGroupParam:Mappable{
    init?(map: Map){}
    mutating func mapping(map: Map) {
        rgId    <- map["rgId"]
        action    <- map["action"]
        userId    <- map["userId"]
        name    <- map["name"]
        introduce    <- map["introduce"]
        coverPhotoUrl    <- map["coverPhotoUrl"]
        rauGroupAlbums    <- map["rauGroupAlbums"]
        address    <- map["address"]
        longitude    <- map["longitude"]
        latitude    <- map["latitude"]
    }
}
