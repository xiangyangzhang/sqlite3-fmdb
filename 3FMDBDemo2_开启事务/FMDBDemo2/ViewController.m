//
//  ViewController.m
//  FMDBDemo2
//
//  Created by lzxuan on 15/9/28.
//  Copyright (c) 2015年 lzxuan. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import "DataBaseManager.h"
#import "StudentModel.h"


@interface ViewController () <UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *uidTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *scoreTextField;
- (IBAction)addClick:(id)sender;
- (IBAction)deleteClick:(id)sender;
- (IBAction)updateClick:(id)sender;
- (IBAction)fetchClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArr = [[NSMutableArray alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 100;
    //注册
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    //图片点击
    [self addTapGesture];
    
}
#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
//显示 填充cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    StudentModel *model = self.dataArr[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"uid:%@ name:%@ score:%f",model.uid,model.name,model.score];
    cell.imageView.image = [UIImage imageWithData:model.headimage];
    return cell;
}
#pragma mark - 图片点击
- (void)addTapGesture {
    //点击手势 能够点击 图片
    self.myImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [self.myImageView addGestureRecognizer:tap];
}
- (void)tapClick:(UITapGestureRecognizer *)tap {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //设置访问相册
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    //设置代理
    picker.delegate = self;
    //模态跳转
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"choose");
    
    NSString *type = info[UIImagePickerControllerMediaType];
    if ([type isEqualToString:(NSString *)kUTTypeImage]) {
        //图片
        //获取原始图片
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        self.myImageView.image = image;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.uidTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
    [self.scoreTextField resignFirstResponder];
}

- (IBAction)addClick:(id)sender {
    StudentModel *model = [[StudentModel alloc] init];
    model.uid = self.uidTextField.text;
    model.name = self.nameTextField.text;
    model.score = self.scoreTextField.text.doubleValue;
    //把图片转化为二进制
    model.headimage = UIImagePNGRepresentation(self.myImageView.image);
    //增加数据库 数据
    [[DataBaseManager defaultManager] insertDataWithModel:model];
   
}
//对数据 删除
- (IBAction)deleteClick:(id)sender {
    [[DataBaseManager defaultManager] deleteDataWithUid:self.uidTextField.text];
}

- (IBAction)updateClick:(id)sender {
    StudentModel *newModel = [[StudentModel alloc] init];
    newModel.uid = self.uidTextField.text ;
    newModel.name = self.nameTextField.text;
    newModel.score = self.scoreTextField.text .doubleValue;
    newModel.headimage = UIImagePNGRepresentation(self.myImageView.image);
    //修改
    [[DataBaseManager defaultManager] updateDataWithUid:newModel.uid newModel:newModel];
}
- (IBAction)fetchClick:(id)sender {
    [self.dataArr removeAllObjects];
    //增加 数据库中现有的
    [self.dataArr addObjectsFromArray:[[DataBaseManager defaultManager]  fetchAllData]];
    [self.tableView reloadData];
}

@end



