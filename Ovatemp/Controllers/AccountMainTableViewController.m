//
//  AccountMainTableViewController.m
//  Ovatemp
//
//  Created by Josh L on 10/15/14.
//  Copyright (c) 2014 Back Forty. All rights reserved.
//

#import "AccountMainTableViewController.h"
#import "AccountTableViewCell.h"
#import "WebViewController.h"
#import "ONDOViewController.h"
//#import "ProfileTableViewController.h"
#import "UserProfileReadOnlyViewController.h"
#import "SettingsTableViewController.h"

@interface AccountMainTableViewController () <UITableViewDelegate, UITableViewDataSource>

@property AccountTableViewCell *accountTableViewCell;
@property (strong, nonatomic) UIActivityViewController *activityViewController;

@end

@implementation AccountMainTableViewController

NSArray *accountMenuItems;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    accountMenuItems = [NSArray arrayWithObjects:@"Profile", @"Settings", @"ONDO Thermometer", @"Help", @"Share Ovatemp", @"Rate this App", @"How it Works", @"Terms of Service", nil];
    
    [[self tableView] registerNib:[UINib nibWithNibName:@"AccountTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"accountCell"];
    
    // logout
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(doLogout)];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor ovatempAquaColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIBarButtonItem appearance] setTintColor:[UIColor ovatempAquaColor]];
}

- (void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doLogout {
    UIAlertController *errorAlert = [UIAlertController
                                     alertControllerWithTitle:@"Logout"
                                     message:@"Are you sure you want to logout?"
                                     preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction *logout = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self logout];
    }];
    
    [errorAlert addAction:no];
    [errorAlert addAction:logout];
    
    [self presentViewController:errorAlert animated:YES completion:nil];
//    [self logout];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [accountMenuItems count];
}


- (AccountTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountCell" forIndexPath:indexPath];
    
    [[cell textLabel] setText:[accountMenuItems objectAtIndex:indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0: // Profile
        {
//            ProfileTableViewController *profileVC = [[ProfileTableViewController alloc] init];
//            [self.navigationController pushViewController:profileVC animated:YES];
            UserProfileReadOnlyViewController *profileVC = [[UserProfileReadOnlyViewController alloc] init];
            [self.navigationController pushViewController:profileVC animated:YES];
            break;
        }
            
        case 1: // Settings
        {
            SettingsTableViewController *settingsVC = [[SettingsTableViewController alloc] init];
            [self.navigationController pushViewController:settingsVC animated:YES];
            break;
        }
            
        case 2: // ONDO
        {
            ONDOViewController *ondoVC = [[ONDOViewController alloc] init];
            [self.navigationController pushViewController:ondoVC animated:YES];
            break;
        }
            
        case 3: // Help
        {
            break;
        }
            
        case 4: // Share
        {
            NSString *shareString = @"I just downloaded the @Ovatemp App! Download yours and learn about your fertile health! #fertilityawareness #ovatemp http://bit.ly/1sPirWe";
            
            self.activityViewController =
            [[UIActivityViewController alloc] initWithActivityItems:@[shareString]
                                              applicationActivities:nil];
            
            self.activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypeCopyToPasteboard];
            [self.activityViewController setValue:@"Ovatemp" forKey:@"subject"];
            
            // TODO: FIXME, activityViewController will sometimes dismiss by itself
            [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:self.activityViewController animated:YES completion:nil];
            break;
        }
            
        case 5: // Rate app
        {
            
            // https://itunes.apple.com/us/app/ovatemp/id692187268?mt=8 - normal store URL
            // http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=692187268&pageNumber=0& sortOrdering=2&type=Purple+Software&mt=8 - brings user to ratings tab
            
            NSURL *appStoreURL = [NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=692187268&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"];
            if ([[UIApplication sharedApplication]canOpenURL:appStoreURL]) {
                [[UIApplication sharedApplication]openURL:appStoreURL];
            } else {
                NSLog(@"error opening link in AppStore");
            }
            break;
        }
            
        case 6: // How it Works
        {
            NSString *url = @"http://ovatemp.helpshift.com/a/ovatemp/?s=fertility-faqs&f=how-does-ovatemp-work";
            WebViewController *webViewController = [WebViewController withURL:url];
            [self.navigationController pushViewController:webViewController animated:YES];
            break;
        }
            
        case 7: // TOS
        {
            NSString *url = [ROOT_URL stringByAppendingString:@"/terms"];
            WebViewController *webViewController = [WebViewController withURL:url];
            webViewController.title = @"Terms of Service";
            [self.navigationController pushViewController:webViewController animated:YES];
            break;
        }
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
