//
//  PAWInviteFriendsViewController.h
//  Anywall
//
//  Created by R. Bowman on 12/29/15.
//  Copyright © 2015 Parse Inc. All rights reserved.
//

#ifndef PAWInviteFriendsViewController_h
#define PAWInviteFriendsViewController_h


#endif /* PAWInviteFriendsViewController_h */


@class PAWInviteFriendsViewController;



@protocol PAWInviteFriendsViewControllerDelegate <NSObject>
- (void)addItemViewController:(PAWInviteFriendsViewController *)controller didFinishEnteringItem:(NSArray *)friendsInvited;
- (void)FriendsViewControllerWantsToPresentProfile:(PAWInviteFriendsViewController *)controller;

@end

@interface PAWInviteFriendsViewController : UIViewController <UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *contentList;

}
- (id)initWithFriends:(NSArray *)friends;
@property (nonatomic, weak) id<PAWInviteFriendsViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UILabel *username;

@property (nonatomic, strong) IBOutlet UITableView *recentPosts;


@property(nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@property(nonatomic, strong) PFUser *User;



@end


