//
//  PAWWallPostCreateViewController.h
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CZPicker.h>
@class PAWWallPostCreateViewController;

@protocol PAWWallPostCreateViewControllerDataSource <NSObject>

- (CLLocation *)currentLocationForWallPostCrateViewController:(PAWWallPostCreateViewController *)controller;

@end

@protocol PAWWallPostCreateViewControllerDelegate <NSObject>


@end
@interface PAWWallPostCreateViewController : UIViewController <UIImagePickerControllerDelegate,CZPickerViewDelegate,CZPickerViewDataSource>

@property (nonatomic, weak) id<PAWWallPostCreateViewControllerDataSource> dataSource;
@property (nonatomic, strong) IBOutlet UIImagePickerController *camPicker;
@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UILabel *characterCountLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *postButton;
@property (nonatomic, strong)IBOutlet UIImageView *imageView;
@property (nonatomic, strong)IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) id<PAWWallPostCreateViewControllerDelegate> delegate;
@property (nonatomic, strong)IBOutlet UIView *blankView;
@property (nonatomic, strong)IBOutlet UIButton *inviteButton;

- (IBAction)friendsInvite:(id)sender;
@end
