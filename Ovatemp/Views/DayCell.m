//
//  DayCell.m
//  Ovatemp
//
//  Created by Chris Cahoon on 2/12/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import "DayCell.h"

@implementation DayCell

- (void)awakeFromNib{
  self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setDay:(Day *)day {
  NSLog(@"Set day not implemented for: %@", [self class]);
}

@end
