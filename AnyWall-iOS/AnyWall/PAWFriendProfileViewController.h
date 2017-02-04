//
//  PAWProfileViewController.h
//  Poppin
//
//  Created by R. Bowman on 5/10/16.
//  Copyright © 2016 Matthew Bowman. All rights reserved.
//

#ifndef PAWProfileViewController_h
#define PAWProfileViewController_h

#endif /* PAWProfileViewController_h */
@class PAWFriendProfileViewController;


@protocol PAWFriendProfileViewControllerDelegate <NSObject>

-(void)friendWasRemoved:(PFUser *)removedFriend;
@end
@interface PAWFriendProfileViewController : UIViewController <UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    PFUser *friend;
    BOOL requestInProgress;
    BOOL forceRefresh;
    
    
    
}


-(void)showModalViewController:(UIViewController *)modalViewController;
-(void)closeModalViewController;
- (id)initWithFriend:(PFUser *)Friend;

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
-(void)showAlertWithMessage:(NSString *)message;


@property (nonatomic, weak) id<PAWFriendProfileViewControllerDelegate> delegate;
@property (strong, nonatomic) UINavigationController *navController;

@property(nonatomic, strong) UIBarButtonItem *rightBarButtonItem;


@end



