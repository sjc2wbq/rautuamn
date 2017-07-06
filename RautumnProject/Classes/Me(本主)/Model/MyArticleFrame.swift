//
//  MyArticleFrame.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/17.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit

class MyArticleFrame: NSObject {
    override init() {
        super.init()
    }
    var bigTimeLabelFrame : CGRect! //大时间
    var deleteBtnFrame : CGRect! //删除按钮
    
    var commentBtnFrame : CGRect! //评论按钮
    
    var dashangBtnFrame : CGRect! //打赏按钮

    var contentLabelFrame : CGRect! //文本
    
    var  fullTextLabelFrame : CGRect! //全文
    
    var  imageContentViewFrame : CGRect! //图片容器
    
    var videoImgViewViewFrame : CGRect! //视频图片容器
    
    var videoPlayImgViewFrame : CGRect! //视频播放容器
    
    var audioButtonFrame: CGRect! // 音频
    var audioTimeLabelFrame: CGRect!
    
    var timeLabelFrame : CGRect! //时间
    
    var addressLabelFrame : CGRect! //地点
    
    var huluBtnFrame : CGRect! //葫芦
    
    var cellHeight: CGFloat = 0.0
    var rautumnFriendsCircle:RautumnFriendsCircle!{
        didSet{
            
            bigTimeLabelFrame = CGRect(x: 14, y: 14, width: 200, height: 30)
            
            deleteBtnFrame = CGRect(x: screenW -  55, y: 14, width: 41, height: 22)
            
            if maxContentLabelHeight == 0{
                maxContentLabelHeight = 16 * CGFloat(maxLineNumber)
            }
            let margin : CGFloat = 10
            let textSize = self.rautumnFriendsCircle.attrContent.boundingRect(with: CGSize(width: screenW - 2 * 10, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size
            
            if rautumnFriendsCircle.shouldShowMoreButton {
                rautumnFriendsCircle.isOpening.asObservable().subscribe(onNext: {[unowned self] (isOpening) in
                    var   contenH : CGFloat = 0
                    if isOpening{
                        contenH =  textSize.height + 10
                    }else{
                        contenH = maxContentLabelHeight
                    }
                    self.contentLabelFrame = CGRect(x: margin, y: self.bigTimeLabelFrame.maxY +  margin, width: screenW - CGFloat(2) * margin, height: contenH)
                    self.fullTextLabelFrame = CGRect(x: self.contentLabelFrame.minX, y: self.contentLabelFrame.maxY + 2, width: 50, height: 20)
                    }, onError: nil, onCompleted: nil, onDisposed: nil)
                    .addDisposableTo(rx_disposeBag)
            }else{
                self.contentLabelFrame = CGRect(x: margin, y: self.bigTimeLabelFrame.maxY + margin , width: screenW - CGFloat(2) * margin, height:  textSize.height + 10)
                fullTextLabelFrame = CGRect(x: contentLabelFrame.minX, y: contentLabelFrame.maxY + 2, width: 0, height: 0)
            }
            
            imageContentViewFrame = CGRect.zero
            videoImgViewViewFrame = CGRect.zero
            videoPlayImgViewFrame = CGRect.zero
            audioButtonFrame = CGRect.zero
            audioTimeLabelFrame = CGRect.zero
            
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
//                var columnCount = ceilf(Float(rautumnFriendsCircle.rfcPhotosOrSmallVideos.count / perRowItemCount) + 0.5)
                var columnCount = Float(5.0)
//                    CGFloat h = columnCount * itemH + (columnCount - 1) * margin;
                switch rautumnFriendsCircle.rfcPhotosOrSmallVideos.count {
                case 1...2:
                    columnCount = 1
                case 3...6:
                    columnCount = 2
                default:
                    columnCount = 3
                }
                let h = Float(columnCount) * itemW + (columnCount - 1) * margin
                
                imageContentViewFrame = CGRect(x: contentLabelFrame.minX, y: fullTextLabelFrame.maxY + 10, width: CGFloat(w), height: CGFloat(h))
                addressLabelFrame = CGRect(x: imageContentViewFrame.minX, y: imageContentViewFrame.maxY + 10, width: screenW - 20, height: rautumnFriendsCircle.positionName == "" ? 0 : 12)
                
            }else if rautumnFriendsCircle.type == 2 { //视频
                
                videoImgViewViewFrame = CGRect(x: 10, y: fullTextLabelFrame.maxY + 10, width: screenW - 10 * 2, height: screenW / 2)
                
                videoPlayImgViewFrame = CGRect(x: 0, y: 0, width: videoImgViewViewFrame.size.width, height: videoImgViewViewFrame.size.height)
                
                addressLabelFrame = CGRect(x: videoImgViewViewFrame.minX, y: videoImgViewViewFrame.maxY + 10, width: screenW - 20, height: rautumnFriendsCircle.positionName == "" ? 0 : 12)
                
            } else { // 音频
                
                audioButtonFrame = CGRect(x: 10, y: fullTextLabelFrame.maxY + 10, width: 55, height: 55.0)
                audioTimeLabelFrame = CGRect(x: 10, y: audioButtonFrame.maxY, width: 55, height: 21.0)
                addressLabelFrame = CGRect(x: audioButtonFrame.minX, y: audioTimeLabelFrame.maxY + 10, width: screenW - 20, height: rautumnFriendsCircle.positionName == "" ? 0 : 12)
            }
            
            timeLabelFrame = CGRect(x: addressLabelFrame.minX, y: addressLabelFrame.maxY + 10 , width: 100, height: 27)
            
            
            dashangBtnFrame = CGRect(x:contentLabelFrame.maxX - "\(rautumnFriendsCircle.countRC.value)".width(13, height: 27) - 40 - 14, y: timeLabelFrame.minY, width: "\(rautumnFriendsCircle.countRC.value)".width(13, height: 27) + 40, height: 27)
            
            commentBtnFrame = CGRect(x:dashangBtnFrame.minX - "\(rautumnFriendsCircle.countRC.value)".width(13, height: 27) - 40 - 20, y: timeLabelFrame.minY, width: "\(rautumnFriendsCircle.commentCount.value)".width(13, height: 27) + 40, height: 27)

            
            cellHeight =   commentBtnFrame.maxY + 10
        
        }
    }

}
