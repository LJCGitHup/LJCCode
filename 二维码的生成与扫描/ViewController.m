//
//  ViewController.m
//  二维码的生成与扫描
//
//  Created by LiJiChao on 16/12/2.
//  Copyright © 2016年 LJC. All rights reserved.
//

#import "ViewController.h"

#import "CreatCodeViewController.h"
#import "ScanCodeViewController.h"
#import "CreatSingleCodeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"二维码(条形码)扫描和生成";
    
    [self buidUI];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)buidUI
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    scanButton.frame = CGRectMake(size.width/2-100, 114, 200, 30);
    [scanButton setTitle:@"扫描二维码（条形码）" forState:UIControlStateNormal];
    [scanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(dealScan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
    scanButton.backgroundColor = [UIColor brownColor];
    
    
    UIButton *createButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    createButton.frame = CGRectMake(size.width/2-100, 194, 200, 30);
    [createButton setTitle:@"生成二维码(可长按扫描)" forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(dealCreate) forControlEvents:UIControlEventTouchUpInside];
    [createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:createButton];
    createButton.backgroundColor = [UIColor brownColor];
    
    UIButton *createBarCodeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    createBarCodeButton.frame = CGRectMake(size.width/2-100, 274, 200, 30);
    [createBarCodeButton setTitle:@"生成条形码" forState:UIControlStateNormal];
    [createBarCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [createBarCodeButton addTarget:self action:@selector(dealCreate2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBarCodeButton];
    createBarCodeButton.backgroundColor = [UIColor brownColor];
}

-(void)dealScan
{
    ScanCodeViewController * scan = [[ScanCodeViewController alloc] init];
    [self.navigationController pushViewController:scan animated:YES];
}
-(void)dealCreate
{
    CreatCodeViewController * creat = [[CreatCodeViewController alloc] init];
    [self.navigationController pushViewController:creat animated:YES];
}

-(void)dealCreate2
{
    CreatSingleCodeViewController * creat = [[CreatSingleCodeViewController alloc] init];
    [self.navigationController pushViewController:creat animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
