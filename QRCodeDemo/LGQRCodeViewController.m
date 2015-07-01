//
//  LGQRCodeViewController.m
//  ZiXuWuYou
//
//  Created by Runge on 15/6/27.
//  Copyright (c) 2015 Runge. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "LGQRCodeViewController.h"
#import "UIImage+QRCode.h"

@interface LGQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *scanLine;
@property (weak, nonatomic) IBOutlet UIImageView *scanBgView;

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property (strong, nonatomic) NSString *qrString;

@property (weak, nonatomic) UIImageView *qrImageView;

@end

@implementation LGQRCodeViewController

- (void)dealloc {
    [_session stopRunning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupCamera];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect frame = _scanLine.frame;
    frame.origin.y = [self scanLineStartY];
    _scanLine.frame = frame;
    
    _scanLine.hidden = NO;
    [self scanAnimation];
}

- (CGFloat)scanLineStartY {
    return CGRectGetMinY(_scanBgView.frame) + 20.f;
}

- (CGFloat)scanLineEndY {
    return CGRectGetMaxY(_scanBgView.frame) - 20.f;
}

-(void)scanAnimation
{
    CGRect rect = _scanLine.frame;
    
    if (rect.origin.y == [self scanLineStartY]) {
        rect.origin.y = [self scanLineEndY];
    } else {
        rect.origin.y = [self scanLineStartY];
    }
    
    [UIView animateWithDuration:2. animations:^{
        _scanLine.frame = rect;
    } completion:^(BOOL finished) {
        [self scanAnimation];
    }];
}

- (void)setupCamera
{
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _session = [[AVCaptureSession alloc]init];
    
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input]) {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output]) {
        [_session addOutput:self.output];
    }
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];

    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = self.view.bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    [_session startRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (!_preview.connection.enabled) {
        return;
    }
    _preview.connection.enabled = NO;
    
    _qrString = nil;
    if ([metadataObjects count] > 0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects firstObject];
        _qrString = metadataObject.stringValue;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Result" message:_qrString delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:@"Regenerate", nil];
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self showQRCodeImageWeGenerateWithQRString:_qrString];
    } else {
        _preview.connection.enabled = YES;
    }
}

- (void)showQRCodeImageWeGenerateWithQRString:(NSString *)qrString {
    UIImage *image = [UIImage imageWithQRCode:qrString desiredSize:_scanBgView.frame.size.width];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_scanBgView.frame];
    imageView.image = image;
    
    [self.view addSubview:(_qrImageView = imageView)];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    
    [_qrImageView removeFromSuperview];
    
    _preview.connection.enabled = YES;
}

@end
