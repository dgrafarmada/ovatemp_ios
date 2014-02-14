//
//  Calendar.h
//  Ovatemp
//
//  Created by Chris Cahoon on 2/12/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Calendar : NSObject

+ (NSDate *)date;
+ (void)setDate:(NSDate *)date;
+ (Calendar *)sharedInstance;
+ (void)stepDay:(NSInteger)offset;
+ (BOOL)isOnToday;

@end