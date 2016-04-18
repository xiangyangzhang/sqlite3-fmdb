//
//  DataBaseManager.h
//  FMDBDemo2
//
//  Created by lzxuan on 15/9/28.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StudentModel.h"

/*
 数据库 很多界面 都有可能 进行访问，这时我们需要把数据库管理 设计成一个单例(单例就是一个类 只有一个实例对象，对象的数据在整个程序 中 所有文件 共享的，类似于全局变量 )--》20个俯卧撑
 //sql语句 一条 10个
 */
@interface DataBaseManager : NSObject
//非标准单例 类方法 + defaultXXX + sharedXXX + instanceXXX
+ (instancetype)defaultManager;

#pragma mark - 增加
//把一个model 的数据增加到数据库
- (void)insertDataWithModel:(StudentModel *)model;

//连续增加 多个model数据 向数据库
- (void)insertDataWithArray:(NSArray *)arr isBeginTransaction:(BOOL)isBegine;


#pragma mark - 删除
/**
 *  删除数据
 *
 *  @param uid 学生的id
 */
- (void)deleteDataWithUid:(NSString *)uid;

#pragma mark - 修改
- (void)updateDataWithUid:(NSString *)uid newModel:(StudentModel *)newModel;

#pragma mark - 查找
- (NSArray *)fetchAllData;

#pragma mark - 查询有多少条记录

- (NSInteger)countOfData;

@end










