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
//  GeneratePasswordViewController.m
//  pa55 nyaps
//
//  Created by Anirban Basu on 10/12/15.
//  Copyright © 2015 Anirban Basu. All rights reserved.
//

#import "GeneratePasswordViewController.h"
#import "AESCryptosystem.h"

@interface GeneratePasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *uitfMasterSecret;

@property (weak, nonatomic) IBOutlet UITextField *uitfGeneratedPassword;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *uibbiCopyToClipboard;
@property (weak, nonatomic) IBOutlet UILabel *uilblMasterSecret;
@property (weak, nonatomic) IBOutlet UILabel *uilblGeneratedPassword;
@property (weak, nonatomic) IBOutlet UIImageView *uiimgvQRCode;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uibbiFlipQR;

@property (nonatomic) BOOL shouldNotAttemptToGeneratePassword;
@property (weak, nonatomic) IBOutlet UILabel *uilblEncryptQR;
@property (weak, nonatomic) IBOutlet UISwitch *uiswchEncryptQR;
@property (weak, nonatomic) IBOutlet UIButton *uibReveal;

@end

@implementation GeneratePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _uilblMasterSecret.text = NSLocalizedString(lcGeneratePasswordViewControllerLabelMasterSecret, nil);
    _uilblGeneratedPassword.text = NSLocalizedString(lcGeneratePasswordViewControllerLabelGeneratedPassword, nil);
    _uibbiCopyToClipboard.title = NSLocalizedString(lcGeneratePasswordViewControllerButtonCopyToClipboard, nil);
    _uibbiFlipQR.title = NSLocalizedString(lcGeneratePasswordViewControllerButtonFlipQR, nil);
    _uilblEncryptQR.text = NSLocalizedString(lcGeneratePasswordViewControllerLabelEncryptQR, nil);
    [_uiswchEncryptQR addTarget:self action:@selector(stateDidChangeForQREncryption:) forControlEvents:UIControlEventValueChanged];
    _uitfGeneratedPassword.delegate = self;
    _uitfMasterSecret.delegate = self;
    
    [_uitfMasterSecret addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [_uibReveal setTitle:NSLocalizedString(lcGeneratePasswordViewControllerButtonReveal1, nil) forState:UIControlStateNormal];
    
    [self resetGeneratedPasswordState];
}

- (void) textFieldChanged:(UITextField *) textField {
    if(textField == _uitfMasterSecret) {
        NSString *newValue = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(newValue.length > 0) {
            _uibReveal.enabled = YES;
        }
        else {
            _uibReveal.enabled = NO;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    _shouldNotAttemptToGeneratePassword = YES;
    [super viewWillDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    if([MiscellaneousUtilities defaultInstance].cachedMasterSecret!=nil) {
        [self generatePasswordWithMasterSecret:[MiscellaneousUtilities defaultInstance].cachedMasterSecret];
    }
}

- (void) stateDidChangeForQREncryption: (id) sender {
    if(sender==_uiswchEncryptQR) {
        if(_uitfGeneratedPassword.text.length > 0) {
            _uiimgvQRCode.image = [self generateQRCodeForPassword:_uitfGeneratedPassword.text usingEncryption:((UISwitch *)sender).isOn];
        }
    }
    //otherwise, ignore
}
- (IBAction)toggleMasterSecretRevelation:(id)sender {
    [_uitfMasterSecret setSecureTextEntry:!_uitfMasterSecret.secureTextEntry];
    if(_uitfMasterSecret.secureTextEntry) {
        [_uibReveal setTitle:NSLocalizedString(lcGeneratePasswordViewControllerButtonReveal1, nil) forState:UIControlStateNormal];
    }
    else {
        [_uibReveal setTitle:NSLocalizedString(lcGeneratePasswordViewControllerButtonReveal2, nil) forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)flipQRCode:(id)sender {
    if(_uiimgvQRCode.image!=nil) {
        UIImageOrientation orientation = UIImageOrientationUp;
        switch (_uiimgvQRCode.image.imageOrientation) {
            case UIImageOrientationUp:
                orientation = UIImageOrientationUpMirrored;
                break;
            case UIImageOrientationUpMirrored:
                orientation = UIImageOrientationUp;
            default:
                break;
        }
        _uiimgvQRCode.image = [UIImage imageWithCGImage:_uiimgvQRCode.image.CGImage scale:1.0 orientation:orientation];
    }
}

- (IBAction)copyToClipboard:(id)sender {
    if(_uitfGeneratedPassword.text.length > 0) {
        [[UIPasteboard generalPasteboard] setString:_uitfGeneratedPassword.text];
        UIAlertController *info = [UIAlertController
                                   alertControllerWithTitle:NSLocalizedString(lcGeneratePasswordViewControllerCopyTitle, nil)
                                   message:NSLocalizedString(lcGeneratePasswordViewControllerCopySuccessMessage, nil)
                                   preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppOkLabel, nil) style:UIAlertActionStyleCancel handler:nil];
        [info addAction:okButton];
        [self.navigationController presentViewController:info animated:YES completion:nil];
    }
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField == _uitfGeneratedPassword) {
        [textField resignFirstResponder];
        return NO;
    }
    else {
        [self resetGeneratedPasswordState];
        return YES;
    }
}

- (void) resetGeneratedPasswordState {
    _uitfMasterSecret.placeholder = NSLocalizedString(lcGeneratePasswordViewControllerPlaceholderMasterSecret, nil);
    _uitfGeneratedPassword.text = NSLocalizedString(lcAppEmptyString, nil);
    _uitfGeneratedPassword.placeholder = NSLocalizedString(lcGeneratePasswordViewControllerPlaceholderGeneratedPassword, nil);
    _uibbiCopyToClipboard.enabled = NO;
    _uiimgvQRCode.image = nil;
    _uibbiFlipQR.enabled = NO;
    
    [_uitfMasterSecret setSecureTextEntry:YES];
    [_uibReveal setTitle:NSLocalizedString(lcGeneratePasswordViewControllerButtonReveal1, nil) forState:UIControlStateNormal];
    if([MiscellaneousUtilities defaultInstance].cachedMasterSecret!= nil) {
        _uitfMasterSecret.text = [MiscellaneousUtilities defaultInstance].cachedMasterSecret;
        _uibReveal.enabled = YES;
    }
    else {
        _uitfMasterSecret.text = NSLocalizedString(lcAppEmptyString, nil);
        _uibReveal.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (UIImage *) generateQRCodeForPassword:(NSString *) password usingEncryption:(BOOL) useEncryption {
    if(useEncryption) {
        AESCryptosystem *cryptosystem = [[AESCryptosystem alloc] init];
        Ciphertext *ciphertext = [cryptosystem encryptWithHmac:password password:[_uitfMasterSecret.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        NSData *data = [NSJSONSerialization dataWithJSONObject:[ciphertext dictionary] options:NSJSONWritingPrettyPrinted error:NULL];
        //NSLog(@"QR data: %@ of length %lu characters", [data description], data.length);
        return [self createNonInterpolatedUIImageFromCIImage:[self createQRForData:data] withEdgeSize:_uiimgvQRCode.bounds.size.height];
    }
    else {
        //NSLog(@"QR data: %@ of length %lu characters", password, password.length);
        return [self createNonInterpolatedUIImageFromCIImage:[self createQRForString:password] withEdgeSize:_uiimgvQRCode.bounds.size.height];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if(textField == _uitfMasterSecret) {
        //TODO Generate password
        NSString *newValue = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        _uitfMasterSecret.text = newValue;
        if(newValue.length > 0) {
            _uibReveal.enabled = YES;
        }
        else {
            _uibReveal.enabled = NO;
        }
        //NSLog(@"Dynamic hint: %@", _dynamicHint);
        //NSLog(@"User preferences: %@", [_userPreferences description]);
        //NSLog(@"Master secret: %@", newValue);
        //NSLog(@"Hint: '%@', Master secret: '%@'", _dynamicHint, newValue);
        [self generatePasswordWithMasterSecret:newValue];
    }
}

- (void) generatePasswordWithMasterSecret:(NSString *) masterSecret {
    if(!_shouldNotAttemptToGeneratePassword) { //this is required because a blank value in the master secret while attempting to go back will try to show a warning message, which may be in an undefined state due to the view controller transition
        @try {
            NSString *generatedPassword = [NYAPSCore generateAESDRBGPasswordWithPhrase:masterSecret hint:_dynamicHint length:_passwordLength userPreferences:_userPreferences userCharset:_userCharset];
            //NSLog(@"Genenerated password: %@", generatedPassword);
            _uitfGeneratedPassword.text = generatedPassword;
            _uibbiCopyToClipboard.enabled = YES;
            _uiimgvQRCode.image = [self generateQRCodeForPassword:generatedPassword usingEncryption:_uiswchEncryptQR.isOn];
            _uibbiFlipQR.enabled = YES;
            if([[NSUserDefaults standardUserDefaults] boolForKey:strPreferencesCacheMasterSecret]) {
                [MiscellaneousUtilities defaultInstance].cachedMasterSecret = masterSecret;
            }
            else {
                [MiscellaneousUtilities defaultInstance].cachedMasterSecret = nil;
            }
        }
        @catch (NSException *exception) {
            [MiscellaneousUtilities defaultInstance].cachedMasterSecret = nil;
            [self resetGeneratedPasswordState];
            UIAlertController *warn = [UIAlertController
                                       alertControllerWithTitle:[exception name]
                                       message:[exception reason]
                                       preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction actionWithTitle:NSLocalizedString(lcAppOkLabel, nil) style:UIAlertActionStyleCancel handler:nil];
            [warn addAction:okButton];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.navigationController presentViewController:warn animated:YES completion:nil];
            });
        }
    }
}

#pragma mark - QR code generation

//Modified from https://github.com/ShinobiControls/iOS7-day-by-day/blob/master/15-core-image-filters/15-core-image-filters.md but QR code orientation is corrected by a correct transformation of the coordinate system.

- (CIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object?
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    return [self createQRForData:stringData];
}

- (CIImage *)createQRForData:(NSData *)qrData {
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:qrData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    // Send the image back
    return qrFilter.outputImage;
}

- (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withEdgeSize:(CGFloat)size {
    //Initialise CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake(size, size));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //It is essential to rotate and translate the coordinate system because CIImage and CGImage/UIImage coordinate systems are different!
    CGContextRotateCTM(context, M_PI / 2.0);
    CGContextTranslateCTM(context, 0, -size);
    
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    // We don't want to interpolate (since we've got a pixel-correct image)
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    //draw with padding around the image
    CGContextDrawImage(context, CGRectMake(0.25*size, 0.25*size, 0.5*size, 0.5*size), cgImage);
    
    // Get the image out
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // Tidy up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    return scaledImage;
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
