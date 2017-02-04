//
//  PAWLoginViewController.h
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PAWLoginViewController;

@protocol PAWLoginViewControllerDelegate <NSObject>

- (void)loginViewControllerDidLogin:(PAWLoginViewController *)controller;

@end

@interface PAWLoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<PAWLoginViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;

@end
