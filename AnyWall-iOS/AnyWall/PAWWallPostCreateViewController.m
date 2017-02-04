//
//  PAWWallPostCreateViewController.m
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import "PAWWallPostCreateViewController.h"

#import <Parse/Parse.h>

#import "PAWConstants.h"
#import "PAWConfigManager.h"
#import "PAWInviteFriendsViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface PAWWallPostCreateViewController () <UIImagePickerControllerDelegate,PAWInviteFriendsViewControllerDelegate>
{
    NSArray *pickerData;
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;
}


@property (nonatomic, assign) NSUInteger maximumCharacterCount;
@property (nonatomic) NSInteger timerLength;
@property (nonatomic) BOOL pic;
@property (nonatomic, strong) CZPickerView *picker;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) NSArray *friendsInvited;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

@end

@implementation PAWWallPostCreateViewController

#pragma mark -
#pragma mark Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];

    if (self) {
        _maximumCharacterCount = [[PAWConfigManager sharedManager] postMaxCharacterCount];
    }
    return self;
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    screenRect = [[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    self.pic = NO;
    pickerData = @[@"15 mins", @"30 mins", @"45 mins",@"1 Hour", @"2 Hours", @"3 Hours", @"4 Hours", @"5 Hours", @"6 Hours"];
    
    self.scrollView.contentSize = CGSizeMake(self.blankView.frame.size.width/2,self.blankView.frame.size.height);
  //  self.scrollView.contentSize=CGSizeMake(screenWidth,screenHeight);
    UIToolbar* numberToolbar;
    numberToolbar.barStyle = UIBarStyleDefault;
    [numberToolbar setBarTintColor:[UIColor lightGrayColor]];
    // do any further configuration to the scroll view
    // add a view, or views, as a subview of the scroll view.
    
    // release scrollView as self.view retains it
    //self.view=scrollView;
    
    // self.picker.delegate = self;
    
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 144, 35)];
    UIBarButtonItem *timebut =[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"stopwatch@3x.png"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(selectButton)];
    timebut.tintColor =  [UIColor colorWithRed:0 green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
    UIBarButtonItem *cambut =[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"compact_camera@2x.png"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(cameraButton)];
    cambut.tintColor =  [UIColor colorWithRed:0 green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
    self.characterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 144.0f, 21.0f)];
    self.characterCountLabel.backgroundColor = [UIColor clearColor];
    [self.characterCountLabel setFont:[UIFont systemFontOfSize:12]];
    self.characterCountLabel.textColor = [UIColor darkGrayColor];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc] initWithCustomView:self.characterCountLabel],                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           timebut,                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
 cambut
,
                           nil];
  [numberToolbar sizeToFit];
   // [numberToolbar addSubview:self.characterCountLabel];
    self.timerLength = 0;
    //  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
    //                                                                         action:@selector(dismissKeyboard)];
    

    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPost:)];
    
    self.postButton = [[UIBarButtonItem alloc]initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(postPost:)];
    self.navigationItem.rightBarButtonItem = self.postButton;

    self.title = @"Create a Post";
    
    //[self.view addGestureRecognizer:tap];
    self.textView.inputAccessoryView = numberToolbar;

    [self updateCharacterCountLabel];
    [self checkCharacterCount];
    [self
     setNeedsStatusBarAppearanceUpdate];
}
//-(void)dismissKeyboard {
//   [_textView resignFirstResponder];

//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textView becomeFirstResponder];
    [self.inviteButton setEnabled:true];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.pic = YES;
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    self.imageView =[[UIImageView alloc] initWithFrame:CGRectMake(self.textView.frame.origin.x,self.textView.frame.origin.y + self.textView.frame.size.height+30,self.textView.frame.size.width,320)];
    self.imageView.image = chosenImage;
    self.imageView.userInteractionEnabled = YES;
    
    
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOnPic)];
    UIImage *btnImage = [UIImage imageNamed:@"cancel.png"];
    UIButton *btnTwo = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTwo.frame = CGRectMake(self.imageView.frame.size.width*.90, 9, 18, 18);
    [btnTwo addTarget:self action:@selector(removePic) forControlEvents:UIControlEventTouchUpInside];
    [self.imageView addSubview:btnTwo];
    [btnTwo setImage:btnImage forState:UIControlStateNormal];
    
    [self.imageView addGestureRecognizer:tap];
    [self.scrollView addSubview:self.imageView];
    NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
    self.photoFile = [PFFile fileWithData:imageData];
    
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    NSLog(@"Requested background expiration task with id %lu for Anypic photo upload", (unsigned long)self.fileUploadBackgroundTaskId);
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
        
    }];
    self.photoFile = [PFFile fileWithData:imageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    NSLog(@"Requested background expiration task with id %lu for Anypic photo upload", (unsigned long)self.fileUploadBackgroundTaskId);
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
        
    }];

    
  //  CGRect imageViewFrame = CGRectZero;
   
 //   imageViewFrame.origin.x = 0;
    
   // imageViewFrame.origin.y = 0;
   
   // imageViewFrame.size.height = 30;
    
    //imageViewFrame.size.width = 30;
    
  // self.imageView = [[UIImageView alloc]initWithFrame:imageViewFrame];
//    [self.imageView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
   // [self.textView addSubview:self.imageView];
    
    
   // NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.textView.text];

  //  NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
   // textAttachment.image = chosenImage;
  
   // CGFloat oldWidth = textAttachment.image.size.width;
    
    //I'm subtracting 10px to make the image display nicely, accounting
    //for the padding inside the textView
  //  CGFloat scaleFactor = oldWidth / (self.textView.frame.size.width - 10);
   // textAttachment.image = [UIImage imageWithCGImage:textAttachment.image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
  //  NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
    // [attributedString replaceCharactersInRange:NSMakeRange(6, 1) withAttributedString:attrStringWithImage];
   // self.textView.attributedText = attributedString;
  //  [self.textView.textStorage insertAttributedString:attrStringWithImage atIndex:self.textView.selectedRange.location];
    [picker dismissModalViewControllerAnimated:YES];
   }

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    self.pic = NO;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)addItemViewController:(PAWInviteFriendsViewController *)controller didFinishEnteringItem:(NSArray *)item
{
    self.friendsInvited = item;
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


- (IBAction)friendsInvite:(id)sender{
    

                    PFRelation *relation = [[PFUser currentUser] relationForKey:@"friends"];
                    PFQuery *relationQuery = [relation query];
                   // [relationQuery includeKey:@"friends"];
                    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
                        if (error) {
                        } else {
                            
                             [self.inviteButton setEnabled:false];
                            PAWInviteFriendsViewController *inviteViewController = [[PAWInviteFriendsViewController alloc] initWithFriends:friends];
                            NSLog(@"I have this many friends %i",[friends count]);
                            
                            
                            inviteViewController.delegate = self;
                            
                          // [self presentViewController:inviteViewController animated:YES completion:NULL];
                           
                        [self.navigationController pushViewController:inviteViewController animated:YES];
                            
                        }
                    }];
    }

    

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    if ([touch view] != self.picker ){
        [self.picker endEditing:YES];
        self.picker.hidden = YES;
    [self.textView becomeFirstResponder];

    }
 //   if ([touch view] != self.textView){
  //  [self.textView resignFirstResponder];
  //     [self.textView endEditing:YES];
        
 // }
}

- (void)cameraButton {
    
    self.camPicker = [[UIImagePickerController alloc] init];
    self.camPicker.delegate = self;
    self.camPicker.allowsEditing = YES;
    self.camPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:self.camPicker animated:YES completion:NULL];
    
    
}
- (void) touchOnPic {
    [self.textView resignFirstResponder];

}

- (void) removePic {
    [self.imageView removeFromSuperview];
    self.pic = NO;
    
}

- (NSAttributedString *)czpickerView:(CZPickerView *)pickerView
               attributedTitleForRow:(NSInteger)row{
    
    NSAttributedString *att = [[NSAttributedString alloc]
                               initWithString:pickerData[row]
                               attributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:12.0]
                                            }];
    return att;
}

- (NSString *)czpickerView:(CZPickerView *)pickerView
               titleForRow:(NSInteger)row{
    return pickerData[row];
}



- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView {
    return [pickerData count];
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row {
    NSLog(@"%@ is chosen!", pickerData[row]);
    _timerLength = row+1;

   //[self.navigationController setNavigationBarHidden:YES];
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemsAtRows:(NSArray *)rows {
    for (NSNumber *n in rows) {
        NSInteger row = [n integerValue];
        NSLog(@"%@ is chosen!", pickerData[row]);
    }
}

- (void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView {
    //[self.navigationController setNavigationBarHidden:YES];
    NSLog(@"Canceled.");
}

- (void)czpickerViewWillDisplay:(CZPickerView *)pickerView {
    NSLog(@"Picker will display.");
}

- (void)czpickerViewDidDisplay:(CZPickerView *)pickerView {
    NSLog(@"Picker did display.");
}

- (void)czpickerViewWillDismiss:(CZPickerView *)pickerView {
    NSLog(@"Picker will dismiss.");
}

- (void)czpickerViewDidDismiss:(CZPickerView *)pickerView {
    NSLog(@"Picker did dismiss.");
}

- (IBAction)selectbtn:(id)sender {
    if(self.imageView != NULL){
        self.imageView.hidden = !self.imageView.hidden;
    }
    if(self.picker == nil){
        self.picker = [[CZPickerView alloc] initWithHeaderTitle:@"" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm" navigationBarHeight:self.navigationController.navigationBar.frame.size.height];

  //  self.picker = [[CZPickerView alloc] initWithHeaderTitle:@"" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
       // [self.picker setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width/2, self.view.frame.size.height/5)];
    self.picker.headerBackgroundColor = [UIColor whiteColor];
  //  picker.backgroundColor = [UIColor colorWithRed:245 green:245 blue:245 alpha:0.7];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    self.picker.needFooterView = NO;
    
    [self.picker show];
    }
    else
    {
        [self.picker show];
    }
    /**
    if (self.picker == nil) {
 
      
        [self.view endEditing:YES];
        
        self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(screenWidth*.03, screenHeight/11, screenWidth*.94, screenHeight/2)];
        [self.picker setBackgroundColor:[UIColor whiteColor]];
        
        self.picker.showsSelectionIndicator = YES;
        self.textView.hidden = YES;
        self.picker.hidden = NO;
        self.picker.delegate = self;
        UIViewController *sortViewController = [[UIViewController alloc] init];
        sortViewController.view = self.picker;
        sortViewController.preferredContentSize = CGSizeMake(320, 216);
        self.SortPopover = [[UIPopoverController alloc] initWithContentViewController:sortViewController];
        [self.SortPopover presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
   
    
        [self.view addSubview:self.picker];
    }
    else if(self.picker.hidden == NO)
    {
        self.textView.hidden = NO;

        self.picker.hidden = YES;
        
    }
    
    else if(self.picker.hidden == YES)
    {
        [self.view endEditing:YES];
        
        self.textView.hidden = YES;

        self.picker.hidden = NO;
        
    }
    **/
}


- (void)selectButton{
    if(self.imageView != NULL){
        self.imageView.hidden = !self.imageView.hidden;
    }
    if(self.picker == nil){
        self.picker = [[CZPickerView alloc] initWithHeaderTitle:@"" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm" navigationBarHeight:self.navigationController.navigationBar.frame.size.height-5];
        
        //  self.picker = [[CZPickerView alloc] initWithHeaderTitle:@"" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
        // [self.picker setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width/2, self.view.frame.size.height/5)];
        self.picker.headerBackgroundColor = [UIColor whiteColor];
        //  picker.backgroundColor = [UIColor colorWithRed:245 green:245 blue:245 alpha:0.7];
        self.picker.delegate = self;
        self.picker.dataSource = self;
        
        self.picker.needFooterView = NO;
        
        [self.picker show];
    }
    else
    {
        [self.picker show];
    }
    /**
     if (self.picker == nil) {
     
     
     [self.view endEditing:YES];
     
     self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(screenWidth*.03, screenHeight/11, screenWidth*.94, screenHeight/2)];
     [self.picker setBackgroundColor:[UIColor whiteColor]];
     
     self.picker.showsSelectionIndicator = YES;
     self.textView.hidden = YES;
     self.picker.hidden = NO;
     self.picker.delegate = self;
     UIViewController *sortViewController = [[UIViewController alloc] init];
     sortViewController.view = self.picker;
     sortViewController.preferredContentSize = CGSizeMake(320, 216);
     self.SortPopover = [[UIPopoverController alloc] initWithContentViewController:sortViewController];
     [self.SortPopover presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
     
     
     
     [self.view addSubview:self.picker];
     }
     else if(self.picker.hidden == NO)
     {
     self.textView.hidden = NO;
     
     self.picker.hidden = YES;
     
     }
     
     else if(self.picker.hidden == YES)
     {
     [self.view endEditing:YES];
     
     self.textView.hidden = YES;
     
     self.picker.hidden = NO;
     
     }
     **/
}


#pragma mark -
#pragma mark UINavigationBar-based actions

- (IBAction)cancelPost:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
    
}

- (IBAction)postPost:(id)sender {
    // Resign first responder to dismiss the keyboard and capture in-flight autocorrect suggestions
    [self.textView resignFirstResponder];
    [self.picker removeFromSuperview];
    // Capture current text field contents:
    [self updateCharacterCountLabel];
    BOOL isAcceptableAfterAutocorrect = [self checkCharacterCount];
    
    if (!isAcceptableAfterAutocorrect) {
        [self.textView becomeFirstResponder];
        return;
    }
    
    // Data prep:
   
    CLLocation *currentLocation = [self.dataSource currentLocationForWallPostCrateViewController:self];
    CLLocationCoordinate2D currentCoordinate = currentLocation.coordinate;
    PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                                                      longitude:currentCoordinate.longitude];
    PFUser *user = [PFUser currentUser];
   
     [user incrementKey:@"pins"];
     [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // The score key has been incremented
        } else {
            // There was a problem, check error.description
        }
    }];

    // Stitch together a postObject and send this async to Parse
    PFObject *postObject = [PFObject objectWithClassName:PAWParsePostsClassName];
    postObject[PAWParsePostTextKey] = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    postObject[@"postSize"] = @(round( (self.textView.contentSize.height - self.textView.textContainerInset.top - self.textView.textContainerInset.bottom) / self.textView.font.lineHeight) );
    postObject[PAWParsePostUserKey] = user;
    
    if(self.friendsInvited != nil){
        // WRONG WAY TO SEND PUSH - INSECURE!
        
        // Find devices associated with these users

        PFUser *user = [PFUser currentUser];
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" containedIn:self.friendsInvited];
        [pushQuery whereKey:@"user" notEqualTo:user];
    
        
        NSString *message = [NSString stringWithFormat:@"%@Sent you an invite!", user[@"name"]];
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery]; // Set our Installation query
        [push setMessage:message];
        [push sendPushInBackground];
        postObject[@"invited"] = self.friendsInvited;
    }
    if(self.pic == YES){
    postObject[PAWParsePostImageKey] = self.photoFile;
   /** NSData *imageData = UIImagePNGRepresentation(self.imageView.image);
        PFFile *file = [PFFile fileWithData:imageData];
                [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"WHAT UP BOI");
                // The image has now been uploaded to Parse. Associate it with a new object
                postObject[PAWParsePostImageKey] = file;
            
            }
        }]; **/
    }
    postObject[PAWParsePostLocationKey] = currentPoint;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *timer;
    
    if(_timerLength == 0)
    {
        timer = [calendar dateByAddingUnit:NSCalendarUnitMinute
                                     value:15
                                    toDate:[NSDate date]
                                   options:kNilOptions];
        
    }
    
    else if(_timerLength == 1)
    {
        timer = [calendar dateByAddingUnit:NSCalendarUnitMinute
                                     value:30
                                    toDate:[NSDate date]
                                   options:kNilOptions];
        
    }
    else if(_timerLength == 2)
    {
        timer = [calendar dateByAddingUnit:NSCalendarUnitHour
                                     value:45
                                    toDate:[NSDate date]
                                   options:kNilOptions];
        
    }
    
    else   {
        timer = [calendar dateByAddingUnit:NSCalendarUnitHour
                                     value:_timerLength
                                    toDate:[NSDate date]
                                   options:kNilOptions];
        
    }
    
    postObject[PAWParsePostDateKey] = timer;
    
    // Use PFACL to restrict future modifications to this object.
    PFACL *readOnlyACL = [PFACL ACL];
    [readOnlyACL setPublicReadAccess:YES];
    [readOnlyACL setPublicWriteAccess:YES];
    postObject.ACL = readOnlyACL;
    
    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Couldn't save!");
            NSLog(@"%@", error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error userInfo][@"error"]
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Ok", nil];
            [alertView show];
            return;
        }
        if (succeeded) {
            NSLog(@"Successfully saved!");
            NSLog(@"%@", postObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:PAWPostCreatedNotification object:nil];
            });
        } else {
            NSLog(@"Failed to save.");
        }
    }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
  //  CGFloat fixedWidth = textView.frame.size.width;
   // CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
   // CGRect newFrame = textView.frame;
  //  newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
//textView.frame = newFrame;
    //if(self.imageView != NULL){
    //[self.imageView setFrame:CGRectMake(50, newFrame.origin.y + 10, self.imageView.frame.size.width, self.imageView.frame.size.height)];
    //}
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [self.textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = self.textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    self.textView.frame = newFrame;
    if(self.imageView != NULL){
    [self.imageView setFrame:CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y+self.textView.frame.size.height+30, self.imageView.frame.size.width, self.imageView.frame.size.height)];
    }
    [self updateCharacterCountLabel];
    [self checkCharacterCount];
}

#pragma mark -
#pragma mark Accessors

- (void)setMaximumCharacterCount:(NSUInteger)maximumCharacterCount {
    if (self.maximumCharacterCount != maximumCharacterCount) {
        _maximumCharacterCount = maximumCharacterCount;
        
        [self updateCharacterCountLabel];
        [self checkCharacterCount];
    }
}

#pragma mark -
#pragma mark Private

- (void)updateCharacterCountLabel {
    NSUInteger count = [self.textView.text length];
    self.characterCountLabel.text = [NSString stringWithFormat:@"%lu/%lu",
                                     (unsigned long)count,
                                     (unsigned long)self.maximumCharacterCount];
   
}



- (BOOL)checkCharacterCount {
    BOOL enabled = NO;
    
    NSUInteger count = [self.textView.text length];
    if (count > 0 && count < self.maximumCharacterCount) {
        enabled = YES;
    }
    
    self.postButton.enabled = enabled;
    
    return enabled;
}
// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)selectedRowInComponent:(NSInteger)component
{
    
    
}
// Catpure the picker view selection

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    _timerLength = row+1;
    //self.picker.hidden = YES;
    
    
    
    
    
}

@end
