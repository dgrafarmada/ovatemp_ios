//
//  UIViewController+Analytics.m
//  Ovatemp
//
//  Created by Flip Sasser on 4/14/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import "UIViewController+Analytics.h"

#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleAnalytics-iOS-SDK/GAIFields.h>
#import <GoogleAnalytics-iOS-SDK/GAIDictionaryBuilder.h>

#import <Mixpanel/Mixpanel.h>

@implementation UIViewController (Analytics)

- (void)trackScreenView {
  NSString *screenName = self.title;
  if (!screenName.length) {
    screenName = self.navigationItem.title;
  }
  if (screenName.length) {
    [self trackScreenView:screenName];
  }
}

- (void)trackScreenView:(NSString *)name {
  id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];

  // This screen name value will remain set on the tracker and sent with
  // hits until it is set to a new value or to nil.
  [tracker set:kGAIScreenName
         value:@"Home Screen"];
  
  [tracker send:[[GAIDictionaryBuilder createAppView] build]];

  // Mixpanel tracking
  [[Mixpanel sharedInstance] track:@"Screen View" properties:@{@"Screen": name}];
}

@end
