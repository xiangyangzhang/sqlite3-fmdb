//
//  ViewController.m
//  C_SqliteDemo
//
//  Created by LZXuan on 15-4-18.
//  Copyright (c) 2015年 LZXuan. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"
#import "SqliteManager.h"

@interface ViewController ()< UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (Student *)currentStudent {
    Student *student = [[Student alloc] init];
    student.name = self.name.text;
    student.age = [self.age.text intValue];
    student.image = self.imageView.image;
    return student;
}
- (IBAction)addClick:(UIButton *)sender {
    [[SqliteManager sharedManager] add:[self currentStudent]];
}


- (IBAction)deleteClick:(UIButton *)sender {
    [[SqliteManager sharedManager] deleteByName:[NSString stringWithFormat:@"%@", self.name.text]];
}

- (IBAction)updateClick:(UIButton *)sender {
    [[SqliteManager sharedManager] update:[self currentStudent]];
}

- (IBAction)fetchClick:(UIButton *)sender {
    NSArray *studentArray = [[SqliteManager sharedManager] fetchAll];
    for (Student *student in studentArray) {
        NSLog(@"%@", student);
    }
    
    Student *student = studentArray.lastObject;
    self.imageView.image = student.image;
}

- (IBAction)chooseImage:(UITapGestureRecognizer *)sender {
    UIImagePickerController *imageController = [[UIImagePickerController alloc] init];
    imageController.delegate = self;
    [self presentViewController:imageController animated:YES completion:^{
    }];

}
#pragma mark - <UIImagePickerControllerDelegate>
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.imageView.image = info[@"UIImagePickerControllerOriginalImage"];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//收键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.name resignFirstResponder];
    [self.age resignFirstResponder];
}

@end
