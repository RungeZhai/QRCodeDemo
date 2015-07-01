//
//  UIImage+QRCode.h
//  ZiXuWuYou
//
//  Created by Runge on 7/1/15.
//  Copyright (c) 2015 ZiXuWuYou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCode)

+ (UIImage *)imageWithQRCode:(NSString *)qrCode;

+ (UIImage *)imageWithQRCode:(NSString *)qrCode desiredSize:(CGFloat)desiredWidth;

@end
