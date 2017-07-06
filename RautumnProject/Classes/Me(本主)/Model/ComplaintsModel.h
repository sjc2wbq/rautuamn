//
//  ComplaintsModel.h
//  AiChuXing
//
//  Created by Raychen on 16/6/13.
//  Copyright © 2016年 hao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ComplaintsModel : NSObject
@property(nonatomic,copy) NSString  *title;
@property(nonatomic,assign,getter=isCheck) BOOL check;
+ (NSArray *)dataSource;
@end
