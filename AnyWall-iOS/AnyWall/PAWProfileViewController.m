//
//  PAWProfileViewController.m
//  Poppin
//
//  Created by R. Bowman on 5/10/16.
//  Copyright © 2016 Matthew Bowman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAWProfileViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <PAWFriendViewController.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "PAWPostTableViewCell.h"
#import "PAWConstants.h"
#import "PAWPost.h"
#import "SimpleTableViewController.h"


@interface PAWProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate,SimpleTableViewControllerDelegate>
{
    PFUser *user;
    
    UILabel *userNameLabel;
    UILabel *challengesLabel;
    UILabel *solutionsLabel;
    PFImageView *userImageView;
    UITableView *nominationsTableView;
    UITableView *socialLinksTable;
    NSMutableArray *socialLinkArray;
    NSArray *nominationsArray;
    BOOL stopFetching;
    int pageNumber;
    UIAlertView *alertView;
    UILabel *emptyLabel;
    
}
@property (nonatomic, strong) UIScrollView *scrollView;

@end


@implementation PAWProfileViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
   self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.scrollView= [[UIScrollView alloc]initWithFrame:CGRectMake(0 ,0,screenWidth ,screenHeight)];
    self.scrollView.delegate= self;
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:YES];
    self.scrollView.scrollEnabled= YES;
    self.scrollView.userInteractionEnabled= YES;
    [self.view addSubview:self.scrollView];
    self.scrollView.contentSize= CGSizeMake(screenWidth ,screenHeight*.9);//(width,height)
    
    self.navigationItem.title = @"My Profile";
    self.view.backgroundColor = [UIColor whiteColor];

    userImageView = [[PFImageView alloc] initWithFrame:CGRectMake(10, 35, 70, 70)];
    userImageView.contentMode = UIViewContentModeScaleAspectFill;
    userImageView.clipsToBounds = YES;
    userImageView.layer.cornerRadius = 35.f;
    userImageView.layer.borderColor = [[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f] CGColor];
    userImageView.layer.borderWidth = 1.0f;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageViewHandler)];
    userImageView.userInteractionEnabled = YES;
    [userImageView addGestureRecognizer:tap];
    [self.scrollView addSubview:userImageView];
    
    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButton)];
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    
    
    userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 35, screenWidth-110, 17)];
    userNameLabel.textColor = [UIColor darkGrayColor];
    userNameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(usernameLabelViewHandler)];
    userNameLabel.userInteractionEnabled = YES;
    [userNameLabel addGestureRecognizer:tap];
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
    emptyLabel.text = @"You have no recent activty :)";
    
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

-(void)logoutButton{
  
    [PFUser logOut];
    
    [self.delegate ProfileViewControllerDidLogout:self];

    
}
- (void) userImageViewHandler {
    NSString *other1 = @"take a photo";
    NSString *other2 = @"choose from library";
    NSString *cancelTitle = @"cancel";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:other1, other2, nil];
    [actionSheet showInView:self.view];
}

- (void) showLogin
{
    //[self showModalViewController:[[PFLogInViewController alloc] init]];
}

-(void)viewWillAppear:(BOOL)animated
{
    PFQuery *query = [PFQuery queryWithClassName:@"socialMedia"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        socialLinkArray = [[NSMutableArray alloc] init];
        if (!error) {
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
            [socialLinkArray addObject:@"empty:Add a social account"];
            NSLog(@"juuu%lu",(unsigned long)[socialLinkArray count]);
            
            
            [socialLinksTable reloadData];
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];



}


- (void)viewDidAppear:(BOOL)animated
{
    if (![PFUser currentUser] || ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self showLogin];
    } else {
        user = [PFUser currentUser];
        
        FAKFontAwesome *icon = [FAKFontAwesome userIconWithSize:50.0f];
       // [icon addAttribute:NSForegroundColorAttributeName value:[Utils themeColor]];
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]];
        userImageView.image = [icon imageWithSize:CGSizeMake(70, 70)];
        

           // NSLog(@"GOT USER DATA: %@", object);
            
            userNameLabel.text = user[@"name"];
            userImageView.file = user[@"profileImageThumb"];
            challengesLabel.text = [NSString stringWithFormat:@"%d\nPins", [user[@"pins"] intValue]];
            solutionsLabel.text = [NSString stringWithFormat:@"%d\nLikes", [user[@"checkins"] intValue]];
            [userImageView loadInBackground];
      
    [self forceFetchData];

    }
}


#pragma mark - DTAlertView Delegate Methods

# pragma mark UIActionSheetDelegate method
/**
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePicker = nil;
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    switch (buttonIndex) {
        case 1:
            imagePicker.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            imagePicker.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor whiteColor],NSForegroundColorAttributeName,
                                                             [UIFont fontWithName:@"Aileron" size:20],NSFontAttributeName, nil];
            
            [self presentViewController:imagePicker animated:YES completion:NULL];
            break;
        case 0:
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePicker animated:YES completion:NULL];
            }
            break;
        default:
            break;
    }
}

**/
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
        
        cell.textLabel.font = [UIFont systemFontOfSize:13.0];

        [cell setIndentationLevel:3];

        NSArray* foo = [[socialLinkArray objectAtIndex:indexPath.row] componentsSeparatedByString: @":"];
        NSString* firstBit = [foo objectAtIndex: 0];
        NSString* secondBit = [foo objectAtIndex: 1];
        if([firstBit isEqualToString:@"empty"]){
            cell.textLabel.text = secondBit;
            cell.tag = 0;
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(15,8, 20, 20)];
            imv.image=[UIImage imageNamed:@"Plus@3x.png"];
            [cell addSubview:imv];
        }
        else if([firstBit isEqualToString:@"Snapchat"]){
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
        if(tag == 0){
            SimpleTableViewController *socialAccountPicker = [SimpleTableViewController alloc];
            
            
            socialAccountPicker.delegate = self.delegate;
            
            
            [self.navigationController pushViewController:socialAccountPicker animated:YES];
        
        }
        else if(tag == 1){
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
#pragma UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *image = info[UIImagePickerControllerEditedImage];
    image = [self imageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9f);
    
    PFFile *imageFile = [PFFile fileWithName:@"profileimage.png" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
           // DLOG(@"uploaded user photo");
            [user setObject:imageFile forKey:@"profileImageThumb"];
            [user setObject:imageFile forKey:@"profileImage"];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                   NSLog(@"error while saving: %@", error);
                } else {
                    NSLog(@"updated user photo");
                     //userImageView.image = image;
                    [userImageView setImage:image];
                    [userImageView setNeedsDisplay];
                }
            }];
        } else {
     //       DLOG(@"error while uploading: %@", error);
        }
    }];
    
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
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        
        
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
        PFRelation *relation = [[PFUser currentUser] relationForKey:@"authors"];
        // generate a query based on that relation
        PFQuery *relationQuery = [relation query];
        relationQuery.limit = 20;
        relationQuery.skip = pageNumber*20;
        [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
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

/**

- (void)alertView:(UIAlertView *)alertView_ clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.textField != nil) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [alertView dismiss];
            return;
        }
        
        if (alertView.textField.text.length>0) {
            
            [user setUsername:alertView.textField.text.lowercaseString];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
            
                    [alertView shakeAlertView];
                    alertView.message = [NSString stringWithFormat:@"%@ is taken.", alertView.textField.text];
                } else {
                    userNameLabel.text = alertView.textField.text;
                    [alertView dismiss];
                }
            }];
        }
        
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

**/

@end
