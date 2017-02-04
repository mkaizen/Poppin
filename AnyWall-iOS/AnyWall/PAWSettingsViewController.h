//
//  PAWSettingsViewController.h
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PAWSettingsViewController;

@protocol PAWSettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerDidLogout:(PAWSettingsViewController *)controller;

@end

@interface PAWSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) id<PAWSettingsViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
