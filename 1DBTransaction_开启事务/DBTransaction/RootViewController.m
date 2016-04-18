//
//  RootViewController.m
//  DBTransaction
//
//  Created by  LZXuan on 14-8-26.
//  Copyright (c) 2014年  LZXuan. All rights reserved.
//

#import "RootViewController.h"
#import "FMDatabase.h"

@interface RootViewController ()
{
    FMDatabase *_dataBase;
}
@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *dbPath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/test.db"];
    //初始化
    _dataBase = [[FMDatabase alloc] initWithPath:dbPath];
    if ([_dataBase open]) {
       //创建表
        NSString *createSql = @"create table if not exists student(id integer,name varchar(256))";
        if (![_dataBase executeUpdate:createSql]) {
            NSLog(@"create error:%@",_dataBase.lastErrorMessage);
        }
    }
    //NSDate 时间类
    NSDate *date1 = [NSDate date];//获取系统当前时间
    [self insertDataWithCount:1000 isUseTransaction:NO];
    NSDate *date2 = [NSDate date];
    //取到时间的差值  (timeIntervalSinceDate 两个时间的差值，单位是秒)
    //NSTimeInterval 时间差变量，秒
    NSTimeInterval time = [date2 timeIntervalSinceDate:date1];
    NSLog(@"time:%f",time);
    
	// Do any additional setup after loading the view.
}
//插入批量数据，是否手动启用事务
- (void)insertDataWithCount:(NSInteger)count isUseTransaction:(BOOL)isUse{
    if (isUse) {
        //手动启用事务
        BOOL isError = NO;
        
        @try {
         //写可能出现异常的代码
            [_dataBase beginTransaction];//手动开启一个事务
            for (int i=0; i<count; i++) {
                NSString *idStr =[NSString stringWithFormat:@"%d",i];
                NSString *stName = [NSString stringWithFormat:@"student%d",i];
                NSString *insertSql = @"insert into student(id,name) values(?,?)";
                if (![_dataBase executeUpdate:insertSql,idStr,stName]) {
                    NSLog(@"insert error:%@",_dataBase.lastErrorMessage);
                }
            }
        }
        @catch (NSException *exception) {
          //捕获到异常
            NSLog(@"error:%@",exception.reason);
            isError = YES;
            [_dataBase rollback];//回滚，回到最初的状态
        }
        @finally {
           //无论有没有异常，代码都会执行到此处
            if (isError==NO) {
                [_dataBase commit];//提交事务，让批量操作生效
            }
        }
        
    }else{
       //常规操作
        for (int i=0; i<count; i++) {
            NSString *idStr =[NSString stringWithFormat:@"%d",i];
            NSString *stName = [NSString stringWithFormat:@"student%d",i];
            NSString *insertSql = @"insert into student(id,name) values(?,?)";
            if (![_dataBase executeUpdate:insertSql,idStr,stName]) {
                NSLog(@"insert error:%@",_dataBase.lastErrorMessage);
            }
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
