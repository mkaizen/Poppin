//
//  PAWAppDelegate.m
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import "PAWAppDelegate.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "PAWConstants.h"
#import "PAWConfigManager.h"
#import "PAWLoginViewController.h"
#import "PAWSettingsViewController.h"
#import "PAWWallViewController.h"
#import "PAWFriendViewController.h"
#import "PAWProfileViewController.h"
#import "PAWPostFullPage.h"
#import "PAWInviteFriendsViewController.h"
#import <Neumob/Neumob.h>


@interface PAWAppDelegate ()
<PAWLoginViewControllerDelegate,
PAWWallViewControllerDelegate,
PAWSettingsViewControllerDelegate,PAWFriendViewControllerDelegate,PAWProfileViewControllerDelegate,PAWPostFullPageDelegate,PAWInviteFriendsViewControllerDelegate>

@end

@implementation PAWAppDelegate

#pragma mark -
#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // ****************************************************************************
    // Parse initialization
   // [Parse setApplicationId:@"9Wy52yYc0lRiX67c02RIdCU6Il9LREzNMIFwnhLu" clientKey:@"69P0e7hwOAaqr9fvPWso80XDeTiEHe1iayxsgDIr"];
    

     [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = @"9Wy52yYc0lRiX67c02RIdCU6Il9LREzNMIFwnhLu";
        configuration.clientKey = @"69P0e7hwOAaqr9fvPWso80XDeTiEHe1iayxsgDIr";
        configuration.server = @"https://parseapi.back4app.com";
        configuration.localDatastoreEnabled = NO; // If you need to enable local data store
    }]];

    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];


    // PFFacebookUtils initialization
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    // ****************************************************************************

       // ****************************************************************************

    
    [Neumob initialize:@"xEw2Lax3fijP67q5"];
    // Set the global tint on the navigation bar
        // Setup default NSUserDefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:PAWUserDefaultsFilterDistanceKey] == nil) {
        // If we have no accuracy in defaults, set it to 1000 feet.
        [userDefaults setDouble:PAWFeetToMeters(PAWDefaultFilterDistance) forKey:PAWUserDefaultsFilterDistanceKey];
    }

    self.navigationController = [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc] init]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0 green:202.0f/255.0f blue:202.0f/255.0f alpha:1.0f]];

    if ([PFUser currentUser]) {
        // Present wall straight-away
        [self presentWallViewControllerAnimated:NO];
        PFInstallation *installation = [PFInstallation currentInstallation];
        installation[@"user"] = [PFUser currentUser];
        [installation saveInBackground];
        
        
    } else {
        // Go to the welcome screen and have them log in or create an account.
        [self presentLoginViewController];
    }



    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    [[PAWConfigManager sharedManager] fetchConfigIfNeeded];

    return YES;
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
    
    


    
  
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark LoginViewController

- (void)presentLoginViewController {
    // Go to the welcome screen and have them log in or create an account.
    PAWLoginViewController *viewController = [[PAWLoginViewController alloc] initWithNibName:nil bundle:nil];
    viewController.delegate = self;
    [self.navigationController setViewControllers:@[ viewController ] animated:NO];
}

#pragma mark Delegate

- (void)loginViewControllerDidLogin:(PAWLoginViewController *)controller {
    [self presentWallViewControllerAnimated:YES];
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
    
}



#pragma mark -
#pragma mark WallViewController

- (void)presentWallViewControllerAnimated:(BOOL)animated {
    PAWWallViewController *wallViewController = [[PAWWallViewController alloc] initWithNibName:nil bundle:nil];
    wallViewController.delegate = self;
    [self.navigationController setViewControllers:@[ wallViewController ] animated:animated];
}

#pragma mark Delegate

- (void)wallViewControllerWantsToPresentSettings:(PAWWallViewController *)controller {
    [self presentSettingsViewController];
}

- (void)friendViewControllerWantsToPresentSettings:(PAWFriendViewController *)controller {
    [self presentSettingsViewController];
}

- (void)friendViewControllerWantsToPresentProfile:(PAWFriendViewController *)controller {
    [self presentProfileViewController];
}

- (void)wallViewControllerWantsToPresentFriend:(PAWWallViewController *)controller {
    [self presentFriendViewController];
}

- (void)wallViewControllerWantsToPresentProfile:(PAWWallViewController *)controller {
    [self presentProfileViewController];
}

#pragma mark -
#pragma mark SettingsViewController

- (void)presentSettingsViewController {
    PAWSettingsViewController *settingsViewController = [[PAWSettingsViewController alloc] initWithNibName:nil bundle:nil];
    settingsViewController.delegate = self;

    settingsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:settingsViewController animated:YES completion:nil];
}

- (void)presentFriendViewController {
    PAWFriendViewController *friendViewController = [[PAWFriendViewController alloc] initWithNibName:nil bundle:nil];
    friendViewController.delegate = self;
    
    //friendViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
   // [self.navigationController presentViewController:friendViewController animated:YES completion:nil];
    [self.navigationController pushViewController:friendViewController animated:YES];
}

- (void)presentProfileViewController {
    PAWProfileViewController *profileViewController = [[PAWProfileViewController alloc] initWithNibName:nil bundle:nil];
    profileViewController.delegate = self;
    
    profileViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:profileViewController animated:YES completion:nil];
}

#pragma mark Delegate

- (void)settingsViewControllerDidLogout:(PAWSettingsViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self presentLoginViewController];
}

- (void)FriendsViewControllerDidLogout:(PAWFriendViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self presentLoginViewController];
}

- (void)ProfileViewControllerDidLogout:(PAWProfileViewController*)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self presentLoginViewController];
}

@end
