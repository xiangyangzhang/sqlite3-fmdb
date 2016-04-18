//
//  SqliteManager.h
//  C_SqliteDemo
//
//  Created by LZXuan on 15-4-18.
//  Copyright (c) 2015年 LZXuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Student.h"

/*
 对底层 的C语言 sqlite 进行封装 
 
 对数据库分别进行 增删改查
 
 */


@interface SqliteManager : NSObject
+ (SqliteManager *)sharedManager;

// 注：删，改，基于名字
- (BOOL)add:(Student *)student;
- (BOOL)delete:(Student *)student;
- (BOOL)deleteByName:(NSString *)name;
- (BOOL)update:(Student *)student;
- (NSMutableArray *)fetchAll;

- (BOOL)isExists:(Student *)student;
- (BOOL)isExistByName:(NSString *)name;
@end
