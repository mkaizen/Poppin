//
//  PAWWallViewController.m
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import "PAWWallViewController.h"

#import "PAWConstants.h"
#import "PAWPost.h"
#import "PAWPostFullPage.h"
#import "PAWFriendViewController.h"
#import "PAWWallPostCreateViewController.h"
#import "PAWWallPostsTableViewController.h"

@interface PAWWallViewController ()
<PAWWallPostsTableViewControllerDataSource,
PAWWallPostCreateViewControllerDataSource,UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (strong, nonatomic) UITableView *directionsTableView;
@property (nonatomic, strong) MKCircle *circleOverlay;
@property (nonatomic, strong) NSMutableArray *annotations;
@property (nonatomic, assign) BOOL mapPinsPlaced;
@property (nonatomic, assign) MKDirections *directions;
@property (nonatomic, strong) NSMutableArray *directionsArray;
@property (nonatomic, assign) MKRoute *routeDetails;
@property (nonatomic, assign) BOOL mapPannedSinceLocationUpdate;

@property (nonatomic, strong) PAWWallPostsTableViewController *wallPostsTableViewController;



@end

@implementation PAWWallViewController

#pragma mark -
#pragma mark Init

BOOL postMade;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Poppin";
        
        _annotations = [[NSMutableArray alloc] initWithCapacity:10];
        _allPosts = [[NSMutableArray alloc] initWithCapacity:10];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(distanceFilterDidChange:)
                                                     name:PAWFilterDistanceDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(postWasCreated:)
                                                     name:PAWPostCreatedNotification
                                                   object:nil];
        
    }
    return self;
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    [_locationManager stopUpdatingLocation];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAWFilterDistanceDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PAWPostCreatedNotification object:nil];
   }

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self loadWallPostsTableViewController];
  

      self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"New@2x.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(postButtonSelected:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"users@2x.png"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(friendsButtonSelected:)];
    
   // UIBarButtonItem *FriendButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Contact@2x.png"]
     //                                                               style:UIBarButtonItemStylePlain
    //                                                               target:self
    //                                                               action:@selector(friendsButtonSelected:)];
    
 //   UIBarButtonItem *SettingsButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Cog@2x.png"]
    //                                                                  style:UIBarButtonItemStylePlain
//                                                                     target:self
                                                                 //    action:@selector(settingsButtonSelected:)];
   // self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: SettingsButton, FriendButton,nil];
    
    
    /*
  
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Post"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(postButtonSelected:)];
    
    self.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Friends"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(friendsButtonSelected:)];
    
    // Set our nav bar items.
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"New@2x.png"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(postButtonSelected:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Contact@2x.png"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(friendsButtonSelected:)];
    
    UIBarButtonItem *FriendButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Contact@2x.png"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(friendsButtonSelected:)];
    
    UIBarButtonItem *SettingsButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Cog@2x.png"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(settingsButtonSelected:)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:FriendButton, SettingsButton, nil];
     */

    //navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:183.0f/255.0f blue:241.0f/255.0f alpha:1.0f]};
 
    NSDictionary *textTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIFont fontWithName:@"Aileron" size:20],NSFontAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = textTitleAttributes;
    
  //  UISwipeGestureRecognizer *swipeRightGesture=[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGestureRight:)];
   // [self.view addGestureRecognizer:swipeRightGesture];
  //  swipeRightGesture.direction=UISwipeGestureRecognizerDirectionRight;

    
   // [[self.navigationController.navigationBar appearance] setBarTintColor:[UIColor colorWithRed:0 green:202.0f/255.0f blue:202.0f/255.0f alpha:1.0f]];
    
   // self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:202.0f/255.0f blue:202.0f/255.0f alpha:1.0f];
     /**
    if([self.wallPostsTableViewController getDirections]!= NULL){
        NSLog(@"I DONT GIVE A FUCK DICK RIDRERRR");
        self.directions = [self.wallPostsTableViewController getDirections];
        [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Error %@", error.description);
            } else {
                NSLog(@"HENTAI IS THE GAME DIIIKKK IS THE NAME");
                self.routeDetails = response.routes.lastObject;
                [self.mapView addOverlay:self.routeDetails.polyline];
             
                self.destinationLabel.text = [placemark.addressDictionary objectForKey:@"Street"];
                self.distanceLabel.text = [NSString stringWithFormat:@"%0.1f Miles", routeDetails.distance/1609.344];
                self.transportLabel.text = [NSString stringWithFormat:@"%u" ,routeDetails.transportType];
                self.allSteps = @"";
                for (int i = 0; i < routeDetails.steps.count; i++) {
                    MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
                    NSString *newStep = step.instructions;
                    self.allSteps = [self.allSteps stringByAppendingString:newStep];
                    self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
                    self.steps.text = self.allSteps;
                }
      
            }
                 
        }];
    
    
    
    }
    else{
    NSLog(@"FAGGOT ASS BITCH GET MONEY CASH CASH CASHHSHHHHSHSH");
    
    }
**/
    
    self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(47.62053671457036f, -122.3606449741787f),
                                                MKCoordinateSpanMake(1.0f, 1.0f));
  
    self.mapPannedSinceLocationUpdate = NO;
    [NSTimer scheduledTimerWithTimeInterval:3.0f
                                    target:self selector:@selector(methodB:) userInfo:nil repeats:YES];
    postMade = false;
    PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            
            //    self.navigationItem.rightBarButtonItem.title = @"Post";

            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    [self startStandardUpdates];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem.leftBarButtonItem setEnabled:true];

/*
    
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSFontAttributeName:[UIFont fontWithName:@"Aileron Heavy Italic" size:21],
                                                                    NSForegroundColorAttributeName: [UIColor colorWithRed:0 green:183.0f/255.0f blue:241.0f/255.0f alpha:1.0f]
                                                                    };
    */
    
  
    
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];

    [self.locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self.locationManager stopUpdatingLocation];
}

-(void) recievedDirections:(NSNotification *) obj{
    //lets say you are sending string as object
    self.directions =(MKDirections *) [obj object] ;
    
    
    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {

            NSLog(@"Error %@", error.description);



        } else {
      
        //   self.routeDetails = response.routes.lastObject;
          //  [self.mapView addOverlay:self.routeDetails.polyline];
            for (MKRoute *route in [response routes]) {
                [self.mapView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads];
            }

            /**
             self.destinationLabel.text = [placemark.addressDictionary objectForKey:@"Street"];
             self.distanceLabel.text = [NSString stringWithFormat:@"%0.1f Miles", routeDetails.distance/1609.344];
             self.transportLabel.text = [NSString stringWithFormat:@"%u" ,routeDetails.transportType];
             self.allSteps = @"";
             for (int i = 0; i < routeDetails.steps.count; i++) {
             MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
             NSString *newStep = step.instructions;
             self.allSteps = [self.allSteps stringByAppendingString:newStep];
             self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
             self.steps.text = self.allSteps;
             }
             **/
        }
        
    }];
    
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    const CGRect bounds = self.view.bounds;

    CGRect tableViewFrame = CGRectZero;
    tableViewFrame.origin.x = 6.0f;
    tableViewFrame.origin.y = CGRectGetMaxY(self.mapView.frame) + 6.0f;
    tableViewFrame.size.width = CGRectGetMaxX(bounds) - CGRectGetMinX(tableViewFrame) * 2.0f;
    tableViewFrame.size.height = CGRectGetMaxY(bounds) - CGRectGetMaxY(tableViewFrame);
    self.wallPostsTableViewController.view.frame = tableViewFrame;
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

- (void)gotDirections:(MKDirections *)theDirections {
    
    const CGRect bounds = self.view.bounds;
    
    CGRect tableViewFrame = CGRectZero;
    tableViewFrame.origin.x = 6.0f;
    tableViewFrame.origin.y = CGRectGetMaxY(self.mapView.frame) + 6.0f;
    tableViewFrame.size.width = CGRectGetMaxX(bounds) - CGRectGetMinX(tableViewFrame) * 2.0f;
    tableViewFrame.size.height = CGRectGetMaxY(bounds) - CGRectGetMaxY(tableViewFrame);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"mapCancel@2x.png"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(cancelButtonSelected:)];
    
    self.directions = theDirections;
    [self.directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
        
            //[self.directionsArray initWithArray:response.routes];
              self.routeDetails = response.routes.lastObject;
            [self.mapView addOverlay:self.routeDetails.polyline];
            for (MKRoute *route in [response routes]) {
                [self.mapView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads];
            }
            if(self.directionsTableView == nil){
            self.directionsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
            
            // must set delegate & dataSource, otherwise the the table will be empty and not responsive
            self.directionsTableView.delegate = self;
            self.directionsTableView.dataSource = self;
            self.directionsTableView.frame = tableViewFrame;
            self.directionsTableView.backgroundColor = [UIColor whiteColor];
            NSString *theDirections;
            self.directionsArray = [[NSMutableArray alloc] init];
            [self.view addSubview:self.directionsTableView];
            }
            else
            {
                self.directionsTableView.hidden = false;
            }
            for (int i = 0; i < self.routeDetails.steps.count; i++) {
                MKRouteStep *step = [self.routeDetails.steps objectAtIndex:i];
                NSString *newStep = step.instructions;
                double distance1 = step.distance;
                double distance2 = distance1 * 0.000621371;
                unichar firstChar = [[newStep uppercaseString] characterAtIndex:0];
                if (firstChar == 'C' || firstChar == 'P') {
                    NSMutableString* aString = [NSMutableString stringWithFormat:@"\%@ for %.2f miles",newStep,distance2];
                    [self.directionsArray addObject:aString];

                }
                else
                {
                    NSMutableString* aString = [NSMutableString stringWithFormat:@"\%@ in %.2f miles",newStep,distance2];
                    [self.directionsArray addObject:aString];


                }
                if(i == self.routeDetails.steps.count - 1){
                        [self.directionsTableView reloadData];
                 
                
                
                }
                
            }
            
            // add to canvas

            /**
             self.destinationLabel.text = [placemark.addressDictionary objectForKey:@"Street"];
             self.distanceLabel.text = [NSString stringWithFormat:@"%0.1f Miles", routeDetails.distance/1609.344];
             self.transportLabel.text = [NSString stringWithFormat:@"%u" ,routeDetails.transportType];
             self.allSteps = @"";
             for (int i = 0; i < routeDetails.steps.count; i++) {
             MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
             NSString *newStep = step.instructions;
             self.allSteps = [self.allSteps stringByAppendingString:newStep];
             self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
             self.steps.text = self.allSteps;
             }
             **/
        }
        
    }];

}

#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.directionsArray count];
}

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"newFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = self.directionsArray[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    
 
    //etc.
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont * font = [UIFont systemFontOfSize:14.0f];
    NSString *text = [self.directionsArray objectAtIndex:indexPath.row];
    NSAttributedString *attributedText =
    
    [[NSAttributedString alloc]
     initWithString:text
     attributes:@
     {
     NSFontAttributeName: font     }];
    
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size.height + 20;
}

#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected %d row", indexPath.row);
}

#pragma mark -
#pragma mark WallPostsTableViewController

- (void)loadWallPostsTableViewController {
    // Add the wall posts tableview as a subview with view containment (new in iOS 5.0):
    self.wallPostsTableViewController = [[PAWWallPostsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.wallPostsTableViewController.dataSource = self;
    [self.view addSubview:self.wallPostsTableViewController.view];
    self.wallPostsTableViewController.parent = self;
    [self addChildViewController:self.wallPostsTableViewController];
    [self.wallPostsTableViewController didMoveToParentViewController:self];
}

#pragma mark DataSource

- (CLLocation *)currentLocationForWallPostsTableViewController:(PAWWallPostsTableViewController *)controller {
    return self.currentLocation;
}

#pragma mark -
#pragma mark WallPostCreatViewController

- (void)presentWallPostCreateViewController {
    PAWWallPostCreateViewController *viewController = [[PAWWallPostCreateViewController alloc] initWithNibName:nil bundle:nil];
    viewController.dataSource = self;
    //[self.navigationController presentViewController:viewController animated:YES completion:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark DataSource

- (CLLocation *)currentLocationForWallPostCrateViewController:(PAWWallPostCreateViewController *)controller {
    return self.currentLocation;
}

#pragma mark -
#pragma mark NSNotificationCenter notification handlers

- (void)distanceFilterDidChange:(NSNotification *)note {
    CLLocationAccuracy filterDistance = [[note userInfo][kPAWFilterDistanceKey] doubleValue];

    if (self.circleOverlay != nil) {
        [self.mapView removeOverlay:self.circleOverlay];
        self.circleOverlay = nil;
    }
    self.circleOverlay = [MKCircle circleWithCenterCoordinate:self.currentLocation.coordinate radius:filterDistance];
    [self.mapView addOverlay:self.circleOverlay];

    // Update our pins for the new filter distance:
    [self updatePostsForLocation:self.currentLocation withNearbyDistance:filterDistance];

    // If they panned the map since our last location update, don't recenter it.
    if (!self.mapPannedSinceLocationUpdate) {
        // Set the map's region centered on their location at 2x filterDistance
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, filterDistance * 2.0f, filterDistance * 2.0f);

        [self.mapView setRegion:newRegion animated:YES];
        self.mapPannedSinceLocationUpdate = NO;
    } else {
        // Just zoom to the new search radius (or maybe don't even do that?)
        MKCoordinateRegion currentRegion = self.mapView.region;
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(currentRegion.center, filterDistance * 2.0f, filterDistance * 2.0f);

        BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
        [self.mapView setRegion:newRegion animated:YES];
        self.mapPannedSinceLocationUpdate = oldMapPannedValue;
    }
}

- (void) methodB:(NSTimer *)timer
{
    for (PAWPost *post in _allPosts) {
        [self queryForAllPostsNearLocation:self.currentLocation withNearbyDistance:30000];

    }
    }

- (void)setCurrentLocation:(CLLocation *)currentLocation {
    if (self.currentLocation == currentLocation) {
        return;
    }

    _currentLocation = currentLocation;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PAWCurrentLocationDidChangeNotification
                                                            object:nil
                                                          userInfo:@{ kPAWLocationKey : currentLocation } ];
        
    
    });
    
    CLLocationAccuracy filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:PAWUserDefaultsFilterDistanceKey];

    // If they panned the map since our last location update, don't recenter it.
    if (!self.mapPannedSinceLocationUpdate) {
        // Set the map's region centered on their new location at 2x filterDistance
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, filterDistance * 2.0f, filterDistance * 2.0f);

        BOOL oldMapPannedValue = self.mapPannedSinceLocationUpdate;
        [self.mapView setRegion:newRegion animated:YES];
        self.mapPannedSinceLocationUpdate = oldMapPannedValue;
    } // else do nothing.

    if (self.circleOverlay != nil) {
        [self.mapView removeOverlay:self.circleOverlay];
        self.circleOverlay = nil;
    }
    self.circleOverlay = [MKCircle circleWithCenterCoordinate:self.currentLocation.coordinate radius:filterDistance];
    [self.mapView addOverlay:self.circleOverlay];

    // Update the map with new pins:
    [self queryForAllPostsNearLocation:self.currentLocation withNearbyDistance:filterDistance];
    // And update the existing pins to reflect any changes in filter distance:
    [self updatePostsForLocation:self.currentLocation withNearbyDistance:filterDistance];
}

- (void)postWasCreated:(NSNotification *)note {
    CLLocationAccuracy filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:PAWUserDefaultsFilterDistanceKey];
    [self queryForAllPostsNearLocation:self.currentLocation withNearbyDistance:filterDistance];
}

#pragma mark -
#pragma mark UINavigationBar-based actions

- (IBAction)settingsButtonSelected:(id)sender {
    [self.delegate wallViewControllerWantsToPresentSettings:self];
}

- (IBAction)friendsButtonSelected:(id)sender {
    
    [self.navigationItem.leftBarButtonItem setEnabled:false];
    [self.delegate wallViewControllerWantsToPresentFriend:self];
    }


- (IBAction)cancelButtonSelected:(id)sender {
    
    self.directionsTableView.hidden = true;

    for (id<MKOverlay> overlayToRemove in self.mapView.overlays)
    {
         if ([overlayToRemove isKindOfClass:[MKPolyline class]])
        {
            [self.mapView removeOverlay:overlayToRemove];
        }
    }
  


    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"New@2x.png"]
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(postButtonSelected:)];




}


- (IBAction)postButtonSelected:(id)sender {
   // if (postMade == true) {
    /*
        PFQuery *query = [PFQuery queryWithClassName:@"Posts"];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                for (PFObject *object in objects) {
                 //   [object deleteInBackground];
                    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            
                            
                            [self.wallPostsTableViewController loadObjects];
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
        
     //   self.navigationItem.rightBarButtonItem.title = @"Post";
         [self presentWallPostCreateViewController];
        
        
      //  postMade = false;
   // }
 //   else
   // {
     //   [self presentWallPostCreateViewController];
     //    self.navigationItem.rightBarButtonItem.title = @"Cancel";
     //   postMade = true;
        
    //}
}

#pragma mark -
#pragma mark CLLocationManagerDelegate methods and helpers

- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];

        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;

        // Set a movement threshold for new events.
        _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    }
    return _locationManager;
}

- (void)startStandardUpdates {
	[self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];

    CLLocation *currentLocation = self.locationManager.location;
    if (currentLocation) {
        self.currentLocation = currentLocation;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorized:
        {
            NSLog(@"kCLAuthorizationStatusAuthorized");
            // Re-enable the post button if it was disabled before.
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self.locationManager startUpdatingLocation];
        }
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"kCLAuthorizationStatusDenied");
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Poppin can’t access your current location.\n\nTo view nearby posts or create a post at your current location, turn on access for Anywall to your location in the Settings app under Location Services." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
            // Disable the post button.
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
        {
            NSLog(@"kCLAuthorizationStatusNotDetermined");
        }
            break;
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"kCLAuthorizationStatusRestricted");
        }
            break;
		default:break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    self.currentLocation = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        [self.locationManager stopUpdatingLocation];
    } else if (error.code == kCLErrorLocationUnknown) {
        // todo: retry?
        // set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error retrieving location"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay {
   
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:self.routeDetails.polyline];
        routeLineRenderer.strokeColor = [UIColor colorWithRed:200.0f/255.0f green:135.0f/255.0f blue:254.0f/255.0f alpha:1.0f];
        routeLineRenderer.lineWidth = 4;
       
        return routeLineRenderer;
    }
    
    if ([overlay isKindOfClass:[MKCircle class]]) {
        
        MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:self.circleOverlay];
        [circleRenderer setFillColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.2f]];
        [circleRenderer setStrokeColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.7f]];
        [circleRenderer setLineWidth:1.0f];
        return circleRenderer;
    }


    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapVIew viewForAnnotation:(id<MKAnnotation>)annotation {
    // Let the system handle user location annotations.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }

    static NSString *pinIdentifier = @"CustomPinAnnotation";

    // Handle any custom annotations.
    if ([annotation isKindOfClass:[PAWPost class]]) {
        // Try to dequeue an existing pin view first.
        MKAnnotationView *pinView = (MKAnnotationView*)[mapVIew dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];

        if (!pinView) {
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:pinIdentifier];
        } else {
            pinView.annotation = annotation;
            
        }
        if ([(PAWPost *)annotation invited] != nil) {
            
            pinView.image = [UIImage imageNamed:@"mapPinFriends@2x.png"];
        }
        else {
            
            pinView.image = [UIImage imageNamed:@"mapPin@2x.png"];
        
        }
        //pinView.pinColor = [(PAWPost *)annotation pinColor];
        //pinView.animatesDrop = [((PAWPost *)annotation) animatesDrop];
     //   pinView.image = [UIImage imageNamed:@"Pin.png"];
        pinView.centerOffset = CGPointMake(0.0f, -pinView.frame.size.height/2);
        pinView.canShowCallout = YES;

        return pinView;
    }

    return nil;
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    id<MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[PAWPost class]]) {
        PAWPost *post = [view annotation];
        [self.wallPostsTableViewController highlightCellForPost:post];
    } else if ([annotation isKindOfClass:[MKUserLocation class]]) {
        // Center the map on the user's current location:
        CLLocationAccuracy filterDistance = [[NSUserDefaults standardUserDefaults] doubleForKey:PAWUserDefaultsFilterDistanceKey];
        MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate,
                                                                          filterDistance * 2.0f,
                                                                          filterDistance * 2.0f);

        [self.mapView setRegion:newRegion animated:YES];
        self.mapPannedSinceLocationUpdate = NO;
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    id<MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[PAWPost class]]) {
        PAWPost *post = [view annotation];
        [self.wallPostsTableViewController unhighlightCellForPost:post];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.mapPannedSinceLocationUpdate = YES;
}

#pragma mark -
#pragma mark Fetch map pins

- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance {
    PFQuery *query = [PFQuery queryWithClassName:PAWParsePostsClassName];

    if (currentLocation == nil) {
        NSLog(@"%s got a nil location!", __PRETTY_FUNCTION__);
    }

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.allPosts count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

    // Query for posts sort of kind of near our current location.
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    [query whereKey:PAWParsePostLocationKey nearGeoPoint:point withinKilometers:PAWWallPostMaximumSearchDistance];
    [query includeKey:PAWParsePostUserKey];
    query.limit = PAWWallPostsSearchDefaultLimit;

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error in geo query: %@", error.description); // todo why is this ever happening?
        } else {
            // We need to make new post objects from objects,
            // and update allPosts and the map to reflect this new array.
            // But we don't want to remove all annotations from the mapview blindly,
            // so let's do some work to figure out what's new and what needs removing.

            // 1. Find genuinely new posts:
            NSMutableArray *newPosts = [[NSMutableArray alloc] initWithCapacity:PAWWallPostsSearchDefaultLimit];
        
            // (Cache the objects we make for the search in step 2:)
            NSMutableArray *allNewPosts = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            for (PFObject *object in objects) {
                
                PAWPost *newPost = [[PAWPost alloc] initWithPFObject:object];

                [allNewPosts addObject:newPost];
                if (![_allPosts containsObject:newPost]) {
                    [newPosts addObject:newPost];
                
                }
            }
            // newPosts now contains our new objects.

            // 2. Find posts in allPosts that didn't make the cut.
            NSMutableArray *postsToRemove = [[NSMutableArray alloc] initWithCapacity:PAWWallPostsSearchDefaultLimit];
            for (PAWPost *currentPost in _allPosts) {
                if (![allNewPosts containsObject:currentPost]) {
                    [postsToRemove addObject:currentPost];
                }
            }
            // postsToRemove has objects that didn't come in with our new results.

            // 3. Configure our new posts; these are about to go onto the map.
            for (PAWPost *newPost in newPosts) {
                CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:newPost.coordinate.latitude
                                                                        longitude:newPost.coordinate.longitude];
                // if this post is outside the filter distance, don't show the regular callout.
                CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
                [newPost setTitleAndSubtitleOutsideDistance:( distanceFromCurrent > nearbyDistance ? YES : NO )];
                // Animate all pins after the initial load:
                newPost.animatesDrop = self.mapPinsPlaced;
            }

            // At this point, newAllPosts contains a new list of post objects.
            // We should add everything in newPosts to the map, remove everything in postsToRemove,
            // and add newPosts to allPosts.
            [self.mapView removeAnnotations:postsToRemove];
            [self.mapView addAnnotations:newPosts];

            [_allPosts addObjectsFromArray:newPosts];
            [_allPosts removeObjectsInArray:postsToRemove];

            self.mapPinsPlaced = YES;
        }
    }];
}

// When we update the search filter distance, we need to update our pins' titles to match.
- (void)updatePostsForLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy) nearbyDistance {
    for (PAWPost *post in _allPosts) {
        CLLocation *objectLocation = [[CLLocation alloc] initWithLatitude:post.coordinate.latitude
                                                                longitude:post.coordinate.longitude];

        // if this post is outside the filter distance, don't show the regular callout.
        CLLocationDistance distanceFromCurrent = [currentLocation distanceFromLocation:objectLocation];
        if (distanceFromCurrent > nearbyDistance) { // Outside search radius
            [post setTitleAndSubtitleOutsideDistance:YES];
           //[(MKPinAnnotationView *)[self.mapView viewForAnnotation:post] setPinColor:post.pinColor];
        } else {
            [post setTitleAndSubtitleOutsideDistance:NO]; // Inside search radius
          //  [(MKPinAnnotationView *)[self.mapView viewForAnnotation:post] setPinColor:post.pinColor];
        }
    }
}

@end
