//
//  DataBaseManager.m
//  FMDBDemo2
//
//  Created by lzxuan on 15/9/28.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import "DataBaseManager.h"
//使用 cocoapods 之后 sqlite2.dylib系统库 不用再倒入
#import <FMDB.h>
/*
 1.创建数据库（open）
 2.创建表(不存在则创建)
 3.增删改查
 */


@implementation DataBaseManager
{
    FMDatabase *_database;
}
//非标准单例 类方法 + defaultXXX + sharedXXX + instanceXXX
//
+ (instancetype)defaultManager {
    static DataBaseManager * manager = nil;
    @synchronized(self) {//使线程同步(阻塞线程)--》线程安全
        if (manager == nil) {
            manager = [[self alloc] init];
        }
    }
    return manager;
}
//单例初始化 的时候 就应该有 数据库了
- (instancetype)init {
    if (self = [super init]) {
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        //创建 数据库路径
        NSString *dataPath = [docPath stringByAppendingPathComponent:@"student.sqlite"];
        //创建database
        _database = [[FMDatabase alloc] initWithPath:dataPath];
        /*形式
         1.打开数据库 单例创建的时候 就把数据库打开 ，一直打开 不关闭 这样写效率高
         2.或者 每次进行增删改之前 先打开 操作之后 再关闭
         */
        //打开数据库 打开的时候没有 会创建
        if (![_database open]) {
            //失败
            NSLog(@"open error:%@",_database.lastErrorMessage);
        }else {
            //成功 创建表
            [self createTable];
        }
    }
    return self;
}
#pragma mark - 创建表
- (void)createTable {
    //创建表 里面的字段 名字 和model  的属性名 对应
    NSString *sql = @"CREATE TABLE IF NOT EXISTS stu (serial integer  Primary Key Autoincrement,uid Varchar(256) DEFAULT NULL, name Varchar(256),score Double,headimage blob)";
    if (![_database executeUpdate:sql]) {
        NSLog(@"create table error:%@",_database.lastErrorMessage);
    }
}
#pragma mark - 增加
//把一个model 的数据增加到数据库
- (void)insertDataWithModel:(StudentModel *)model {
    
    if ([self isExistDataWithUid:model.uid]) {
        NSLog(@"该记录 已经 增加");
        return;
    }
    
    NSString *sql = @"insert into stu(uid,name,score,headimage) values (?,?,?,?)";
    if (![_database executeUpdate:sql,model.uid,model.name,@(model.score),model.headimage]) {
        NSLog(@"insert error:%@",_database.lastErrorMessage);
    }
}
/**
 *  增加多个 model
 *
 *  @param arr      model 数组
 *  @param isBegine 是否开启数据库事务
 */
/*
    数据库插入数据操作 就是 文件io操作(读写磁盘) ，读写磁盘过程  是一个耗时过程，当我们 连续 增加 多条数据的时候，会影响数据库的写操作(比较慢)如果要想提高写效率那么 我们 可以开始数据库事务,开启事务之后 增加多条数据的时候不会立即写入数据库磁盘而是先把数据放在内容，等提交事务的一起 写一次 磁盘
 */
- (void)insertDataWithArray:(NSArray *)arr isBeginTransaction:(BOOL)isBegine {
    BOOL isError = NO;
    if (isBegine) {
        @try {
            //把可能会 发送异常的代码 写在这里
            //连续向内存增加多条数据 可能会发生异常
            
            //开启事务
            [_database beginTransaction];
            //开启事务之后 下面的插入操作不会立即写磁盘
            for (StudentModel *model in arr) {
                //增加一条数据
                [self insertDataWithModel:model];
            }
        }
        @catch (NSException *exception) {
            //上面的代码 有异常了 才会 调用这里
            //这里的功能就是 捕获上面异常
            isError = YES;
            //数据库 要回滚 回滚到 插入之前的初始状态
            [_database rollback];
        }
        @finally {
            //不管 有么有 异常这里都会 执行
            if (isError == NO) {
                //没有异常的时候
                [_database commit];//提交事务  写磁盘
            }
        }
        
    }else {
        //不开启事务 插入一次 写一次 磁盘
        for (StudentModel *model in arr) {
            //增加一条数据
            [self insertDataWithModel:model];
        }
    }
}

#pragma mark - 删除
/**
 *  删除数据
 *
 *  @param uid 学生的id
 */
- (void)deleteDataWithUid:(NSString *)uid {
    NSString *sql = @"delete from stu where uid=?";
    if (![_database executeUpdate:sql,uid]) {
        NSLog(@"delete error:%@",_database.lastErrorMessage);
    }
}

#pragma mark - 修改
- (void)updateDataWithUid:(NSString *)uid newModel:(StudentModel *)newModel {
    NSString *sql = @"update stu set name=?,score=?,headimage=? where uid=?";
    if (![_database executeUpdate:sql,newModel.name,@(newModel.score),newModel.headimage,uid]) {
        NSLog(@"update error:%@",_database.lastErrorMessage);
    }
}

#pragma mark - 根据uid 查找存在不存在

- (BOOL)isExistDataWithUid:(NSString *)uid {
    //根据条件查找
    NSString *sql = @"select * from stu where uid=?";
    FMResultSet *rs = [_database executeQuery:sql,uid];
    
    if ([rs next]) {//如果 有记录 直接返回yes
        return YES;
    }
    return NO;
}

#pragma mark - 查找
- (NSArray *)fetchAllData {
    NSString *sql = @"select * from stu";
    FMResultSet *rs = [_database executeQuery:sql];
    //存放查询结果
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    while ([rs next]) {
        //遍历一次 找到一条记录 要保存到 model
        StudentModel *model = [[StudentModel alloc] init];
        model.uid = [rs stringForColumn:@"uid"];
        model.name = [rs stringForColumn:@"name"];
        model.score = [rs doubleForColumn:@"score"];
        model.headimage = [rs dataForColumn:@"headimage"];
        
        //增加到数组
        [arr addObject:model];
    }
    return arr ;
}

#pragma mark - 查询有多少条记录

- (NSInteger)countOfData {
    //查询有多少记录
    NSString *sql = @"select count(*) from stu";
    //查询 记录条数 结果集合 就一个数据
    FMResultSet *rs = [_database executeQuery:sql];
    while ([rs next]) {
        //这个 集合就一个元素 遍历一次
        return [rs longForColumnIndex:0];
    }
    return 0;
}
@end





