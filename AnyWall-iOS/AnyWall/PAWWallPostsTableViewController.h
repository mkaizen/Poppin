//
//  PAWWallPostsTableViewController.h
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "PAWWallViewController.h"
#import "PAWPostFullPage.h"
@class PAWWallPostsTableViewController;

@protocol PAWWallPostsTableViewControllerDataSource <NSObject>

- (CLLocation *)currentLocationForWallPostsTableViewController:(PAWWallPostsTableViewController *)controller;

@end

@interface PAWWallPostsTableViewController : PFQueryTableViewController <PAWWallViewControllerHighlight,PAWPostFullPageDelegate>

@property (nonatomic, weak) id<PAWWallPostsTableViewControllerDataSource> dataSource;

@property (nonatomic, weak) id<PAWWallViewControllerDelegate> delegate;
@property (nonatomic, retain) PAWWallViewController* parent;
-(MKDirections *)getDirections;

@end

