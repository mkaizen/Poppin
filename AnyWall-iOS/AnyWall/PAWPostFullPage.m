//
//  PAWPostFullPage.m
//  Poppin
//
//  Created by R. Bowman on 5/10/16.
//  Copyright © 2016 Matthew Bowman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAWPostFullPage.h"

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "PAWProfileViewController.h"
#import "PAWFriendProfileViewController.h"
#import <PAWFriendViewController.h>
#import <FontAwesomeKit/FontAwesomeKit.h>
#import "PAWFriendProfileViewController.h"
#import "PAWPostTableViewCell.h"
#import "PAWConstants.h"
#import "PAWPost.h"
#import "PAPBaseTextCell.h"
#import "PAPPhotoDetailsFooterView.h"
#import "PAWComingFriendsViewController.h"
#import "PAPActivityCell.h"
@interface PAWPostFullPage () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UINavigationControllerDelegate,PAWProfileViewControllerDelegate,PAWFriendProfileViewControllerDelegate,PAWComingFriendsViewControllerDelegate,PAWFriendProfileViewControllerDelegate>
{

    CLPlacemark *userCLPlacemark;
    CLPlacemark *pinCLPlacemark;
    MKPlacemark *pinPlacemark;
    MKMapItem *pinMapItem;
    MKPlacemark *userPlacemark;
    MKMapItem *userMapItem;
    UIView * separator;
    UIView * separator1;
    UIView * separator2;
    UIImageView *rulerImage;
    UIImageView *streetImage;
    UILabel *userNameLabel;
    UILabel *likers;
    UIButton *likeButton;
    UILabel *detailsLabel;
    UILabel *distanceLabel;
    UILabel *friendsLabel;
    UILabel *timeLabel;
    UILabel *addressLabel;
    UIButton *but;
    UIButton *directionsBut;
    UILabel *friendsComing;
    PFImageView *userImageView;
   NSArray *friends;
    UITableView *nominationsTableView;
    NSArray *nominationsArray;
    BOOL isComing;
    BOOL stopFetching;
    int pageNumber;
    double distance;
    UIAlertView *alertView;
    UILabel *emptyLabel;
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat postLines;
}

@end

@implementation PAWPostFullPage

- (id)initWithPost:(PAWPost *)post
{
    if(self = [super init]) {
    friendsPost = post;
   
        
          }

    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //NSString * myString = friendsPost.title;
   // NSArray *list = [myString componentsSeparatedByString:@"\n"];
    postLines = ([friendsPost.object[@"postSize"] floatValue]);

screenRect = [[UIScreen mainScreen] bounds];
screenWidth = screenRect.size.width;
screenHeight = screenRect.size.height;
      self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

       if(friendsPost.image != nil)
    {
 
        if(![self.view.subviews containsObject:self.scrollView]){
            self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,self.navController.view.frame.size.height, self.view.frame.size.width, screenHeight*0.40+(postLines*18.0+2.0)+screenWidth*.9
                                                                             )];
            
           // self.scrollView.contentSize = CGSizeMake( self.view.frame.size.width, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height+screenWidth
               //                                      );
            [self.view addSubview:self.scrollView];
            
        }else{
            self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,self.navController.view.frame.size.height, self.view.frame.size.width, screenHeight*0.55+((postLines-1)*50.0)
                                                                             )];
            
            
            
        }

        UIImageView *Picture = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, screenWidth, screenWidth)];
        
        [friendsPost.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                Picture.image = [UIImage imageWithData:data];
                [self.scrollView addSubview:Picture];
            }
        }];
        if(userNameLabel == nil){
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/16, Picture.frame.origin.y + Picture.frame.size.height+screenWidth/16, screenWidth*0.80, 20)];
        userNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        userNameLabel.numberOfLines = 0;
        
        userNameLabel.textColor = [UIColor darkTextColor];
        userNameLabel.font = [UIFont systemFontOfSize:18.0f];
        
        CGRect currentFrame = userNameLabel.frame;
        CGSize max = CGSizeMake(userNameLabel.frame.size.width, 500);
        CGSize expected = [friendsPost.title sizeWithFont:userNameLabel.font constrainedToSize:max lineBreakMode:userNameLabel.lineBreakMode];
        currentFrame.size.height = expected.height;
        userNameLabel.frame = currentFrame;
        [self.scrollView addSubview:userNameLabel];
        }
       
    }
    else{
        if(![self.view.subviews containsObject:self.scrollView]){
            self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,self.navController.view.frame.size.height, self.view.frame.size.width, screenHeight*0.40+(postLines*18.0+2.0)
                                                                             )];
            
           // self.scrollView.contentSize = CGSizeMake( self.view.frame.size.width, self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height
                                     //                );
            [self.view addSubview:self.scrollView];
            
        }else{
            self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,self.navController.view.frame.size.height, self.view.frame.size.width, screenHeight*0.55+((postLines-1)*50.0)
                                                                             )];
            
            
            
        }

        if(userNameLabel == nil){
            userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/16, self.navigationController.navigationBar.frame.size.height
, screenWidth*0.80, 20)];
    userNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    userNameLabel.numberOfLines = 0;
    
    userNameLabel.textColor = [UIColor darkTextColor];
    userNameLabel.font = [UIFont systemFontOfSize:18.0f];
    
    CGRect currentFrame = userNameLabel.frame;
    CGSize max = CGSizeMake(userNameLabel.frame.size.width, 500);
    CGSize expected = [friendsPost.title sizeWithFont:userNameLabel.font constrainedToSize:max lineBreakMode:userNameLabel.lineBreakMode];
    currentFrame.size.height = expected.height;
    userNameLabel.frame = currentFrame;
    [self.scrollView addSubview:userNameLabel];
        }
        
    
    }
   
 /**
  self.friendsTable = [[UITableView alloc] init];
    
    self.friendsTable.delegate = self;
    self.friendsTable.dataSource = self;
    self.friendsTable.delegate = self;
    [self.scrollView addSubview:self.friendsTable];
**/
 
    self.tableView.tableHeaderView = self.scrollView;
    PAPPhotoDetailsFooterView *footerView = [[PAPPhotoDetailsFooterView alloc] initWithFrame:[PAPPhotoDetailsFooterView rectForView]];
    self.commentTextField = footerView.commentField;
    self.commentTextField.delegate = self;
    self.tableView.tableFooterView = footerView;
    
    //userNameLabel.preferredMaxLayoutWidth = screenWidth*0.80;
    if(detailsLabel == nil){
    detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/5,userNameLabel.frame.origin.y+userNameLabel.frame.size.height+15, screenWidth*0.90, 40)];
    detailsLabel.numberOfLines = 2;
    detailsLabel.textColor = [UIColor lightGrayColor];
    detailsLabel.font = [UIFont systemFontOfSize:14.0f];
    //detailsLabel.textAlignment = NSTextAlignmentCenter;
    detailsLabel.userInteractionEnabled = YES;
    
    [self.scrollView addSubview:detailsLabel];
    
}
    self.tableView.separatorColor = [UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:0.5f];

    if(separator == nil){
        separator = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/20,detailsLabel.frame.origin.y+detailsLabel.frame.size.height+5, screenWidth*0.90, 1)];
        separator.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:0.5f];
        [self.scrollView addSubview:separator];
        
        separator1 = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2,detailsLabel.frame.origin.y+detailsLabel.frame.size.height+5, 1, 75)];
        separator1.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:0.5f];
        [self.scrollView addSubview:separator1];
        
        if(rulerImage == nil){
            rulerImage = [[UIImageView alloc] init];
            UIImage *myimg = [UIImage imageNamed:@"ruler.png"];
            rulerImage.image=myimg;
            rulerImage.frame = CGRectMake(screenWidth/4, separator.frame.origin.y+10, 30, 30); // pass your frame here
            [self.scrollView addSubview:rulerImage];
        }
        if(streetImage == nil){
            streetImage = [[UIImageView alloc] init];
            UIImage *myimg1 = [UIImage imageNamed:@"directions.png"];
            streetImage.image=myimg1;
            streetImage.frame = CGRectMake(screenWidth*2/3, separator.frame.origin.y+10, 30, 30); // pass your frame here
           // streetImage.userInteractionEnabled = YES;
            //UITapGestureRecognizer *tapInView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInImageView:)];
          //  [streetImage addGestureRecognizer:tapInView];
            [self.scrollView addSubview:streetImage];
        }


    if(distanceLabel == nil){
    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/12, rulerImage.frame.origin.y + 25, screenWidth*0.40, 40)];
    distanceLabel.numberOfLines = 2;
    distanceLabel.textColor = [UIColor lightGrayColor];
    distanceLabel.font = [UIFont systemFontOfSize:14.0f];
    distanceLabel.textAlignment = NSTextAlignmentCenter;
    distanceLabel.userInteractionEnabled = YES;
   [self.scrollView addSubview:distanceLabel];
    }
        if(likeButton == nil){
            UIImage *likeImage = [UIImage imageNamed: @"like@2x.png"];
            likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            likeButton.frame = CGRectMake(screenWidth/9, distanceLabel.frame.origin.y + distanceLabel.frame.size.height+16, 20, 20);
            NSLog(@"image frame: %@", NSStringFromCGRect(likeButton.frame));
            [likeButton setImage:likeImage forState:UIControlStateNormal];
            [likeButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:likeButton];
            
            UILabel *numLikes =  [[UILabel alloc] initWithFrame:CGRectMake(userNameLabel.frame.origin.x+userNameLabel.frame.size.width,self.navigationController.navigationBar.frame.size.height, 24, 24)];
            [numLikes setFont:[UIFont systemFontOfSize:18]];
            numLikes.backgroundColor = [UIColor clearColor];
            numLikes.textAlignment = NSTextAlignmentCenter;
            numLikes.textColor = [UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
            numLikes.numberOfLines = 0;
            [self.scrollView addSubview:numLikes];
            
        }
    if(addressLabel == nil){
    addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth*0.52, streetImage.frame.origin.y +25, screenWidth*0.40, 40)];
    
    addressLabel.numberOfLines = 0;

    addressLabel.textColor = [UIColor lightGrayColor];
    addressLabel.font = [UIFont systemFontOfSize:14.0f];
    addressLabel.textAlignment = NSTextAlignmentCenter;
        
    addressLabel.userInteractionEnabled = YES;
    [self.scrollView addSubview:addressLabel];
}
        /**
        if(directionsBut == nil)
        {
          
            directionsBut= [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [directionsBut setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]];

            [directionsBut addTarget:self action:@selector(buttonDirectionsClicked:) forControlEvents:UIControlEventTouchUpInside];
            [directionsBut setFrame:CGRectMake(screenWidth*.51, distanceLabel.frame.origin.y+distanceLabel.frame.size.height+50, screenWidth*.35, 40)];
            [directionsBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [directionsBut setTitle:@"Directions" forState:UIControlStateNormal];
            directionsBut.layer.cornerRadius = 4; // this value vary as per your desire
            directionsBut.clipsToBounds = YES;
            [directionsBut setExclusiveTouch:YES];
            
            [self.scrollView addSubview:directionsBut];
            
        }
    **/
    // set up our query for a User object
 
    
    // configure any constraints on your query...
    // for example, you may want users who are also playing with or against you
    
    // tell the query to fetch all of the Weapon objects along with the user
    // get the "many" at the same time that you're getting the "one"
        PFRelation *relation = [friendsPost.object relationForKey:@"likers"];
        PFQuery *query = [[friendsPost.object relationForKey:@"likers"] query];
     friends = [query findObjects];
    // execute the query
   
  
        
        NSString *friendsString = @"";
        NSString *otherString = @"";
        
                for (PFUser* currentUser in friends)
        {
            if([currentUser.objectId isEqual:[PFUser currentUser].objectId])
            {
            
            [likeButton setImage: [UIImage imageNamed:@"liked@2x.png"] forState:UIControlStateNormal];
            likeButton.selected = YES;
            
            }
            else{
                [likeButton setImage: [UIImage imageNamed:@"like@2x.png"] forState:UIControlStateNormal];
                likeButton.selected = NO;
                
            }
           otherString = [friendsString stringByAppendingString:(currentUser[PAWParsePostNameKey])];
            if([otherString containsString:[PFUser currentUser][PAWParsePostNameKey]])
            {
                isComing = YES;
            }
            
        }
        if(friendsComing == nil){
        friendsComing = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/5, distanceLabel.frame.origin.y + distanceLabel.frame.size.height+5, screenWidth*0.60, 40)];
        
        if([friends count] == 1)
        {
            friendsComing.text = [otherString stringByAppendingString:@" likes this."];
        }
        else if([friends count] == 0){
            
            friendsComing.text = @"no likes yet.";
            [friendsComing setUserInteractionEnabled:FALSE];
  
        }
        else
        {   NSString *howMany = [NSString stringWithFormat:@" and %d others like this.", [friends count]-1];
            friendsComing.text = [otherString stringByAppendingString:howMany];

        }
    
        friendsComing.numberOfLines = 1;
        friendsComing.preferredMaxLayoutWidth = screenWidth * 0.80;
        
        friendsComing.textColor = [UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
        friendsComing.font = [UIFont systemFontOfSize:14.0f];
        friendsComing.textAlignment = NSTextAlignmentLeft;
        friendsComing.userInteractionEnabled = YES;
        
 
       UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(friendsComingHandler)];
        [friendsComing addGestureRecognizer:tap];

        [self.scrollView addSubview:friendsComing];
        }
    /**
        if(but == nil && isComing == YES){
        but= [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [but setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0f]];
        [but addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [but setFrame:CGRectMake(screenWidth*.14, distanceLabel.frame.origin.y+distanceLabel.frame.size.height+50, screenWidth*.35, 40)];
        [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [but setTitle:@"I can't go" forState:UIControlStateNormal];
        but.layer.cornerRadius = 4; // this value vary as per your desire
        but.clipsToBounds = YES;
        [but setExclusiveTouch:YES];
        
        [self.scrollView addSubview:but];
        }
        else if(but != nil)
        {
     
        [but setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:86.0f/255.0f blue:86.0f/255.0f alpha:1.0f]];
         [but setTitle:@"I can't go" forState:UIControlStateNormal];
        
        
        }
        else if(but == nil)
        {
            NSLog(@"POOP");
            but= [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [but setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]];
            [but addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [but setFrame:CGRectMake(screenWidth*.14, distanceLabel.frame.origin.y+distanceLabel.frame.size.height+50, screenWidth*.35, 40)];
            [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [but setTitle:@"I'm going" forState:UIControlStateNormal];
            but.layer.cornerRadius = 4; // this value vary as per your desire
            but.clipsToBounds = YES;
            [but setExclusiveTouch:YES];
            
            [self.scrollView addSubview:but];

        }
        
        
    }
    else
    {
        if (but == nil){
         but= [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [but setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]];
        [but addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [but setFrame:CGRectMake(screenWidth*.14, distanceLabel.frame.origin.y+distanceLabel.frame.size.height+50, screenWidth*.35, 40)];
        [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [but setTitle:@"I'm going" forState:UIControlStateNormal];
        but.layer.cornerRadius = 4; // this value vary as per your desire
        but.clipsToBounds = YES;
        [but setExclusiveTouch:YES];
    
    [self.scrollView addSubview:but];
           
     
        }
     **/

    

     
        /**
         float w = 0;
         float h = 0;
        for (UIView *v in [self.scrollView subviews]) {
            float fw = v.frame.origin.x + v.frame.size.width;
            float fh = v.frame.origin.y + v.frame.size.height;
            w = MAX(fw, w);
            h = MAX(fh, h);
        }
         if(detailsLabel.numberOfLines > 1){
         NSLog(@"%f",self.scrollView.frame.size.height);
         [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y,self.scrollView.frame.size.width, self.scrollView.frame.size.height+100)];
         NSLog(@"%f",self.scrollView.frame.size.height);
         }
         **/


        
        if(friendsPost.user[@"profileImageThumb"] == nil){
    userImageView = [[PFImageView alloc] initWithFrame:CGRectMake(screenWidth/16, userNameLabel.frame.origin.y+userNameLabel.frame.size.height+15, 35, 35)];
    userImageView.contentMode = UIViewContentModeScaleAspectFill;
    userImageView.clipsToBounds = YES;
    userImageView.layer.cornerRadius = 17.0f;
    userImageView.layer.borderColor = [[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f] CGColor];   userImageView.layer.borderWidth = 1.0f;
    
    [self.scrollView addSubview:userImageView];
        }
        else
        {
            userImageView = [[PFImageView alloc] initWithFrame:CGRectMake(screenWidth/16, userNameLabel.frame.origin.y+userNameLabel.frame.size.height+15, 35, 35)];
            userImageView.contentMode = UIViewContentModeScaleAspectFill;
            userImageView.clipsToBounds = YES;
            userImageView.layer.cornerRadius = 17.0f;
            userImageView.layer.borderColor = [[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f] CGColor];   userImageView.layer.borderWidth = 1.0f;
            
            [self.scrollView addSubview:userImageView];
        
        
        
        
        }
       

    // if you like to add backgroundImage else no need
    
  
    
   /**
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(userImageView.frame)+15, screenWidth-20, 20)];
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont boldSystemFontOfSize:15.f];
    label.text = @"Current Pins:";
    [self.scrollView addSubview:label];

    emptyLabel = [[UILabel alloc] initWithFrame:nominationsTableView.bounds];
    emptyLabel.textAlignment = NSTextAlignmentCenter;
    emptyLabel.textColor = [UIColor lightGrayColor];
    emptyLabel.text = @"User has no pins currently";
    **/

    separator2 = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/20,detailsLabel.frame.origin.y+addressLabel.frame.size.height+80, screenWidth*0.90, 1)];
    separator2.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:0.5f];
    [self.scrollView addSubview:separator2];
    
        UIView *blank = [[UIView alloc] initWithFrame:CGRectMake(0,self.tableView.tableFooterView.frame.origin.y+self.tableView.tableFooterView.frame.size.height+5, screenWidth, 150)];
     
        [self.tableView.tableFooterView addSubview:blank];

    }


    

    
}
- (BOOL) doILike:(PFUser *)user {
    
 
        for (PFUser* currentUser in friends)
        {
            if([currentUser.objectId isEqual: user.objectId])
            {
                return YES;
            
            }
          
        }
     return NO;

    

}
-(void) buttonDirectionsClicked:(UIButton*)sender

{
    request = [[MKDirectionsRequest alloc] init];
    PFGeoPoint *location = [friendsPost.object objectForKey:@"location"];
    
    CLGeocoder *CEO = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
    MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:self.myLocation.coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    MKMapItem *sourceMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:loc.coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
    [request setSource:sourceMapItem];
    [request setDestination:distMapItem];
    // [request setDestination:[[MKMapItem alloc] initWithPlacemark:pinPlacemark]];
    
    request.transportType = MKDirectionsTransportTypeWalking;
    request.requestsAlternateRoutes = false;
    directions = [[MKDirections alloc] initWithRequest:request];
    [self.delegate addItemViewController:self sendDataToA:directions];
    [self.navigationController popViewControllerAnimated:YES];
    /**
     [CEO reverseGeocodeLocation:loc
     completionHandler:^(NSArray *placemarks, NSError *error) {
     CLPlacemark *placemark = [placemarks objectAtIndex:0];
     if (placemark) {
     
     [CEO reverseGeocodeLocation:self.myLocation
     completionHandler:^(NSArray *placemarks1, NSError *error) {
     CLPlacemark *placemark1 = [placemarks1 objectAtIndex:0];
     
     if (placemark1) {
     userCLPlacemark = placemark1;
     userPlacemark = [userPlacemark initWithPlacemark:userCLPlacemark];
     userMapItem = [userMapItem initWithPlacemark:userPlacemark];
     NSLog(@"placemark %@", placemark1.region);
     NSLog(@"placemark %@",placemark1.country);  // Give Country Name
     NSLog(@"placemark %@",placemark1.locality); // Extract the city name
     NSLog(@"location %@",placemark1.name);
     pinCLPlacemark = placemark;
     pinPlacemark = [pinPlacemark initWithPlacemark:pinCLPlacemark];
     // [request setSource:[MKMapItem mapItemForCurrentLocation]];
     [request setSource:userMapItem];
     [request setDestination:[[MKMapItem alloc] initWithPlacemark:pinPlacemark]];
     request.transportType = MKDirectionsTransportTypeAutomobile;
     request.requestsAlternateRoutes = false;
     directions = [[MKDirections alloc] initWithRequest:request];
     [self.delegate addItemViewController:self sendDataToA:directions];
     [self.navigationController popViewControllerAnimated:YES];
     NSLog(@"placemark %@",placemark);
     //String to hold address
     NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
     NSLog(@"addressDictionary %@", placemark.addressDictionary);
     
     NSLog(@"placemark %@",placemark.region);
     NSLog(@"placemark %@",placemark.country);  // Give Country Name
     NSLog(@"placemark %@",placemark.locality); // Extract the city name
     NSLog(@"location %@",placemark.name);
     NSLog(@"location %@",placemark.ocean);
     NSLog(@"location %@",placemark.postalCode);
     NSLog(@"location %@",placemark.subLocality);
     self.navigationItem.title = placemark.locality;
     
     NSLog(@"location %@",placemark.location);
     //Print the location to console
     addressLabel.text = [NSString stringWithFormat:@"%@", placemark.name];
     
     NSLog(@"I am currently at %@",locatedAt);
     
     }
     else {
     NSLog(@"Could not locate");
     }
     }
     ];
     
     }
     else {
     NSLog(@"Could not locate");
     }
     }
     ];
     
     **/


}


-(void) buttonClicked:(UIButton*)sender
{
    
    PFObject *touchedObject = friendsPost.object;
    UIButton *button = (UIButton *)sender;
    
    button.selected = ![button isSelected];
    
    PFRelation *relation = [touchedObject relationForKey:@"likers"];
    PFQuery *query = [[touchedObject relationForKey:@"likers"] query];
    // [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        friends = objects;
        if ([objects count] > 0){
         [friendsComing setUserInteractionEnabled:TRUE];
        }
        else{
            friendsComing.text = @"";
            [friendsComing setUserInteractionEnabled:FALSE];
        }
        
            if([self doILike:[PFUser currentUser]])
            {
                if(button.selected){
                
                
                
                }
                else{
                    
                    [likeButton setImage: [UIImage imageNamed:@"like@2x.png"] forState:UIControlStateNormal];

                    [relation removeObject:[PFUser currentUser]];
                    
                    [touchedObject incrementKey:@"likes" byAmount:[NSNumber numberWithInt:-1]];
                    
                    [touchedObject saveInBackground];
                    NSMutableArray *array1 = [NSMutableArray arrayWithArray:friends];
                    [array1 enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PFUser *p, NSUInteger index, BOOL *stop) {
                        if ([p.objectId isEqual:[PFUser currentUser].objectId]) {
                            [array1 removeObjectAtIndex:index];
                        }
                    }];

                    friends = [array1 copy];
                    NSString *friendsString = @"";
                    NSString *otherString = @"";
                    if([self doILike:[PFUser currentUser]])
                    {
                        NSLog(@"FUCK THE MOTHERFUCKING OPLICE");
                    }
                    else{
                        
                        for (int i = 0; i < [friends count]; i++)
                        {
                            otherString = [friendsString stringByAppendingString:([friends objectAtIndex:i][PAWParsePostNameKey])];
                            
                        }
                        if(friendsComing == nil){
                            friendsComing = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/5, distanceLabel.frame.origin.y + distanceLabel.frame.size.height+5, screenWidth*0.60, 40)];
                          
                            if([friends count] == 1)
                            {
                                friendsComing.text = [otherString stringByAppendingString:@" likes this."];
                                [friendsComing setUserInteractionEnabled:TRUE];

                            }
                            else if([friends count] == 0){
                                friendsComing.text = @"no likes yet.";
                                [friendsComing setUserInteractionEnabled:FALSE];
                                
                            }
                            else
                            {   NSString *howMany = [NSString stringWithFormat:@" and %d others like this.", [friends count]-1];
                                friendsComing.text = [otherString stringByAppendingString:howMany];
                                [friendsComing setUserInteractionEnabled:TRUE];

                                
                            }
                            
                            friendsComing.numberOfLines = 1;
                            friendsComing.preferredMaxLayoutWidth = screenWidth * 0.80;
                            
                            friendsComing.textColor = [UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
                            friendsComing.font = [UIFont systemFontOfSize:14.0f];
                            friendsComing.textAlignment = NSTextAlignmentLeft;
                            friendsComing.userInteractionEnabled = YES;
                            
                            
                            UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(friendsComingHandler)];
                            [friendsComing addGestureRecognizer:tap];
                            
                            [self.scrollView addSubview:friendsComing];
                        }
                        if([friends count] == 1)
                        {
                            friendsComing.text = [otherString stringByAppendingString:@" likes this."];
                            [friendsComing setUserInteractionEnabled:TRUE];

                        }
                        else if([friends count] == 0){
                            friendsComing.text = @"no likes yet.";
                            [friendsComing setUserInteractionEnabled:FALSE];

                        }
                        else
                        {   NSString *howMany = [NSString stringWithFormat:@" and %d others like this.", [friends count]-1];
                            friendsComing.text = [otherString stringByAppendingString:howMany];
                            [friendsComing setUserInteractionEnabled:TRUE];

                            
                        }
                    }
                    
                
        
                }
                
            }
        
        else{
            
            [likeButton setImage: [UIImage imageNamed:@"liked@2x.png"] forState:UIControlStateNormal];

            [relation addObject:[PFUser currentUser]];
            
            [touchedObject incrementKey:@"likes" byAmount:[NSNumber numberWithInt:1]];
            
            [touchedObject saveInBackground];
            friends = [objects arrayByAddingObjectsFromArray:@[[PFUser currentUser]]];
            
            NSString *friendsString = @"";
            NSString *otherString = @"";
         
                for (int i = 0; i < [friends count]; i++)
                {
                    otherString = [friendsString stringByAppendingString:([friends objectAtIndex:i][PAWParsePostNameKey])];
                    
                }
                if(friendsComing == nil){
                    friendsComing = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/5, distanceLabel.frame.origin.y + distanceLabel.frame.size.height+5, screenWidth*0.60, 40)];
                    
                    if([friends count] == 1)
                    {
                        friendsComing.text = [otherString stringByAppendingString:@" likes this."];
                        [friendsComing setUserInteractionEnabled:TRUE];

                    }
                    else
                    {   NSString *howMany = [NSString stringWithFormat:@" and %d others like this.", [friends count]-1];
                        friendsComing.text = [otherString stringByAppendingString:howMany];
                        [friendsComing setUserInteractionEnabled:TRUE];

                        
                    }
                    
                    friendsComing.numberOfLines = 1;
                    friendsComing.preferredMaxLayoutWidth = screenWidth * 0.80;
                    
                    friendsComing.textColor = [UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
                    friendsComing.font = [UIFont systemFontOfSize:14.0f];
                    friendsComing.textAlignment = NSTextAlignmentLeft;
                    friendsComing.userInteractionEnabled = YES;
                    
                    
                    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(friendsComingHandler)];
                    [friendsComing addGestureRecognizer:tap];
                    
                    [self.scrollView addSubview:friendsComing];
                }
                if([friends count] == 1)
                {
                    friendsComing.text = [otherString stringByAppendingString:@" likes this."];
                    [friendsComing setUserInteractionEnabled:TRUE];

                }
                else
                {   NSString *howMany = [NSString stringWithFormat:@" and %d others like this.", [friends count]-1];
                    friendsComing.text = [otherString stringByAppendingString:howMany];
                    [friendsComing setUserInteractionEnabled:TRUE];

                }
            

        }
    }];
    [friendsComing setNeedsDisplay];

}


- (void) showLogin
{
    //[self showModalViewController:[[PFLogInViewController alloc] init]];
}

-(void)viewWillAppear:(BOOL)animated
{
  

    
}
/**
@synthesize delegate;
-(void)viewWillDisappear:(BOOL)animated
{
    [self.delegate addItemViewController:self sendDataToA:directions];

}
 **/

#pragma mark - PFQueryTableViewController


- (PFQuery *)queryForTable {
  
    PFQuery *query = [PFQuery queryWithClassName:PAWPostCommentKey];
    [query whereKey:PAWPostCommentPost equalTo:friendsPost.object];
    [query includeKey:PAWPostCommentUser];
    [query orderByAscending:@"createdAt"];
    NSArray *results = [query findObjects:nil];
    NSLog(@"%@",[results description]);
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
  //  if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
   //     [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
   // }
    
    return query;
   
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *cellID = @"CommentCell";
    
    
    // Try to dequeue a cell and create one if necessary
    PAPBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[PAPBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.cellInsetWidth = 20.0f;
        
        cell.delegate = self;
    }
    
    [cell setUser:[object objectForKey:PAWPostCommentUser]];
    [cell setContentText:[object objectForKey:PAWPostCommentContent]];
    [cell setDate:[object createdAt]];
    
    return cell;
    // Try to dequeue a cell and create one if necessary
    /**
    PAPBaseTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[PAPBaseTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.delegate = self;
    }
    
    [cell setUser:[object objectForKey:kPAPActivityFromUserKey]];
    [cell setContentText:[object objectForKey:kPAPActivityContentKey]];
    [cell setDate:[object createdAt]];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"NextPageDetails";
    
    PAPLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PAPLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.cellInsetWidth = kPAPCellInsetWidth;
        cell.hideSeparatorTop = YES;
    }
    
    return cell;
     
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = @"hahahaha";
    return cell;
     **/
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *trimmedComment = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedComment.length != 0) {
        PFObject *comment = [PFObject objectWithClassName:PAWPostCommentKey];
        [comment setObject:friendsPost.object forKey:PAWPostCommentPost];
        [comment setObject:trimmedComment forKey:PAWPostCommentContent]; // Set comment text
        [comment setObject:[PFUser currentUser] forKey:PAWPostCommentUser]; // Set fromUser
       // [comment setObject:self.photo forKey:kPAPActivityPhotoKey];
    /**
        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [ACL setPublicReadAccess:YES];
        [ACL setWriteAccess:YES forUser:[self.photo objectForKey:kPAPPhotoUserKey]];
        comment.ACL = ACL;
        
        [[PAPCache sharedCache] incrementCommentCountForPhoto:self.photo];
     
        // Show HUD view
        [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
       **/
        // If more than 5 seconds pass since we post a comment, stop waiting for the server to respond
        if(friendsPost.object[@"commentCount"] == nil)
        {
            friendsPost.object[@"commentCount"] = @1;
        [friendsPost.object saveInBackground];
        }
        else{
        [friendsPost.object incrementKey:@"commentCount" byAmount:[NSNumber numberWithInt:1]];
            [friendsPost.object saveInBackground];
        }
   
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(handleCommentTimeout:) userInfo:@{@"comment": comment} repeats:NO];
        
        [comment saveEventually:^(BOOL succeeded, NSError *error) {
            [timer invalidate];
            
            if (error && error.code == kPFErrorObjectNotFound) {
               // [[PAPCache sharedCache] decrementCommentCountForPhoto:self.photo];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Could not post comment", nil) message:NSLocalizedString(@"This post is no longer available", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
  
          //  [MBProgressHUD hideHUDForView:self.view.superview animated:YES];
            [self loadObjects];
        }];
    }
    
    [textField setText:@""];
    return [textField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification*)note {
    // Scroll the view to the comment text box
    NSDictionary* info = [note userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.tableView setContentOffset:CGPointMake(0.0f, self.tableView.contentSize.height-kbSize.height) animated:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
   // if((int)friendsPost.object[@"commentCount"]>2){
   
   int movementDistance = (self.tableView.tableFooterView.frame.origin.y +self.tableView.tableFooterView.frame.size.height)-(screenHeight*.55); // tweak as needed
    NSLog(@"%d",movementDistance);
    if(movementDistance  < 0){
        movementDistance = 0;
    }else{
        if(movementDistance < 200){
            movementDistance = -movementDistance;
        }
        else{
            movementDistance = -screenHeight *.34;
        }
    }
    const float movementDuration = 0.3f; // tweak as needed
        int movement = (up ? movementDistance : -movementDistance);
        
        [UIView beginAnimations: @"animateTextField" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        self.view.frame = CGRectOffset(self.view.frame, 0, movement);
        [UIView commitAnimations];
   // }
    
  
}
-(void)friendsComingHandler {
    PAWComingFriendsViewController *friendComingProfileViewController = [[PAWComingFriendsViewController alloc] initWithFriends:friends];
    NSLog(@"I have this many friends %i",[friends count]);
    
    
    friendComingProfileViewController.delegate = self.delegate;
    
    
    [self.navigationController pushViewController:friendComingProfileViewController animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.objects.count) { // A comment row
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        if (object) {
            NSString *commentString = [self.objects[indexPath.row] objectForKey:PAWPostCommentContent];
            
            PFUser *commentAuthor = (PFUser *)[object objectForKey:PAWPostCommentUser];
            
            NSString *nameString = @"";
            if (commentAuthor) {
                nameString = [commentAuthor objectForKey:@"name"];
            }
            
            return [PAPActivityCell heightForCellWithName:nameString contentString:commentString cellInsetWidth:20.0];
        }
    }
    
    // The pagination row
    return 44.0f;
}
- (void)viewDidAppear:(BOOL)animated
{
    
    
    PFUser *user = [PFUser currentUser];
    if(friendsPost.user[@"profileImageThumb"] == nil){
    FAKFontAwesome *icon = [FAKFontAwesome userIconWithSize:50.0f];
    [icon addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f]];
    
    // [icon addAttribute:NSForegroundColorAttributeName value:[Utils themeColor]];
    userImageView.image = [icon imageWithSize:CGSizeMake(70, 70)];
    }
    else
    {
        userImageView.file = friendsPost.user[@"profileImageThumb"];
        
        [userImageView loadInBackground];
    }
    userNameLabel.text = friendsPost.title;
    [userNameLabel sizeToFit];
    detailsLabel.text = friendsPost.subtitle;
    
    long seconds = lroundf(friendsPost.object.createdAt.timeIntervalSinceNow); // Since modulo operator (%) below needs int or long
    
    int hour = -(seconds / 3600);
    int mins = -((seconds % 3600) / 60);
    if (mins < 1) {
        NSString *intervalString = [NSString stringWithFormat:@"posted %ld seconds ago", -seconds];
        detailsLabel.text = [NSString stringWithFormat:@"%@ \r%@",friendsPost.subtitle,intervalString];
    }
    
    else if (hour < 1) {
        NSString *intervalString = [NSString stringWithFormat:@"posted %d minutes ago", mins];
        detailsLabel.text = [NSString stringWithFormat:@"%@ \r%@",friendsPost.subtitle,intervalString];
    }
    else if (hour == 1) {
        NSString *intervalString = [NSString stringWithFormat:@"posted %d hour ago", hour];
        detailsLabel.text = [NSString stringWithFormat:@"%@ \r%@",friendsPost.subtitle,intervalString];   }
    else{
        NSString *intervalString = [NSString stringWithFormat:@"posted %d hours ago", hour];
        detailsLabel.text = [NSString stringWithFormat:@"%@ \r%@",friendsPost.subtitle,intervalString];
    }

    [detailsLabel sizeToFit];
    [self.friendsTable reloadData];

    PFGeoPoint *location = [friendsPost.object objectForKey:@"location"];
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  if (placemark) {
                      
                 
                      NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             
                      addressLabel.text = [NSString stringWithFormat:@"%@", placemark.name];
                      self.navigationItem.title = placemark.locality;
       
                      [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                          if (!error) {
                              NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
                              CLLocation *loca = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude]; //insert your coordinates
                              [ceo reverseGeocodeLocation:loca
                                        completionHandler:^(NSArray *placemarks, NSError *error) {
                                            CLPlacemark *placemark = [placemarks objectAtIndex:0];
                                            
                                            if (placemark) {
                                   
                                                
                                                
                                            }
                                            else {
                                                NSLog(@"Could not locate");
                                            }
                                        }
                               ];
                              [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
                              [[PFUser currentUser] saveInBackground];
                              
                              distance = [user[@"currentLocation"] distanceInMilesTo:location];
                              
                              
                              
                              distanceLabel.text = [NSString stringWithFormat:@"%.02f miles", distance];

                          }
                      }];
                      
                      
                  }
                  else {
                      NSLog(@"Could not locate");
                  }
              }
     ];


    
    
     /**
    PFQuery *query = [PFObject query];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 60*60;
    [query whereKey:@"objectId" equalTo: friendsPost.object[@"objectId"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSLog(@"GOT USER DATA: %@", object);
        
        userNameLabel.text = object[@"text"];
        if(friendsPost.image != nil){
            userImageView.file = object[@"image"];
            [userImageView loadInBackground];
        }
        detailsLabel.text = [NSString stringWithFormat:@"%d\nPins", [friend[@"pins"] intValue]];
        distanceLabel.text = [NSString stringWithFormat:@"%d\ncheckins", [friend[@"checkins"] intValue]];
    }];
     **/
    
    CGRect contentRect = CGRectZero;
    for (UIView *view in self.scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    CGRect frameRect = contentRect;
    if(friendsPost.image != nil){
        frameRect.size.height = contentRect.size.height+50;
    }
    else
    {
        frameRect.size.height = contentRect.size.height-50;
        
    }
    contentRect = frameRect;
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    //self.scrollView.contentSize = contentRect.size;
 
    
}


-(void)tapInImageView:(UITapGestureRecognizer *)tap
{
    
    request = [[MKDirectionsRequest alloc] init];
    PFGeoPoint *location = [friendsPost.object objectForKey:@"location"];

    CLGeocoder *CEO = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
    MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:self.myLocation.coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    MKMapItem *sourceMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:loc.coordinate addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
    [request setSource:sourceMapItem];
    [request setDestination:distMapItem];
   // [request setDestination:[[MKMapItem alloc] initWithPlacemark:pinPlacemark]];

    request.transportType = MKDirectionsTransportTypeWalking;
    request.requestsAlternateRoutes = false;
    directions = [[MKDirections alloc] initWithRequest:request];
    [self.delegate addItemViewController:self sendDataToA:directions];
    [self.navigationController popViewControllerAnimated:YES];
   /**
    [CEO reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  if (placemark) {
                      
                      [CEO reverseGeocodeLocation:self.myLocation
                                completionHandler:^(NSArray *placemarks1, NSError *error) {
                                    CLPlacemark *placemark1 = [placemarks1 objectAtIndex:0];
                                    
                                    if (placemark1) {
                                        userCLPlacemark = placemark1;
                                        userPlacemark = [userPlacemark initWithPlacemark:userCLPlacemark];
                                        userMapItem = [userMapItem initWithPlacemark:userPlacemark];
                                        NSLog(@"placemark %@", placemark1.region);
                                        NSLog(@"placemark %@",placemark1.country);  // Give Country Name
                                        NSLog(@"placemark %@",placemark1.locality); // Extract the city name
                                        NSLog(@"location %@",placemark1.name);
                                        pinCLPlacemark = placemark;
                                        pinPlacemark = [pinPlacemark initWithPlacemark:pinCLPlacemark];
                                        // [request setSource:[MKMapItem mapItemForCurrentLocation]];
                                        [request setSource:userMapItem];
                                        [request setDestination:[[MKMapItem alloc] initWithPlacemark:pinPlacemark]];
                                        request.transportType = MKDirectionsTransportTypeAutomobile;
                                        request.requestsAlternateRoutes = false;
                                        directions = [[MKDirections alloc] initWithRequest:request];
                                        [self.delegate addItemViewController:self sendDataToA:directions];
                                        [self.navigationController popViewControllerAnimated:YES];
                                        NSLog(@"placemark %@",placemark);
                                        //String to hold address
                                        NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                                        NSLog(@"addressDictionary %@", placemark.addressDictionary);
                                        
                                        NSLog(@"placemark %@",placemark.region);
                                        NSLog(@"placemark %@",placemark.country);  // Give Country Name
                                        NSLog(@"placemark %@",placemark.locality); // Extract the city name
                                        NSLog(@"location %@",placemark.name);
                                        NSLog(@"location %@",placemark.ocean);
                                        NSLog(@"location %@",placemark.postalCode);
                                        NSLog(@"location %@",placemark.subLocality);
                                        self.navigationItem.title = placemark.locality;
                                        
                                        NSLog(@"location %@",placemark.location);
                                        //Print the location to console
                                        addressLabel.text = [NSString stringWithFormat:@"%@", placemark.name];
                                        
                                        NSLog(@"I am currently at %@",locatedAt);
                                        
                                    }
                                    else {
                                        NSLog(@"Could not locate");
                                    }
                                }
                       ];
           
                  }
                  else {
                      NSLog(@"Could not locate");
                  }
              }
     ];
    
    **/
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    const CGRect bounds = self.view.bounds;

    CGRect tableViewFrame = CGRectZero;
    
    tableViewFrame.origin.x = 0.0f;
    
    tableViewFrame.origin.y = CGRectGetMaxY(self.view.frame)+ 10.0f;
    
    //  tableViewFrame.size.width = 200;
    //   tableViewFrame.size.height = 200;
    tableViewFrame.size.width = CGRectGetMaxX(bounds) - CGRectGetMinX(tableViewFrame) * 1.0f;
    
    tableViewFrame.size.height = CGRectGetMaxY(bounds) - CGRectGetMaxY(tableViewFrame);
    
    self.friendsTable.frame = tableViewFrame;
    
}


- (void)cell:(PAPBaseTextCell *)cellView didTapUserButton:(PFUser *)aUser {
  //  [self shouldPresentAccountViewForUser:aUser];
    
    if([aUser.objectId isEqual:[PFUser currentUser].objectId]){
        PAWProfileViewController *ProfileViewController = [[PAWProfileViewController alloc] init];
        
        
        
        ProfileViewController.delegate = self;
        
        
        [self.navigationController pushViewController:ProfileViewController animated:YES];
        
    }
    else{
    PAWFriendProfileViewController *friendProfileViewController = [[PAWFriendProfileViewController alloc] initWithFriend:aUser];
    
    
    
    friendProfileViewController.delegate = self.delegate;
    
    
    [self.navigationController pushViewController:friendProfileViewController animated:YES];
    }
}


#pragma mark - DTAlertView Delegate Methods






-(void)profileViewButton:(UIButton*)sender{
    
    PAWProfileViewController *profileViewController = [[PAWProfileViewController alloc] initWithNibName:nil bundle:nil];
    profileViewController.delegate = self.delegate;
    
    [self.navigationController pushViewController:profileViewController animated:YES];
    
}










- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}






@end

