//
//  TrackingSymptomsTableViewCell.m
//  Ovatemp
//
//  Created by Josh L on 11/7/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import "TrackingSymptomsTableViewCell.h"

@implementation TrackingSymptomsTableViewCell

NSArray *symptomsDataSource;

- (void)awakeFromNib {
    // Initialization code
    
    self.selectedDate = [[NSDate alloc] init];
    
    symptomsDataSource = [NSArray arrayWithObjects:@"Acne", @"Backache", @"Breast Tenderness", @"Constipation", @"Cramps", @"Diarrhea", @"Fatigue", @"Fever", @"Headache", @"Indigestion", @"Insomnia", @"Mood Swings", @"Nausea", @"PMS", @"Stress", @"Tired", @"Vaginal Pain", @"Vomiting", nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)didSelectInfoButton:(id)sender {
    // TODO: Present UIAlertController
}

#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [symptomsDataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    cell.textLabel.text = [symptomsDataSource objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.symptomsTableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    // TODO: Hit backend?
}

@end
