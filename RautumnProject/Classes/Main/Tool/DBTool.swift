
//
//  DBTool.swift
//  RautumnProject
//
//  Created by 陈雷 on 2017/2/20.
//  Copyright © 2017年 Rautumn. All rights reserved.
//

import UIKit
import FMDB
import SDWebImage
import ARSLineProgress
import ObjectMapper
class DBTool: NSObject {
    
    let db:FMDatabase = {
        let path = (NSHomeDirectory() as NSString ).appendingPathComponent("Documents/data.sqlite")
        let db = FMDatabase(path: path)
        db?.open()
        db?.executeStatements("CREATE TABLE IF NOT EXISTS t_addressBook(id integer PRIMARY KEY AUTOINCREMENT,userId integer NOT NULL,addressBook blob NOT NULL);")
        
        db?.executeStatements("CREATE TABLE IF NOT EXISTS t_radiumFriendsCircle(id integer PRIMARY KEY AUTOINCREMENT,userId integer NOT NULL,type text NOT NULL,radiumFriendsCircle blob NOT NULL);")

        db?.executeStatements("CREATE TABLE IF NOT EXISTS t_systemMessage(id integer PRIMARY KEY AUTOINCREMENT,userId integer NOT NULL,systemMessage blob NOT NULL);")
        
        db?.executeStatements("CREATE TABLE IF NOT EXISTS t_userModel(id integer PRIMARY KEY AUTOINCREMENT,userId integer NOT NULL,userModel blob NOT NULL);")

        db?.executeStatements("CREATE TABLE IF NOT EXISTS t_newFriend(id integer PRIMARY KEY AUTOINCREMENT,userId integer NOT NULL,newFriend blob NOT NULL);")
        
        db?.executeStatements("CREATE TABLE IF NOT EXISTS t_nearFriend(id integer PRIMARY KEY AUTOINCREMENT,userId integer NOT NULL,nearFriend blob NOT NULL);")

        db?.executeStatements("CREATE TABLE IF NOT EXISTS t_nearActivity(id integer PRIMARY KEY AUTOINCREMENT,userId integer NOT NULL,nearActivity blob NOT NULL);")

        db?.executeStatements("CREATE TABLE IF NOT EXISTS t_nearGroup(id integer PRIMARY KEY AUTOINCREMENT,userId integer NOT NULL,nearGroup blob NOT NULL);")

        db?.executeStatements("CREATE TABLE IF NOT EXISTS t_nearOpinionPolls(id integer PRIMARY KEY AUTOINCREMENT,userId integer NOT NULL,nearOpinionPolls blob NOT NULL);")
        
        db?.executeStatements("CREATE TABLE IF NOT EXISTS t_rsv(id integer PRIMARY KEY AUTOINCREMENT,userId integer NOT NULL,type text NOT NULL,rsv blob NOT NULL);")

        db?.executeStatements("CREATE TABLE IF NOT EXISTS t_live(id integer PRIMARY KEY AUTOINCREMENT,userId integer NOT NULL,live blob NOT NULL);")

        return db!
    }()
    
    
    static let  shared = DBTool()
    
    public  func clearDisk(completioned:@escaping (() -> ())){
        completioned()
    }
    
    public func saveAddressBook(dict: [String:Any])  {
            if let json = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted){
                if addressBook() != nil{
                    db.executeUpdate("update t_addressBook set userId  = (?) and addressBook = (?);", withArgumentsIn:[UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: json)])
                }else{
                    db.executeUpdate("INSERT INTO t_addressBook(userId,addressBook) VALUES (?,?);", withArgumentsIn: [UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: json)])
                }
            }
    }
    public func addressBook() -> [String:Any]? {
        var dict:[String:Any]?
        let set = db.executeQuery("SELECT * FROM t_addressBook where userId = \(UserModel.shared.id);", withArgumentsIn: nil)
        if set!.next(){
//            NSKeyedUnarchiver.unarchiveObject(with: set!.data(forColumn: "addressBook")) 
            if  let data = NSKeyedUnarchiver.unarchiveObject(with: set!.data(forColumn: "addressBook")) as? Data{
              dict =  try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
            }
        }
        return dict
    }
  
    ///系统消息
    func addSysTemMessage(message:SystemMessage) {
        db.executeUpdate("INSERT INTO t_systemMessage(userId,systemMessage) VALUES (?,?);", withArgumentsIn: [UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: message)])
    }
    func sysTemMessages() -> [SystemMessage]? {
        var messages = [SystemMessage]()
        let set = db.executeQuery("SELECT systemMessage FROM t_systemMessage where userId = (?) order by id desc;", withArgumentsIn: [UserModel.shared.id])
        while set!.next(){
            let message  = NSKeyedUnarchiver.unarchiveObject(with: (set?.data(forColumn: "systemMessage"))!) as? SystemMessage
             messages.append(message!)
        }
        return messages
    }
    func removeAllSysTemMessages() {
        db.executeUpdate("DELETE FROM t_systemMessage;", withArgumentsIn:nil)
    }
    
    ///镭友圈
    func saveRadiumFriendsCircle(dict:[String:Any],type:Int) {
        if radiumFriendsCircle(type:type) != nil{
            db.executeUpdate("update t_radiumFriendsCircle set userId  = (?) and radiumFriendsCircle = (?) and type = (?);", withArgumentsIn:[UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: dict),"\(type)"])
        }else{
            db.executeUpdate("INSERT INTO t_radiumFriendsCircle(userId,type,radiumFriendsCircle) VALUES (?,?,?);", withArgumentsIn: [UserModel.shared.id,"\(type)",NSKeyedArchiver.archivedData(withRootObject: dict)])
        }
    }
    func radiumFriendsCircle(type:Int) -> [String:Any]? {
        var dict:[String:Any]?
        let set = db.executeQuery("SELECT * FROM t_radiumFriendsCircle where userId = (?) and type = (?);", withArgumentsIn: [UserModel.shared.id,"\(type)"])
        while set!.next(){
            dict =  NSKeyedUnarchiver.unarchiveObject(with: set!.data(forColumn: "radiumFriendsCircle")) as? [String : Any]
        }
        return dict
    }

    ///用户信息
    func saveUserModel(){
        if userModel() != nil{
            db.executeUpdate("update t_userModel set userId  = (?) and userModel = (?);", withArgumentsIn:[UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<UserModel>().toJSON(UserModel.shared))])
        }else{
            db.executeUpdate("INSERT INTO t_userModel(userId,userModel) VALUES (?,?);", withArgumentsIn: [UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<UserModel>().toJSON(UserModel.shared))])
        }
    }
    func removeUserModel(){
        db.executeUpdate("DELETE FROM t_userModel;", withArgumentsIn:nil)
    }
    
    func userModel() -> UserModel? {
        var userModel:UserModel?
        let set = db.executeQuery("SELECT * FROM t_userModel where userId = \(UserModel.shared.id);", withArgumentsIn: nil)
        if set!.next(){
            if  let json = NSKeyedUnarchiver.unarchiveObject(with: set!.data(forColumn: "userModel")) as? [String:Any]{
                userModel =  Mapper<UserModel>().map(JSON: json)
            }
        }
        return userModel;
    }
    //新的朋友
    func saveNewFriend(newFriendModel:NewFriendModel)  {
        if newFriend() != nil{
            db.executeUpdate("update t_newFriend set userId  = (?) and newFriend = (?);", withArgumentsIn:[UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<NewFriendModel>().toJSON(newFriendModel))])
        }else{
            db.executeUpdate("INSERT INTO t_newFriend(userId,newFriend) VALUES (?,?);", withArgumentsIn: [UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<NewFriendModel>().toJSON(newFriendModel))])
        }
    }
    func newFriend() -> NewFriendModel? {
        var newFriendModel:NewFriendModel?
        let set = db.executeQuery("SELECT * FROM t_newFriend where userId = \(UserModel.shared.id);", withArgumentsIn: nil)
        if set!.next(){
            if  let json = NSKeyedUnarchiver.unarchiveObject(with: set!.data(forColumn: "newFriend")) as? [String:Any]{
                newFriendModel =  Mapper<NewFriendModel>().map(JSON: json)
            }
        }
        return newFriendModel;
    }
    
    // 新的加群申请
    func saveNewGroup(groupModel:ApplyGroupModel) {
        if newGroup() != nil{
            db.executeUpdate("update t_newGroup set userId  = (?) and group = (?);", withArgumentsIn:[UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<ApplyGroupModel>().toJSON(groupModel))])
        }else{
            db.executeUpdate("INSERT INTO t_newGroup(userId,group) VALUES (?,?);", withArgumentsIn: [UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<ApplyGroupModel>().toJSON(groupModel))])
        }
    }
    
    func newGroup() -> ApplyGroupModel? {
        var newGroup:ApplyGroupModel?
        let set = db.executeQuery("SELECT * FROM t_newFriend where userId = \(UserModel.shared.id);", withArgumentsIn: nil)
        if set!.next(){
            if  let json = NSKeyedUnarchiver.unarchiveObject(with: set!.data(forColumn: "newGroup")) as? [String:Any]{
                newGroup =  Mapper<ApplyGroupModel>().map(JSON: json)
            }
        }
        return newGroup;
    }
    
    //附近镭友
    func saveNearFriend(friend :NearbyRauFriendModel)  {
       
        if nearFriend() != nil{
            db.executeUpdate("update t_nearFriend set userId  = (?) and nearFriend = (?);", withArgumentsIn:[UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<NearbyRauFriendModel>().toJSON(friend))])
        }else{
            db.executeUpdate("INSERT INTO t_nearFriend(userId,nearFriend) VALUES (?,?);", withArgumentsIn: [UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<NearbyRauFriendModel>().toJSON(friend))])
        }
        
    }
    func nearFriend() -> NearbyRauFriendModel? {
        var model:NearbyRauFriendModel?
        let set = db.executeQuery("SELECT * FROM t_nearFriend where userId = \(UserModel.shared.id);", withArgumentsIn: nil)
        if set!.next(){
            if  let json = NSKeyedUnarchiver.unarchiveObject(with: set!.data(forColumn: "nearFriend")) as? [String:Any]{
                model =  Mapper<NearbyRauFriendModel>().map(JSON: json)
            }
        }
        return model
    }
    
    //附近活动
    func saveNearActivity(activity :NearbyActivityModel)  {
        if nearActivity() != nil{
            db.executeUpdate("update t_nearActivity set userId  = (?) and nearActivity = (?);", withArgumentsIn:[UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<NearbyActivityModel>().toJSON(activity))])
        }else{
            db.executeUpdate("INSERT INTO t_nearActivity(userId,nearActivity) VALUES (?,?);", withArgumentsIn: [UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<NearbyActivityModel>().toJSON(activity))])
        }
    }
    func nearActivity() -> NearbyActivityModel? {
        var model:NearbyActivityModel?
        let set = db.executeQuery("SELECT * FROM t_nearActivity where userId = \(UserModel.shared.id);", withArgumentsIn: nil)
        if set!.next(){
            if  let json = NSKeyedUnarchiver.unarchiveObject(with: set!.data(forColumn: "nearActivity")) as? [String:Any]{
                model =  Mapper<NearbyActivityModel>().map(JSON: json)
            }
        }
        return model
    }
    
    //附近群组
    func saveNearGroup(group :NearbyGroupModel)  {
        if nearGroup() != nil{
            db.executeUpdate("update t_nearGroup set userId  = (?) and nearGroup = (?);", withArgumentsIn:[UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<NearbyGroupModel>().toJSON(group))])
        }else{
            db.executeUpdate("INSERT INTO t_nearGroup(userId,nearGroup) VALUES (?,?);", withArgumentsIn: [UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<NearbyGroupModel>().toJSON(group))])
        }
        
    }
    func nearGroup() -> NearbyGroupModel? {
        var model:NearbyGroupModel?
        let set = db.executeQuery("SELECT * FROM t_nearGroup where userId = \(UserModel.shared.id);", withArgumentsIn: nil)
        if set!.next(){
            if  let json = NSKeyedUnarchiver.unarchiveObject(with: set!.data(forColumn: "nearGroup")) as? [String:Any]{
                model =  Mapper<NearbyGroupModel>().map(JSON: json)
            }
        }
        return model
    }
    
    //镭秋民调
    func saveNearOpinionPolls(model :RauFriCivilMediationModel)  {
        if nearOpinionPolls() != nil{
            db.executeUpdate("update t_nearOpinionPolls set userId  = (?) and nearOpinionPolls = (?);", withArgumentsIn:[UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<RauFriCivilMediationModel>().toJSON(model))])
        }else{
            db.executeUpdate("INSERT INTO t_nearOpinionPolls(userId,nearOpinionPolls) VALUES (?,?);", withArgumentsIn: [UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<RauFriCivilMediationModel>().toJSON(model))])
        }
    }
    func nearOpinionPolls() -> RauFriCivilMediationModel? {
        var model:RauFriCivilMediationModel?
        let set = db.executeQuery("SELECT * FROM t_nearOpinionPolls where userId = \(UserModel.shared.id);", withArgumentsIn: nil)
        if set!.next(){
            if  let json = NSKeyedUnarchiver.unarchiveObject(with: set!.data(forColumn: "nearOpinionPolls")) as? [String:Any]{
                model =  Mapper<RauFriCivilMediationModel>().map(JSON: json)
            }
        }
        return model
    }
    
    //RSV
    func saveRSV(model:RvUsefulModel,type:Int) {
        if rav(type:type) != nil{
            db.executeUpdate("update t_rsv set userId  = (?) and rsv = (?) and type = (?);", withArgumentsIn:[UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<RvUsefulModel>().toJSON(model)),"\(type)"])
        }else{
            db.executeUpdate("INSERT INTO t_rsv(userId,rsv,type) VALUES (?,?,?);", withArgumentsIn: [UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<RvUsefulModel>().toJSON(model)),"\(type)"])
        }
    }
    func rav(type:Int) -> RvUsefulModel? {
        var model:RvUsefulModel?
        let set = db.executeQuery("SELECT * FROM t_rsv where userId = \(UserModel.shared.id) and type = \(type);", withArgumentsIn: nil)
        if set!.next(){
            if  let json = NSKeyedUnarchiver.unarchiveObject(with: set!.data(forColumn: "rsv")) as? [String:Any]{
                model =  Mapper<RvUsefulModel>().map(JSON: json)
            }
        }
        return model
    }
    //LIVE
    func saveLIVE(model:RvUsefulModel)  {
        if live() != nil{
            db.executeUpdate("update t_live set userId  = (?) and live = (?);", withArgumentsIn:[UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<RvUsefulModel>().toJSON(model))])
        }else{
            db.executeUpdate("INSERT INTO t_live(userId,live) VALUES (?,?);", withArgumentsIn: [UserModel.shared.id,NSKeyedArchiver.archivedData(withRootObject: Mapper<RvUsefulModel>().toJSON(model))])
        }
    }
    
    func live() -> RvUsefulModel? {
        var model:RvUsefulModel?
        let set = db.executeQuery("SELECT * FROM t_live where userId = \(UserModel.shared.id);", withArgumentsIn: nil)
        if set!.next(){
            if  let json = NSKeyedUnarchiver.unarchiveObject(with: set!.data(forColumn: "live")) as? [String:Any]{
                model =  Mapper<RvUsefulModel>().map(JSON: json)
            }
        }
        return model

    }
    func clearCache() {
        ARSLineProgress.show()
        db.executeUpdate("DELETE FROM t_nearActivity;", withArgumentsIn:nil)
        db.executeUpdate("DELETE FROM t_radiumFriendsCircle;", withArgumentsIn:nil)
        db.executeUpdate("DELETE FROM t_nearFriend;", withArgumentsIn:nil)
        db.executeUpdate("DELETE FROM t_nearActivity;", withArgumentsIn:nil)
        db.executeUpdate("DELETE FROM t_nearGroup;", withArgumentsIn:nil)
        db.executeUpdate("DELETE FROM t_nearOpinionPolls;", withArgumentsIn:nil)
        db.executeUpdate("DELETE FROM t_rsv;", withArgumentsIn:nil)
        db.executeUpdate("DELETE FROM t_live;", withArgumentsIn:nil)
        SDImageCache.shared().clearDisk()
        SDImageCache.shared().clearMemory()
       let s =  RCIMClient.shared().clearConversations([RCConversationType.ConversationType_PRIVATE,RCConversationType.ConversationType_GROUP,RCConversationType.ConversationType_SYSTEM])
        ARSLineProgress.showSuccess()
    }
}
