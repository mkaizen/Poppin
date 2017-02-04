//
//  PAWFriendViewController.h
//  Anywall
//
//  Created by R. Bowman on 12/29/15.
//  Copyright © 2015 Parse Inc. All rights reserved.
//

#ifndef PAWFriendViewController_h
#define PAWFriendViewController_h


#endif /* PAWFriendViewController_h */


@class PAWFriendViewController;

@protocol PAWFriendViewControllerDelegate <NSObject>



- (void)friendViewControllerWantsToPresentProfile:(PAWFriendViewController *)controller;

@end

@protocol FBSDKAppInviteDialogDelegate <NSObject>


@end
@interface PAWFriendViewController : UIViewController <UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    NSMutableArray *contentList;
    NSMutableArray *filteredContentList;
    BOOL isSearching;

}

@property (nonatomic, weak) id<PAWFriendViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UILabel *username;

@property (nonatomic, strong) IBOutlet UISearchBar *friendSearch;

@property (nonatomic) IBOutlet UITableView *recentPosts;


@property(nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@property(nonatomic, strong) PFUser *User;



@end


