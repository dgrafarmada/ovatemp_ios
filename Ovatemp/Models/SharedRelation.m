//
//  SharedRelation.m
//  Ovatemp
//
//  Created by Chris Cahoon on 2/24/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import "SharedRelation.h"

@implementation SharedRelation

- (id)init {
  self = [super init];
  if(!self) {
    return nil;
  }

  self.ignoredAttributes = [NSSet setWithArray:@[@"createdAt", @"updatedAt", @"userId"]];

  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ (%@): %@ [%@ to all users]", [self class], self.id, self.name, self.belongsToAllUsers ? @"belongs" : @"doesn't belong"];
}

@end