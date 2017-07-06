//
//  RautumnFriendsCircleFrame.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/1/21.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

class RautumnFriendsCircleFrame: NSObject {
    
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
    
    var  imageContentViewFrame : CGRect! //图片容器
    
    var videoImgViewViewFrame : CGRect! //视频图片容器
    
    var videoPlayImgViewFrame : CGRect! //视频播放容器
    
    var audioButtonFrame: CGRect! // 音频button
    
    var aduioTimeLabelFrame: CGRect! //
    
    var timeLabelFrame : CGRect! //时间
    
    var addressLabelFrame : CGRect! //地点
    
    var huluBtnFrame : CGRect! //葫芦

    var cellHeight: CGFloat = 0.0
    var rautumnFriendsCircle:RautumnFriendsCircle!{
        didSet{
            if maxContentLabelHeight == 0{
                maxContentLabelHeight = 16 * CGFloat(maxLineNumber)
            }
            
            avatarImgViewFrame = CGRect(x: 14, y: 24, width: 50, height: 50)

            rankImgViewFrame = CGRect(x: avatarImgViewFrame.maxX - 15, y: avatarImgViewFrame.maxY - 15, width: 15, height: 15)
        
            nameLabelFrame =  CGRect(x: avatarImgViewFrame.maxX + 10, y: avatarImgViewFrame.minY + 4, width: rautumnFriendsCircle.nickName.width(16, height: 15), height: 15)
            
            starViewFrame = CGRect(x: nameLabelFrame.maxX + 4, y: nameLabelFrame.minY - 2.5, width: CGFloat(rautumnFriendsCircle.starLevel * 18), height: 20)

            if rautumnFriendsCircle.emotion == "呵呵一笑" {
                tag1LabelFrame = CGRect(x: starViewFrame.maxX + 5, y: starViewFrame.minY, width: 0, height: 0)
            }else{
                tag1LabelFrame = CGRect(x: starViewFrame.maxX + 5, y: starViewFrame.minY, width: 27, height: 17)
            }
            
            if rautumnFriendsCircle.changeJob {
                tag2LabelFrame = CGRect(x: tag1LabelFrame.maxX + 2, y: tag1LabelFrame.minY, width: 27, height: 17)
            }else{
                tag2LabelFrame = CGRect(x: tag1LabelFrame.maxX + 2, y: tag1LabelFrame.minY, width: 0, height: 0)
            }
            if rautumnFriendsCircle.mutualTourism {
                huzhuImgViewFrame = CGRect(x: tag2LabelFrame.maxX + 2, y: tag2LabelFrame.minY, width: 27, height: 17)
            }else{
                huzhuImgViewFrame = CGRect(x: tag2LabelFrame.maxX + 2, y: tag2LabelFrame.minY - 10, width: 0, height: 0)
            }
            cityBtnFrame = CGRect(x: nameLabelFrame.minX, y: nameLabelFrame.maxY + 10, width: rautumnFriendsCircle.permanentCity.width(15, height: 20) + 20, height: 20)
            
             distanceBtnFrame = CGRect(x: cityBtnFrame.maxX + 10, y: cityBtnFrame.minY, width: 100, height: 20)
            
              leiTaBtnFrame = CGRect(x: screenW - 10 - 66 , y: distanceBtnFrame.minY - 3, width: 66, height: 26)
            
            let textSize = self.rautumnFriendsCircle.attrContent.boundingRect(with: CGSize(width: screenW - 2 * self.avatarImgViewFrame.minX, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size

            if rautumnFriendsCircle.shouldShowMoreButton {
                rautumnFriendsCircle.isOpening.asObservable().subscribe(onNext: {[unowned self] (isOpening) in
                    var   contenH : CGFloat = 0
                    if isOpening{
                        contenH =  textSize.height + 10
                    }else{
                        contenH = maxContentLabelHeight
                    }
                    self.contentLabelFrame = CGRect(x: self.avatarImgViewFrame.minX, y: self.avatarImgViewFrame.maxY + 10, width: screenW - 2 * self.avatarImgViewFrame.minX, height: contenH)
                    self.fullTextLabelFrame = CGRect(x: self.contentLabelFrame.minX, y: self.contentLabelFrame.maxY, width: 50, height: 20)
                }, onError: nil, onCompleted: nil, onDisposed: nil)
                .addDisposableTo(rx_disposeBag)
            }else{
                self.contentLabelFrame = CGRect(x: self.avatarImgViewFrame.minX, y: self.avatarImgViewFrame.maxY + 10, width: screenW - 2 * self.avatarImgViewFrame.minX, height:  textSize.height + 10)
                fullTextLabelFrame = CGRect(x: contentLabelFrame.minX, y: contentLabelFrame.maxY , width: 0, height: 0)
            }
            imageContentViewFrame = CGRect.zero
            videoImgViewViewFrame = CGRect.zero
            videoPlayImgViewFrame = CGRect.zero
            audioButtonFrame = CGRect.zero
            aduioTimeLabelFrame = CGRect.zero
            
            if  rautumnFriendsCircle.type == 0{
             addressLabelFrame = CGRect(x: fullTextLabelFrame.minX, y: fullTextLabelFrame.maxY , width: screenW - 20, height: rautumnFriendsCircle.positionName == "" ? 0 : 12)
            } else if  rautumnFriendsCircle.type == 1 { //图片
            let margin : Float = 5.0
            var perRowItemCount = 0
            var itemW : Float = 0
            if rautumnFriendsCircle.rfcPhotosOrSmallVideos.count < 3 {
                perRowItemCount = rautumnFriendsCircle.rfcPhotosOrSmallVideos.count
            }else if rautumnFriendsCircle.rfcPhotosOrSmallVideos.count <= 4{
                perRowItemCount = 2
            }else{
                perRowItemCount = 3
            }
            
            if rautumnFriendsCircle.rfcPhotosOrSmallVideos.count == 1 {
                itemW = 120
            }else{
                itemW = (Float(UIScreen.main.bounds.size.width) - 36.0) / 3.0
            }
            let w  = Float(perRowItemCount) * itemW + Float((perRowItemCount - 1) ) * margin
                var columnCount:Float = 0
                if rautumnFriendsCircle.rfcPhotosOrSmallVideos.count > 0 {
               columnCount = ceilf(Float(rautumnFriendsCircle.rfcPhotosOrSmallVideos.count / perRowItemCount) + 0.5)
                }
                //    CGFloat h = columnCount * itemH + (columnCount - 1) * margin;
                switch rautumnFriendsCircle.rfcPhotosOrSmallVideos.count {
                case 0:
                    columnCount = 0
                case 1...2:
                    columnCount = 1
                case 3...6:
                    columnCount = 2
                default:
                    columnCount = 3
                }
            let h = Float(columnCount) * itemW + (columnCount - 1) * margin
            imageContentViewFrame = CGRect(x: contentLabelFrame.minX, y: fullTextLabelFrame.maxY + 10, width: CGFloat(w), height: CGFloat(h))
            addressLabelFrame = CGRect(x: imageContentViewFrame.minX, y: imageContentViewFrame.maxY + 10 , width: screenW - 28, height: rautumnFriendsCircle.positionName == "" ? 0 : 12)
            }else if rautumnFriendsCircle.type == 2 { //视频
                videoImgViewViewFrame = CGRect(x: avatarImgViewFrame.minX , y: fullTextLabelFrame.maxY + 10 , width: screenW - avatarImgViewFrame.minX * 2, height: screenW / 2)
            
                videoPlayImgViewFrame = videoImgViewViewFrame
            
                addressLabelFrame = CGRect(x: videoImgViewViewFrame.minX, y: videoImgViewViewFrame.maxY + 10 , width: screenW - 28, height: rautumnFriendsCircle.positionName == "" ? 0 : 12)
            } else { // 音频
                audioButtonFrame = CGRect(x: avatarImgViewFrame.minX , y: fullTextLabelFrame.maxY + 10 , width: 55.0, height: 55.0)
                aduioTimeLabelFrame = CGRect(x: audioButtonFrame.minX , y: audioButtonFrame.maxY, width: 55.0, height: 21.0)
                
                addressLabelFrame = CGRect(x: aduioTimeLabelFrame.minX, y: aduioTimeLabelFrame.maxY + 10 , width: screenW - 28, height: rautumnFriendsCircle.positionName == "" ? 0 : 12)
            }

        timeLabelFrame = CGRect(x: addressLabelFrame.minX, y: addressLabelFrame.maxY + 10 , width: 100, height: 15)
        huluBtnFrame = CGRect(x:contentLabelFrame.maxX - 36, y: timeLabelFrame.minY - 10.5, width: 50, height: 36)
        cellHeight =   huluBtnFrame.maxY + 10
            
        }
    }
}
