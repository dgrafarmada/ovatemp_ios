//
//  Configuration.m
//  Ovatemp
//
//  Created by Flip Sasser on 1/29/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import "Configuration.h"
#import "User.h"
#import "Day.h"

static Configuration *_sharedConfiguration;

@implementation Configuration

# pragma mark - Setup

+ (Configuration *)sharedConfiguration {
  if (!_sharedConfiguration) {
    _sharedConfiguration = [[self alloc] init];
    [_sharedConfiguration observeKeys:@[@"token", @"hasSeenProfileIntroScreen"]];
  }
  return _sharedConfiguration;
}

- (void)observeKeys:(NSArray *)keys {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  for (NSString *key in keys) {
    id value = [userDefaults objectForKey:key];
    [self setValue:value forKey:key];
    [self addObserver:self forKeyPath:key options:0 context:nil];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  id value = [self valueForKey:keyPath];
  [userDefaults setObject:value forKey:keyPath];
  [userDefaults synchronize];
}

+ (void)loggedInWithResponse:(NSDictionary *)response {
  NSDictionary *userDict = response[@"user"];
  User *user = [User withAttributes:userDict];
  [User setCurrent:user];

  [Configuration sharedConfiguration].token = response[@"token"];
  [UserProfile setCurrent:[UserProfile withAttributes:response[@"user_profile"]]];

  [Supplement resetInstancesWithArray:response[@"supplements"]];
  [Medicine resetInstancesWithArray:response[@"medicines"]];
  [Symptom resetInstancesWithArray:response[@"symptoms"]];

  [Day resetInstances];
}

+ (BOOL)loggedIn {
  return [Configuration sharedConfiguration].token != nil;
}

+ (void)logOut {
  [User setCurrent:nil];
  [UserProfile setCurrent:nil];
  [Configuration sharedConfiguration].token = nil;
}


@end
