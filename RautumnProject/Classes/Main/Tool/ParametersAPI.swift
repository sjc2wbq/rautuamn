//
//  ParametersAPI.swift
//  TargetObject
//
//  Created by Raychen on 2016/10/5.
//  Copyright © 2016年 raychen. All rights reserved.
//

import UIKit
import ObjectMapper
import CryptoSwift
enum ParametersAPI {
    case theMain//本主
    case getVerificationCode(phone:String,type:Int) //获取验证码
    case register(param:RegisterParam)//用户注册
    case forgetPassword(phone:String,newPassword:String,vcode:String)//忘记密码
    case gratuityRauCurr(gratuityRauCurr:Float,objId:Int,type:Int)//打赏
    case publishRFC(param:PublishRFCParam)//发布镭友圈文章
    case registerVerificationVCode(userPhone:String,vcode:String)//注册时验证验证码
    case userLogin(phone:String,password:String)//用户登录
    case getRautumnFriendsCircleList(pageIndex:Int,type:Int)//镭友圈
    case comment(objId:String,content:String,type:Int)//镭友圈评论接口 类型 1镭友圈评论 2镭视宝评论
    case rfcComment(rfcId:String,pageIndex:Int)//获取镭友圈评论
    case rfcDetails(rfcId:Int)//镭友圈详情
    case raufriDetails(visitorUserId:Int)//镭友详情
    case establishFriendRelationship(beAddedUserInfoId:Int,msg:String)//加好友（先建立关系）
    case rauFriendRecord(pageIndex:Int)//镭友录
    case findRF(param:FindFriendParam)//找镭友
    case newFriends(pageIndex:Int,pageSize:Int)//新的朋友接口
    case friendsAgreeOrDelete(beAddedUserInfoId:Int,type:Int) //好友同意或者删除好友接口
    case deleteFShow(fId:Int)//删除新的朋友
    case rauFriend//镭缘分接口
    case publishRFCM(param:PublishRFCMParam)//发布镭友民调
    case activityDetails(raId:Int)//活动详情
    case activityEnroll(raId:Int)//镭秋活动报名
    case iCreatedTheGroup(pageIndex:Int,type:Int)//我创建的群
    case dissolutionGroup(rgId:Int)//解散群
    case nearbyRauFriend(pageIndex:Int)//附近镭友
    case nearbyActivity(pageIndex:Int)//附近活动
    case nearbyGroup(pageIndex:Int)//附近群组
    case joinOutRauGroup(rgId:Int,type:Int)//加入或者退出群
    case rauFriCivilMediation(pageIndex:Int)//镭友民调
    case rfcmDetails(rfcmId:Int)//镭友民调详情
    case rfcmvCount(rfcmId:Int)//镭友民调投票统计
    case rfcmv(rfcmId:Int,optionADC:String)//镭友民调投票
    case createGroup(param:CreateGroupParam)//建群
    case groupDetails(groupId:Int)//群详情
    case publishActivity(param:PublishActivityParam)//发布活动（组局）
    case rvUseful(type:Int,newOrHot:Int,pageIndex:Int)//获取镭视宝
    case rsvComment(rsvId:Int,pageIndex:Int)//获取镭视宝评论
    case myWallet(type:Int,pageIndex:Int)//我的镭秋钱包
    case withdrawDeposit(rautumnCurrency:Double,alipay:String,weChatAccount:String)//申请提现
    case placeAnOrder(objId:Int,type:Int,payType:Int)//镭秋币或者会员下单操作
    case payDemoActivity(subject:String,body:String,price:String,out_trade_no:String,type:String)//获取支付宝支付信息接口
    case wxPayCreateOrder(out_trade_no:String,body:String,total_fee:Float,type:Int)//微信支付下单接口
    case getVIPOrderSettingList(type:Int)//获取会员设置
    case myRSV(pageIndex:Int)//我的视频
    case iJoinedTheActivity(type:Int,pageIndex:Int)//我参加的活动
    case modifyPassword(oldPwd:String,newPwd:String)//修改密码
    case openOrCloseDistance(type:Int)//打开或者关闭距离
    case feedback(content:String)//意见反馈
    case publishRSV(title:String,coverPhotoUrl:String,videoUrl:String,position:String)//发布RSV
    case rsvPlayTimes(rsvId:String)//累计播放次数
    case uploadLocation(longitude:CLLocationDegrees,latitude:CLLocationDegrees)//上传用户位置
    case deleteUserPhoto(upId:String)//删除用户相册
    case editUserInfo(param:EditUserInfoParam)//编辑用户资料
    case chatroomQueryUser(rsvId:Int)//获取观看镭视宝LIVE用户信息
    case getMyRautumnFriendsCircleList(pageIndex:Int)//我的文章
    case blacklist(receiveUserInfoId:Int,type:Int)//拉黑或者取消拉黑
    case complain(appelleeUserInfoId:Int,reason:String)//举报投诉
    case getRauGroupUser(groupId:Int)//群成员
    case getPlatformProtocol//平台协议
    case deleteRGA(rgId:Int,rgaIds:String)//删除群相册
    case editGroup(param:EditGroupParam)//修改群信息
    case deleteRauGroupUser(mainGroUserId:Int,rgId:Int,userIds:String)//删除群用户
    case deleteArticle(rfcId:Int)//删除我的文章
    case deleteMyRSV(rsvIds:String)//删除镭视宝（我的视频）
    case getPullTheBlack(pageIndex:Int)//获取拉黑列表
    case getGratuityRauCurr(type:Int,pageIndex:Int)//我的镭秋币记录
    case rautumnCurrencyOrder(out_trade_no:String,trade_no:String,total_fee:String)//应用内镭秋币购买
    case vipOrder(out_trade_no:String,trade_no:String,total_fee:String)//应用内会员购买
    case exitActivity(raId:Int)//退出活动
    
    // 1.1
    case deleteGratuityRau(recordId:Int)  // 删除打赏
    case getMyFriendsCircleList(friendUid:Int,pageIndex:Int) // 获取镭友的发布历史
    case applyJoinGroup(beAddGroupId:Int,msg:String) // 保存入群申请
    case delApplyJoinGroup(applyJoinGroupId:Int) // 删除我的加群申请消息
    case getApplyJoinGroup() // 查询我的群申请加入信息
    case agrredJoinGroup(userId:Int,rgId:Int)
    case getAppImg()

}
extension ParametersAPI  {
    var parameters: [String: Any] {
        switch self {
        case .getVerificationCode(let phone,let type): //获取验证码
            return ["action":"getVerificationCode","phone":phone,"type":type]
        case .register(let param)://用户注册
        return Mapper<RegisterParam>().toJSON(param)
        case .forgetPassword(let phone,let newPassword,let vcode)://忘记密码
            return ["action":"forgetPassword","phone":phone,"newPassword":newPassword.md5(),"vcode":vcode]
        case .gratuityRauCurr(let gratuityRauCurr,let objId,let type)://打赏
            return ["action":"gratuityRauCurr","gratuityRauCurr":gratuityRauCurr,"objId":objId,"type":type,"userId":UserModel.shared.id]
        case .publishRFC(let param)://发布镭友圈文章
            return Mapper<PublishRFCParam>().toJSON(param)
        case .registerVerificationVCode(let userPhone,let vcode)://注册时验证验证码
            return ["action":"registerVerificationVCode","userPhone":userPhone,"vcode":vcode]
        case .userLogin(let phone,let password)://用户登录
            return ["action":"userLogin","phone":phone,"password":password]
        case .getRautumnFriendsCircleList(let pageIndex,let type)://镭友圈
            return ["action":"getRautumnFriendsCircleList","pageIndex":pageIndex,"pageSize":10,"type":type,"userId":UserModel.shared.id]
        case .comment(let objId,let content,let type)://镭友圈评论接口 类型 1镭友圈评论 2镭视宝评论
            return ["action":"comment","objId":objId,"content":content,"type":type,"userId":UserModel.shared.id]
        case .rfcComment(let rfcId,let pageIndex)://获取镭友圈评论
            return ["action":"rfcComment","rfcId":rfcId,"pageIndex":pageIndex,"pageSize":10,"userId":UserModel.shared.id]
        case .rfcDetails(let rfcId)://镭友圈详情
            return ["action":"rfcDetails","rfcId":rfcId,"userId":UserModel.shared.id]
        case .raufriDetails(let visitorUserId)://镭友详情
            return ["action":"raufriDetails","userId":visitorUserId,"visitorUserId":UserModel.shared.id]
        case .establishFriendRelationship(let beAddedUserInfoId,let msg)://加好友（先建立关系）
            return ["action":"establishFriendRelationship","beAddedUserInfoId":beAddedUserInfoId,"activeUserInfoId":UserModel.shared.id,"msg":msg]
        case .rauFriendRecord(let pageIndex)://镭友录
            return ["action":"rauFriendRecord","pageIndex":pageIndex,"pageSize":10000000,"userId":UserModel.shared.id]
        case .findRF(let param)://找镭友
            return Mapper<FindFriendParam>().toJSON(param)
        case .newFriends(_, _)://新的朋友接口
            return ["action":"newFriends","userId":UserModel.shared.id]
        case .friendsAgreeOrDelete(let beAddedUserInfoId,let type): //好友同意或者删除好友接口
            return ["action":"friendsAgreeOrDelete","beAddedUserInfoId":UserModel.shared.id,"activeUserInfoId":beAddedUserInfoId,"type":type]
        case .deleteFShow(let fId)://删除新的朋友
            return ["action":"deleteFShow","userId":UserModel.shared.id,"fId":fId]
        case .rauFriend://镭缘分接口
            return ["action":"rauFriend","userId":UserModel.shared.id]
        case .publishRFCM(let param)://发布镭友民调
            return Mapper<PublishRFCMParam>().toJSON(param)
        case .activityDetails(let raId)://活动详情
            return ["action":"activityDetails","userId":UserModel.shared.id,"raId":raId]
        case .activityEnroll(let raId)://镭秋活动报名
            return ["action":"activityEnroll","userId":UserModel.shared.id,"raId":raId]
        case .iCreatedTheGroup(let pageIndex,let type)://我创建的群
            return ["action":"iCreatedTheGroup","pageIndex":pageIndex,"pageSize":10,"userId":UserModel.shared.id,"type":type]
        case .dissolutionGroup(let rgId)://解散群
            return ["action":"dissolutionGroup","rgId":rgId,"userId":UserModel.shared.id]
        case .nearbyRauFriend(let pageIndex)://附近镭友
            return ["action":"nearbyRauFriend","pageIndex":pageIndex,"pageSize":10,"userId":UserModel.shared.id]
        case .nearbyActivity(let pageIndex)://附近活动
            return ["action":"nearbyActivity","pageIndex":pageIndex,"pageSize":10,"userId":UserModel.shared.id]
        case .nearbyGroup(let pageIndex)://附近群组
            return ["action":"nearbyGroup","pageIndex":pageIndex,"pageSize":10,"userId":UserModel.shared.id]
        case .joinOutRauGroup(let rgId,let type)://加入或者退出群
            return ["action":"joinOutRauGroup","rgId":rgId,"type":type,"userId":UserModel.shared.id]
        case .rauFriCivilMediation(let pageIndex)://镭友民调
            return ["action":"rauFriCivilMediation","pageIndex":pageIndex,"pageSize":10,"userId":UserModel.shared.id]
        case .rfcmDetails(let rfcmId)://镭友民调详情
            return ["action":"rfcmDetails","rfcmId":rfcmId,"userId":UserModel.shared.id]
        case .rfcmvCount(let rfcmId)://镭友民调投票统计
            return ["action":"rfcmvCount","rfcmId":rfcmId,"userId":UserModel.shared.id]
        case .rfcmv(let rfcmId,let optionADC)://镭友民调投票
            return ["action":"rfcmv","rfcmId":rfcmId,"userId":UserModel.shared.id,"optionABC":optionADC]
        case .createGroup(let param)://建群
            return Mapper<CreateGroupParam>().toJSON(param)
        case .groupDetails(let groupId)://群详情
            return ["action":"groupDetails","groupId":groupId,"userId":UserModel.shared.id]
        case .publishActivity(let param)://发布活动（组局）
            return Mapper<PublishActivityParam>().toJSON(param)
        case .rvUseful(let type,let newOrHot,let pageIndex)://获取镭视宝
            return ["action":"rvUseful","type":type,"newOrHot":newOrHot,"pageIndex":pageIndex,"pageSize":10,"userId":UserModel.shared.id]
        case .rsvComment(let rsvId,let pageIndex)://获取镭视宝评论
            return ["action":"rsvComment","rsvId":rsvId,"pageIndex":pageIndex,"pageSize":10,"userId":UserModel.shared.id]
        case .myWallet(let type,let pageIndex)://我的镭秋钱包
            return ["action":"myWallet","type":type,"pageIndex":pageIndex,"pageSize":10,"userId":UserModel.shared.id]
        case .withdrawDeposit(let rautumnCurrency,let alipay,let  weChatAccount)://申请提现
            return ["action":"withdrawDeposit","rautumnCurrency":rautumnCurrency,"alipay":alipay,"weChatAccount":weChatAccount,"userId":UserModel.shared.id]
        case .placeAnOrder(let objId,let type,let payType)://镭秋币或者会员下单操作
            return ["action":"placeAnOrder","objId":objId,"type":type,"payType":payType,"userId":UserModel.shared.id]
        case .payDemoActivity(let subject,let body,let price,let out_trade_no,let type)://获取支付宝支付信息接口
            return ["action":"payDemoActivity","subject":subject,"body":body,"price":price,"out_trade_no":out_trade_no,"type":type]
        case .wxPayCreateOrder(let out_trade_no,let body,let total_fee,let type)://微信支付下单接口
            return ["action":"wxPayCreateOrder","out_trade_no":out_trade_no,"body":body,"total_fee":total_fee,"type":type]
        case .getVIPOrderSettingList(let type)://获取会员设置
            return ["action":"getVIPOrderSettingList","userId":UserModel.shared.id,"type":type]
        case .myRSV(let pageIndex)://我的视频
            return ["action":"myRSV","pageIndex":pageIndex,"pageSize":10,"userId":UserModel.shared.id]
        case .iJoinedTheActivity(let type,let pageIndex)://我参加的活动
            return ["action":"iJoinedTheActivity","pageIndex":pageIndex,"pageSize":10,"userId":UserModel.shared.id,"type":type]
        case .modifyPassword(let oldPwd,let newPwd)://修改密码
            return ["action":"modifyPassword","userId":UserModel.shared.id,"oldPwd":oldPwd.md5(),"newPwd":newPwd.md5()]
        case .openOrCloseDistance(let type)://打开或者关闭距离
            return ["action":"openOrCloseDistance","type":type,"userId":UserModel.shared.id]
        case .feedback(let content)://意见反馈
            return ["action":"feedback","content":content,"userId":UserModel.shared.id]
        case .publishRSV(let title,let coverPhotoUrl,let videoUrl,let position)://发布RSV
            return ["action":"publishRSV","title":title,"userId":UserModel.shared.id,"coverPhotoUrl":coverPhotoUrl,"videoUrl":videoUrl,"position":position]
        case .rsvPlayTimes(let rsvId)://累计播放次数
            return ["action":"rsvPlayTimes","rsvId":rsvId,"userId":UserModel.shared.id]
        case .uploadLocation(let longitude,let latitude)://上传用户位置
            return ["action":"uploadLocation","longitude":longitude,"latitude":latitude,"userId":UserModel.shared.id]
        case .deleteUserPhoto(let upId)://删除用户相册
            return ["action":"deleteUserPhoto","upIds":upId,"userId":UserModel.shared.id]
        case .editUserInfo(let param)://编辑用户资料
            return Mapper<EditUserInfoParam>().toJSON(param)
        case .chatroomQueryUser(let rsvId)://获取观看镭视宝LIVE用户信息
            return ["action":"chatroomQueryUser","rsvId":rsvId,"userId":UserModel.shared.id]
        case .getMyRautumnFriendsCircleList(let pageIndex)://我的文章
            return ["action":"getMyRautumnFriendsCircleList","pageIndex":pageIndex,"pageSize":10,"userId":UserModel.shared.id]
        case .blacklist(let receiveUserInfoId,let type)://拉黑或者取消拉黑
            return ["action":"blacklist","receiveUserInfoId":receiveUserInfoId,"type":type,"activeUserInfoId":UserModel.shared.id]
        case .complain(let appelleeUserInfoId,let reason)://举报投诉
            return ["action":"complain","appelleeUserInfoId":appelleeUserInfoId,"complUserInfoId":UserModel.shared.id,"reason":reason]
        case .getRauGroupUser(let groupId)://群成员
            return ["action":"getRauGroupUser","pageIndex":1,"pageSize":1000,"userId":UserModel.shared.id,"groupId":groupId]
        case .getPlatformProtocol://平台协议
            return ["action":"getPlatformProtocol","userId":UserModel.shared.id]
        case .deleteRGA(let rgId,let rgaIds)://删除群相册
            return ["action":"deleteRGA","userId":UserModel.shared.id,"rgId":rgId,"rgaIds":rgaIds]
        case .editGroup(let param)://修改群信息
            return Mapper<EditGroupParam>().toJSON(param)
        case .deleteRauGroupUser(let mainGroUserId,let rgId,let userIds)://删除群用户
            return ["action":"deleteRauGroupUser","rgId":rgId,"mainGroUserId":mainGroUserId,"userIds":userIds]
        case .deleteArticle(let rfcId)://删除我的文章
            return ["action":"deleteArticle","userId":UserModel.shared.id,"rfcId":rfcId]
        case .deleteMyRSV(let rsvIds)://删除镭视宝（我的视频）
            return ["action":"deleteMyRSV","userId":UserModel.shared.id,"rsvIds":rsvIds]
        case .theMain://本主
            return ["action":"theMain","userId":UserDefaults.standard.value(forKey: "userId") as! String]
        case .getPullTheBlack(let pageIndex)://获取拉黑列表
            return ["action":"getPullTheBlack","pageIndex":pageIndex,"pageSize":15,"userId":UserModel.shared.id]
        case .getGratuityRauCurr(let type,let pageIndex)://我的镭秋币记录
            return ["action":"getGratuityRauCurr","pageIndex":pageIndex,"pageSize":15,"userId":UserModel.shared.id,"type":type]
        case .rautumnCurrencyOrder(let out_trade_no,let trade_no,let total_fee)://应用内镭秋币购买
            return ["action":"rautumnCurrencyOrder","out_trade_no":out_trade_no,"trade_no":trade_no,"total_fee":total_fee]
        case .vipOrder(let out_trade_no,let trade_no,let total_fee)://应用内会员购买
            return ["action":"vipOrder","out_trade_no":out_trade_no,"trade_no":trade_no,"total_fee":total_fee]
        case .exitActivity(let raId)://退出活动
            return ["action":"exitActivity","userId":UserModel.shared.id,"raId":raId]
         
        case .deleteGratuityRau(let recordId): // 删除打赏
            return ["action":"delGratuityRauCurr","gratuityRauCurrRecordId":recordId,"isShow":0]
        case .getMyFriendsCircleList(let friendUid, let pageIndex):
            return  ["action":"getMyRautumnFriendsCircleList","pageIndex":pageIndex,"pageSize":10,"my_userId":UserModel.shared.id,"userId":friendUid]
        case .applyJoinGroup(let beAddGroupId, let msg):
            return ["action":"applyJoinGroup","activeUserInfoId":UserModel.shared.id,"beAddGroupId":beAddGroupId,"msg":msg]
        case .delApplyJoinGroup(let applyJoinGroupId):
            return ["action":"delApplyJoinGroup","applyJoinGroupId":applyJoinGroupId]
            
        case .getApplyJoinGroup():
            return ["action":"getApplyJoinGroup","userId":UserModel.shared.id]
            
        case .agrredJoinGroup(let userId, let rgId):
            return ["action":"joinOutRauGroup","rgId":rgId,"type":1,"userId":userId]
            
        case .getAppImg():
            return ["action":"getAppImg"]
        }
    }
}
