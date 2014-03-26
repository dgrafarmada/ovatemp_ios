//
//  UIColor+Traits.h
//  Sweepon
//
//  Created by Flip Sasser on 3/6/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Traits)

@property (readonly) CGFloat brightness;

- (UIColor *)darkenBy:(CGFloat)amount;

@end
