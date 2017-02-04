//
//  PAWFriendProfileViewController.m
//  Poppin
//
//  Created by R. Bowman on 5/10/16.
//  Copyright © 2016 Matthew Bowman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAWFriendProfileViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <PAWFriendViewController.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "PAWPostTableViewCell.h"
#import "PAWConstants.h"
#import "PAWPost.h"



@interface PAWFriendProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UINavigationControllerDelegate>
{
  
    
    UILabel *userNameLabel;
    UILabel *challengesLabel;
    UILabel *solutionsLabel;
    PFImageView *userImageView;
    BOOL friendWasRemoved;
    UITableView *nominationsTableView;
    NSArray *nominationsArray;
    UITableView *socialLinksTable;
    NSMutableArray *socialLinkArray;
    BOOL stopFetching;
    int pageNumber;
    UIAlertView *alertView;
    UILabel *emptyLabel;
    
}
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation PAWFriendProfileViewController

- (id)initWithFriend:(PFUser *)Friend
{
    if(self = [super init]) {
        friend = Friend;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    friendWasRemoved = NO;
    self.scrollView= [[UIScrollView alloc]initWithFrame:CGRectMake(0 ,0,screenWidth ,screenHeight)];
    self.scrollView.delegate= self;
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:YES];
    self.scrollView.scrollEnabled= YES;
    self.scrollView.userInteractionEnabled= YES;
    [self.view addSubview:self.scrollView];
    self.scrollView.contentSize= CGSizeMake(screenWidth ,screenHeight*.9);//(width,height)
    
    self.navigationItem.title = @"Profile";
    self.view.backgroundColor = [UIColor whiteColor];
    
    userImageView = [[PFImageView alloc] initWithFrame:CGRectMake(10, 35, 70, 70)];
    userImageView.contentMode = UIViewContentModeScaleAspectFill;
    userImageView.clipsToBounds = YES;
    userImageView.layer.cornerRadius = 35.f;
    userImageView.layer.borderColor = [[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f] CGColor];
    userImageView.layer.borderWidth = 1.0f;
    userImageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:userImageView];
    

    
    userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 35, screenWidth-110, 17)];
    userNameLabel.textColor = [UIColor darkGrayColor];
    userNameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [self.scrollView addSubview:userNameLabel];
    
    challengesLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 60, 75, 40)];
    challengesLabel.numberOfLines = 2;
    challengesLabel.textColor = [UIColor darkGrayColor];
    challengesLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    challengesLabel.textAlignment = NSTextAlignmentCenter;
    challengesLabel.userInteractionEnabled = YES;
    // tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(challengesLabelHandler)];
    // [challengesLabel addGestureRecognizer:tap];
    [self.scrollView addSubview:challengesLabel];
    
    solutionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 60, 75, 40)];
    solutionsLabel.numberOfLines = 2;
    solutionsLabel.textColor = [UIColor darkGrayColor];
    solutionsLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    solutionsLabel.textAlignment = NSTextAlignmentCenter;
    solutionsLabel.userInteractionEnabled = YES;
    //  tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(solutionsLabelHandler)];
    // [solutionsLabel addGestureRecognizer:tap];
    [self.scrollView addSubview:solutionsLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(userImageView.frame)+15, screenWidth-20, 20)];
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont boldSystemFontOfSize:14.f];
    label.text = @"Recent Activity";
    [self.scrollView addSubview:label];
    
    nominationsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(label.frame)+10, screenWidth, self.view.frame.size.height *0.60 - CGRectGetMaxY(label.frame) - 70)];
    nominationsTableView.dataSource = self;
    nominationsTableView.delegate = self;
    nominationsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    nominationsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.scrollView addSubview:nominationsTableView];
    
    
    emptyLabel = [[UILabel alloc] initWithFrame:nominationsTableView.bounds];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor lightGrayColor];
    emptyLabel.text = @"User has no recent activity :)";
    
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"friends"];
    PFQuery *relationQuery = [relation query];
    [relationQuery whereKey:@"objectId" equalTo:friend.objectId];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (error) {
        }
        else {
            if([friends count] > 0)
            {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"removeUser@2x.png"]
                                                                                         style:UIBarButtonItemStylePlain
                                                                                        target:self action:@selector(removeFriendButton)];

                
              
               // self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
            }
            else
            {
                
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"addUser@2x.png"]
                                                                                        style:UIBarButtonItemStylePlain target:self action:@selector(addfriendButton)];
                
                
                
               // self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;

            
            }
            
        }
    }];
    

    
    UILabel *socialLinks = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(nominationsTableView.frame)+15, screenWidth-20, 20)];
    socialLinks.textColor = [UIColor darkGrayColor];
    socialLinks.font = [UIFont boldSystemFontOfSize:14.f];
    socialLinks.text = @"Social Links";
    [self.scrollView addSubview:socialLinks];
    
    socialLinksTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(socialLinks.frame)+10, screenWidth, self.view.frame.size.height *0.35)];
    socialLinksTable.dataSource = self;
    socialLinksTable.delegate = self;
    socialLinksTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    socialLinksTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.scrollView addSubview:socialLinksTable];
}




- (void) showLogin
{
    //[self showModalViewController:[[PFLogInViewController alloc] init]];
}


-(void)viewWillAppear:(BOOL)animated
{
    PFQuery *query = [PFQuery queryWithClassName:@"socialMedia"];
    [query whereKey:@"user" equalTo:friend];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            socialLinkArray = [[NSMutableArray alloc] init];
            if(!object){
            }
            else{
                if(![object[@"Snapchat"] isEqualToString:@"none"]){
                    [socialLinkArray addObject:[NSString stringWithFormat:@"%@%@", @"Snapchat:", object[@"Snapchat"]]];
                }
                if(![object[@"Instagram"] isEqualToString:@"none"]){
                    [socialLinkArray addObject:[NSString stringWithFormat:@"%@%@", @"Instagram:", object[@"Instagram"]]];
                }
                if(![object[@"Twitter"] isEqualToString:@"none"]){
                    [socialLinkArray addObject:[NSString stringWithFormat:@"%@%@", @"Twitter:", object[@"Twitter"]]];
                }
                if(![object[@"Facebook"] isEqualToString:@"none"]){
                    [socialLinkArray addObject:[NSString stringWithFormat:@"%@%@", @"Facebook:", object[@"Facebook"]]];
                    
                }
                
                [socialLinkArray addObject:@"empty:Add a social account"];
                
                
                [socialLinksTable reloadData];
                NSLog(@"juuu%lu",(unsigned long)[socialLinkArray count]);
                
                
            }
            // NSLog(@"HELL NAW");
            
            
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    if(friendWasRemoved == YES)
    {
        [self.delegate friendWasRemoved:friend];
    }
}
- (void)viewDidAppear:(BOOL)animated
{

        FAKFontAwesome *icon = [FAKFontAwesome userIconWithSize:50.0f];
    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]];

        // [icon addAttribute:NSForegroundColorAttributeName value:[Utils themeColor]];
        userImageView.image = [icon imageWithSize:CGSizeMake(70, 70)];
        
        PFQuery *query = [PFUser query];
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        query.maxCacheAge = 60*60;
        [query whereKey:@"objectId" equalTo:friend.objectId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"GOT USER DATA: %@", object);
            
            userNameLabel.text = object[@"name"];
            userImageView.file = object[@"profileImageThumb"];
            challengesLabel.text = [NSString stringWithFormat:@"%d\nPins", [friend[@"pins"] intValue]];
            solutionsLabel.text = [NSString stringWithFormat:@"%d\nLikes", [friend[@"checkins"] intValue]];
            [userImageView loadInBackground];
        }];
    
   // [nominationsTableView reloadData];
        [self forceFetchData];
    
}



#pragma mark - DTAlertView Delegate Methods

-(void)addfriendButton
{
    
    PFUser *user = [PFUser currentUser];
    PFRelation *relationCurrentUser = [user relationForKey:@"friends"];
    friendWasRemoved = NO;
    [relationCurrentUser addObject:friend];
    [user saveInBackground];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"removeUser@2x.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self action:@selector(removeFriendButton)];
    PFRelation *relation = [user relationForKey:@"friends"];
    PFQuery *relationQuery = [relation query];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (error) {
        } else {
           
        }
    }];
    
    //  [self.User saveEventually];
    //  [OtherUser saveEventually];

}
-(void)removeFriendButton
{
    
    PFUser *user = [PFUser currentUser];
    PFRelation *relationCurrentUser = [user relationForKey:@"friends"];
    friendWasRemoved = YES;
    PFRelation *relation = [user relationForKey:@"friends"];
    PFQuery *relationQuery = [relation query];
    [relationQuery whereKey:@"objectId" equalTo:friend.objectId];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (error) {
        } else {
            if([friends count] > 0)
            {
                [relation removeObject:friend];
                [user saveInBackground];
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"addUser@2x.png"]
                                                                                         style:UIBarButtonItemStylePlain target:self action:@selector(addfriendButton)];
                
                
            }
            else
            {
               
                
            }
            
        }
    }];
    
    //  [self.User saveEventually];
    //  [OtherUser saveEventually];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([tableView isEqual:nominationsTableView]){
        if (indexPath.row >= [nominationsArray count]) {
            return [tableView rowHeight];
        }
        
        // Retrieve the text and username for this row:
        PFObject *object = [nominationsArray objectAtIndex:indexPath.row];
        PAWPost *post = [[PAWPost alloc] initWithPFObject:object];
        
        return [PAWPostTableViewCell sizeThatFits:tableView.bounds.size forPost:post].height;
    }
    else{
        return 35;
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:nominationsTableView]){
        return nominationsArray.count;
    }
    else{
        NSLog(@"%lu",(unsigned long)[socialLinkArray count]);
        
        return [socialLinkArray count];
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:nominationsTableView]){
        if (indexPath.row==nominationsArray.count-1) {
            //[self fetchData];
        }
        PFObject *object = [nominationsArray objectAtIndex:indexPath.row];
        
        PAWPostTableViewCellStyle cellStyle = PAWPostTableViewCellStyleRight;
        
        
        NSString *reuseIdentifier = nil;
        switch (cellStyle) {
            case PAWPostTableViewCellStyleLeft:
            {
                static NSString *leftCellIdentifier = @"left";
                reuseIdentifier = leftCellIdentifier;
            }
                break;
            case PAWPostTableViewCellStyleRight:
            {
                static NSString *rightCellIdentifier = @"right";
                reuseIdentifier = rightCellIdentifier;
            }
                break;
        }
        
        PAWPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        if (cell == nil) {
            cell = [[PAWPostTableViewCell alloc] initWithPostTableViewCellStyle:cellStyle
                                                                reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        PAWPost *post = [[PAWPost alloc] initWithPFObject:object];
        
        
        [cell updateFromPost:post];
        
        
        return cell;
    }
    else{
        static NSString *simpleTableIdentifier = @"SimpleTableItem";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        
        [cell setIndentationLevel:3];
        
        NSArray* foo = [[socialLinkArray objectAtIndex:indexPath.row] componentsSeparatedByString: @":"];
        NSString* firstBit = [foo objectAtIndex: 0];
        NSString* secondBit = [foo objectAtIndex: 1];
       if([firstBit isEqualToString:@"Snapchat"]){
            cell.textLabel.text = secondBit;
            cell.tag = 1;
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(15,8, 20, 20)];
            imv.image=[UIImage imageNamed:@"snap@3x.png"];
            [cell addSubview:imv];
        }
        else if([firstBit isEqualToString:@"Instagram"]){
            cell.textLabel.text = secondBit;
            cell.tag = 2;
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(15,8, 20, 20)];
            imv.image=[UIImage imageNamed:@"insta@3x.png"];
            [cell addSubview:imv];
        }
        else if([firstBit isEqualToString:@"Twitter"]){
            cell.textLabel.text = secondBit;
            cell.tag = 3;
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(15,8, 20, 20)];
            imv.image=[UIImage imageNamed:@"Twitter@3x.png"];
            [cell addSubview:imv];
        }
        else if([firstBit isEqualToString:@"Facebook"]){
            cell.textLabel.text = secondBit;
            cell.tag = 4;
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(15,8, 20, 20)];
            imv.image=[UIImage imageNamed:@"Facebook@3x.png"];
            [cell addSubview:imv];
        }
        // cell.textLabel.text = [socialLinkArray objectAtIndex:indexPath.row];
        return cell;
        
    }
}



- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:nominationsTableView]){
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
    else{
        NSArray* foo = [[socialLinkArray objectAtIndex:indexPath.row] componentsSeparatedByString: @":"];
        NSString* firstBit = [foo objectAtIndex: 0];
        NSString* secondBit = [foo objectAtIndex: 1];
        UITableViewCell *cell = [socialLinksTable cellForRowAtIndexPath:indexPath];
        NSInteger tag = cell.tag;
      if(tag == 1){
            UIApplication *ourApplication = [UIApplication sharedApplication];
            NSString *ourPath = [NSString stringWithFormat:@"%@/%@",@"Snapchat://add/", secondBit];
            NSURL *ourURL = [NSURL URLWithString:ourPath];
            if ([[UIApplication sharedApplication] canOpenURL:ourURL]) {
                [ourApplication openURL:ourURL];
            }
            else{
                NSString *webPath = [NSString stringWithFormat:@"%@/%@",@"https://www.Snapchat.com/add", secondBit];
                NSURL *webURL = [NSURL URLWithString:webPath];
                [[UIApplication sharedApplication] openURL:webURL];
            }
        }
        else if(tag == 2){
            UIApplication *ourApplication = [UIApplication sharedApplication];
            NSString *ourPath = [NSString stringWithFormat:@"%@%@",@"Instagram://user?username=", secondBit];
            NSURL *ourURL = [NSURL URLWithString:ourPath];
            if ([[UIApplication sharedApplication] canOpenURL:ourURL]) {
                [ourApplication openURL:ourURL];
            }
            else{
                NSString *webPath = [NSString stringWithFormat:@"%@%@",@"http://www.Instagram.com/", secondBit];
                NSURL *webURL = [NSURL URLWithString:webPath];
                [[UIApplication sharedApplication] openURL:webURL];
            }
        }
        else if(tag == 3){
            UIApplication *ourApplication = [UIApplication sharedApplication];
            NSString *ourPath = [NSString stringWithFormat:@"%@/%@",@"Twitter://user?screen_name=", secondBit];
            NSURL *ourURL = [NSURL URLWithString:ourPath];
            if ([[UIApplication sharedApplication] canOpenURL:ourURL])
                [[UIApplication sharedApplication] openURL:ourURL];
            else{
                NSString *webPath = [NSString stringWithFormat:@"%@%@",@"http://www.Twitter.com/", secondBit];
                NSURL *webURL = [NSURL URLWithString:webPath];
                [[UIApplication sharedApplication] openURL:webURL];
            }
        }
        else if(tag == 4){
            UIApplication *ourApplication = [UIApplication sharedApplication];
            NSString *ourPath = [NSString stringWithFormat:@"%@/%@",@"fb://profile/", secondBit];
            NSURL *ourURL = [NSURL URLWithString:ourPath];
            if ([[UIApplication sharedApplication] canOpenURL:ourURL])
                [[UIApplication sharedApplication] openURL:ourURL];
            else{
                NSString *webPath = [NSString stringWithFormat:@"%@%@",@"http://www.Facebook.com/", secondBit];
                NSURL *webURL = [NSURL URLWithString:webPath];
                [[UIApplication sharedApplication] openURL:webURL];
            }
        }
    }
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)forceFetchData
{
    forceRefresh = YES;
    stopFetching = NO;
    pageNumber=0;
    [self fetchData];
}

- (void)fetchData
{
    if (!requestInProgress && !stopFetching) {
        requestInProgress = YES;
        
        PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
        query.limit = 20;
        query.skip = pageNumber*20;
        [query includeKey:@"user"];
        [query whereKey:@"user" equalTo:friend];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [objects arrayByAddingObjectsFromArray:[PFUser currentUser][PAWParsePostCheckedInKey]];
            if (error) {
                NSLog(@"error: %@", error);
                requestInProgress = NO;
                forceRefresh = NO;
                
                
            } else {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                if (!forceRefresh) {
                    [array addObjectsFromArray:nominationsArray];
                }
                
                for (PFObject *object in objects) {
                    [array addObject:object];
                }
                
                nominationsArray = [NSArray arrayWithArray:array];
                [nominationsTableView reloadData];
                
                if (nominationsArray.count==0) {
                    [nominationsTableView addSubview:emptyLabel];
                } else {
                    [emptyLabel removeFromSuperview];
                }
                
                
                requestInProgress = NO;
                forceRefresh = NO;
                if (objects.count<20) {
                    stopFetching = YES;
                }
                pageNumber++;
            }
        }];
    }
}




@end
