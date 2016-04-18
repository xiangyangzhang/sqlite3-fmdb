//
//  Student.m
//  C_SqliteDemo
//
//  Created by LZXuan on 15-4-18.
//  Copyright (c) 2015年 LZXuan. All rights reserved.
//

#import "Student.h"

@implementation Student
//描述
- (NSString *)description {
    return [NSString stringWithFormat:@"name: %@  age: %d  imageSize: %ld", self.name, self.age, [UIImageJPEGRepresentation(self.image, 1.0) length]];
}
@end
