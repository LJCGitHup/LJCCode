# IOS二维码与条形码的生成与扫描
使用系统框架，自定义生成二维码与条形码，支持长按识别与扫描（识别须在真机演示），代码清晰

1.需要导入的框架：AVFoundation.framework和CoreImage.framework
2.二维码与条形码生成核心代码
// 1. 实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
// 1. 实例化条形码滤镜
    //CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];

    // 2. 恢复滤镜的默认属性
    [filter setDefaults];
    // 3. 将字符串转换成NSData
    NSData *data = [_textField.text dataUsingEncoding:NSUTF8StringEncoding];
    // 4. 通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKey:@"inputMessage"];
    // 5. 获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    // 6. 将CIImage转换成UIImage，并放大显示，这样写生成的码会比较模糊，所以换了种转换方式
//    UIImage * image = [UIImage imageWithCIImage:outputImage scale:20.0 orientation:UIImageOrientationUp];
    UIImage * image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:200];

3.二维码与条形码扫描核心代码
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

2.二维码长按识别核心代码
    UIImage * srcImage = _showCodeImageView.image;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *image = [CIImage imageWithCGImage:srcImage.CGImage];
    NSArray *features = [detector featuresInImage:image];
    if (features.count) {
        CIQRCodeFeature *feature = [features firstObject];
        NSString *result = feature.messageString;
        //显示结果
        _resultLabel.text = result;
    }
    else{
        return;
    }
