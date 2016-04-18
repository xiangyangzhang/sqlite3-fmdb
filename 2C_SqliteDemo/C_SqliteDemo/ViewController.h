//
//  ViewController.h
//  C_SqliteDemo
//
//  Created by LZXuan on 15-4-18.
//  Copyright (c) 2015年 LZXuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *name;

@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *fetchButton;
- (IBAction)addClick:(UIButton *)sender;
- (IBAction)deleteClick:(UIButton *)sender;
- (IBAction)updateClick:(UIButton *)sender;
- (IBAction)fetchClick:(UIButton *)sender;
- (IBAction)chooseImage:(UITapGestureRecognizer *)sender;

@end

