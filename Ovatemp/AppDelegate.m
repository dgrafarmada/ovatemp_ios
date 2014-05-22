//
//  AppDelegate.m
//  Ovatemp
//
//  Created by Flip Sasser on 1/22/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

#import <GoogleAnalytics-iOS-SDK/GAI.h>
#import <GoogleConversionTracking/ACTReporter.h>

#import <HockeySDK/HockeySDK.h>

#import <Mixpanel/Mixpanel.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Build the main window
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];

  // Setup 3rd party libraries
  [self configureAnalytics];
  [self configureHockey];
  
  // Display the app!
  [self.window makeKeyAndVisible];

  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

  RootViewController *rvc = (RootViewController *)self.window.rootViewController;
  [rvc refreshToken];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

# pragma mark - 3rd party librarys

- (void)configureAnalytics {
  [GAI sharedInstance].trackUncaughtExceptions = YES;
  [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsTrackingID];

  [ACTConversionReporter reportWithConversionID:kGoogleAdwordsConversionID
                                          label:kGoogleAdwordsConversionLabel
                                          value:@"0.000000"
                                   isRepeatable:NO];

  [Mixpanel sharedInstanceWithToken:kMixpanelToken];
}

- (void)configureHockey {
  BITHockeyManager *hockey = [BITHockeyManager sharedHockeyManager];
  [hockey configureWithIdentifier:kHockeyIdentifier];
  [hockey startManager];
  [hockey.authenticator authenticateInstallation];
}

@end
