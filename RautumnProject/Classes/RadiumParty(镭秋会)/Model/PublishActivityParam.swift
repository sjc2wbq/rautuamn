
//
//  PublishActivityParam.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper

struct PublishActivityParam {
    /*
     userId 	是 	string 	用户ID
     authorPhone 	是 	string 	发起人手机号
     name 	是 	string 	活动名称
     activityDateTime 	是 	string 	活动日期时间（yyyy-MM-dd HH:mm）
     place 	否 	string 	活动地点
     label 	是 	string 	分类
     enrollmentCeiling 	是 	int 	报名人数上限
     expense 	是 	double 	活动费用
     coverPhotoUrl 	是 	string 	活动封面图片地址
     rauActivityPictures 	是 	string 	镭秋活动详情图片(多个以英文逗号“,”隔开)
     activityDetails 	是 	string 	活动描述
     longitude 	否 	double 	活动地址经度
     latitude 	否 	double 	活动地址纬度
     */
    var userId = UserModel.shared.id
    var authorPhone = ""
    var name = ""
    var activityDateTime = ""
    var place = ""
    var label = ""
    var enrollmentCeiling = 0
    var expense : Double = 0
    var coverPhotoUrl = ""
    var rauActivityPictures = ""
    var activityDetails = ""
    var longitude = ""
    var latitude = ""
    var action = "publishActivity"
     init() {}
}

extension PublishActivityParam:Mappable{
    init?(map: Map){}
    mutating func mapping(map: Map) {
        action    <- map["action"]
        userId    <- map["userId"]
        name    <- map["name"]
        activityDateTime    <- map["activityDateTime"]
        place    <- map["place"]
        label    <- map["label"]
        enrollmentCeiling    <- map["enrollmentCeiling"]
        expense    <- map["expense"]
        coverPhotoUrl    <- map["coverPhotoUrl"]
        rauActivityPictures    <- map["rauActivityPictures"]
        activityDetails    <- map["activityDetails"]
        longitude    <- map["longitude"]
        latitude    <- map["latitude"]
        authorPhone    <- map["authorPhone"]
    }
}
