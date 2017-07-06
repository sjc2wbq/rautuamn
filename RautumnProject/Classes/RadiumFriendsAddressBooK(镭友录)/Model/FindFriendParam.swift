//
//  FindFriendParam.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/17.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
struct UserInfoModel {
    var userInfos: [Friend] = []
    
    init( map: Map) {}
}

extension UserInfoModel: Mappable {
    mutating func mapping(map: Map) {
        userInfos <- map["userInfos"]
    }
}

struct FindFriendParam {
    
    init() {
        
    }
    /*
     userId 	是 	int 	用户ID
     permanentCity 	是 	string 	区域城市
     changeJob 	否 	boolean 	是否换工作
     emotion 	否 	string 	情感（多个以英文逗号隔开）
     mutualTourism 	否 	boolean 	是否互助旅游
     language 	否 	string 	语言 （多个以英文逗号隔开）
     constellation 	否 	string 	星座 （多个以英文逗号隔开）
     hobby 	否 	string 	爱好 （多个以英文逗号隔开）
     occupation 	否 	string 	职业 （多个以英文逗号隔开）
     vocationalCertificate 	否 	string 	证书 （多个以英文逗号隔开）
     pageIndex 	是 	int 	页码
     pageSize 	是 	int 	每页显示的行数
     */
    var action = "findRF"
    var userId = UserModel.shared.id
    var permanentCity = ""
    var changeJob = ""
//    var emotion = "呵呵一笑"
    var emotion = ""
    var mutualTourism = ""
    var language = ""
    var constellation = ""
    var hobby = ""
    var occupation = ""
    var vocationalCertificate = ""
    var pageIndex = 1
    var pageSize = 10
}
extension FindFriendParam:Mappable {
    init?(map: Map){}
    mutating func mapping(map: Map) {
        action    <- map["action"]
        userId    <- map["userId"]
        permanentCity    <- map["permanentCity"]
        changeJob    <- map["changeJob"]
        emotion    <- map["emotion"]
        mutualTourism    <- map["mutualTourism"]
        language    <- map["language"]
        constellation    <- map["constellation"]
        hobby    <- map["hobby"]
        occupation    <- map["occupation"]
        vocationalCertificate    <- map["vocationalCertificate"]
        pageIndex    <- map["pageIndex"]
        pageSize    <- map["pageSize"]
    }
}

