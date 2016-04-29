//
//  ViewController.m
//  VKFMDBHelperProj
//
//  Created by Awhisper on 16/4/29.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "ViewController.h"
#import "TESTDBModel.h"
#import "VKDBManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[VKDBManager defaultManager] openDefault];
    [TESTDBModel buildTable];//数据库建表 or 标记表已建好
    
    TESTDBModel* p = [[TESTDBModel alloc]init];
    p.name = @"wangdefu";
    p.famliy = @"lulu";
    
    [p saveToDB];
    
    
    NSArray* result1 = [TESTDBModel allObjectData];
    
    //所有返回的数据都是数组 不是person对象
    NSMutableArray* objectArr = [[NSMutableArray alloc]init];
    for (NSDictionary* itemdic in result1) {
        TESTDBModel* p = [[TESTDBModel alloc]initWithDictionary:itemdic];//一键自动将数组转化为对象
        [objectArr addObject:p];
    }

    [[VKDBManager defaultManager] closeDefault];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
