//
//  UserModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/23.
//  Copyright © 2016年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import ObjectMapper
class UserModel :NSObject {
    static var  shared = UserModel()
    var changeJob = false
    var permanentCity = ""
    var headPortUrl = Variable("")
    var portraitUri = ""
    var userIDCards: [UserIDCard] = []
    var emotion = ""
    var language = ""
    var mutualTourism = false
    var hobby = ""
    var motto = ""
    var height = 0
    var userPhotos: [UserPhoto] = []
    var occupation = ""
    var nickName = Variable("")
    var name = ""
    var vcrUrl = ""
    var vcr = ""
    var constellation = ""
    var autograph = ""
    var vocationalCertificate = ""
    var sex = 0
    var id = 0{
        didSet{
        inApp =  (UserDefaults.standard.value(forKey: "userPhone") as? String) == "13678114186"
        }
    }
    var userPhone = ""
    var ID = 0
    var rank = Variable("V")
    var starLevel = 0
    var rautumnCurrency:Variable<Float> = Variable(0.0)
    var distanceOff = false
    var token = ""
    var perfectDegreeOfData = 0
    var licenseStatus = 0
    var rautumnId = ""
    var dateOfBirth = ""
    var rauFriCount = 0
    var registerDate = ""
    var vcrCoverUrl = ""
    var city = "定位失败"
    var userCount = Variable(0)
    var r = Variable(0)
    var inApp:Bool = false
    
    required init?(map: Map) {}
    
     override init(){}
}

extension UserModel: Mappable {
    func mapping(map: Map) {
        rautumnId <- map["rautumnId"]
        licenseStatus <- map["licenseStatus"]
        userCount.value <- map["userCount"]
        r.value <- map["r"]
        
        dateOfBirth <- map["dateOfBirth"]
        rauFriCount <- map["rauFriCount"]
        registerDate <- map["registerDate"]
        vcrCoverUrl <- map["vcrCoverUrl"]
        perfectDegreeOfData <- map["perfectDegreeOfData"]
        userPhone <- map["userPhone"]
        token <- map["token"]
        distanceOff <- map["distanceOff"]
        rautumnCurrency.value <- map["rautumnCurrency"]
        ID <- map["id"]
        id <- map["id"]
        rank.value <- map["rank"]
        starLevel <- map["starLevel"]
        changeJob <- map["changeJob"]
        permanentCity <- map["permanentCity"]
        portraitUri <- map["headPortUrl"]
        headPortUrl.value <- map["headPortUrl"]
        userIDCards <- map["userIDCards"]
        emotion <- map["emotion"]
        language <- map["language"]
        mutualTourism <- map["mutualTourism"]
        hobby <- map["hobby"]
        motto <- map["motto"]
        height <- map["height"]
        userPhotos <- map["userPhotos"]
        occupation <- map["occupation"]
        name <- map["nickName"]
        nickName.value <- map["nickName"]
        vcrUrl <- map["vcrUrl"]
        vcr <- map["vcr"]
        constellation <- map["constellation"]
        autograph <- map["autograph"]
        vocationalCertificate <- map["vocationalCertificate"]
        sex <- map["sex"]
    }
}

// MARK: - Useridcard

class UserIDCard {
    var id = 0
    var type = 0
    var url = ""
    
    required init?(map: Map) {}
}

extension UserIDCard: Mappable {
    func mapping(map: Map) {
        id <- map["id"]
        type <- map["type"]
        url <- map["url"]
    }
}

// MARK: - Userphoto

class UserPhoto {
    var id = 0
    var url = ""
    
    required init?(map: Map) {}
}

extension UserPhoto: Mappable {
    func mapping(map: Map) {
        id <- map["id"]
        url <- map["url"]
    }
}


struct VerificationCode:Mappable {
    var verificationCode:String?
    init?(map: Map){}
    
    mutating func mapping(map: Map) {
        verificationCode    <- map["verificationCode"]
        
    }
}
struct EmptyModel:Mappable {
    init?(map: Map){}
    
    mutating func mapping(map: Map) {
    }
}
