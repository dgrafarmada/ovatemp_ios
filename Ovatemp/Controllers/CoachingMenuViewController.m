//
//  CoachingMenuViewController.m
//  Ovatemp
//
//  Created by Chris Cahoon on 3/24/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import "CoachingMenuViewController.h"
#import "CoachingMenuCell.h"
#import "Day.h"

@interface CoachingMenuViewController ()

@property (nonatomic, strong) NSArray *rowNames;
@property (nonatomic, strong) NSArray *rowColors;

@end

@implementation CoachingMenuViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.rowNames = @[@"Acupressure",        @"Lifestyle",        @"Massage",           @"Meditation"];
    self.rowColors = @[Color(125, 205, 200), Color(84, 194, 187), Color(61, 175, 168), Color(37, 145, 138)];

    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [self.fertilityStatusView updateWithDay:[Day forDate:[NSDate date]]];
  self.profileImageView.image = [UIImage imageNamed:@"Refresh"];
  self.profileLabel.text = @"Refresh";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if([self.rowNames[indexPath.row] isEqualToString:@"Lifestyle"]) {
    [self performSegueWithIdentifier:@"PushLifestyleMenu" sender:self];
  }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.rowNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  CoachingMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoachingMenuCell"];
  cell.titleLabel.text = self.rowNames[indexPath.row];
  cell.iconImageView.image = [UIImage imageNamed:self.rowNames[indexPath.row]];
  cell.backgroundColor = self.rowColors[indexPath.row];

  return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return tableView.frame.size.height / self.rowNames.count;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end