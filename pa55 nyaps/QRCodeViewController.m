/*
 
 PA55 NYAPS iOS
 
 Copyright 2015 Anirban Basu
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */


//
//  QRCodeViewController.m
//  pa55v2
//
//  Created by Anirban Basu on 10/5/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import "QRCodeViewController.h"
#import "GlobalConstants.h"
#import "CameraFocusSquareView.h"
#import "AESCryptosystem.h"

@interface QRCodeViewController ()
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureDevice *frontCamera;
@property (nonatomic, strong) AVCaptureDevice *backCamera;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uibbiSwitchCamera;
@property (weak, nonatomic) IBOutlet UIView *uivCameraPreview;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCameraRestart;
@property (nonatomic, strong) CameraFocusSquareView *cameraFocusSquareView;
@property (nonatomic) BOOL shouldRead;

@property (nonatomic, strong) UIAlertController *inputPasswordDialog;
@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _captureSession = nil;
    _shouldRead = YES;
    self.navigationItem.title = NSLocalizedString(lcQRCodeViewControllerTitle, nil);
    //by default, get the back camera
    [self getCameraDevicePreferFront:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)value {
    return _lblStatus.text;
}

- (IBAction)switchCamera:(id)sender {
    [self performSelectorOnMainThread:@selector(stopReading:) withObject:nil waitUntilDone:YES];
    [self getCameraDevicePreferFront:(_captureDevice == _backCamera)];
    _shouldRead = YES;
    [self startReading];
}

- (IBAction)restartCamera:(id)sender {
    _shouldRead = YES;
    [self startReading];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self startReading];
}

- (void) obtainAVCaptureDeviceAccessPreferFront:(BOOL) front {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL videoGranted) {
        if(videoGranted) {
            [self activateCaptureDevicePreferFront:front];
        }
        else {
            UIAlertController *warn = [UIAlertController
                                       alertControllerWithTitle:NSLocalizedString(lcQRCodeViewControllerAVWarnTitle, nil)
                                       message:NSLocalizedString(lcQRCodeViewControllerAVWarnMessage, nil)
                                       preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppOkLabel, nil) style:UIAlertActionStyleCancel handler:nil];
            [warn addAction:okButton];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.navigationController presentViewController:warn animated:YES completion:nil];
            });
            //forget previous values
            _backCamera = nil;
            _frontCamera = nil;
            _uibbiSwitchCamera.enabled = NO;
            [self performSegueWithIdentifier:segidUnwindToFileList sender:self];
        }
    }];
}

- (void) getCameraDevicePreferFront:(BOOL) front {
    [self obtainAVCaptureDeviceAccessPreferFront:front];
}

- (void) activateCaptureDevicePreferFront:(BOOL) front {
    if(_backCamera == nil) {
        NSArray *devices = [AVCaptureDevice devices];
        for (AVCaptureDevice *device in devices) {
            if ([device hasMediaType:AVMediaTypeVideo]) {
                if ([device position] == AVCaptureDevicePositionBack) {
                    _backCamera = device;
                }
                else if ([device position] == AVCaptureDevicePositionFront) {
                    _frontCamera = device;
                }
            }
        }
    }
    if(front && _frontCamera!=nil) {
        _captureDevice = _frontCamera;
        _uibbiSwitchCamera.title = NSLocalizedString(lcQRCodeViewControllerSwitchCameraBack, nil);
    }
    else { //default to this if back camera is unavailable
        _captureDevice = _backCamera;
        _uibbiSwitchCamera.title = NSLocalizedString(lcQRCodeViewControllerSwitchCameraFront, nil);
    }
    if(_frontCamera == nil) {
        _uibbiSwitchCamera.enabled = NO;
    }
}

- (BOOL)startReading {
    if(_shouldRead) {
        _lblStatus.text = NSLocalizedString(lcAppEmptyString, nil);
        _btnCameraRestart.enabled = NO;
        [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:NSLocalizedString(lcAppEmptyString, nil) waitUntilDone:NO];
        NSError *error;
        
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&error];
        if (!input) {
            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[error localizedDescription] waitUntilDone:NO];
            return NO;
        }
        
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession addInput:input];
        
        AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [_captureSession addOutput:captureMetadataOutput];
        
        dispatch_queue_t dispatchQueue;
        dispatchQueue = dispatch_queue_create("qrCodeQueue", NULL);
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
        [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
        
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [_videoPreviewLayer setFrame:_uivCameraPreview.layer.bounds];
        [_uivCameraPreview.layer addSublayer:_videoPreviewLayer];

        
        [_captureSession startRunning];
        
        _shouldRead = NO;
        return YES;
    }
    else {
        return NO;
    }
}


-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self performSelectorOnMainThread:@selector(stopReading:) withObject:[metadataObj stringValue] waitUntilDone:NO];
        }
    }
}

- (void) stopReading:(NSString *)readValue {
    if(readValue!=nil && _captureSession.isRunning) {
        NSLog(@"%@", readValue);
        if([readValue rangeOfString:@"Ciphertext"].location==NSNotFound) {
            //plaintext password
            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:NSLocalizedString(lcQRCodeViewControllerSuccessfulRead, nil), readValue] waitUntilDone:NO];
            [[UIPasteboard generalPasteboard] setString:readValue];
        }
        else {
            //encrypted password
            [self readEncryptedQRFromString:readValue];
        }
    }
    [_captureSession stopRunning];
    _captureSession = nil;
    [_videoPreviewLayer removeFromSuperlayer];
    _btnCameraRestart.enabled = YES;
    [_cameraFocusSquareView removeFromSuperview];
    _cameraFocusSquareView = nil;
}

- (void) readEncryptedQRFromString:(NSString *)readValue {
    
    _inputPasswordDialog = [UIAlertController
                            alertControllerWithTitle:NSLocalizedString(lcQRCodeViewControllerEnterMasterSecretDialogTitle, nil)
                            message:NSLocalizedString(lcQRCodeViewControllerEnterMasterSecretDialogMessage, nil)
                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    [_inputPasswordDialog addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(lcAppPlaceholderPasswordLabel, nil);
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *continueButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppContinueLabel, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSString *masterSecret = [_inputPasswordDialog.textFields[0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *errorMessage;
        AESCryptosystem *cryptosystem = [[AESCryptosystem alloc] init];
        NSString *password = nil;
        @try {
            NSData *readData = [readValue dataUsingEncoding:NSUTF8StringEncoding];
            Ciphertext *ciphertext = [[Ciphertext alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:readData options:NSJSONReadingMutableContainers error:NULL]];
            password = [cryptosystem decryptWithHmac:ciphertext password:masterSecret];
        }
        @catch(NSException *exception) {
            errorMessage = [exception reason];
        }
        if(errorMessage!=nil) {
            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:NSLocalizedString(lcQRCodeViewControllerEncryptedQRReadError, nil) waitUntilDone:NO];
            UIAlertController *warn = [UIAlertController
                                       alertControllerWithTitle:NSLocalizedString(lcAppFileReadErrorTitle, nil)
                                       message:errorMessage
                                       preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppOkLabel, nil) style:UIAlertActionStyleCancel handler:nil];
            [warn addAction:okButton];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.navigationController presentViewController:warn animated:YES completion:nil];
            });
        }
        else {
            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:NSLocalizedString(lcQRCodeViewControllerSuccessfulRead, nil), password] waitUntilDone:NO];
            [[UIPasteboard generalPasteboard] setString:password];
        }
    }];
    
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppCancelLabel, nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self restartCamera:nil];
    }];
    
    [_inputPasswordDialog addAction:continueButton];
    [_inputPasswordDialog addAction:cancelButton];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.navigationController presentViewController:_inputPasswordDialog animated:YES completion:nil];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [self performSelectorOnMainThread:@selector(stopReading:) withObject:nil waitUntilDone:NO];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPoint = [touch locationInView:touch.view];
    if(touch.view == self.uivCameraPreview && self.uivCameraPreview != nil) {
        [self focus:touchPoint];
    }
}

- (void) focus:(CGPoint) aPoint {
    if([_captureDevice isFocusPointOfInterestSupported] &&
       [_captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        CGPoint focusPoint = [self.videoPreviewLayer captureDevicePointOfInterestForPoint:aPoint];
        if([_captureDevice lockForConfiguration:nil]) {
            [_captureDevice setFocusPointOfInterest:CGPointMake(focusPoint.x,focusPoint.y)];
            [_captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
            if ([_captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                [_captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
            }
            [_captureDevice unlockForConfiguration];
        }
        
        if(_cameraFocusSquareView) {
            [_cameraFocusSquareView updatePoint:aPoint];
        }
        else {
            _cameraFocusSquareView = [[CameraFocusSquareView alloc] initWithTouchPoint:aPoint];
            [self.uivCameraPreview addSubview:_cameraFocusSquareView];
            [_cameraFocusSquareView setNeedsDisplay];
        }
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
