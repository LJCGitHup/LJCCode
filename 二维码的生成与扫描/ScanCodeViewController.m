//
//  ScanCodeViewController.m
//  二维码的生成与扫描
//
//  Created by LiJiChao on 16/12/2.
//  Copyright © 2016年 LJC. All rights reserved.
//

#import "ScanCodeViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureOutput.h>

@interface ScanCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>


@property (strong,nonatomic) AVCaptureSession * session;
@property (strong,nonatomic) AVCaptureVideoPreviewLayer * previewLayer;

@end

@implementation ScanCodeViewController

-(void)viewDidAppear:(BOOL)animated
{
    [self readQRcode];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描二维码（条形码）";
    [self CreatUI];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

//创建开关
- (void)CreatUI
{
    UISwitch * swich = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    swich.on = NO;
    [swich addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:swich];
}

//开关
-(void)switchAction:(id)sender
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        UISwitch *switchButton = (UISwitch*)sender;
        BOOL isButtonOn = [switchButton isOn];
        if (isButtonOn) {
            [device setTorchMode:AVCaptureTorchModeOn];
        }else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
    
    
}

#pragma mark - 读取二维码
- (void)readQRcode
{
    // 1. 摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2. 设置输入
    // 因为模拟器是没有摄像头的，因此在此最好做一个判断
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        return;
    }
    
    // 3. 设置输出(Metadata元数据)
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc] init];
    
    // 3.1 设置输出的代理
    // 说明：使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //    [output setMetadataObjectsDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    // 4. 拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    // 添加session的输入和输出
    [session addInput:input];
    [session addOutput:output];
    // 4.1 设置输出的格式
    // 提示：一定要先设置会话的输出为output之后，再指定输出的元数据类型！
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
    
    // 5. 设置预览图层（用来让用户能够看到扫描情况）
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    // 5.1 设置preview图层的属性
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    // 5.2 设置preview图层的大小
    
//    [preview setFrame:self.view.bounds];
    
    //根据需求设置大小
    [preview setFrame:self.view.bounds];
    // 5.3 将图层添加到视图的图层
    [self.view.layer insertSublayer:preview atIndex:0];
    self.previewLayer = preview;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, size.width, size.height - 64)];
    imageView.image = [UIImage imageNamed:@"front.png"];
    [self.view addSubview:imageView];
    
    // 6. 启动会话
    [session startRunning];
    
    self.session = session;
}

#pragma mark - 输出代理方法
// 此方法是在识别到QRCode，并且完成转换
// 如果QRCode的内容越大，转换需要的时间就越长
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    // 会频繁的扫描，调用代理方法
    // 1. 如果扫描完成，停止会话
    [self.session stopRunning];
    // 2. 删除预览图层
    [self.previewLayer removeFromSuperlayer];
    
    NSLog(@"%@", metadataObjects);
    // 3. 设置界面显示扫描结果
    
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        // 提示：如果需要对url或者名片等信息进行扫描，可以在此进行扩展！

        NSLog(@"obj.stringValue = %@",obj.stringValue);
        UIAlertView *alertView = [[UIAlertView alloc] init];
        alertView.message = [NSString stringWithFormat:@"二维码（条形码）数据: %@",obj.stringValue];
        [alertView addButtonWithTitle:@"取消"];
        [alertView show];
        
    }

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
