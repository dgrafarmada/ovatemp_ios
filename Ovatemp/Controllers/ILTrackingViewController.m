//
//  ILTrackingViewController.m
//  Ovatemp
//
//  Created by Daniel Lozano on 3/10/15.
//  Copyright (c) 2015 Back Forty. All rights reserved.
//

#import "ILTrackingViewController.h"

#import "CycleViewController.h"
#import "CalendarViewController.h"
#import "ILCalendarViewController.h"
#import "WebViewController.h"
#import "TrackingNotesViewController.h"
#import "ConnectionManager.h"
#import "UserProfile.h"
#import "Alert.h"

#import "Calendar.h"
#import "Day.h"
#import "ONDO.h"

#import "TrackingStatusTableViewCell.h"
#import "TrackingTemperatureTableViewCell.h"
#import "TrackingCervicalFluidTableViewCell.h"
#import "TrackingCervicalPositionTableViewCell.h"
#import "TrackingPeriodTableViewCell.h"
#import "TrackingIntercourseTableViewCell.h"
#import "TrackingMoodTableViewCell.h"
#import "TrackingSymptomsTableViewCell.h"
#import "TrackingOvulationTestTableViewCell.h"
#import "TrackingPregnancyTestTableViewCell.h"
#import "TrackingSupplementsTableViewCell.h"
#import "TrackingMedicinesTableViewCell.h"

#import "DateCollectionViewCell.h"

@import HealthKit;

@interface ILTrackingViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,TrackingStatusCellDelegate,TrackingTemperatureCellDelegate,TrackingCervicalFluidCellDelegate,TrackingCervicalPositionCellDelegate,TrackingPeriodCellDelegate,TrackingIntercourseCellDelegate,TrackingMoodCellDelegate,TrackingSymptomsCellDelegate,TrackingOvulationTestCell,TrackingPregnancyCellDelegate,TrackingSupplementsCellDelegate,TrackingMedicinesCellDelegate,ILCalendarViewControllerDelegate,ONDODelegate>

@property (nonatomic) NSDate *selectedDate;
@property (nonatomic) NSDate *peakDate;

@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) NSIndexPath *selectedTableRowIndex;

@property (nonatomic) NSArray *trackingTableDataArray;
@property (nonatomic) NSMutableArray *drawerDateData;
@property (nonatomic) NSMutableArray *datesWithPeriod;
@property (nonatomic) NSMutableArray *daysFromBackend;

@property (nonatomic) Day *day;
@property (nonatomic) CycleViewController *cycleViewController;
@property (nonatomic) NSString *notes;

@property (nonatomic) NSNumber *selectedTemperature;

@property (nonatomic) BOOL lowerDrawer;
@property (nonatomic) BOOL inLandscape;

@property (nonatomic) UIActivityIndicatorView *activity;

@end

@implementation ILTrackingViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedDate = [NSDate date];
    self.lowerDrawer = YES;
    
    [self addOrientationObserver];
    [self setUpOndo];
    
    [self setTitleView];
    [self customizeAppearance];
    [self setTitleViewGestureRecognizer];
    [self setUpDrawerCollectionView];
    [self registerTableNibs];
    
    [self refreshDrawerCollectionViewData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"ShouldRotate"];
    [defaults synchronize];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    self.selectedIndexPath = [NSIndexPath indexPathForRow: 86 inSection:0];
    [self.drawerCollectionView scrollToItemAtIndexPath: self.selectedIndexPath atScrollPosition: UICollectionViewScrollPositionCenteredHorizontally animated: YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"ShouldRotate"];
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self removeOrientationObserver];
}

#pragma mark - ONDO

- (void)setUpOndo
{
    if ([ONDO sharedInstance].devices.count > 0) {
        [ONDO startWithDelegate: self];
    }
}

#pragma mark - Notifications

- (void)addOrientationObserver
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

}

- (void)removeOrientationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

#pragma mark - Appearance

- (void)customizeAppearance
{

}

- (void)startActivity
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
}

- (void)stopActivity
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

- (void)setTitleView
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    
    NSString *dateString = [df stringFromDate: self.selectedDate];
    self.titleLabel.text = dateString;
    
    if (self.day.cycleDay) {
        self.subtitleLabel.text = [NSString stringWithFormat:@"Cycle Day #%@", self.day.cycleDay];
    } else {
        self.subtitleLabel.text = [NSString stringWithFormat:@"Enter Cycle Info"];
    }
    
    if (!self.lowerDrawer) {
        // flip arrow if the drawer is already open
        self.arrowButton.transform = CGAffineTransformMakeRotation(M_PI);
    }
}

- (void)setTitleViewGestureRecognizer
{
    UITapGestureRecognizer *titleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(toggleDrawer:)];
    UITapGestureRecognizer *subtitleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(toggleDrawer:)];
    [self.titleLabel addGestureRecognizer: titleTapRecognizer];
    [self.subtitleLabel addGestureRecognizer: subtitleTapRecognizer];
    self.titleLabel.userInteractionEnabled = YES;
    self.subtitleLabel.userInteractionEnabled = YES;
}

- (void)setUpDrawerCollectionView
{
    // Initial setup
    
    self.drawerCollectionView.delegate = self;
    self.drawerCollectionView.dataSource = self;
    
    [self.drawerCollectionView registerNib: [UINib nibWithNibName: @"DateCollectionViewCell" bundle: [NSBundle mainBundle]]forCellWithReuseIdentifier: @"dateCvCell"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(50, 50)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    [self.drawerCollectionView setCollectionViewLayout:flowLayout];
    
    [self.drawerCollectionView setShowsHorizontalScrollIndicator: NO];
    [self.drawerCollectionView setShowsVerticalScrollIndicator: NO];
    
    // Add dates to collection view
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth: -3];
    
    NSDateComponents *dayOffset = [[NSDateComponents alloc] init];
    dayOffset.day = 3;
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDate *threeDaysAfterTodayDate = [currentCalendar dateByAddingComponents:dayOffset toDate:[NSDate date] options:0];
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    
    for (int i = 0; i < 90; i++) {
        dayComponent.day = -i;
        NSDate *previousDate = [currentCalendar dateByAddingComponents:dayComponent toDate:threeDaysAfterTodayDate options:0];
        [self.drawerDateData insertObject:previousDate atIndex:0];
    }
    
}

#pragma mark - Network

- (void)refreshTrackingView
{
    NSLog(@"REFRESH TRACKING VIEW");
    
    [ConnectionManager get: @"/cycles"
                    params: @{
                              @"date": [self.selectedDate dateId],
                              }
                   success:^(id response) {
                       
                       [Cycle cycleFromResponse: response];
                       self.day = [Day forDate: self.selectedDate];
                       if (!self.day) {
                           self.day = [Day withAttributes:@{@"date": self.selectedDate, @"idate": self.selectedDate.dateId}];
                       }
                       
                       NSDateFormatter* dtFormatter = [[NSDateFormatter alloc] init];
                       [dtFormatter setLocale:[NSLocale systemLocale]];
                       [dtFormatter setDateFormat:@"yyyy-MM-dd"];
                       self.peakDate = [dtFormatter dateFromString:[response objectForKey: @"peak_date"]];
                       
                       if (![self.day.cyclePhase isEqualToString:@"period"]) {
                           [self.datesWithPeriod removeObject: self.day.date];
                       }
                       
                       NSLog(@"REFRESH SUCCESS : RELOADING TABLE");
                       
                       [self reloadTableWithAnimation];
                       
                   }
                   failure:^(NSError *error) {
                       
                       NSLog(@"ERROR: %@", error.localizedDescription);
                       
                   }];
    
}

- (void)refreshDrawerCollectionViewData
{
    NSLog(@"REFRESH DAYS COLLECTION VIEW");
    
    [ConnectionManager get:@"/days"
                    params:@{
                             @"start_date": [self.drawerDateData firstObject],
                             @"end_date": [self.drawerDateData lastObject]
                             }
                   success:^(NSDictionary *response) {
                       //                       NSArray *orphanDays = response[@"days"];
                       NSArray *cycles = response[@"cycles"]; // array of dictionaries
                       // [cycles[0] objectForKey:@"days"] <- array of days
                       // [[[cycles[0] objectForKey:@"days"] objectAtIndex:0] objectForKey:@"date"]
                       for (NSDictionary *days in cycles) {
                           NSArray *daysArray = [days objectForKey:@"days"];
                           for (NSDictionary *day in daysArray) {
                               //                               NSLog(@"%@", [day objectForKey:@"date"]);
                               //                               [daysFromBackend addObject:[day objectForKey:@"date"]]; <- this will give you the date, we need the whole day dictionary
                               [self.daysFromBackend addObject:day];
                               
                               if ((![[day objectForKey:@"period"] isEqual:[NSNull null]])) {
                                   if ([[day objectForKey:@"period"] isEqualToString:@"spotting"] || [[day objectForKey:@"period"] isEqualToString:@"light"] || [[day objectForKey:@"period"] isEqualToString:@"medium"] || [[day objectForKey:@"period"] isEqualToString:@"heavy"]) {
                                       NSDateFormatter* dtFormatter = [[NSDateFormatter alloc] init];
                                       [dtFormatter setLocale:[NSLocale systemLocale]];
                                       [dtFormatter setDateFormat:@"yyyy-MM-dd"];
                                       NSDate *tempDate = [dtFormatter dateFromString:[day objectForKey:@"date"]];
                                       if (![self.datesWithPeriod containsObject:tempDate]) {
                                           // add date to dates with period array
                                           // if we have a spotting day right after a period day, it still counts as the period cycle phase
                                           [self.datesWithPeriod addObject:tempDate];
                                       }
                                   }
                               }
                               
                           }
                       }
                       
                       NSLog(@"REFRESH DAYS COLLECTION VIEW  : SUCCESS");
                       
                       [self.drawerCollectionView reloadData];
                       [self refreshTrackingView];
                   }
                   failure:^(NSError *error) {
                       NSLog(@"error: %@", error);
                   }];
}

#pragma mark - IBAction's

- (IBAction)openGraph:(id)sender
{
    // Don't present the chart here, just change device orientation and let the notification for changed orientation take care of presenting the view.
    [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
}

- (IBAction)openCalendar:(id)sender
{
    UINavigationController *navVC = [self.storyboard instantiateViewControllerWithIdentifier: @"navCalendarViewController"];
    ILCalendarViewController *calendarVC = navVC.childViewControllers[0];
    calendarVC.delegate = self;
    
    [self presentViewController: navVC animated: YES completion: nil];
}

- (IBAction)toggleDrawer:(id)sender
{
    [self.view layoutIfNeeded];
    
    if (self.lowerDrawer) {
        self.calendarTopConstraint.constant = 90;
        self.lowerDrawer = NO;
    }else{
        self.calendarTopConstraint.constant = 0;
        self.lowerDrawer = YES;
    }
    
    [UIView animateWithDuration: 0.5 delay: 0.0 usingSpringWithDamping: 0.6f initialSpringVelocity: 0.4f options: 0 animations:^{
        [self.view layoutIfNeeded];
        
        if (self.lowerDrawer) {
            self.arrowButton.transform = CGAffineTransformMakeRotation(M_PI * 180);
        }else{
            self.arrowButton.transform = CGAffineTransformMakeRotation(M_PI);
        }
        
    } completion:^(BOOL finished) {
        if (!self.lowerDrawer) {
            // refresh drawer when closed
            [self refreshDrawerCollectionViewData];
        }
    }];
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.trackingTableDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0:{
            // Status Cell
            cell = [tableView dequeueReusableCellWithIdentifier: @"statusCell" forIndexPath: indexPath];
            ((TrackingStatusTableViewCell *)cell).delegate = self;
            [((TrackingStatusTableViewCell *)cell) updateCell];
            
            break;
        }
        case 1:{
            // Temperature Cell
            cell = [tableView dequeueReusableCellWithIdentifier: @"tempCell" forIndexPath: indexPath];
            ((TrackingTemperatureTableViewCell *)cell).delegate = self;
            [((TrackingTemperatureTableViewCell *)cell) updateCell];
            
            if (self.selectedTemperature) {
                ((TrackingTemperatureTableViewCell *)cell).temperatureValueLabel.text = [NSString stringWithFormat: @"%.2f", [self.selectedTemperature floatValue]];
            }
            
            // Hide/Move Labels
            if (self.selectedTableRowIndex.row == 1) {
                [((TrackingTemperatureTableViewCell *)cell) setExpanded];
            }else{
                [((TrackingTemperatureTableViewCell *)cell) setMinimized];
            }
            break;
        }
        case 2:{
            // Cervical Fluid Cell
            cell = [tableView dequeueReusableCellWithIdentifier: @"cfCell" forIndexPath: indexPath];
            ((TrackingCervicalFluidTableViewCell *)cell).delegate = self;
            [((TrackingCervicalFluidTableViewCell *)cell) updateCell];
            
            // Hide/Move Labels
            if (self.selectedTableRowIndex.row == 2) {
                [((TrackingCervicalFluidTableViewCell *)cell) setExpanded];
            }else{
                [((TrackingCervicalFluidTableViewCell *)cell) setMinimized];
            }
            break;
        }
        case 3:{
            // Cervical Position Cell
            cell = [tableView dequeueReusableCellWithIdentifier: @"cpCell" forIndexPath: indexPath];
            ((TrackingCervicalPositionTableViewCell *)cell).delegate = self;
            [((TrackingCervicalPositionTableViewCell *)cell) updateCell];
            
            // Hide/Move Labels
            if (self.selectedTableRowIndex.row == 3) {
                [((TrackingCervicalPositionTableViewCell *)cell) setExpanded];
            }else{
                [((TrackingCervicalPositionTableViewCell *)cell) setMinimized];
            }
            break;
        }
        case 4:{
            // Period Cell
            cell = [tableView dequeueReusableCellWithIdentifier: @"periodCell" forIndexPath: indexPath];
            ((TrackingPeriodTableViewCell *)cell).delegate = self;
            [((TrackingPeriodTableViewCell *)cell) updateCell];
            
            // Hide/Move Labels
            if (self.selectedTableRowIndex.row == 4) {
                [((TrackingPeriodTableViewCell *)cell) setExpanded];
            }else{
                [((TrackingPeriodTableViewCell *)cell) setMinimized];
            }
            break;
        }
        case 5:{
            // Intercourse Cell
            cell = [self.tableView dequeueReusableCellWithIdentifier: @"intercourseCell" forIndexPath: indexPath];
            ((TrackingIntercourseTableViewCell *)cell).delegate = self;
            [((TrackingIntercourseTableViewCell *)cell) updateCell];
            
            // Hide/Move Labels
            if (self.selectedTableRowIndex.row == 5) {
                [((TrackingIntercourseTableViewCell *)cell) setExpanded];
            }else{
                [((TrackingIntercourseTableViewCell *)cell) setMinimized];
            }
            break;
        }
        case 6:{
            // Mood Cell
            cell = [self.tableView dequeueReusableCellWithIdentifier: @"moodCell" forIndexPath: indexPath];
            ((TrackingMoodTableViewCell *)cell).delegate = self;
            [((TrackingMoodTableViewCell *)cell) updateCell];
            
            // Hide/Move Labels
            if (self.selectedTableRowIndex.row == 6) {
                [((TrackingMoodTableViewCell *)cell) setExpanded];
            }else{
                [((TrackingMoodTableViewCell *)cell) setMinimized];
            }
            break;
        }
        case 7:{
            // Symptoms Cell
            cell = [tableView dequeueReusableCellWithIdentifier: @"symptomsCell" forIndexPath: indexPath];
            ((TrackingSymptomsTableViewCell *)cell).delegate = self;
            [((TrackingSymptomsTableViewCell *)cell) updateCell];
            
            // Hide/Move Labels
            if (self.selectedTableRowIndex.row == 7) {
                [((TrackingSymptomsTableViewCell *)cell) setExpanded];
            }else{
                [((TrackingSymptomsTableViewCell *)cell) setMinimized];
            }
            break;
        }
        case 8:{
            // Ovulation Cell
            cell = [self.tableView dequeueReusableCellWithIdentifier: @"ovulationCell" forIndexPath: indexPath];
            ((TrackingOvulationTestTableViewCell *)cell).delegate = self;
            [((TrackingOvulationTestTableViewCell *)cell) updateCell];
            
            // Hide/Move Labels
            if (self.selectedTableRowIndex.row == 8) {
                [((TrackingOvulationTestTableViewCell *)cell) setExpanded];
            }else{
                [((TrackingOvulationTestTableViewCell *)cell) setMinimized];
            }
            break;
        }
        case 9:{
            // Pregnancy Cell
            cell = [tableView dequeueReusableCellWithIdentifier: @"pregnancyCell" forIndexPath: indexPath];
            ((TrackingPregnancyTestTableViewCell *)cell).delegate = self;
            [((TrackingPregnancyTestTableViewCell *)cell) updateCell];
            
            // Hide/Move Labels
            if (self.selectedTableRowIndex.row == 9) {
                [((TrackingPregnancyTestTableViewCell *)cell) setExpanded];
            }else{
                [((TrackingPregnancyTestTableViewCell *)cell) setMinimized];
            }
            break;
        }
        case 10:{
            // Supplements Cell
            cell = [tableView dequeueReusableCellWithIdentifier: @"supplementsCell" forIndexPath: indexPath];
            ((TrackingSupplementsTableViewCell *)cell).delegate = self;
            [((TrackingSupplementsTableViewCell *)cell) updateCell];
            
            // Hide/Move Labels
            if (self.selectedTableRowIndex.row == 10) {
                [((TrackingSupplementsTableViewCell *)cell) setExpanded];
            }else{
                [((TrackingSupplementsTableViewCell *)cell) setMinimized];
            }
            break;
        }
        case 11:{
            // Medicines Cell
            cell = [tableView dequeueReusableCellWithIdentifier: @"medicinesCell" forIndexPath: indexPath];
            ((TrackingMedicinesTableViewCell *)cell).delegate = self;
            [((TrackingMedicinesTableViewCell *)cell) updateCell];
            
            // Hide/Move Labels
            if (self.selectedTableRowIndex.row == 11) {
                [((TrackingMedicinesTableViewCell *)cell) setExpanded];
            }else{
                [((TrackingMedicinesTableViewCell *)cell) setMinimized];
            }
            break;
        }
        default:
            break;
    }
    
    [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 190;
    }
    
    if(self.selectedTableRowIndex && indexPath.row == self.selectedTableRowIndex.row) {
        if (indexPath.row == 1) {
            return 200.0f;
        } else if (indexPath.row == 6  || indexPath.row == 7 || indexPath.row == 10 || indexPath.row == 11) {
            return 200.0f;
        } else {
            return 150.0f;
        }
    }
    
    return 64.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self uploadSelectedTemperature];
    
    if (self.selectedTableRowIndex.row == indexPath.row) {
        self.selectedTableRowIndex = nil;
        
    }else{
        NSIndexPath *oldIndexPath = self.selectedTableRowIndex;
        self.selectedTableRowIndex = indexPath;
        
        if (oldIndexPath) {
            [self.tableView reloadRowsAtIndexPaths: @[oldIndexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];

}

#pragma mark - UICollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.drawerDateData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DateCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"dateCvCell" forIndexPath:indexPath];
    NSDate *cellDate = [self.drawerDateData objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"EEE"];
    NSString *dayOfWeek = [[formatter stringFromDate:cellDate] uppercaseString];
    [formatter setDateFormat:@"d"];
    NSString *day = [formatter stringFromDate:cellDate];
    
    cell.monthLabel.text = dayOfWeek;
    cell.dayLabel.text = day;

    // MAKE CELL LARGER IF IS SELECTED
    if (indexPath.row == self.selectedIndexPath.row) {
        CGRect cellFrame = cell.frame;
        cellFrame.size.height = 54.0f;
        cellFrame.size.width = 44.0f;
        cell.frame = cellFrame;
    } else {
        CGRect cellFrame = cell.frame;
        cellFrame.size.height = 44.0f;
        cellFrame.size.width = 44.0f;
        cell.frame = cellFrame;
    }
    
    // CELL IS IN THE FUTURE
    if ([cellDate compare:[NSDate date]] == NSOrderedDescending) {
        cell.statusImageView.image = [UIImage imageNamed:@"icn_dd_empty state_small"];
        cell.monthLabel.textColor = [UIColor ovatempGreyColorForDateCollectionViewCells];
        cell.dayLabel.textColor = [UIColor ovatempGreyColorForDateCollectionViewCells];
        
        return cell;
    }
    
    for (NSDictionary *dayDict in self.daysFromBackend) {
        
        NSDateFormatter *dtFormatter = [[NSDateFormatter alloc] init];
        [dtFormatter setLocale:[NSLocale systemLocale]];
        [dtFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *dateFromBackend = [dtFormatter dateFromString:[dayDict objectForKey:@"date"]];
        
        if ([[dtFormatter stringFromDate:cellDate] isEqualToString:[dtFormatter stringFromDate:dateFromBackend]]) {

            NSString *cyclePhase = [dayDict objectForKey:@"cycle_phase"];
            BOOL useOldCyclePhase = YES;
            NSString *oldCyclePhase = cyclePhase;
            
            for (NSDate *periodDate in self.datesWithPeriod) {
                if ([[dtFormatter stringFromDate:cellDate] isEqualToString:[dtFormatter stringFromDate:periodDate]]) {
                    cyclePhase = @"period";
                    useOldCyclePhase = NO;
                }
            }
            
            if (useOldCyclePhase) {
                cyclePhase = oldCyclePhase;
            }
            
            // if this cell is spotting and the day before did not have a period, cell is not fertile
            if (![[dayDict objectForKey:@"period"] isEqual:[NSNull null]]) {
                if ([[dayDict objectForKey:@"period"] isEqualToString:@"spotting"]) {
                    // check if cell the day before had a period
                    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
                    dayComponent.day = -1;
                    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
                    NSDate *dayBeforeCellDate = [currentCalendar dateByAddingComponents:dayComponent toDate:cellDate options:0];
                    
                    NSDateFormatter *dtFormatter = [[NSDateFormatter alloc] init];
                    [dtFormatter setLocale:[NSLocale systemLocale]];
                    [dtFormatter setDateFormat:@"yyyy-MM-dd"];
                    
                    BOOL dayBeforeHadPeriod = NO;
                    
                    for (NSDate *periodDate in self.datesWithPeriod) {
                        if ([[dtFormatter stringFromDate:periodDate] isEqualToString:[dtFormatter stringFromDate:dayBeforeCellDate]]) {
                            dayBeforeHadPeriod = YES;
                        }
                    }
                    
                    if (!dayBeforeHadPeriod) {
                        // return not fertile cell
                        cell.statusImageView.image = [UIImage imageNamed:@"icn_pulldown_notfertile_small"];
                        cell.monthLabel.textColor = [UIColor whiteColor];
                        cell.dayLabel.textColor = [UIColor whiteColor];
                        return cell;
                    }
                    
                }
                
            }
            
            if ([cyclePhase isKindOfClass:[NSString class]]) {
                
                UserProfile *currentUserProfile = [UserProfile current];
                
                NSNumber *inFertilityWindowNumber = (NSNumber *)[dayDict objectForKey: @"in_fertility_window"];
                
                if ([inFertilityWindowNumber boolValue] == YES) {
                    if (currentUserProfile.tryingToConceive) {
                        // green fertility image
                        cell.statusImageView.image = [UIImage imageNamed:@"icn_pulldown_fertile_small"];
                        cell.monthLabel.textColor = [UIColor whiteColor];
                        cell.dayLabel.textColor = [UIColor whiteColor];
                        return cell;
                    } else { // avoid
                        // red fertility image
                        cell.statusImageView.image = [UIImage imageNamed:@"icn_dd_fertile_small"];
                        cell.monthLabel.textColor = [UIColor whiteColor];
                        cell.dayLabel.textColor = [UIColor whiteColor];
                        return cell;
                    }
                }
                
                if ([cyclePhase isEqualToString:@"period"]) { // if it's not null
                    
                    cell.statusImageView.image = [UIImage imageNamed:@"icn_period"];
                    // change text color
                    cell.monthLabel.textColor = [UIColor whiteColor];
                    cell.dayLabel.textColor = [UIColor whiteColor];
                    return cell;
                    
                } else if ([cyclePhase isEqualToString:@"ovulation"]) { // fertile
                    
                    if (currentUserProfile.tryingToConceive) {
                        // green fertility image
                        cell.statusImageView.image = [UIImage imageNamed:@"icn_pulldown_fertile_small"];
                    } else {
                        // trying to avoid, red fertility image
                        cell.statusImageView.image = [UIImage imageNamed:@"icn_dd_fertile_small"];
                    }
                    cell.monthLabel.textColor = [UIColor whiteColor];
                    cell.dayLabel.textColor = [UIColor whiteColor];
                    return cell;
                    
                } else if ([cyclePhase isEqualToString:@"preovulation"]) { // not fertile
                    
                    if (![[dayDict objectForKey:@"cervical_fluid"] isEqual:[NSNull null]]) {
                        if (([[dayDict objectForKey:@"cervical_fluid"] isEqualToString:@"dry"]) && !currentUserProfile.tryingToConceive) {
                            cell.statusImageView.image = [UIImage imageNamed:@"icn_dd_notfertile_small"];
                        } else if (([[dayDict objectForKey:@"cervical_fluid"] isEqualToString:@"sticky"]) && !currentUserProfile.tryingToConceive) {
                            // red fertile asset
                            cell.statusImageView.image = [UIImage imageNamed:@"icn_dd_fertile_small"];
                        }
                        else {
                            cell.statusImageView.image = [UIImage imageNamed:@"icn_pulldown_notfertile_small"];
                        }
                    } else {
                        cell.statusImageView.image = [UIImage imageNamed:@"icn_pulldown_notfertile_small"];
                    }
                    cell.monthLabel.textColor = [UIColor whiteColor];
                    cell.dayLabel.textColor = [UIColor whiteColor];
                    return cell;
                    
                } else if ([cyclePhase isEqualToString:@"postovulation"]) { // not fertile
                    
                    cell.statusImageView.image = [UIImage imageNamed:@"icn_pulldown_notfertile_small"];
                    cell.monthLabel.textColor = [UIColor whiteColor];
                    cell.dayLabel.textColor = [UIColor whiteColor];
                    return cell;
                    
                }
            }
        }

    }
    
    cell.statusImageView.image = [UIImage imageNamed:@"icn_pulldown_notfertile_empty"];
    cell.monthLabel.textColor = [UIColor ovatempGreyColorForDateCollectionViewCells];
    cell.dayLabel.textColor = [UIColor ovatempGreyColorForDateCollectionViewCells];

    return cell;
}

#pragma mark - UICollectionView Delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath == self.selectedIndexPath) {
        return CGSizeMake(44, 54);
    }
    
    return CGSizeMake(44, 44);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *dateAtIndex = [self.drawerDateData objectAtIndex:indexPath.row];
    
    if ([dateAtIndex compare:[NSDate date]] == NSOrderedDescending) {
        // today is earlier than selected date, don't allow user to access that date
        return;
    }
    
    if (self.selectedDate == dateAtIndex) {
        // do nothing, select date is the date we're already on
        return;
    }
    
    self.selectedDate = dateAtIndex;
    self.selectedIndexPath = indexPath;
    
    [self.drawerCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    DateCollectionViewCell *selectedCell = (DateCollectionViewCell *)[self.drawerCollectionView cellForItemAtIndexPath:indexPath];
    
    CGRect cellFrame = selectedCell.frame;
    cellFrame.size.height += 5;
    selectedCell.frame = cellFrame;
    
    [self.drawerCollectionView reloadData];
    [self.drawerCollectionView.collectionViewLayout invalidateLayout];
    
    [[self.drawerCollectionView cellForItemAtIndexPath: indexPath] setNeedsDisplay];
    
    [self refreshTrackingView];
    [self setTitleView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView == self.drawerCollectionView && decelerate == NO) {
        NSLog(@"Centering Cell");
        [self centerCell];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.drawerCollectionView) {
        NSLog(@"Centering Cell");
        [self centerCell];
    }
}

- (void)centerCell
{
    NSIndexPath *pathForCenterCell = [self.drawerCollectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(self.drawerCollectionView.bounds), CGRectGetMidY(self.drawerCollectionView.bounds))];
    
    // we need +/- 10 as an offset here in case the user scrolls in between two cells, the indexPath will never be nil we will always snap to a cell
    
    if (!pathForCenterCell) {
        pathForCenterCell = [self.drawerCollectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(self.drawerCollectionView.bounds) - 10, CGRectGetMidY(self.drawerCollectionView.bounds))];
    }
    
    if (!pathForCenterCell) {
        pathForCenterCell = [self.drawerCollectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(self.drawerCollectionView.bounds) + 10, CGRectGetMidY(self.drawerCollectionView.bounds))];
    }
    
    if (!pathForCenterCell) { // still nil
        // I tried
        NSLog(@"You're Tearing Me Apart, Lisa!");
        return; // Oh Hi Mark
    }
    
    [self.drawerCollectionView scrollToItemAtIndexPath:pathForCenterCell atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    self.selectedIndexPath = pathForCenterCell;
    [self.drawerCollectionView reloadData];
    
    [self collectionView: self.drawerCollectionView didSelectItemAtIndexPath: pathForCenterCell];
}

#pragma mark - TrackingStatusCell Delegate

- (void)pressedNotes
{
    TrackingNotesViewController *trackingVC = [self.storyboard instantiateViewControllerWithIdentifier: @"trackingNotesViewController"];
    trackingVC.selectedDate = self.selectedDate;
    trackingVC.notesText = self.notes;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController: trackingVC];
    
    [self presentViewController: navVC animated: YES completion: nil];
}

- (NSMutableArray *)getDatesWithPeriod
{
    return self.datesWithPeriod;
}

- (NSDate *)getSelectedDate
{
    return self.selectedDate;
}

- (Day *)getSelectedDay
{
    return self.day;
}

- (NSDate *)getPeakDate
{
    return self.peakDate;
}

- (NSString *)getNotes
{
    return self.notes;
}

- (BOOL)usedOndo
{
    return NO;
}

#pragma mark - Cell Delegate's

- (void)didSelectTemperature:(NSNumber *)temperature
{
    self.selectedTemperature = temperature;
    self.day.usedOndo = NO;
}

- (void)didSelectDisturbance:(BOOL)disturbance
{
    [self uploadDisturbance: disturbance];
}

- (void)didSelectCervicalFluidType:(id)type
{
    NSDictionary *params = @{@"log_name" : @"CERVICAL FLUID TYPE",
                             @"attribute_key" : @"cervical_fluid",
                             @"attribute_data" : type,
                             @"notification_id" : @"cf",
                             @"index_path_row" : @2,
                             @"skip_reload" : [NSNumber numberWithBool: NO]};
    
    [self uploadWithParameters: params];
}

- (void)didSelectCervicalPositionType:(id)type
{
    NSDictionary *params = @{@"log_name" : @"CERVICAL POSITION TYPE",
                             @"attribute_key" : @"cervical_position",
                             @"attribute_data" : type,
                             @"notification_id" : @"cp",
                             @"index_path_row" : @3,
                             @"skip_reload" : [NSNumber numberWithBool: NO]
                             };
    
    [self uploadWithParameters: params];
}

- (void)didSelectPeriodWithType:(id)type
{
    NSDictionary *params = @{@"log_name" : @"PERIOD TYPE",
                             @"attribute_key" : @"period",
                             @"attribute_data" : type,
                             @"notification_id" : @"period",
                             @"index_path_row" : @4,
                             @"skip_reload" : [NSNumber numberWithBool: NO]
                             };
    
    [self uploadWithParameters: params];
}

- (void)didSelectIntercourseWithType:(id)type
{
    NSDictionary *params = @{@"log_name" : @"INTERCOURSE TYPE",
                             @"attribute_key" : @"intercourse",
                             @"attribute_data" : type,
                             @"notification_id" : @"intercourse",
                             @"index_path_row" : @5,
                             @"skip_reload" : [NSNumber numberWithBool: NO]
                             };
    
    [self uploadWithParameters: params];
}

- (void)didSelectMoodWithType:(id)type
{
    NSDictionary *params = @{@"log_name" : @"MOOD TYPE",
                             @"attribute_key" : @"mood",
                             @"attribute_data" : type,
                             @"notification_id" : @"mood",
                             @"index_path_row" : @6,
                             @"skip_reload" : [NSNumber numberWithBool: YES]
                             };
    
    [self uploadWithParameters: params];
}

- (void)didSelectSymptomsWithTypes:(NSMutableArray *)types
{
    NSDictionary *params = @{@"log_name" : @"SYMPTOMS TYPE",
                             @"attribute_key" : @"symptom_ids",
                             @"attribute_data" : types,
                             @"notification_id" : @"symptoms",
                             @"index_path_row" : @7,
                             @"skip_reload" : [NSNumber numberWithBool: YES]
                             };
    
    [self uploadWithParameters: params];
}

- (void)didSelectOvulationWithType:(id)type
{
    NSDictionary *params = @{@"log_name" : @"OVULATION TEST",
                             @"attribute_key" : @"opk",
                             @"attribute_data" : type,
                             @"notification_id" : @"ovulation",
                             @"index_path_row" : @8,
                             @"skip_reload" : [NSNumber numberWithBool: NO]
                             };
    
    [self uploadWithParameters: params];
}

- (void)didSelectPregnancyWithType:(id)type
{
    NSDictionary *params = @{@"log_name" : @"PREGNANCY TEST",
                             @"attribute_key" : @"ferning",
                             @"attribute_data" : type,
                             @"notification_id" : @"pregnancy",
                             @"index_path_row" : @9,
                             @"skip_reload" : [NSNumber numberWithBool: NO]
                             };
    
    [self uploadWithParameters: params];
}

- (void)presentViewControllerWithViewController:(UIViewController *)viewController
{
    [self presentViewController: viewController animated: YES completion:nil];
}

#pragma mark - TrackingSupplementsCell Delegate
#pragma mark - TrackingMedicinesCell Delegate

#pragma mark - ILCalendarView Delegate

- (void)didSelectDateInCalendar:(NSDate *)date
{
    [self dismissViewControllerAnimated: YES completion:^{
        
        NSIndexPath *indexPath = [self getIndexPathForDate: date];
        [self collectionView: self.drawerCollectionView didSelectItemAtIndexPath: indexPath];
        
    }];
    
}

- (NSIndexPath *)getIndexPathForDate:(NSDate *)date
{
    for (int i = 0; i < [self.drawerDateData count]; i++) {
        
        NSDate *drawerDate = self.drawerDateData[i];
        
        unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSDateComponents *dateComponents = [calendar components: flags fromDate: date];
        NSDateComponents *drawerDateComponents = [calendar components: flags fromDate: drawerDate];
        
        NSDate *dateOnly = [calendar dateFromComponents: dateComponents];
        NSDate *drawerDateOnly = [calendar dateFromComponents: drawerDateComponents];
        
        
        if ([drawerDateOnly isEqualToDate: dateOnly]) {
            return [NSIndexPath indexPathForItem: i inSection: 0];
        }
    }
    
    return nil;
}

#pragma mark - Orientation/Cycle Chart

- (void)orientationChanged:(NSNotification *)notification
{
    BOOL isAnimating = self.cycleViewController.isBeingPresented || self.cycleViewController.isBeingDismissed;
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShouldRotate"]) {
            self.inLandscape = YES;
            if (!isAnimating) {
                [self showCycleViewController];
            }
        }
    } else {
        self.inLandscape = NO;
        if (!isAnimating) {
            [self hideCycleViewController];
        }
    }
}

- (void)hideCycleViewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.inLandscape) {
            [self showCycleViewController];
        }
    }];
}

- (void)showCycleViewController
{
    [self performSelector: @selector(presentChart) withObject:nil afterDelay:1.0];
}

- (void)presentChart
{
    //    [self pushViewController:self.cycleViewController];
}

#pragma mark - ONDO Delegate

- (void)ONDOsaysBluetoothIsDisabled:(ONDO *)ondo
{
    [Alert showAlertWithTitle: @"Bluetooth is Off"
                      message: @"Bluetooth is off, so we can't detect a thing"];
}

- (void)ONDOsaysLEBluetoothIsUnavailable:(ONDO *)ondo
{
    [Alert showAlertWithTitle: @"LE Bluetooth Unavailable"
                      message: @"Your device does not support low-energy Bluetooth, so it can't connect to your ONDO"];
}

- (void)ONDO:(ONDO *)ondo didEncounterError:(NSError *)error
{
    [Alert presentError: error];
}

- (void)ONDO:(ONDO *)ondo didReceiveTemperature:(CGFloat)temperature
{
    float tempInCelsius = temperature;
    temperature = temperature * 9.0f / 5.0f + 32.0f;

    if ((tempInCelsius < 0) || (temperature < 0)) {
        [Alert showAlertWithTitle: @"Error"
                          message: @"There was a problem taking your temperature, please try again.\n"];
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL tempPrefFahrenheit = [defaults boolForKey:@"temperatureUnitPreferenceFahrenheit"];

    NSString *temperatureString;

    if (tempPrefFahrenheit) {
        temperatureString = [NSString stringWithFormat: @"Recorded a temperature of %.2fºF for today", temperature];
        self.selectedTemperature = [NSNumber numberWithFloat: temperature];
    } else {
        temperatureString = [NSString stringWithFormat: @"Recorded a temperature of %.2fºC for today", tempInCelsius];
        self.selectedTemperature = [NSNumber numberWithFloat: tempInCelsius];
    }
    
    self.day.usedOndo = YES;
    
    [self uploadSelectedTemperature];
    
    //[Alert showAlertWithTitle: @"Temperature Recorded" message: temperatureString];
}

#pragma mark - Network

- (void)uploadSelectedTemperature
{
    // Check if there has been a change in the selected temperature, if yes, post to backend.
    
    if (!self.selectedTemperature) {
        return;
    }
    
    if ([self.selectedTemperature floatValue] == [self.day.temperature floatValue]) {
        return;
    }
    
    NSLog(@"ILTrackingVC : UPLOADING SELECTED TEMPERATURE");
    
    float tempInFahrenheit;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey: @"temperatureUnitPreferenceFahrenheit"]) {
        tempInFahrenheit = (([self.selectedTemperature floatValue] * 1.8000f) + 32);
    } else {
        tempInFahrenheit = [self.selectedTemperature floatValue];
    }
    
    [self updateHealthKitWithTemp: tempInFahrenheit];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd"];
    
    NSString *stringDateForBackend = [formatter stringFromDate: self.selectedDate];
    [attributes setObject: stringDateForBackend forKey: @"date"];
    [attributes setObject: [NSNumber numberWithFloat: tempInFahrenheit] forKey: @"temperature"];
    [attributes setObject: [NSNumber numberWithBool: self.day.usedOndo] forKeyedSubscript: @"used_ondo"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"temp_start_activity" object: self];
    
    [ConnectionManager put:@"/days/"
                    params:@{
                             @"day": attributes,
                             }
                   success:^(NSDictionary *response) {
                       
                       NSLog(@"ILTrackingVC : UPLOADING SELECTED TEMPERATURE SUCCESS");
                       
                       [Cycle cycleFromResponse: response];
                       [Calendar setDate: self.selectedDate];
                       
                       self.selectedTemperature = nil;
                       
                       [self.tableView reloadRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: 1 inSection: 0]] withRowAnimation: UITableViewRowAnimationNone];
                       
                       [[NSNotificationCenter defaultCenter] postNotificationName: @"temp_stop_activity" object: self];
                   }
                   failure:^(NSError *error) {
                       NSLog(@"ILTrackingVC : UPLOADING SELECTED TEMPERATURE FAILURE");
                       [Alert presentError:error];
                       [self stopActivity];
                       [[NSNotificationCenter defaultCenter] postNotificationName: @"temp_stop_activity" object: self];
                   }];
}

- (void)uploadDisturbance:(BOOL)disturbance
{
    NSLog(@"ILTrackingVC : UPLOADING DISTURBANCE");
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject: self.selectedDate forKey: @"date"];
    [attributes setObject: [NSNumber numberWithBool: disturbance] forKey: @"disturbance"];
    
    [self startActivity];
    
    [ConnectionManager put:@"/days/"
                    params:@{
                             @"day": attributes,
                             }
                   success:^(NSDictionary *response) {
                       NSLog(@"ILTrackingVC : UPLOADING DISTURBANCE : SUCCESS");
                       
                       [Cycle cycleFromResponse:response];
                       [Calendar setDate: self.selectedDate];
                       
                       [self stopActivity];
                   }
                   failure:^(NSError *error) {
                       NSLog(@"ILTrackingVC : UPLOADING DISTURBANCE FAILURE");
                       [Alert presentError:error];
                       [self stopActivity];
                   }];
}

- (void)uploadWithParameters:(NSDictionary *)params
{
    NSString *logName = params[@"log_name"];
    NSString *attributeKey = params[@"attribute_key"];
    NSString *attributeData = params[@"attribute_data"];
    NSString *notificationId = params[@"notification_id"];
    NSNumber *indexPathRow = params[@"index_path_row"];
    
    NSNumber *skipReloadNum = params[@"skip_reload"];
    BOOL skipReload = [skipReloadNum boolValue];
    
    NSLog(@"ILTrackingVC : UPLOADING %@", logName);
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    
    [attributes setObject: attributeData forKey: attributeKey];
    [attributes setObject: self.selectedDate forKey: @"date"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: [NSString stringWithFormat: @"%@_start_activity", notificationId] object: self];
    
    [ConnectionManager put:@"/days/"
                    params:@{
                             @"day": attributes,
                             }
                   success:^(NSDictionary *response) {
                       
                       NSLog(@"ILTrackingVC : UPLOADING %@ : SUCCESS", logName);
                       [Cycle cycleFromResponse:response];
                       [Calendar setDate: self.selectedDate];
                       
                       if (!skipReload) {
                           self.selectedTableRowIndex = nil;
                           [self.tableView reloadRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: [indexPathRow integerValue] inSection: 0]]
                                                 withRowAnimation: UITableViewRowAnimationAutomatic];

                       }
                       
                       [[NSNotificationCenter defaultCenter] postNotificationName: [NSString stringWithFormat: @"%@_stop_activity", notificationId] object: self];
                       
                   }
                   failure:^(NSError *error) {
                       
                       NSLog(@"ILTrackingVC : UPLOADING %@ : FAILURE", logName);
                       [Alert presentError:error];
                       
                       [[NSNotificationCenter defaultCenter] postNotificationName: [NSString stringWithFormat: @"%@_stop_activity", notificationId] object: self];
                   }];
}

# pragma mark - HealthKit

- (void)updateHealthKitWithTemp:(float)temp
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey: HKCONNECTION]) {
        if(temp) {
            NSString *identifier = HKQuantityTypeIdentifierBodyTemperature;
            HKQuantityType *tempType = [HKObjectType quantityTypeForIdentifier:identifier];
            
            HKQuantity *myTemp = [HKQuantity quantityWithUnit:[HKUnit degreeFahrenheitUnit]
                                                  doubleValue: temp];
            
            HKQuantitySample *temperatureSample = [HKQuantitySample quantitySampleWithType: tempType
                                                                                  quantity: myTemp
                                                                                 startDate: self.selectedDate
                                                                                   endDate: self.selectedDate
                                                                                  metadata: nil];
            HKHealthStore *healthStore = [[HKHealthStore alloc] init];
            [healthStore saveObject: temperatureSample withCompletion:^(BOOL success, NSError *error) {
                NSLog(@"I saved to healthkit");
            }];
        }
    }
    else {
        NSLog(@"Could not save to healthkit. No connection could be made");
    }
}

#pragma mark - Helper's

- (void)reloadTableWithAnimation
{
    for (int i = 0; i <= 11; i++) {
        [self.tableView reloadRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: i inSection: 0]] withRowAnimation: UITableViewRowAnimationAutomatic];
    }
}

- (void)registerTableNibs
{
    [[self tableView] registerNib:[UINib nibWithNibName:@"TrackingStatusTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"statusCell"];
    [[self tableView] registerNib:[UINib nibWithNibName:@"TrackingTemperatureTableViewCell" bundle:nil] forCellReuseIdentifier:@"tempCell"];
    [[self tableView] registerNib:[UINib nibWithNibName:@"TrackingCervicalFluidTableViewCell" bundle:nil] forCellReuseIdentifier:@"cfCell"];
    [[self tableView] registerNib:[UINib nibWithNibName:@"TrackingCervicalPositionTableViewCell" bundle:nil] forCellReuseIdentifier:@"cpCell"];
    [[self tableView] registerNib:[UINib nibWithNibName:@"TrackingPeriodTableViewCell" bundle:nil] forCellReuseIdentifier:@"periodCell"];
    [[self tableView] registerNib:[UINib nibWithNibName:@"TrackingIntercourseTableViewCell" bundle:nil] forCellReuseIdentifier:@"intercourseCell"];
    [[self tableView] registerNib:[UINib nibWithNibName:@"TrackingMoodTableViewCell" bundle:nil] forCellReuseIdentifier:@"moodCell"];
    [[self tableView] registerNib:[UINib nibWithNibName:@"TrackingSymptomsTableViewCell" bundle:nil] forCellReuseIdentifier:@"symptomsCell"];
    [[self tableView] registerNib:[UINib nibWithNibName:@"TrackingOvulationTestTableViewCell" bundle:nil] forCellReuseIdentifier:@"ovulationCell"];
    [[self tableView] registerNib:[UINib nibWithNibName:@"TrackingPregnancyTestTableViewCell" bundle:nil] forCellReuseIdentifier:@"pregnancyCell"];
    [[self tableView] registerNib:[UINib nibWithNibName:@"TrackingSupplementsTableViewCell" bundle:nil] forCellReuseIdentifier:@"supplementsCell"];
    [[self tableView] registerNib:[UINib nibWithNibName:@"TrackingMedicinesTableViewCell" bundle:nil] forCellReuseIdentifier:@"medicinesCell"];
}

- (void)pushInfoAlertWithTitle:(NSString *)title AndMessage:(NSString *)message AndURL:(NSString *)url
{
    UIAlertController *infoAlert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *gotIt = [UIAlertAction actionWithTitle:@"Got it"
                                                    style:UIAlertActionStyleDefault
                                                  handler:nil];
    
    UIAlertAction *learnMore = [UIAlertAction actionWithTitle:@"Learn more"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          
                                                          WebViewController *webViewController = [WebViewController withURL:url];
                                                          webViewController.title = title;
                                                          
                                                          [self presentViewController: webViewController animated: YES completion: nil];
                                                          
                                                      }];
    
    [infoAlert addAction:gotIt];
    [infoAlert addAction:learnMore];
    infoAlert.view.tintColor = [UIColor ovatempAquaColor];
    
    [self presentViewController:infoAlert animated:YES completion:nil];
}

#pragma mark - Set/Get

- (NSArray *)trackingTableDataArray
{
    if (!_trackingTableDataArray) {
        _trackingTableDataArray = @[@"Status", @"Temperature", @"Cervical Fluid", @"Cervical Position", @"Period", @"Intercourse", @"Mood", @"Symptoms",
                                    @"Ovulation Test", @"Pregnancy Test", @"Supplements", @"Medicines"];
    }
    
    return _trackingTableDataArray;
}

- (CycleViewController *)cycleViewController
{
    if (!_cycleViewController) {
        _cycleViewController = [[CycleViewController alloc] init];
        _cycleViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    
    return _cycleViewController;
}

- (NSMutableArray *)drawerDateData
{
    if (!_drawerDateData) {
        _drawerDateData = [[NSMutableArray alloc] init];
    }
    
    return _drawerDateData;
}

- (NSMutableArray *)datesWithPeriod
{
    if (!_datesWithPeriod) {
        _datesWithPeriod = [[NSMutableArray alloc] init];
    }
    
    return _datesWithPeriod;
}

- (NSMutableArray *)daysFromBackend
{
    if (!_daysFromBackend) {
        _daysFromBackend = [[NSMutableArray alloc] init];
    }
    
    return _daysFromBackend;
}

- (Day *)day
{
    if (!_day) {
        _day = [[Day alloc] init];
    }
    
    return _day;
}

@end