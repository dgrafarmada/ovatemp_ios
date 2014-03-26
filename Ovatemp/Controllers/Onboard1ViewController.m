//
//  ProfileSetupViewController.m
//  Ovatemp
//
//  Created by Chris Cahoon on 3/19/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import "Onboard1ViewController.h"
#import "UserProfile.h"
#import "UIViewController+UserProfileHelpers.h"
#import "UIViewController+KeyboardObservers.h"

@interface Onboard1ViewController ()

@end

@implementation Onboard1ViewController

- (void)viewDidLoad {
  self.cycleDatePicker = [self useDatePickerForTextField:self.cycleDateTextField];
  self.cycleDatePicker.maximumDate = [NSDate date];
  [self.cycleDatePicker addTarget:self
                           action:@selector(cycleDateChanged:)
                 forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
  [self addKeyboardObservers];

  if(self.firstDay) {
    self.firstDay.period = nil;
    [self.firstDay save];
    self.firstDay = nil;
  }
}

- (void)viewDidDisappear:(BOOL)animated {
  [self removeKeyboardObservers];
}

- (void)commit {
  [[UserProfile current] save];
  [self updateControls];
}

- (void)viewWillLayoutSubviews {
  [self updateControls];
}

- (void)cycleDateChanged:(id)sender {
  self.cycleDateTextField.text = [self.cycleDatePicker.date classicDate];
}

- (IBAction)tryingToConceiveChanged:(UISwitch *)toggle {
  [UserProfile current].tryingToConceive = [NSNumber numberWithBool:self.tryingToConceive.on];

  [self commit];
}

- (IBAction)tryingToAvoidChanged:(UISwitch *)toggle {
  [UserProfile current].tryingToConceive = [NSNumber numberWithBool:!self.tryingToAvoid.on];

  [self commit];
}

- (void)updateControls {
  self.tryingToConceive.on = [[UserProfile current].tryingToConceive boolValue];
  self.tryingToAvoid.on =   ![[UserProfile current].tryingToConceive boolValue];
}

# pragma mark - Closing text inputs

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self.cycleDateTextField resignFirstResponder];
}

# pragma mark - View Navigation

- (IBAction)pushToNext:(id)sender {
  if(self.cycleDatePicker.date) {
    self.firstDay = [Day forDate:self.cycleDatePicker.date];
    if(!self.firstDay) {
      self.firstDay = [Day withAttributes:@{@"date": self.cycleDatePicker.date,
                                            @"idate": [self.cycleDatePicker.date classicDate],
                                            @"period": @""}];
    }
    [self.firstDay selectProperty:@"period" withindex:PERIOD_LIGHT];
    [self.firstDay save];
  }

  [self performSegueWithIdentifier:@"Profile1ToProfile2" sender:sender];
}

- (IBAction)skipOnboard:(id)sender {
  [self dismissViewControllerAnimated:TRUE completion:nil];
}

@end