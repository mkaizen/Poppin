//
//  PAWSettingsViewController.m
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import "PAWSettingsViewController.h"

#import <Parse/Parse.h>

#import "PAWConstants.h"
#import "PAWConfigManager.h"

typedef NS_ENUM(uint8_t, PAWSettingsTableViewSection)
{
    PAWSettingsTableViewSectionDistance = 0,
    PAWSettingsTableViewSectionLogout,

    PAWSettingsTableViewNumberOfSections
};

static uint16_t const PAWSettingsTableViewLogoutNumberOfRows = 1;

@interface PAWSettingsViewController ()

@property (nonatomic, strong) NSArray *distanceOptions;
@property (nonatomic, assign) CLLocationAccuracy filterDistance;

@end

@implementation PAWSettingsViewController

#pragma mark -
#pragma mark Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:PAWUserDefaultsFilterDistanceKey];
        [self loadAvailableDistanceOptions];
    }
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor colorWithRed:0 green:202.0f/255.0f blue:202.0f/255.0f alpha:1.0f],NSForegroundColorAttributeName,
                                    [UIFont fontWithName:@"Aileron" size:20],NSFontAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    return self;
}

#pragma mark -
#pragma mark UIViewController


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark -
#pragma mark Accessors
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor colorWithRed:0 green:202.0f/255.0f blue:202.0f/255.0f alpha:1.0f],NSForegroundColorAttributeName,
                                    [UIFont fontWithName:@"Aileron" size:20],NSFontAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;

}
- (void)setFilterDistance:(CLLocationAccuracy)filterDistance {
    if (self.filterDistance != filterDistance) {
        _filterDistance = filterDistance;

        [[NSUserDefaults standardUserDefaults] setDouble:filterDistance forKey:PAWUserDefaultsFilterDistanceKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:PAWFilterDistanceDidChangeNotification
                                                                object:nil
                                                              userInfo:@{ kPAWFilterDistanceKey : @(filterDistance) }];
        });
    }
}

#pragma mark -
#pragma mark UINavigationBar-based actions

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Data

- (void)loadAvailableDistanceOptions {
	NSMutableArray *distanceOptions = [[[PAWConfigManager sharedManager] filterDistanceOptions] mutableCopy];

    NSNumber *defaultFilterDistance = @(PAWDefaultFilterDistance);
    if (![distanceOptions containsObject:defaultFilterDistance]) {
        [distanceOptions addObject:defaultFilterDistance];
    }

    [distanceOptions sortUsingSelector:@selector(compare:)];

    self.distanceOptions = [distanceOptions copy];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return PAWSettingsTableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case PAWSettingsTableViewSectionDistance:
            return [self.distanceOptions count];
            break;
        case PAWSettingsTableViewSectionLogout:
            return PAWSettingsTableViewLogoutNumberOfRows;
            break;
        case PAWSettingsTableViewNumberOfSections:
            return 0;
            break;
    };

	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SettingsTableView";
    if (indexPath.section == PAWSettingsTableViewSectionDistance) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if ( cell == nil )
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }

		PAWLocationAccuracy distance = [self.distanceOptions[indexPath.row] doubleValue];

        // Configure the cell.
        cell.textLabel.text = [NSString stringWithFormat:@"%d feet", (int)distance];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;

        if (self.filterDistance == 0.0) {
            NSLog(@"We have a zero filter distance!");
        }

        if (fabs(PAWFeetToMeters(distance) - self.filterDistance) < 0.001 ) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        return cell;
    } else if (indexPath.section == PAWSettingsTableViewSectionLogout) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if ( cell == nil )
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }

        // Configure the cell.
        cell.textLabel.text = @"Log out of Poppin";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;

        return cell;
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case PAWSettingsTableViewSectionDistance:
            return @"Search Distance";
            break;
        case PAWSettingsTableViewSectionLogout:
        case PAWSettingsTableViewNumberOfSections:
            return nil;
            break;
    }

    return nil;
}

#pragma mark -
#pragma mark UITableViewDelegate

// Called after the user changes the selection.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == PAWSettingsTableViewSectionDistance) {
        [aTableView deselectRowAtIndexPath:indexPath animated:YES];

        // if we were already selected, bail and save some work.
        UITableViewCell *selectedCell = [aTableView cellForRowAtIndexPath:indexPath];
        if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            return;
        }

        // uncheck all visible cells.
        for (UITableViewCell *cell in [aTableView visibleCells]) {
            if (cell.accessoryType != UITableViewCellAccessoryNone) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;

        PAWLocationAccuracy distanceForCellInFeet = [self.distanceOptions[indexPath.row] doubleValue];
        self.filterDistance = PAWFeetToMeters(distanceForCellInFeet);
    } else if (indexPath.section == PAWSettingsTableViewSectionLogout) {
        [aTableView deselectRowAtIndexPath:indexPath animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log out of Poppin?"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Log out"
                                                  otherButtonTitles:@"Cancel", nil];
        [alertView show];
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertView.cancelButtonIndex) {
        // Log out.
        [PFUser logOut];

        [self.delegate settingsViewControllerDidLogout:self];
	}
}

// Nil implementation to avoid the default UIAlertViewDelegate method, which says:
// "Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button"
// Since we have "Log out" at the cancel index (to get it out from the normal "Ok whatever get this dialog outta my face"
// position, we need to deal with the consequences of that.
- (void)alertViewCancel:(UIAlertView *)alertView {
    return;
}

@end
