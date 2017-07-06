

//
//  EditUserInfoParam.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/14.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
struct EditUserInfoParam {
    /*
     phone 	是 	string 	手机号
     password 	是 	string 	密码
     hrurl 	是 	string 	头像路径
     nickName 	是 	string 	昵称
     height 	是 	int 	身高（厘米）
     language 	是 	string 	语言
     sex 	是 	int 	性别 1男 2女
     emotion 	是 	string 	情感
     cons 	是 	string 	星座
     motto 	是 	string 	座右铭
     occ 	是 	string 	职业
     changeJob 	否 	boolean 	是否跟换工作 true 是 false 否
     hobby 	是 	string 	爱好
     perCity 	是 	string 	常住城市
     mutualTourism 	否 	boolean 	是否提供互助旅游 true是 false否
     autograph 	否 	string 	小道消息
     quacer 	否 	string 	职业资格证，多个以英文逗号隔开
     vcrUrl 	是 	string 	vcr视频路径
     photosUrl 	否 	string 	相册路径，多个以英文逗号隔开
     idCardsUrl 	否 	string 	身份证路径，多个以英文逗号隔开，第一个位置是身份证正面 第2个位置是身份证反面
     dateOfBirth 	是 	string 	出生日期 yyyy-MM-dd
     */
    var phone = ""
    var password = ""
    var hrurl = ""
    var nickName = ""
    var language = ""
    var emotion = ""
    var cons = ""
    var motto = ""
    var height = ""
    var sex = 0
    var occ = ""
    var changeJob = false
    var hobby = ""
    var perCity = ""
    var mutualTourism = false
    var autograph = ""
    var quacer = ""
    var vcrUrl = ""
    var photosUrl = ""
    var idCardsUrl = ""
    var dateOfBirth = ""
    var action = "editUserInfo"
    init?( map: Map) {}
    init() {}

}
extension EditUserInfoParam: Mappable {
    mutating func mapping(map: Map) {
        phone <- map["phone"]
        password <- map["password"]
        hrurl <- map["hrurl"]
        nickName <- map["nickName"]
        language <- map["language"]
        emotion <- map["emotion"]
        cons <- map["cons"]
        motto <- map["motto"]
        height <- map["height"]
        sex <- map["sex"]
        occ <- map["occ"]
        changeJob <- map["changeJob"]
        hobby <- map["hobby"]
        perCity <- map["perCity"]
        mutualTourism <- map["mutualTourism"]
        autograph <- map["autograph"]
        quacer <- map["quacer"]
        vcrUrl <- map["vcrUrl"]
        photosUrl <- map["photosUrl"]
        idCardsUrl <- map["idCardsUrl"]
        dateOfBirth <- map["dateOfBirth"]
        action <- map["action"]
    }
}

