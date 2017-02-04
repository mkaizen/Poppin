//
//  PAWProfileViewController.h
//  Poppin
//
//  Created by R. Bowman on 5/10/16.
//  Copyright © 2016 Matthew Bowman. All rights reserved.
//

#ifndef PAWProfileViewController_h
#define PAWProfileViewController_h

#import "PAWPost.h"
#import "NavController.h"

#endif /* PAWProfileViewController_h */
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
@class PAWPostFullPage;


@protocol PAWPostFullPageDelegate <NSObject>
-(void)addItemViewController:(PAWPostFullPage *)controller sendDataToA:(MKDirections *)directions; //I am thinking my data is NSArray, you can use another object for store your information.


@end
@interface PAWPostFullPage : PFQueryTableViewController <UIAlertViewDelegate,UITableViewDelegate,UISearchBarDelegate>
{
    PAWPost *friendsPost;
    BOOL requestInProgress;
    BOOL forceRefresh;

    PFUser *friend;
    MKDirectionsRequest *request;
    MKDirections *directions;
}


-(void)showModalViewController:(UIViewController *)modalViewController;
-(void)closeModalViewController;
- (id)initWithPost:(PAWPost *)post;

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
-(void)showAlertWithMessage:(NSString *)message;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) IBOutlet UITableView *friendsTable;
@property(nonatomic, strong) CLLocation *myLocation;
@property (nonatomic, weak) id<PAWPostFullPageDelegate> delegate;
@property (strong, nonatomic) UINavigationController *navController;
@property (nonatomic, strong)IBOutlet UIView *scrollView;


@end

