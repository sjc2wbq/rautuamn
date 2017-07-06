
//
//  RvUsefulFrame.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/8.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit


class RvUsefulFrame: NSObject {
    
    override init() {
        super.init()
    }
    var avatarImgViewFrame: CGRect! //头像的尺寸
    
    var rankImgViewFrame: CGRect! //会员等级的尺寸
    
    var nameLabelFrame: CGRect!//名字的尺寸
    
    var  starViewFrame: CGRect! //星级的尺寸
    
    var tag1LabelFrame: CGRect! //找男友 、找女友
    
    var tag2LabelFrame: CGRect! //找工作
    
    var huzhuImgViewFrame: CGRect! //互助旅游
    
    var leiTaBtnFrame : CGRect!//镭Ta按钮
    
    var cityBtnFrame : CGRect! //城市按钮
    
    var distanceBtnFrame : CGRect! //距离按钮
    
    var contentLabelFrame : CGRect! //文本
    
    var  fullTextLabelFrame : CGRect! //全文
    

    
    var videoImgViewViewFrame : CGRect! //视频图片容器
    
    var videoPlayImgViewFrame : CGRect! //视频播放容器
    
    var timeLabelFrame : CGRect! //时间
    
    var addressLabelFrame : CGRect! //地点
    
    var huluBtnFrame : CGRect! //葫芦
    
    var cellHeight: CGFloat = 0.0
    var rvUseful:RvUseful!{
        didSet{
            if maxContentLabelHeight == 0{
                maxContentLabelHeight = 16 * CGFloat(maxLineNumber)
            }
            
            avatarImgViewFrame = CGRect(x: 14, y: 14, width: 50, height: 50)
            
            rankImgViewFrame = CGRect(x: avatarImgViewFrame.maxX - 15, y: avatarImgViewFrame.maxY - 15, width: 15, height: 15)
            
            
            nameLabelFrame =  CGRect(x: avatarImgViewFrame.maxX + 5, y: avatarImgViewFrame.minY + 5, width: rvUseful.nickName.width(16, height: 15), height: 15)
            
            starViewFrame = CGRect(x: nameLabelFrame.maxX + 4, y: nameLabelFrame.minY - 2.5, width: CGFloat(rvUseful.starLevel * 18), height: 20)
            
            
            if rvUseful.emotion == "呵呵一笑" {
                tag1LabelFrame = CGRect(x: starViewFrame.maxX, y: starViewFrame.minY, width: 0, height: 0)
            }else{
                tag1LabelFrame = CGRect(x: starViewFrame.maxX + 10, y: starViewFrame.minY, width: 27, height: 17)
            }
            
            if rvUseful.changeJob {
                tag2LabelFrame = CGRect(x: tag1LabelFrame.maxX + 2, y: tag1LabelFrame.minY, width: 27, height: 17)
            }else{
                tag2LabelFrame = CGRect(x: tag1LabelFrame.maxX + 2, y: tag1LabelFrame.minY, width: 0, height: 0)
            }
            
            
            huzhuImgViewFrame = CGRect(x: tag2LabelFrame.maxX + 2, y: tag2LabelFrame.minY, width: 27, height: 17)
            
            cityBtnFrame = CGRect(x: nameLabelFrame.minX, y: avatarImgViewFrame.maxY - 20, width: rvUseful.permanentCity.width(15, height: 20) + 20, height: 20)
            
            distanceBtnFrame = CGRect(x: cityBtnFrame.maxX + 10, y: cityBtnFrame.minY, width: 100, height: 20)
            
            leiTaBtnFrame = CGRect(x: screenW - 10 - 66 , y: distanceBtnFrame.minY - 3, width: 66, height: 26)
            
            self.contentLabelFrame = CGRect(x: self.avatarImgViewFrame.minX, y: self.avatarImgViewFrame.maxY + 10, width: screenW - 2 * self.avatarImgViewFrame.minX, height: rvUseful.title.height(16, wight: screenW - 2) + 5)
            fullTextLabelFrame = CGRect(x: contentLabelFrame.minX, y: contentLabelFrame.maxY + 2, width: 0, height: 0)
            
            videoImgViewViewFrame = CGRect.zero
            videoPlayImgViewFrame = CGRect.zero
            
            
            videoImgViewViewFrame = CGRect(x: avatarImgViewFrame.minX , y: fullTextLabelFrame.maxY + 10, width: screenW - avatarImgViewFrame.minX * 2, height: screenW / 2)
            
            videoPlayImgViewFrame = CGRect(x: 0, y: 0, width: videoImgViewViewFrame.size.width, height: videoImgViewViewFrame.size.height)
            
            addressLabelFrame = CGRect(x: videoImgViewViewFrame.minX, y: videoImgViewViewFrame.maxY + 10, width: screenW, height: rvUseful.position == "" ? 0 : 12)
            
            timeLabelFrame = CGRect(x: addressLabelFrame.minX, y: addressLabelFrame.maxY + 15, width: 100, height: 12)
            huluBtnFrame = CGRect(x:contentLabelFrame.maxX - 36, y: timeLabelFrame.minY - 12, width: 50, height: 36)
            cellHeight =   huluBtnFrame.maxY + 10
            
        }
    }
}
