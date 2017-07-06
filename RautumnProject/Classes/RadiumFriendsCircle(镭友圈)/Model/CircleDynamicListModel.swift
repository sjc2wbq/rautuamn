
//
//  CircleDynamicListModel.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/7.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import RxSwift
import ObjectMapper
import RxSwift

struct CircleDynamicListModel {
    var r = 0
    var rautumnFriendsCircleList: [RautumnFriendsCircle] = []
    var userCount = 0
    
    init?(map: Map) {}
}

extension CircleDynamicListModel: Mappable {
    mutating func mapping(map: Map) {
        r <- map["r"]
        rautumnFriendsCircleList <- map["rautumnFriendsCircleList"]
        userCount <- map["userCount"]
    }
}


class RautumnFriendsCircle : NSObject{
    override init() {
        super.init()
    }
    var dateTime = ""
    var friend = false
    var coverUrl = Variable("")
    var changeJob = false
    var emotion = ""
    var mutualTourism = false
    var positionName = ""
    var headUrl = ""
    var narrativeContent = ""{
        didSet{
            let contentH = narrativeContent.height(16, wight: screenW - 20)
            shouldShowMoreButton = contentH > UIFont.systemFont(ofSize: 16).lineHeight * 9
        }
    }
    var attrContent : NSAttributedString!
    {
        let  attrString = NSMutableAttributedString()
        let  textAlignment = NSTextAttachment()
        textAlignment.image = UIImage(named: "original")
        textAlignment.bounds = CGRect(x: 0, y: -5, width: 40, height: 20)
        let atts = NSAttributedString(attachment: textAlignment)
        if original == true{
            attrString.append(atts)
            attrString.append(NSAttributedString(string: " \(narrativeContent)"))
        }else{
            
            attrString.append(NSAttributedString(string: " \(narrativeContent)"))
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        attrString.addAttributes([NSParagraphStyleAttributeName:paragraphStyle,NSFontAttributeName:UIFont.systemFont(ofSize: 16),NSForegroundColorAttributeName:UIColor.colorWithHexString("#333333")], range: NSMakeRange(0, attrString.length))

    return attrString

    }
    var original = false

    var starLevel = 0
    var nickName = ""
    var distance = 0
    var rfcPhotosOrSmallVideos: [RfcPhotosOrSmallVideo] = []
    var rank = ""
    var time = "" 
    var type = 0
    var id = 0
    var rfcId = 0
    var permanentCity = ""
    var distanceOff = false
    var isOpening = Variable(false)

    var shouldShowMoreButton = false
    var isShowMenu:Variable<Bool> = Variable(false)
    var countRC:Variable<Float> = Variable(0)
    var commentCount = Variable(0)
    var userId = 0

    required init?(map: Map) {}
}

extension RautumnFriendsCircle: Mappable {
    func mapping(map: Map) {
        dateTime <- map["dateTime"]
        friend <- map["friend"]
        coverUrl.value <- map["coverUrl"]
        userId <- map["userId"]
        rfcId <- map["rfcId"]
        id <- map["id"]
        commentCount.value <- map["commentCount"]
        countRC.value <- map["countRC"]
        distanceOff <- map["distanceOff"]
        permanentCity <- map["permanentCity"]
        type <- map["type"]
        changeJob <- map["changeJob"]
        emotion <- map["emotion"]
        mutualTourism <- map["mutualTourism"]
        positionName <- map["positionName"]
        headUrl <- map["headUrl"]
        narrativeContent <- map["narrativeContent"]
        original <- map["original"]
        starLevel <- map["starLevel"]
        nickName <- map["nickName"]
        distance <- map["distance"]
        rfcPhotosOrSmallVideos <- map["rfcPhotosOrSmallVideos"]
        rank <- map["rank"]
        time <- map["time"]
    }
}



class RfcPhotosOrSmallVideo : NSObject{
    var url = ""
    var coverUrl = ""
    var audio_length = 0
    override init() {
        super.init()
    }
    required init?(map: Map) {}

    
}

extension RfcPhotosOrSmallVideo: Mappable {
    func mapping(map: Map) {
        coverUrl <- map["coverUrl"]
        url <- map["url"]
        audio_length <- map["audio_length"]
    }
}
