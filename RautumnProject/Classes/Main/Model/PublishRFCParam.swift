
//
//  PublishRFCParam.swift
//  RautumnProject
//
//  Created by 陈雷 on 2016/12/23.
//  Copyright © 2016年 Rautumn. All rights reserved.
//

import UIKit
import ObjectMapper
struct PublishRFCParam {
    /*
     userPhone 	是 	string 	发布用户手机号
     content 	是 	string 	发布内容
     photosOrVideosUrl 	是 	string 	图片或者视频地址（多个以英文逗号隔开）
     lable 	是 	string 	标签
     positionName 	是 	string 	发布位置地点
     lon 	是 	double 	发布位置经度
     lat 	是 	double 	发布位置纬度
     */
    init() { }
    var action = "publishRFC"
    var userId = 0
    var content = ""
    var photosOrVideosUrl = ""
    var original = false
    var positionName = ""
    var lon = 0.0
    var lat = 0.0
    var type = 0
    var audio_length = 0
}

extension PublishRFCParam:Mappable{
    init?(map: Map){}
     mutating func mapping(map: Map) {
        type    <- map["type"]
        action    <- map["action"]
        userId    <- map["userId"]
        content    <- map["content"]
        photosOrVideosUrl    <- map["photosOrVideosUrl"]
        original    <- map["original"]
        positionName    <- map["positionName"]
        lon    <- map["lon"]
        lat    <- map["lat"]
        audio_length <- map["audio_length"]

    }
}
