//
//  UIColor+Traits.m
//  Sweepon
//
//  Created by Flip Sasser on 3/6/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import "UIColor+Traits.h"

@implementation UIColor (Traits)

static NSMutableDictionary *__cachedGradients;

+ (UIColor *)gradientWithSize:(CGSize)size
                     fromColor:(UIColor *)fromColor
                 startPosition:(CGPoint)startPosition
                       toColor:(UIColor *)toColor
                   endPosition:(CGPoint)endPosition {
  if (!__cachedGradients) {
    __cachedGradients = [NSMutableDictionary dictionary];
  }

  // Determine how we'll cache this gradient
  NSString *gradientKey = [NSString stringWithFormat:@"%@%@%@%@%@", NSStringFromCGSize(size), NSStringFromCGPoint(startPosition), NSStringFromCGPoint(endPosition), fromColor.description, toColor.description];
  UIColor *color = [__cachedGradients objectForKey:gradientKey];

  // Build the gradient if it doesn't exist yet
  if (!color) {
    color = [self makeGradientWithSize:size
                             fromColor:fromColor
                         startPosition:startPosition
                               toColor:toColor
                           endPosition:endPosition];

    if (color) {
      // Cache the gradient for next time
      [__cachedGradients setObject:color forKey:gradientKey];
    }
  }
  return color;
}

+ (UIColor *)makeGradientWithSize:(CGSize)size
                        fromColor:(UIColor *)fromColor
                    startPosition:(CGPoint)startPosition
                          toColor:(UIColor *)toColor
                      endPosition:(CGPoint)endPosition {
  UIGraphicsBeginImageContextWithOptions(size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();

  NSArray *colors = @[(id)fromColor.CGColor, (id)toColor.CGColor];
  CGGradientRef gradient = CGGradientCreateWithColors(colorspace, (CFArrayRef)colors, NULL);
  CGContextDrawLinearGradient(context, gradient, startPosition, endPosition, 0);

  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

  CGGradientRelease(gradient);
  CGColorSpaceRelease(colorspace);
  UIGraphicsEndImageContext();

  return [UIColor colorWithPatternImage:image];
}

- (CGFloat)brightness {
  CGFloat hue, saturation, brightness, alpha;
  [self reliablyGetHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
  return brightness;
}

- (UIColor *)darkenBy:(CGFloat)amount {
  CGFloat hue, saturation, brightness, alpha;
  [self reliablyGetHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
  return [UIColor colorWithHue:hue saturation:saturation brightness:brightness - amount alpha:alpha];
}

- (UIColor *)desaturateBy:(CGFloat)amount {
  CGFloat hue, saturation, brightness, alpha;
  [self reliablyGetHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
  return [UIColor colorWithHue:hue saturation:saturation - amount brightness:brightness alpha:alpha];
}

- (void)reliablyGetHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha {
  [self getHue:hue saturation:saturation brightness:brightness alpha:alpha];
  if (hue < 0 || saturation < 0 || brightness < 0 || alpha < 0) {
    CGFloat white;
    [self getWhite:&white alpha:alpha];
    if (white < 0 || alpha < 0) {
      // WUT
    }
    *hue = 0;
    *saturation = 0;
    *brightness = white;
  }
}

+ (UIColor *)ovatempGreyColor {
    
    return [UIColor colorWithRed:(68.0f/255.0) green:(68.0f/255.0) blue:(68.0f/255.0) alpha:1.0];
}

+ (UIColor *)ovatempDarkGreyTitleColor {
    return [UIColor colorWithRed:(101.0f/255.0) green:(108.0f/255.0) blue:(111.0f/255.0) alpha:1.0];
}

+ (UIColor *)ovatempAquaColor {
    return [UIColor colorWithRed:(32.0f/255.0) green:(108.0f/255.0) blue:(114.0f/255.0) alpha:1.0];
}

+ (UIColor *)ovatempAlmostWhiteColor {
    return [UIColor colorWithRed:(249.0f/255.0) green:(249.0f/255.0) blue:(249.0f/255.0) alpha:1.0];
}

+ (UIColor *)ovatempGreyColorForDateCollectionViewCells {
    return [UIColor colorWithRed:(204.0f/255.0) green:(204.0f/255.0) blue:(204.0f/255.0) alpha:1.0];
}

#pragma mark - Public Fertility Colors



#pragma mark - Private Fertility Colors

+ (UIColor *)il_greenColor
{
    return [UIColor colorWithRed: 56.0/255.0 green: 192.0/255.0 blue: 191.0/255.0 alpha: 1];
}

+ (UIColor *)il_lightRedColor
{
    return [UIColor colorWithRed: 251.0/255.0 green: 95.0/255.0 blue: 98.0/255.0 alpha: 1];
}

+ (UIColor *)il_darkRedColor
{
    return [UIColor colorWithRed: 176.0/255.0 green: 72.0/255.0 blue: 66.0/255.0 alpha: 1];
}

+ (UIColor *)il_purple
{
    return [UIColor colorWithRed: 124.0/255.0 green: 65.0/255.0 blue: 160.0/255.0 alpha: 1];
}

+ (UIColor *)il_yellowColor
{
    return [UIColor colorWithRed: 56.0/255.0 green: 192.0/255.0 blue: 191.0/255.0 alpha: 1];
}

@end
