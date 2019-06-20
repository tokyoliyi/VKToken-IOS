//
//  UIImage+.h
//  VKToken
//
//  Created by Lee on 06/01/2019.
//  Copyright © 2019 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (VKTOKEN)

+ (UIImage *)tb_imageWithURL:(NSURL *)url;

+ (UIImage *)tb_imageNamed:(NSString *)name scale:(float)scale;

+ (UIImage *)tb_imageNamed:(NSString *)name rect:(CGRect)rect;

+ (UIImage *)tb_imageWithContentsOfFile:(NSString *)path rect:(CGRect)rect;

- (UIImage *)tb_blurredImage:(CGFloat)blurAmount;

+ (UIImage *)tb_imageWithColor:(UIColor *)color andSize:(CGSize)size;

+ (UIImage *)tb_imageWithImage:(UIImage *)image alpha:(CGFloat)alpha;

- (UIImage *)tb_imageWithTintColor:(UIColor *)tintColor;

- (UIImage *)tb_transformToSize:(CGSize)newSize;

@end
