//
//  ONDOSettingViewController.h
//  Ovatemp
//
//  Created by Daniel Lozano on 4/9/15.
//  Copyright (c) 2015 Back Forty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ONDOSettingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *ondoSwitch;

- (IBAction)ondoSwitchChanged:(id)sender;

@end