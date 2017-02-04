//
//  PAWComingFriendsViewController.h
//  Anywall
//
//  Created by R. Bowman on 12/29/15.
//  Copyright © 2015 Parse Inc. All rights reserved.
//

#ifndef PAWComingFriendsViewController_h
#define PAWComingFriendsViewController_h


#endif /* PAWComingFriendsViewController_h */


@class PAWComingFriendsViewController;

@protocol PAWComingFriendsViewControllerDelegate <NSObject>


- (void)friendViewControllerWantsToPresentProfile:(PAWComingFriendsViewController *)controller;

@end

@protocol FBSDKAppInviteDialogDelegate <NSObject>


@end
@interface PAWComingFriendsViewController : UIViewController <UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *contentList;

}
- (id)initWithFriends:(NSArray *)friends;
@property (nonatomic, weak) id<PAWComingFriendsViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UILabel *username;

@property (nonatomic, strong) IBOutlet UITableView *recentPosts;


@property(nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@property(nonatomic, strong) PFUser *User;



@end


