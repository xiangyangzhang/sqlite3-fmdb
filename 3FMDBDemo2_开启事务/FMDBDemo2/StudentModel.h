//
//  StudentModel.h
//  FMDBDemo2
//
//  Created by lzxuan on 15/9/28.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StudentModel : NSObject
//uid
@property (nonatomic,copy) NSString *uid;
//名字
@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) double score;
//头像二进制
@property (nonatomic,strong) NSData *headimage;
@end
