//
//  CycleViewController.m
//  Ovatemp
//
//  Created by Chris Cahoon on 3/10/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import "CycleViewController.h"

#import "Calendar.h"
#import "CycleChartView.h"
#import "ILCycleViewController.h"

@interface CycleViewController () <CycleViewDelegate>

@property (nonatomic) UINavigationController *cycleNavVC;

@end

@implementation CycleViewController

- (id)init
{
  self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
  if (self) {
    self.delegate = self;
    self.dataSource = self;

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName: @"Tracking" bundle: nil];
    self.cycleNavVC = [mainStoryboard instantiateViewControllerWithIdentifier: @"ilcycleNavViewController"];
  }
  return self;
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
  self.view.backgroundColor = LIGHT;
    
  if ([Cycle fullyLoaded]) {
    [self loadCycle];
  } else {
    [self startLoading];
    [Cycle loadAllAnd:^(id response) {
      [self stopLoading];
      [self loadCycle];
    } failure:^(NSError *error) {
      [self stopLoading];
    }];
  }
}

- (void)loadCycle
{
  [Calendar resetDate];
  Day *day = [Calendar day];
  [self setCycle: day.cycle];
}

- (void)setCycle:(Cycle *)cycle
{
  UIViewController *vc = [self viewControllerWithCycle:cycle];
  [self setViewControllers:@[vc] direction: UIPageViewControllerNavigationDirectionForward animated: NO completion: nil];
}

- (UIViewController *)viewControllerWithCycle:(Cycle *)cycle
{
//    CycleChartView *chart = [[[NSBundle mainBundle] loadNibNamed:@"CycleChartView" owner:self options:nil] lastObject];
//    chart.delegate = self;
//
//    chart.cycle = cycle;
//    chart.landscape = TRUE;
//    chart.dateRangeLabel.text = cycle.rangeString;
//
//    UIViewController *vc = [[UIViewController alloc] init];
//    vc.view = chart;
//
//    return vc;
    
    ILCycleViewController *cycleVC = self.cycleNavVC.childViewControllers[0];
    cycleVC.selectedCycle = cycle;

    return self.cycleNavVC;
}

- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskLandscape;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
//  CycleChartView *otherChart = (CycleChartView *)viewController.view;
//  Cycle *cycle = [otherChart.cycle nextCycle];
    
    UINavigationController *cycleNavVC = (UINavigationController *)viewController;
    ILCycleViewController *cycleVC = cycleNavVC.childViewControllers[0];
    Cycle *cycle = [cycleVC.selectedCycle nextCycle];
    
  if (cycle) {
    return [self viewControllerWithCycle:cycle];
  }
  return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
//  CycleChartView *otherChart = (CycleChartView *)viewController.view;
//  Cycle *cycle = [otherChart.cycle previousCycle];
    
    UINavigationController *cycleNavVC = (UINavigationController *)viewController;
    ILCycleViewController *cycleVC = cycleNavVC.childViewControllers[0];
    Cycle *cycle = [cycleVC.selectedCycle previousCycle];
    
  if (cycle) {
    return [self viewControllerWithCycle:cycle];
  }
  return nil;
}

- (BOOL)shouldAutorotate
{
  return FALSE;
}

#pragma mark - CycleViewDelegate

- (void)pushAlertController:(UIAlertController *)alertController
{
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
