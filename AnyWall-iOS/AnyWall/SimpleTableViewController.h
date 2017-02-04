//
//  SimpleTableViewController.h
//  SimpleTable
//
//  Created by Simon Ng on 16/4/12.
//  Copyright (c) 2012 AppCoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SimpleTableViewController;
@protocol SimpleTableViewControllerDelegate <NSObject>

@end

@interface SimpleTableViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, weak) id<SimpleTableViewControllerDelegate> delegate;
@property (strong, nonatomic) UINavigationController *navController;

@property(nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@end
