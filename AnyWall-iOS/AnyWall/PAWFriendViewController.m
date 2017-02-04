//
//  PAWSettingsViewController.m
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import "PAWFriendViewController.h"

#import <Parse/Parse.h>
#import "PAWConstants.h"
#import "PAWConfigManager.h"
#import "PAWWallViewController.h"
#import "PAWProfileViewController.h"
#import "PAWFriendProfileViewController.h"
//#import "PAWPostTableViewCell.h"
#import "PFFacebookUtils.h"
#import "PAWPost.h"
#import "PAWConstants.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FontAwesomeKit/FontAwesomeKit.h>

#import "AFNetworking.h"


@interface PAWFriendViewController () <PAWWallViewControllerDelegate,FBSDKAppInviteDialogDelegate,PAWProfileViewControllerDelegate,PAWFriendProfileViewControllerDelegate>
@property (nonatomic, strong) UIButton *noDataButton;
@end

@implementation PAWFriendViewController



#pragma mark -
#pragma mark Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    [FBSDKAppInviteDialog showFromViewController:self
                                     withContent:content
                                        delegate:self];
    /**
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
     **/
    //  [alertController addAction:cancelAction];
    //  [alertController addAction:okAction];
    
    //    [self presentViewController:alertController animated:YES completion:nil];
    
    //   [[[UIAlertView alloc] initWithTitle:@"Poppin" message:[NSString stringWithFormat:@"Would you like to invite more your friends to use %@", @"Poppin"] delegate:self cancelButtonTitle:@"no" otherButtonTitles:@"yes", nil] show];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.User = [PFUser currentUser];
    
    // contentList = [[NSMutableArray alloc] initWithObjects:@"iPhone", @"iPod", @"iPod touch", @"iMac", @"Mac Pro", @"iBook",@"MacBook", @"MacBook Pro", @"PowerBook", nil];
    contentList = [[NSMutableArray alloc] init];
    filteredContentList = [[NSMutableArray alloc] init];
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
    self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.title = @"Friends";
    //   [self navigationController UINavigationBar
    self.recentPosts = [[UITableView alloc] init];
    
    self.recentPosts.delegate = self;
    self.recentPosts.dataSource = self;
    self.friendSearch.delegate = self;
    [self.view addSubview:self.recentPosts];
    
    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Contact@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(profileViewButton:)];
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    self.definesPresentationContext = NO;
    self.navigationController.extendedLayoutIncludesOpaqueBars = true;
    self.recentPosts.separatorColor = self.view.backgroundColor;
    
    
    
    
    
    
    [self getFriends];
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
}- (void) getFriends {
    BOOL isLinkedToFacebook = [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
    PFRelation *relation = [self.User relationForKey:@"friends"];
    PFQuery *relationQuery = [relation query];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (error) {
            NSLog(@"%lu",(unsigned long)[friends count]);
            if(isLinkedToFacebook){
                if ([friends count]==0) {
                    
                    // no friends use the app
                    // [self showInviteAlert];
                    self.noDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [self.noDataButton setTintColor:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]];
                    self.noDataButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    self.noDataButton.titleLabel.numberOfLines = 2;//if you want unlimited number of lines put 0
                    
                    [self.noDataButton setTitle:@"Send your friends an invite to Poppin" forState:UIControlStateNormal];
                    [self.noDataButton addTarget:self
                                          action:@selector(showInviteAlert)
                                forControlEvents:UIControlEventTouchUpInside];
                    // self.noDataButton.hidden = YES;
                    
                    [self.recentPosts addSubview:self.noDataButton];
                    const CGRect bounds = self.view.bounds;
                    CGRect noDataButtonFrame = CGRectZero;
                    noDataButtonFrame.size = [self.noDataButton sizeThatFits:bounds.size];
                    noDataButtonFrame.origin.x = CGRectGetMidX(bounds) - CGRectGetMidX(noDataButtonFrame);
                    noDataButtonFrame.origin.y = self.recentPosts.frame.origin.y+self.recentPosts.frame.size.height/5;
                    self.noDataButton.frame = noDataButtonFrame;
                    self.noDataButton.hidden = false;
                    
                    return;
                    
                }
                else{
                    NSLog(@"%lu",(unsigned long)[friends count]);
                    self.noDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [self.noDataButton setTintColor:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]];
                    self.noDataButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    self.noDataButton.titleLabel.numberOfLines = 2;//if you want unlimited number of lines put 0
                    
                    [self.noDataButton setTitle:@"Send your friends an invite to Poppin" forState:UIControlStateNormal];
                    [self.noDataButton addTarget:self
                                          action:@selector(showInviteAlert)
                                forControlEvents:UIControlEventTouchUpInside];
                    // self.noDataButton.hidden = YES;
                    
                    [self.recentPosts addSubview:self.noDataButton];
                    const CGRect bounds = self.view.bounds;
                    CGRect noDataButtonFrame = CGRectZero;
                    noDataButtonFrame.size = [self.noDataButton sizeThatFits:bounds.size];
                    noDataButtonFrame.origin.x = CGRectGetMidX(bounds) - CGRectGetMidX(noDataButtonFrame);
                    noDataButtonFrame.origin.y = self.recentPosts.frame.origin.y;
                    self.noDataButton.frame = noDataButtonFrame;
                    
                    self.noDataButton.hidden = false;
                    [self.recentPosts reloadData];
                    
                }
            }
        } else {
            [contentList addObjectsFromArray:friends];
            if(isLinkedToFacebook){
                if ([friends count]==0) {
                    
                    // no friends use the app
                    // [self showInviteAlert];
                    self.noDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [self.noDataButton setTintColor:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]];
                    self.noDataButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    self.noDataButton.titleLabel.numberOfLines = 2;//if you want unlimited number of lines put 0
                    
                    [self.noDataButton setTitle:@"Send your friends an invite to Poppin" forState:UIControlStateNormal];
                    [self.noDataButton addTarget:self
                                          action:@selector(showInviteAlert)
                                forControlEvents:UIControlEventTouchUpInside];
                    // self.noDataButton.hidden = YES;
                    
                    [self.recentPosts addSubview:self.noDataButton];
                    const CGRect bounds = self.view.bounds;
                    CGRect noDataButtonFrame = CGRectZero;
                    noDataButtonFrame.size = [self.noDataButton sizeThatFits:bounds.size];
                    noDataButtonFrame.origin.x = CGRectGetMidX(bounds) - CGRectGetMidX(noDataButtonFrame);
                    noDataButtonFrame.origin.y = self.recentPosts.frame.origin.y+self.recentPosts.frame.size.height/5;
                    self.noDataButton.frame = noDataButtonFrame;
                    self.noDataButton.hidden = false;
                    
                    return;
                    
                }
                else{
                    self.noDataButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [self.noDataButton setTintColor:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]];
                    self.noDataButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    self.noDataButton.titleLabel.numberOfLines = 2;//if you want unlimited number of lines put 0
                    
                    [self.noDataButton setTitle:@"Send your friends an invite to Poppin" forState:UIControlStateNormal];
                    [self.noDataButton addTarget:self
                                          action:@selector(showInviteAlert)
                                forControlEvents:UIControlEventTouchUpInside];
                    // self.noDataButton.hidden = YES;
                    
                    [self.recentPosts addSubview:self.noDataButton];
                    const CGRect bounds = self.view.bounds;
                    CGRect noDataButtonFrame = CGRectZero;
                    noDataButtonFrame.size = [self.noDataButton sizeThatFits:bounds.size];
                    noDataButtonFrame.origin.x = CGRectGetMidX(bounds) - CGRectGetMidX(noDataButtonFrame);
                    noDataButtonFrame.origin.y = self.recentPosts.frame.origin.y;
                    self.noDataButton.frame = noDataButtonFrame;
                    
                    self.noDataButton.hidden = false;
                    [self.recentPosts reloadData];
                    
                }
            }
            /**
             int i;
             for (i = 0; i < [contentList count]; i++) {
             id myArrayElement = [contentList objectAtIndex:i];
             if(![friends containsObject:myArrayElement])
             {
             [relation addObject:myArrayElement];
             }
             }
             [self.User saveInBackground];
             **/
        }
    }];
    
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    isSearching = YES;
    CGRect tableViewFrame = self.recentPosts.frame;
    tableViewFrame.origin.y = tableViewFrame.origin.y - self.friendSearch.bounds.size.height/4;
    [UIView animateWithDuration:0.25
                     animations:^{ self.recentPosts.frame = tableViewFrame; }];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    CGRect tableViewFrame = self.recentPosts.frame;
    tableViewFrame.origin.y = tableViewFrame.origin.y + self.friendSearch.bounds.size.height/4;
    [UIView animateWithDuration:0.25
                     animations:^{ self.recentPosts.frame = tableViewFrame; }];
}

- (void) getFriendsFromURL:(NSString *)url {
    
    NSMutableArray *friendUsersArray = [[NSMutableArray alloc] init];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *operation, id responseObject) {
        
        if ([responseObject[@"data"] count]==0) { // no more friends use the app
            
            // [self hideIndeterminateProgress];
            //  [self showInviteAlert];
            return;
        }
        
        for (NSDictionary *dictionary in responseObject[@"data"]) {
            [friendUsersArray addObject:dictionary[@"id"]];
        }
        
        PFQuery *query = [PFUser query];
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        query.maxCacheAge = 60*60;
        [query whereKey:@"facebookId" containedIn:friendUsersArray];// containedIn:friendUsersArray
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                [self.recentPosts reloadData];
                //[self hideIndeterminateProgress];
                //[self showInviteAlert];
                return;
            } else {
                [contentList addObjectsFromArray:objects];
                
                if (responseObject[@"paging"][@"next"]) {
                    [self getFriendsFromURL:responseObject[@"paging"][@"next"]];
                } else {
                    [self.recentPosts reloadData];
                    //[self hideIndeterminateProgress];
                    //[self showInviteAlert];
                }
            }
        }];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        // [self hideIndeterminateProgress];
        [self.recentPosts reloadData];
        //[self showInviteAlert];
    }];
}

- (void)viewDidAppear:(BOOL)animated

{
    [super viewDidAppear:animated];
    [self.recentPosts reloadData];
    
    [self.navigationItem.rightBarButtonItem setEnabled:true];
    
    
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    const CGRect bounds = self.view.bounds;
    
    
    
    
    
    
    
    
    
    CGRect tableViewFrame = CGRectZero;
    
    tableViewFrame.origin.x = 0.0f;
    
    tableViewFrame.origin.y = CGRectGetMaxY(self.friendSearch.frame)+ 10.0f;
    
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
    if (isSearching) {
        NSLog(@" FILTER CONTENT LIST HAS A SIZE OF %i", [contentList count]);
        
        return [filteredContentList count];
    }
    else {
        NSLog(@"CONTENT LIST HAS A SIZE OF %i", [contentList count]);
        return [contentList count];
    }
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
    
    FAKFontAwesome *icon = [FAKFontAwesome userIconWithSize:15.0f];
    // [icon addAttribute:NSForegroundColorAttributeName value:[Utils themeColor]];
    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]];
    cell.imageView.image = [icon imageWithSize:CGSizeMake(30, 30)];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 15.0f;
    cell.imageView.layer.borderColor = [[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f] CGColor];
    cell.imageView.layer.borderWidth = 1.0f;
    
    PFQuery *query = [PFUser query];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60*60;
    PFUser *aFriend;
    
    
    if (isSearching) {
        aFriend = [filteredContentList objectAtIndex:indexPath.row];
        
        PFFile *imageFile = [aFriend objectForKey:@"profileImageThumb"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:result];
                cell.imageView.image = image;
                CGSize itemSize = CGSizeMake(30, 30);
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
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        
    }
    else
    {
        aFriend = [contentList objectAtIndex:indexPath.row];
        
        PFFile *imageFile = [aFriend objectForKey:@"profileImageThumb"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:result];
                cell.imageView.image = image;
                CGSize itemSize = CGSizeMake(30, 30);
                UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                [cell.imageView.image drawInRect:imageRect];
                cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                [cell setNeedsLayout];
            }
        }];
        cell.textLabel.text = aFriend[@"name"];
        cell.textLabel.textColor = [UIColor darkTextColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    }
    
    
    return cell;
}



-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFUser *object = [contentList objectAtIndex:indexPath.row];
    PAWPost *post = [[PAWPost alloc] initWithPFObject:object];
    __block BOOL friendAlready = false;
    __block BOOL isMyPost = false;
    /*
     if (isSearching) {
     PFObject *object = [filteredContentList objectAtIndex:indexPath.row];
     }
     else {
     PFObject *object = [contentList objectAtIndex:indexPath.row];
     }
     */
    
    
    //   isMyPost = true;
    //  friendAlready = true;
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        PFRelation *relation = [self.User relationForKey:@"friends"];
                                        PFQuery *query = [relation query];
                                        [query whereKey:@"objectId" equalTo:object.objectId];
                                        [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
                                            
                                            if(count > 0){
                                                
                                                PFQuery *queryDeleteFriend = [PFQuery queryWithClassName:@"FriendRequest"];
                                                [queryDeleteFriend whereKey:@"status" equalTo:@"friends"];
                                                [queryDeleteFriend findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                                    if (!error) {
                                                        // The find succeeded.
                                                        
                                                        for (PFObject *object2 in objects) {
                                                            
                                                            
                                                            object2[@"status"] = @"deleted";
                                                            [object2 save];
                                                            
                                                        }
                                                    } else {
                                                        // Log details of the failure
                                                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                                                    }
                                                }];
                                                
                                                
                                                [relation removeObject:object];
                                                [self.User saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                    if (succeeded) {
                                                        // The post has been added to the user's likes relation.
                                                    } else {
                                                        // There was a problem, check error.description
                                                    }
                                                }];
                                                [self.recentPosts reloadData];
                                            }
                                            
                                        }];
                                        
                                        
                                        
                                        
                                        
                                        
                                        PFQuery *queryDeleteFriend = [PFQuery queryWithClassName:@"FriendRequest"];
                                        [queryDeleteFriend whereKey:@"status" equalTo:@"approved"];
                                        
                                        [queryDeleteFriend whereKey:@"fromUser" equalTo:object];
                                        [queryDeleteFriend findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                            if (!error) {
                                                // The find succeeded.
                                                
                                                for (PFObject *object1 in objects) {
                                                    
                                                    
                                                    object1[@"status"] = @"deleted";
                                                    [object1 save];
                                                    
                                                }
                                            } else {
                                                // Log details of the failure
                                                NSLog(@"Error: %@ %@", error, [error userInfo]);
                                            }
                                        }];
                                        [contentList removeObjectAtIndex:indexPath.row];
                                        
                                        [self.recentPosts reloadData];
                                        
                                        /*
                                         
                                         PFRelation *relation = [self.User relationForKey:@"friends"];
                                         PFQuery *query2 = [relation query];
                                         [query2 whereKey:@"fr" equalTo:[PFUser currentUser]];
                                         [query2 findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                                         for (id object in results) {
                                         [object fetchIfNeeded];
                                         
                                         [contentList addObject:object];
                                         }
                                         }];
                                         
                                         PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
                                         [query whereKey:@"user" equalTo:[PFUser currentUser]];
                                         [query whereKey:@"date"equalTo: post.date];
                                         [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                         if (!error) {
                                         // The find succeeded.
                                         for (PFObject *object in objects) {
                                         //   [object deleteInBackground];
                                         [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                         if (succeeded) {
                                         
                                         
                                         [tableView reloadData];
                                         // [self.wallPostsTableViewController.tableView reloadData];
                                         } else {
                                         // There was a problem, check error.description
                                         }
                                         }];
                                         
                                         }
                                         
                                         
                                         
                                         }
                                         else {
                                         // Log details of the failure
                                         NSLog(@"Error: %@ %@", error, [error userInfo]);
                                         }
                                         }];
                                         
                                         */
                                        
                                        [tableView reloadData];
                                    }];
    
    
    
    
    return @[button];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
     else{
     
     PFQuery *lotsOfWins = [PFQuery queryWithClassName:@"FriendRequest"];
     [lotsOfWins whereKey:@"toUser" equalTo: [PFUser currentUser]];
     [lotsOfWins whereKey:@"fromUser" equalTo: post.user];
     PFQuery *fewWins = [PFQuery queryWithClassName:@"FriendRequest"];
     [fewWins whereKey:@"toUser" equalTo:post.user];
     [fewWins whereKey:@"fromUser" equalTo:[PFUser currentUser]];
     
     PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:fewWins,lotsOfWins,nil]];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     // results contains players with lots of wins or only a few wins.
     
     if (!error) {
     // The find succeeded.
     NSLog(@"Successfully retrieved %d friend requests", objects.count);
     // Do something with the found objects
     
     if(objects.count == 0)
     {
     
     
     friendAlready = false;
     isMyPost = false;
     
     
     
     }
     else
     {
     
     
     isMyPost = false;
     friendAlready = true;
     
     
     }
     
     
     
     } else {
     // Log details of the failure
     NSLog(@"Error: %@ %@", error, [error userInfo]);
     }
     }];
     
     if (isMyPost) {
     
     
     UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
     {
     PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
     [query whereKey:@"user" equalTo:[PFUser currentUser]];
     [query whereKey:@"date"equalTo: post.date];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     if (!error) {
     // The find succeeded.
     for (PFObject *object in objects) {
     //   [object deleteInBackground];
     [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
     if (succeeded) {
     
     
     [self loadObjects];
     // [self.wallPostsTableViewController.tableView reloadData];
     } else {
     // There was a problem, check error.description
     }
     }];
     
     }
     
     
     
     }
     else {
     // Log details of the failure
     NSLog(@"Error: %@ %@", error, [error userInfo]);
     }
     }];
     
     
     
     [tableView reloadData];
     }];
     
     
     
     return @[button];
     
     
     
     }
     else if(isMyPost == false)
     {
     
     if (friendAlready == false)
     {
     NSLog(@"foccc");
     UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"+Friend" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
     {
     PFUser *OtherUser = post.user;
     PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
     [query whereKey:@"toUser" equalTo:OtherUser];
     [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
     [query whereKey:@"status" equalTo:@"pending"];
     [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     if (!error) {
     // The find succeeded.
     NSLog(@"Successfully retrieved %d scores.", objects.count);
     // Do something with the found objects
     
     if (objects.count == 0) {
     PFObject *friendRequest = [PFObject objectWithClassName:@"FriendRequest"];
     friendRequest[@"fromUser"] = [PFUser currentUser];
     friendRequest[@"toUser"] = OtherUser;
     friendRequest[@"status"] = @"pending";
     
     [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
     
     
     }];
     [tableView reloadData];
     button.backgroundColor = [UIColor lightGrayColor];
     return @[button];
     
     
     
     }
     else
     {
     
     
     
     }
     
     }
     
     
     }
     
     */
    
    
    
    
    
    
    
    
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)friendWasRemoved:(PFUser *)removedFriend
{
    for (PFUser *friend in contentList) {
        if([friend.objectId isEqual:removedFriend.objectId])
        {
            [contentList removeObject:removedFriend];
            [self.recentPosts reloadData];
            
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int selectedRow = indexPath.row;
    if(isSearching){
        PAWFriendProfileViewController *friendProfileViewController = [[PAWFriendProfileViewController alloc] initWithFriend:[filteredContentList objectAtIndex:indexPath.row]];
        
        
        
        friendProfileViewController.delegate = self;
        
        
        [self.navigationController pushViewController:friendProfileViewController animated:YES];
        
    }
    else
    {
        PAWFriendProfileViewController *friendProfileViewController = [[PAWFriendProfileViewController alloc] initWithFriend:[contentList objectAtIndex:indexPath.row]];
        
        
        
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
    if (indexPath.row >= 6) {
        return [tableView rowHeight];
    }
    
    return 40;
    
    
}

-(void)profileViewButton:(UIButton*)sender{
    
    [self.navigationItem.rightBarButtonItem setEnabled:false];
    
    
    PAWProfileViewController *ProfileViewController = [[PAWProfileViewController alloc] init];
    
    
    
    ProfileViewController.delegate = self.delegate;
    
    
    [self.navigationController pushViewController:ProfileViewController animated:YES];
    
    
}



-(void)addfriendButton:(UIButton*)sender
{
    
    //self.User = [PFUser currentUser];
    PFUser *OtherUser = [filteredContentList objectAtIndex:sender.tag];
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query whereKey:@"toUser" equalTo:OtherUser];
    [query whereKey:@"fromUser" equalTo:self.User];
    [query whereKey:@"status" equalTo:@"pending"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            
            if (objects.count == 0) {
                PFObject *friendRequest = [PFObject objectWithClassName:@"FriendRequest"];
                friendRequest[@"fromUser"] = self.User;
                friendRequest[@"toUser"] = OtherUser;
                friendRequest[@"status"] = @"pending";
                
                [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
    
    
    //  [self.User saveEventually];
    //  [OtherUser saveEventually];
    
    sender.enabled = NO;
}



-(void)acceptFriendButton:(UIButton*)sender
{
    
    //self.User = [PFUser currentUser];
    PFUser *OtherUser = [contentList objectAtIndex:sender.tag][@"fromUser"];
    NSLog(@"%i",sender.tag);
    [OtherUser fetchIfNeeded];
    
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query whereKey:@"toUser" equalTo:self.User];
    [query whereKey:@"fromUser" equalTo:OtherUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d cunt", objects.count);
            // Do something with the found objects
            
            if (objects.count > 0) {
                
                for (PFObject *object in objects) {
                    object[@"status"] = @"approved";
                    [object save];
                    NSLog(@"%@",object[@"status"]);
                    NSLog(@"%@",object[@"fromUser"]);
                    NSLog(@"%@",object[@"toUser"]);
                    
                    //[contentList removeObject:OtherUser];
                    [contentList removeObjectAtIndex:sender.tag];
                    NSLog(@"Successfully retrieved %d contentlist", objects.count);
                    
                    
                }
                PFRelation *relationCurrentUser = [self.User relationForKey:@"friends"];
                [relationCurrentUser addObject:OtherUser];
                [contentList addObject:OtherUser];
                [self.User saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Successfully retrieved %d scores.",[contentList count]);
                        
                        [self.recentPosts reloadData];
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
    /**
     CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.recentPosts];
     NSIndexPath *indexPath = [self.recentPosts indexPathForRowAtPoint:buttonPosition];
     if (indexPath != nil)
     {
     UITableViewCell *cell = [self.recentPosts cellForRowAtIndexPath:indexPath];
     for (UIView *subview in [cell subviews])
     {
     if ([subview isKindOfClass:[UIButton class]])
     {
     sender.enabled = NO;
     [subview setHidden:YES];
     [subview removeFromSuperview];
     }
     }
     }
     **/
    
    //[sender setHidden:YES];
    
    
    
}

-(void)denyFriendButton:(UIButton*)sender
{
    
    
    
    //self.User = [PFUser currentUser];
    PFUser *OtherUser = [contentList objectAtIndex:sender.tag][@"fromUser"];
    
    [OtherUser fetchIfNeeded];
    
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query whereKey:@"toUser" equalTo:self.User];
    [query whereKey:@"fromUser" equalTo:OtherUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            
            if (objects.count == 1) {
                
                for (PFObject *object in objects) {
                    object[@"status"] = @"denied";
                    [object save];
                }
                
                
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    for (UIView *subview in [sender.superview subviews])
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            [subview removeFromSuperview];
        }
    }
    // [sender setHidden:YES];
    [self.recentPosts reloadData];
    
    // sender.enabled = NO;
    
}

-(void)acceptFriendButtonSearch:(UIButton*)sender
{
    
    //self.User = [PFUser currentUser];
    PFUser *OtherUser = [contentList objectAtIndex:sender.tag][@"fromUser"];
    [OtherUser fetchIfNeeded];
    
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query whereKey:@"toUser" equalTo:self.User];
    [query whereKey:@"fromUser" equalTo:OtherUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d friend requests.", objects.count);
            // Do something with the found objects
            
            if (objects.count == 1) {
                
                for (PFObject *object in objects) {
                    object[@"status"] = @"approved";
                    [object save];
                }
                PFRelation *relationCurrentUser = [self.User relationForKey:@"friends"];
                [relationCurrentUser addObject:OtherUser];
                
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
    
    
    //  [sender setHidden:YES];
    //  [self.recentPosts reloadData];
    
    //  sender.enabled = NO;
    
}

-(void)denyFriendButtonSearch:(UIButton*)sender
{
    
    
    //self.User = [PFUser currentUser];
    PFUser *OtherUser = [contentList objectAtIndex:sender.tag][@"fromUser"];
    [OtherUser fetchIfNeeded];
    
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query whereKey:@"toUser" equalTo:self.User];
    [query whereKey:@"fromUser" equalTo:OtherUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            
            if (objects.count == 1) {
                
                for (PFObject *object in objects) {
                    object[@"status"] = @"denied";
                    [object save];
                }
                
                
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    for (UIView *subview in [sender.superview subviews])
    {
        if ([subview isKindOfClass:[UIButton class]])
        {
            
            [subview removeFromSuperview];
        }
    }
    
    [sender setHidden:YES];
    
    
    sender.enabled = NO;
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
- (void)searchTableList {
    NSString *searchString = [self.friendSearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    for (PFUser *friend1 in contentList) {
        
        NSComparisonResult result = [friend1[@"name"] compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        if (result == NSOrderedSame) {
            
            [filteredContentList addObject:friend1];
        }
    }
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
    
}



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSLog(@"Text change - %d",isSearching);
    NSLog(@"how many reulsts %i",[filteredContentList count]);
    //Remove all objects first.
    [filteredContentList removeAllObjects];
    
    if([searchText length] != 0) {
        isSearching = YES;
        [self searchTableList];
    }
    else {
        isSearching = NO;
    }
    [self.recentPosts reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    isSearching = NO;
    [self.recentPosts reloadData];
    
    
    NSLog(@"Text change - %d",isSearching);
    
    NSLog(@"Cancel clicked");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
    [self searchTableList];
}

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
