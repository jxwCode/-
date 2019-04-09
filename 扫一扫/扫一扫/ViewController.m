//
//  ViewController.m
//  扫一扫
//
//  Created by jxw on 2019/4/9.
//  Copyright © 2019 jxw. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,strong) AVCaptureDevice *device;
@property (nonatomic,strong) AVCaptureDeviceInput *input;
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *preview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCamera];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)setupCamera{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //耗时的操作
        //Device
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        //input
        self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
        
        //output
        self.output = [[AVCaptureMetadataOutput alloc]init];
        [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        //session
        self.session = [[AVCaptureSession alloc]init];
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([self.session canAddInput:self.input]) {
            [self.session addInput:self.input];
        }
        if ([self.session canAddOutput:self.output]) {
            [self.session addOutput:self.output];
        }
        
        //条码类型 AVMetadataObjectTypeQRCode
        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新界面
            self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
            self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.preview.frame  = self.view.bounds;
            [self.view.layer insertSublayer:self.preview atIndex:0];
            [self.session startRunning];
        });
    });
}

-(void)viewWillAppear:(BOOL)animated{
    if (_session && ![_session isRunning]) {
        [_session startRunning];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    
}

#pragma AVCaptureDelegate

-(void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *stringValue;
    if ([metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    [_session stopRunning];
    NSLog(@"%@",stringValue);
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:stringValue]]) {
    if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringValue] options:@{} completionHandler:nil];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringValue]];
    }
    }
   
}

@end
