//
//  UIImage+QRCode.m
//  ZiXuWuYou
//
//  Created by Runge on 7/1/15.
//  Copyright (c) 2015 ZiXuWuYou. All rights reserved.
//

#import "UIImage+QRCode.h"

@implementation UIImage (QRCode)

+ (UIImage *)imageWithQRCode:(NSString *)qrCode {
    
    CIImage *ciImage = [[self class] ciImageWithQRCode:qrCode];
    UIImage *image = [UIImage imageWithCIImage:ciImage];
    return image;
}

+ (UIImage *)imageWithQRCode:(NSString *)qrCode desiredSize:(CGFloat)desiredWidth {
    
    CIImage *ciImage = [[self class] ciImageWithQRCode:qrCode];
    
    CGFloat originalWidth = [ciImage extent].size.width;
    CGFloat scale = desiredWidth / originalWidth;
    
    UIImage *image = [[self class] createNonInterpolatedUIImageFromCIImage:ciImage withScale:scale];
    
    return image;
}

+ (CIImage *)ciImageWithQRCode:(NSString *)qrCode {
    
    NSData *stringData = [qrCode dataUsingEncoding:NSISOLatin1StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    return qrFilter.outputImage;
}

+ (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale
{
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    // Now we'll rescale using CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake(image.extent.size.width * scale, image.extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    // We don't want to interpolate (since we've got a pixel-correct image)
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    // Get the image out
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // Tidy up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    // Need to set the image orientation correctly
    UIImage *flippedImage = [UIImage imageWithCGImage:[scaledImage CGImage]
                                                scale:scaledImage.scale
                                          orientation:UIImageOrientationDownMirrored];
    
    return flippedImage;
}

@end
