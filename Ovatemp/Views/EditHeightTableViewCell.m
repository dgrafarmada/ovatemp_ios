//
//  EditHeightTableViewCell.m
//  Ovatemp
//
//  Created by Josh L on 10/24/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import "EditHeightTableViewCell.h"

@implementation EditHeightTableViewCell

NSMutableArray *heightPickerFeetData;
NSMutableArray *heightPickerInchesData;

- (void)awakeFromNib {
    // Initialization code
    
    heightPickerFeetData = [[NSMutableArray alloc] init];
    heightPickerInchesData = [[NSMutableArray alloc] init];
    
    for (int i = 3; i < 7; i++) {
        [heightPickerFeetData addObject:[NSString stringWithFormat:@"%d'", i]];
    }
    
    for (int i = 0; i < 12; i++) {
        [heightPickerInchesData addObject:[NSString stringWithFormat:@"%d\"", i]];
    }
    
    self.heightPicker = [[UIPickerView alloc] init];
    
    self.heightPicker.delegate = self;
    
    // done bar
    UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    [doneToolbar sizeToFit];
    UIBarButtonItem *flexArea = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(endEditing:)];
    doneToolbar.items = @[flexArea, doneButton];
    self.heightField.inputAccessoryView = doneToolbar;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // default value
    [self.heightPicker selectRow:([defaults integerForKey:@"userHeightFeetComponent"] -3) inComponent:0 animated:NO]; // -3
    [self.heightPicker selectRow:[defaults integerForKey:@"userHeightInchesComponent"] inComponent:1 animated:NO];
    
    self.heightField.inputView = self.heightPicker;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UIPickerViewDelegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.heightField.text = [NSString stringWithFormat:@"%@ %@", [heightPickerFeetData objectAtIndex:[self.heightPicker selectedRowInComponent:0]], [heightPickerInchesData objectAtIndex:[self.heightPicker selectedRowInComponent:1]]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) { // Numbers
        return [heightPickerFeetData count];
        
    } else { // Units of Time
        return [heightPickerInchesData count];
    }
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0)
    {
        return [heightPickerFeetData objectAtIndex:row];
    }
    else
    {
        return [heightPickerInchesData objectAtIndex:row];
    }
}

@end