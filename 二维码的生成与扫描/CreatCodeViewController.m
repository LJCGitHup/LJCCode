//
//  CreatCodeViewController.m
//  二维码的生成与扫描
//
//  Created by LiJiChao on 16/12/2.
//  Copyright © 2016年 LJC. All rights reserved.
//

#import "CreatCodeViewController.h"
#import <UIKit/UIKit.h>
@interface CreatCodeViewController ()<UITextFieldDelegate,UIActionSheetDelegate>

@end

@implementation CreatCodeViewController
{
    UITextField *_textField;
    
    UIImageView *_showCodeImageView;
    
    UILabel * _resultLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"生成二维码";
    self.view.backgroundColor = [UIColor whiteColor];
    [self CreatUI];
    // Do any additional setup after loading the view.
}

- (void)CreatUI
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    
    //输入字符串
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 100, 200, 30)];
    _textField.center = CGPointMake(size.width / 2 , 100);
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.text = @"test";
    [self.view addSubview:_textField];
    
    //生成按钮
    UIButton *createButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    createButton.frame = CGRectMake(0, 150, 200, 30);
    createButton.center = CGPointMake(size.width / 2 , 165);
    [createButton setTitle:@"生成二维码" forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(Create) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createButton];
    createButton.backgroundColor = [UIColor brownColor];
    
    //显示
    _showCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    _showCodeImageView.center = CGPointMake(size.width / 2 , 320);
    _showCodeImageView.backgroundColor = [UIColor lightGrayColor];
    _showCodeImageView.tag = 1;
    _showCodeImageView.userInteractionEnabled = YES;
    [self.view addSubview:_showCodeImageView];
    
    _resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(size.width/2-100, CGRectGetMaxY(_showCodeImageView.frame)+20, 200, 30)];
    _resultLabel.backgroundColor = [UIColor lightGrayColor];
    _resultLabel.font = [UIFont systemFontOfSize:12];
    _resultLabel.text = @"结果显示(二维码长按可扫描)";
    [self.view addSubview:_resultLabel];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)Create
{
    // 1. 实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2. 恢复滤镜的默认属性
    [filter setDefaults];
    // 3. 将字符串转换成NSData
    NSData *data = [_textField.text dataUsingEncoding:NSUTF8StringEncoding];
    // 4. 通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKey:@"inputMessage"];
    // 5. 获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    // 6. 将CIImage转换成UIImage，并放大显示
//    UIImage * image = [UIImage imageWithCIImage:outputImage scale:20.0 orientation:UIImageOrientationUp];
    UIImage * image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:200];
    _showCodeImageView.image = image;
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
    longGesture.minimumPressDuration = 1;
    [_showCodeImageView addGestureRecognizer:longGesture];
}


# pragma mark 处理二维码模糊不清的操作
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    
    //设置比例
    
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap（位图）;
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    
    
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
    
}

#pragma mark 长按扫描

- (void)longPress
{
    UIImage * srcImage = _showCodeImageView.image;
//    if (nil == srcImage) {
//        myQRCode(nil,[NSError errorWithDomain:@"未传入图片" code:0 userInfo:nil]);
//        return;
//    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *image = [CIImage imageWithCGImage:srcImage.CGImage];
    NSArray *features = [detector featuresInImage:image];
    if (features.count) {
        CIQRCodeFeature *feature = [features firstObject];
        
        NSString *result = feature.messageString;
        //显示结果
        _resultLabel.text = result;
//        myQRCode(result,nil);
    }
    else{
//        myQRCode(nil,[NSError errorWithDomain:@"未能识别出二维码" code:0 userInfo:nil]);
        return;
    }
}

//长按识别
- (void)longPressGesture:(UILongPressGestureRecognizer *)longGesture
{
    UIImageView * imageview = (id)[self.view viewWithTag:[longGesture view].tag];
    [imageview removeGestureRecognizer:longGesture];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"二维码识别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"识别二维码" otherButtonTitles:nil, nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];

}

//ActionSheet协议方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex) {
        case 0:{
            [self longPress];
            
            //因取消掉了手势，需要重新添加
            UIImageView * imageView = (id)[self.view viewWithTag:1];
            UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
            longGesture.minimumPressDuration = 1;
            [imageView addGestureRecognizer:longGesture];
            
            break;
        }
        default:{
            
            UIImageView * imageView = (id)[self.view viewWithTag:1];
            UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
            longGesture.minimumPressDuration = 1;
            [imageView addGestureRecognizer:longGesture];
            
        }
            break;
    }
 
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
