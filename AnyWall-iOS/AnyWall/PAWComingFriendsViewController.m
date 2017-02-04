//
//  PAWSettingsViewController.m
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import "PAWComingFriendsViewController.h"

#import <Parse/Parse.h>
#import "PAWConstants.h"
#import "PAWConfigManager.h"
#import "PAWWallViewController.h"
#import "PAWProfileViewController.h"
#import "PAWFriendProfileViewController.h"
//#import "PAWPostTableViewCell.h"
#import "PAWPost.h"
#import "PAWConstants.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FontAwesomeKit/FontAwesomeKit.h>

#import "AFNetworking.h"


@interface PAWComingFriendsViewController () <PAWWallViewControllerDelegate,FBSDKAppInviteDialogDelegate,PAWProfileViewControllerDelegate,PAWFriendProfileViewControllerDelegate>
@property (nonatomic, strong) UIButton *noDataButton;
@end

@implementation PAWComingFriendsViewController



#pragma mark -
#pragma mark Init


- (id)initWithFriends:(NSArray *)friends{
    if(self = [super init]) {
        contentList = [[NSMutableArray alloc] init];
        [contentList addObjectsFromArray:friends];
    }
    return self;
}

- (void) showInviteAlert {
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1183432428367559"];
    //optionally set previewImageURL
    content.appInvitePreviewImageURL = [NSURL URLWithString:@"http://i.imgur.com/k5EF9qh.png"];
    
    // present the dialog. Assumes self implements protocol `FBSDKAppInviteDialogDelegate`
    //  [FBSDKAppInviteDialog showWithContent:content
    //                       delegate:self];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Poppin"
                                          message:[NSString stringWithFormat:@"Would you like to invite more of your friends to use %@?", @"Poppin"]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [FBSDKAppInviteDialog showFromViewController:self
                                                                    withContent:content
                                                                       delegate:self];
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    

    //   [[[UIAlertView alloc] initWithTitle:@"Poppin" message:[NSString stringWithFormat:@"Would you like to invite more your friends to use %@", @"Poppin"] delegate:self cancelButtonTitle:@"no" otherButtonTitles:@"yes", nil] show];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.User = [PFUser currentUser];
    
    // contentList = [[NSMutableArray alloc] initWithObjects:@"iPhone", @"iPod", @"iPod touch", @"iMac", @"Mac Pro", @"iBook",@"MacBook", @"MacBook Pro", @"PowerBook", nil];
    //contentList = [[NSMutableArray alloc] init];

    /**
     
     PFQuery *queryRequestsAccepted = [PFQuery queryWithClassName:@"FriendRequest"];
     [queryRequestsAccepted whereKey:@"fromUser" equalTo:self.User];
     [queryRequestsAccepted whereKey:@"status" equalTo:@"approved"];
     [queryRequestsAccepted findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     if (!error) {
     // The find succeeded.
     
     for (PFObject *object in objects) {
     
     PFRelation *acceptedRequest = [self.User relationForKey:@"friends"];
     [acceptedRequest addObject:object[@"toUser"]];
     object[@"status"] = @"friends";
     [object save];
     
     [self.User saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
     if (succeeded) {
     // The object has been saved.
     } else {
     // There was a problem, check error.description
     }
     }];
     }
     } else {
     // Log details of the failure
     NSLog(@"Error: %@ %@", error, [error userInfo]);
     }
     }];
     
     
     PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
     [query whereKey:@"toUser" equalTo:self.User];
     [query whereKey:@"status" equalTo:@"pending"];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     if (!error) {
     // The find succeeded.
     NSLog(@"Successfully retrieved %d friend requests", objects.count);
     // Do something with the found objects
     
     for (PFObject *object in objects) {
     [contentList addObject:object];
     }
     } else {
     // Log details of the failure
     NSLog(@"Error: %@ %@", error, [error userInfo]);
     }
     }];
     
     
     PFQuery *deleteQuery = [PFQuery queryWithClassName:@"FriendRequest"];
     [deleteQuery whereKey:@"toUser" equalTo:self.User];
     [deleteQuery whereKey:@"status" equalTo:@"deleted"];
     [deleteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     if (!error) {
     PFUser *object = objects[0][@"fromUser"];
     
     PFRelation *relation = [self.User relationForKey:@"friends"];
     [relation removeObject:object];
     [objects[0] deleteEventually];
     [self.User saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
     if (succeeded) {
     // The post has been added to the user's likes relation.
     } else {
     // There was a problem, check error.description
     }
     }];
     
     
     
     } else {
     // Log details of the failure
     NSLog(@"Error: %@ %@", error, [error userInfo]);
     }
     }];
     
     PFQuery *deleteQuery2 = [PFQuery queryWithClassName:@"FriendRequest"];
     [deleteQuery2 whereKey:@"fromUser" equalTo:self.User];
     [deleteQuery2 whereKey:@"status" equalTo:@"deleted"];
     [deleteQuery2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     if (!error) {
     PFUser *object = objects[0][@"toUser"];
     
     PFRelation *relation = [self.User relationForKey:@"friends"];
     [relation removeObject:object];
     [objects[0] deleteEventually];
     [self.User saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
     if (succeeded) {
     // The post has been added to the user's likes relation.
     } else {
     // There was a problem, check error.description
     }
     }];
     
     
     
     } else {
     // Log details of the failure
     NSLog(@"Error: %@ %@", error, [error userInfo]);
     }
     }];
     
     
     PFRelation *relation = [self.User relationForKey:@"friends"];
     PFQuery *query2 = [relation query];
     [query2 findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
     for (id object in results) {
     [object fetchIfNeeded];
     
     [contentList addObject:object];
     }
     }];
     
     
     
     filteredContentList = [[NSMutableArray alloc] init];
     UISwipeGestureRecognizer *swipeRightGesture=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
     [self.view addGestureRecognizer:swipeRightGesture];
     swipeRightGesture.direction=UISwipeGestureRecognizerDirectionRight;
     
     
     if (self.User[PAWParseFriends] == NULL) {
     NSMutableArray *friendArray = [NSMutableArray arrayWithObjects:
     @"Your friends list is empty, use the searchbar above to add friends!", nil];
     self.User[PAWParseFriends] = friendArray;
     }
     **/
    self.title = @"Likers";
    //   [self navigationController UINavigationBar
    self.recentPosts = [[UITableView alloc] init];
    
    self.recentPosts.delegate = self;
    self.recentPosts.dataSource = self;
    
    [self.view addSubview:self.recentPosts];
    
 //   self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Contact@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(profileViewButton:)];
   // self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    
    
    self.recentPosts.separatorColor = self.view.backgroundColor;
    
    
    
    self.noDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.noDataButton setTintColor:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]];
    self.noDataButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.noDataButton.titleLabel.numberOfLines = 2;//if you want unlimited number of lines put 0
    
    [self.noDataButton setTitle:@"Send your friends an invite to Poppin." forState:UIControlStateNormal];
    [self.noDataButton addTarget:self
                          action:@selector(showInviteAlert)
                forControlEvents:UIControlEventTouchUpInside];
    self.noDataButton.hidden = YES;
    [self.recentPosts addSubview:self.noDataButton];
    
}
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"app invite result: %@", results);
    
    BOOL complete = [[results valueForKeyPath:@"didComplete"] boolValue];
    NSString *completionGesture = [results valueForKeyPath:@"completionGesture"];
    
    // NOTE: the `cancel` result dictionary will be
    // {
    //   completionGesture = cancel;
    //   didComplete = 1;
    // }
    // else, it will only just `didComplete`
    
    if (completionGesture && [completionGesture isEqualToString:@"cancel"]) {
        // handle cancel state...
        return;
    }
    
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error
{
    NSLog(@"app invite error: %@", error.localizedDescription);
    // handle error...
}


- (void)viewDidAppear:(BOOL)animated

{
    [super viewDidAppear:animated];
    [self.recentPosts reloadData];
    
    
    
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    const CGRect bounds = self.view.bounds;
    CGRect noDataButtonFrame = CGRectZero;
    noDataButtonFrame.size = [self.noDataButton sizeThatFits:bounds.size];
    noDataButtonFrame.origin.x = CGRectGetMidX(bounds) - CGRectGetMidX(noDataButtonFrame);
    noDataButtonFrame.origin.y = 20.0f;
    self.noDataButton.frame = noDataButtonFrame;
    
    
    
    
    
    
    
    
    
    CGRect tableViewFrame = CGRectZero;
    
    tableViewFrame.origin.x = 0.0f;
    
    tableViewFrame.origin.y = self.navigationController.view.frame.origin.y;
    
    //  tableViewFrame.size.width = 200;
    //   tableViewFrame.size.height = 200;
    tableViewFrame.size.width = CGRectGetMaxX(bounds) - CGRectGetMinX(tableViewFrame) * 1.0f;
    
    tableViewFrame.size.height = CGRectGetMaxY(bounds) - CGRectGetMaxY(tableViewFrame);
    
    self.recentPosts.frame = tableViewFrame;
    
}







-(void)handleSwipeGesture:(UIGestureRecognizer *) sender
{
    NSUInteger touches = sender.numberOfTouches;
    if (touches == 1)
    {
        if (sender.state == UIGestureRecognizerStateEnded)
        {
            // [[self navigationController] popViewControllerAnimated:YES];  // goes back to previous view
            [self dismissViewControllerAnimated:YES completion:nil];
            
            
        }
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    
}
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer{
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

        return [contentList count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"He..\\aa.");
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:simpleTableIdentifier];
    }
    for (UIView *subview in [cell.contentView subviews])
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            [subview removeFromSuperview];
        }
    }
    cell.accessoryView = nil;
    
    FAKFontAwesome *icon = [FAKFontAwesome userIconWithSize:40.0f];
    // [icon addAttribute:NSForegroundColorAttributeName value:[Utils themeColor]];
    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]];
    cell.imageView.image = [icon imageWithSize:CGSizeMake(60, 60)];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 30.f;
    cell.imageView.layer.borderColor = [[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f] CGColor];
    cell.imageView.layer.borderWidth = 1.0f;
    
    PFQuery *query = [PFUser query];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60*60;
    PFUser *aFriend;
    
    
            aFriend = [contentList objectAtIndex:indexPath.row];
        
    
    PFFile *imageFile = [aFriend objectForKey:@"profileImageThumb"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:result];
            cell.imageView.image = image;
            CGSize itemSize = CGSizeMake(60, 60);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [cell.imageView.image drawInRect:imageRect];
            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [cell setNeedsLayout];
        }
    }];
    NSLog(@"%@",aFriend[@"name"]);
    cell.textLabel.text = aFriend[@"name"];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    
    
    return cell;
}




- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *selectedFriend = [contentList objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int selectedRow = indexPath.row;
    if([selectedFriend.objectId isEqual:self.User.objectId]){
        PAWProfileViewController *ProfileViewController = [[PAWProfileViewController alloc] init];
        
        
        
        ProfileViewController.delegate = self;
        
        
        [self.navigationController pushViewController:ProfileViewController animated:YES];
    
    }
    else{
        PAWFriendProfileViewController *friendProfileViewController = [[PAWFriendProfileViewController alloc] initWithFriend:selectedFriend];
        
        
        
    friendProfileViewController.delegate = self;
    
        
        [self.navigationController pushViewController:friendProfileViewController animated:YES];
    
    }
    
    
    NSLog(@"touch on row %d", selectedRow);
    
    //[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //[tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25;
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Account for the load more cell at the bottom of the tableview if we hit the pagination limit:
    if (indexPath.row >= 5) {
        return [tableView rowHeight];
    }
    
    return 75;
    
    
}

-(void)profileViewButton:(UIButton*)sender{
    
    PAWProfileViewController *profileViewController = [[PAWProfileViewController alloc] initWithNibName:nil bundle:nil];
    profileViewController.delegate = self.delegate;
    
    [self.navigationController pushViewController:profileViewController animated:YES];
    
}






-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.recentPosts.frame.size.width, 5)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    // UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0,self.recentPosts.frame.size.width, 25)];
    // label.textAlignment = NSTextAlignmentCenter;
    //label.backgroundColor = [UIColor blueColor];
    // label.text = @"";
    // label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    // [headerView addSubview:label];
    
    return headerView;
}


#pragma mark -

#pragma mark UIViewController

    /**
     if(filteredContentList.count == 0 ){
     
     PFQuery *query = [PFUser query];
     
     [query whereKey:@"name" containsString:searchString];
     // [query includeKey:@"username"];
     NSArray *foundUsers = [query findObjects];
     for (PFUser *object in foundUsers) {
     
     [filteredContentList addObject:object];
     //  [object fetchIfNeeded];
     }
     }
     **/
    






- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        // Log out.
        //[PFUser logOut];
        [self.delegate friendViewControllerWantsToPresentProfile:self];
        
        //[self.delegate FriendsViewControllerDidLogout:self];
    }
}

- (IBAction)Logout:(id)sender {
    
    //  UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    // [top presentViewController:secondView animated:YES completion: nil];
    
    PAWProfileViewController *profileViewController = [[PAWProfileViewController alloc] initWithNibName:nil bundle:nil];
    profileViewController.delegate = self;
    
    [self.navigationController presentViewController:profileViewController animated:YES completion:nil];
    
    /**
     UIAlertView *alertView = [[UIAlertView alloc] init WithTitle:@"Log out of Poppin?"
     message:nil
     delegate:self
     cancelButtonTitle:@"Log out"
     otherButtonTitles:@"Cancel", nil];
     [alertView show];
     **/
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