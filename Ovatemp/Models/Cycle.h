//
//  Cycle.h
//  Ovatemp
//
//  Created by Chris Cahoon on 3/11/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Day.h"

@interface Cycle : NSObject

- (Cycle *)initWithDay:(Day *)day;
- (Cycle *)previousCycle;
- (Cycle *)nextCycle;
- (NSArray *)days;

@end
