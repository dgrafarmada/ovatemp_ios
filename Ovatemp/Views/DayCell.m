//
//  DayCell.m
//  Ovatemp
//
//  Created by Chris Cahoon on 2/12/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import "DayCell.h"
#import "UIAlertView+WithBlock.h"

@implementation DayCell

- (void)awakeFromNib{
  self.selectionStyle = UITableViewCellSelectionStyleNone;

  self.page1.backgroundColor = [UIColor whiteColor];
  self.page2.backgroundColor = DAY_EDIT_PAGE_COLOR;
  self.page3.backgroundColor = DAY_EDIT_PAGE_COLOR;

  [self initializeControls];
}

- (void)setDay:(Day *)day {
    _day = day;
    
  [self refreshControls];
}

- (void)refreshControls {
  NSLog(@"refreshControls not implemented for: %@", [self class]);
}

- (void)initializeControls {
  NSLog(@"initializeControls not implemented for %@", [self class]);
}

- (void)toggleDayProperty:(NSString *)key withIndex:(NSInteger)index {
  NSLog(@"cell toggling day: %@ with key %@ and index: %d", self.day, key, index);
  [self.day toggleProperty:key withIndex:index];
  [self refreshControls];
}

- (BOOL)isDayProperty:(NSString *)key ofType:(NSInteger)index {
  return [self.day isProperty:key ofType:index];
}

- (void)showCreateFormWithTitle:(NSString *)title andClass:(id)class {
  UIAlertView *form = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];

  [form setAlertViewStyle:UIAlertViewStylePlainTextInput];
  [form showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if([buttonTitle isEqualToString:@"Save"]) {
      [class createWithName:inputText success:^(NSDictionary *response) {
        [self refreshControls];
      }];
    }
  }];
}

@end
