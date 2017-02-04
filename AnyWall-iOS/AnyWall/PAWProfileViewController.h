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
@class PAWProfileViewController;


@protocol PAWProfileViewControllerDelegate <NSObject>

- (void)ProfileViewControllerDidLogout:(PAWProfileViewController *)controller;

@end
@interface PAWProfileViewController : UIViewController <UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIScrollViewDelegate>
{
    BOOL requestInProgress;
    BOOL forceRefresh;
 

    
}


-(void)showModalViewController:(UIViewController *)modalViewController;
-(void)closeModalViewController;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
-(void)showAlertWithMessage:(NSString *)message;
- (id)initWithFriend:(PFUser *)Friend;

@property (nonatomic, weak) id<PAWProfileViewControllerDelegate> delegate;
@property (strong, nonatomic) UINavigationController *navController;

@property(nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
-(void) openSnapchat:(id)sender;


@end



