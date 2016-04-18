//
//  SqliteManager.m
//  C_SqliteDemo
//
//  Created by LZXuan on 15-4-18.
//  Copyright (c) 2015年 LZXuan. All rights reserved.
//

#import "SqliteManager.h"
#import <sqlite3.h>

@interface SqliteManager ()

@property (nonatomic) sqlite3 *database;
@end

@implementation SqliteManager

//创建 单例
+ (SqliteManager *)sharedManager {
    static SqliteManager *manager = nil;
    @synchronized (self) {
        if (manager == nil) {
            manager = [[self alloc] init];
        }
    }
    return manager;
}

- (id)init {
    self = [super init];
    if (self) {
        //打开数据库
        if ([self openDB]) {
            //成功
            //创建表
            [self createTable];
        }
    }
    
    return self;
}

- (NSString *)databasePath {
    //获取数据库路径
    NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"student_list.db"];
    NSLog(@"dbPath: %@", dbPath);
    return dbPath;
}

- (BOOL)openDB {
    //打开数据库  1.第一个参数 C语言格式的字符串
    //打开的时候 如果没有文件会创建
    if (sqlite3_open([self databasePath].UTF8String, &_database) == SQLITE_OK) {
        return YES;
    }
    return NO;
}

- (BOOL)closeDB {
    //关闭数据库
    if (sqlite3_close(self.database) == SQLITE_OK) {
        return YES;
    }
    return NO;
}

- (BOOL)createTable {
    const char *createSql = "create table if not exists student_list(name varchar(128), age integer, image blob)";
    //执行
    if (sqlite3_exec(_database, createSql, NULL, NULL, NULL) == SQLITE_OK) {
        return YES;
    } else {
        return NO;
    }
}

// 增
- (BOOL)add:(Student *)student {
    [self openDB];
    NSString *insertStr = @"insert into student_list(name, age, image) values(?,?,?)";
    const char *insertSql = [insertStr UTF8String];
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, insertSql, -1, &stmt, 0) != SQLITE_OK) {
        NSLog(@"%s", __func__);
        NSLog(@"Could not prepare this statement")                                                              ;
        [self closeDB];
        return NO;
    }
    
    // SQLITE_API int sqlite3_bind_text(sqlite3_stmt*, int, const char*, int n, void(*)(void*));
    sqlite3_bind_text(stmt, 1, [student.name UTF8String], -1, SQLITE_COPY);
    sqlite3_bind_int(stmt, 2, student.age);
    NSData *imageData = UIImageJPEGRepresentation(student.image, 1.0);
    
    sqlite3_bind_blob(stmt, 3, [UIImageJPEGRepresentation(student.image, 1.0) bytes], (int)[imageData length], SQLITE_TRANSIENT);
    if (sqlite3_step(stmt) == SQLITE_DONE) {
        sqlite3_finalize(stmt);
        return YES;
    } else {
        sqlite3_finalize(stmt);
        return NO;
    }
}

// 删
- (BOOL)delete:(Student *)student {
    return [self deleteByName:student.name];
}

- (BOOL)deleteByName:(NSString *)name {
    [self openDB];
    
#if 0 // 不用stmt方法
    NSString *deleteStr = [NSString stringWithFormat:@"delete from student_list where name='%@'", name];
    const char *deleteSql = [deleteStr UTF8String];
    if (sqlite3_exec(_database, deleteSql, NULL, NULL, NULL) == SQLITE_OK) {
        [self closeDB];
        return YES;
    }
    
    [self closeDB];
    return NO;
    
#elif 1
    // NSString *deleteStr = [NSString stringWithFormat:@"delete from student_list where name=?"];
    // const char *deleteSql = [deleteStr UTF8String];
    const char *deleteSql = "delete from student_list where name=?";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, deleteSql, -1, &stmt, 0) != SQLITE_OK) {
        NSLog(@"%s", __func__);
        NSLog(@"Could not prepare this statement");
        return NO;
    }
    sqlite3_bind_text(stmt, 1, [name UTF8String], -1, NULL);
    if (sqlite3_step(stmt) == SQLITE_DONE) {
        sqlite3_finalize(stmt);
        [self closeDB];
        return YES;
    }
    
    sqlite3_finalize(stmt);
    [self closeDB];
    return NO;
#endif
}

// 改
- (BOOL)update:(Student *)student {
    [self openDB];
#if 1
    NSString *updateStr = [NSString stringWithFormat:@"update student_list set age=%d where name='%@'", student.age, student.name];
    const char *updateSql = [updateStr UTF8String];
    int ret = sqlite3_exec(_database, updateSql, NULL, NULL, NULL);
    if (ret == SQLITE_OK) {
        [self closeDB];
        return YES;
    }
    
    [self closeDB];
    return NO;
#elif 1
    const char *updateSql = "update student_list set age=? where name=?";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare(_database, updateSql, -1, &stmt, 0) != SQLITE_OK) {
        NSLog(@"%s", __func__);
        NSLog(@"Could not prepare for this statement");
        [self closeDB];
        return NO;
    }
    sqlite3_bind_int(stmt, 1, student.age);
    sqlite3_bind_text(stmt, 2, [student.name UTF8String], -1, SQLITE_TRANSIENT);
    if (sqlite3_step(stmt) == SQLITE_DONE) {
        [self closeDB];
        return YES;
    }
    [self closeDB];
    return NO;
#endif
}

// 查
- (NSMutableArray *)fetchAll {
    [self openDB];
    NSMutableArray *array = [NSMutableArray array];
    const char *selectSql = "select * from student_list";
    sqlite3_stmt *stmt = NULL;
    if (sqlite3_prepare_v2(_database, selectSql, -1, &stmt, 0) != SQLITE_OK) {
        NSLog(@"%s", __func__);
        NSLog(@"Could not prepare for this statement");
        sqlite3_finalize(stmt);
        [self closeDB];
        return nil;
    }
    
    while (sqlite3_step(stmt) == SQLITE_ROW) {
        Student *student = [[Student alloc] init];
        student.name = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
        student.age = sqlite3_column_int(stmt, 1);
        
        const void *imageBytes = sqlite3_column_blob(stmt, 2);
        int imageLength = sqlite3_column_bytes(stmt, 2);
        NSData *imageData = [[NSData alloc] initWithBytes:imageBytes length:imageLength];
        student.image = [UIImage imageWithData:imageData];
        
        [array addObject:student];
    }
    
    sqlite3_finalize(stmt);
    [self closeDB];
    
    return array;
}

- (BOOL)isExists:(Student *)student {
    return [self isExistByName:student.name];
}

- (BOOL)isExistByName:(NSString *)name {
    [self openDB];
    const char *existSql = "select * from student_list where name=?";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(_database, existSql, -1, &stmt, 0) != SQLITE_OK) {
        NSLog(@"%s", __func__);
        NSLog(@"Could not prepare for this statement");
        [self closeDB];
    }
    
    sqlite3_bind_text(stmt, 1, [name UTF8String], -1, NULL);
    if (sqlite3_step(stmt) == SQLITE_DONE) {
        [self closeDB];
        return YES;
    }
    
    [self closeDB];
    return NO;
}

#pragma mark - dealloc
- (void)dealloc {
    // sqlite3_finalize(stmt);
    [self closeDB];
}

@end
