//
//  UIImage+Extension.h
//  nzls
//
//  Created by raychen on 15/11/19.
//  Copyright © 2015年 raychen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
- (instancetype)imageWithOverlayColor:(UIColor *)overlayColor;
- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
/** 把图片缩小到指定的宽度范围内为止 */
- (UIImage *)scaleImageWithWidth:(CGFloat)width;

/** 把图片缩小到指定的高度范围内为止 */

- (UIImage *)scaleImageWithHeight:(CGFloat)height;
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;
/**
 *  返回一张纯色的图片
 *
 *  @param color 颜色
 *
 *  @return 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;
/**
 *  打水印
 *
 *  @param bg   背景图片
 *  @param logo 右下角的水印图片
 */
+ (instancetype)waterImageWithBg:(NSString *)bg logo:(NSString *)logo;


/**
 *  返回一张可以随意拉伸不变形的图片
 *
 *  @param name 图片名字
 */
+ (instancetype)resizableImage:(NSString *)name;
/**
 *  图片剪裁（圆形，带圆环）
 *
 *  @param name        图片名
 *  @param borderWidth 边框的大小
 *  @param borderColor 边框的颜色
 *
 *  @return 实例
 */
+ (instancetype)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
/**
 *  图片剪裁（圆形，带圆环
 *
 *  @param image       图片
 *  @param borderWidth 边框的大小
 *  @param borderColor 边框的颜色
 *
 *  @return 实例
 */
+ (instancetype)circleImage:(UIImage *)image borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;
@end
