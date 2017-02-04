//
//  PAWConstants.h
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#ifndef Anywall_PAWConstants_h
#define Anywall_PAWConstants_h

static double PAWFeetToMeters(double feet) {
    return feet * 0.3048;
}

static double PAWMetersToFeet(double meters) {
    return meters * 3.281;
}

static double PAWMetersToKilometers(double meters) {
    return meters / 1000.0;
}

static double const PAWDefaultFilterDistance = 30000.0;
static double const PAWWallPostMaximumSearchDistance = 100.0; // Value in kilometers

static NSUInteger const PAWWallPostsSearchDefaultLimit = 20; // Query limit for pins and tableviewcells

// Parse API key constants:
static NSString * const PAWParsePostsClassName = @"Posts";
static NSString * const PAWParsePostDateKey = @"date";
static NSString * const PAWParsePostCheckedInKey = @"checkedIn";
static NSString * const PAWParsePostFriendsComingKey = @"friendsComing";
static NSString * const PAWParsePostImageKey = @"image";
static NSString * const PAWParsePostUserKey = @"user";
static NSString * const PAWParsePostUsernameKey = @"username";
static NSString * const PAWParsePostTextKey = @"text";
static NSString * const PAWParsePostLocationKey = @"location";
static NSString * const PAWParsePostNameKey = @"name";
static NSString * const PAWParseFriends = @"Friends";
static NSString * const PAWPostCommentKey = @"comment";
static NSString * const PAWPostCommentContent = @"commentContent";
static NSString * const PAWPostCommentUser = @"commentUser";
static NSString * const PAWPostCommentPost = @"commentPost";
// NSNotification userInfo keys:
static NSString * const kPAWFilterDistanceKey = @"filterDistance";
static NSString * const kPAWLocationKey = @"location";

// Notification names:
static NSString * const PAWFilterDistanceDidChangeNotification = @"PAWFilterDistanceDidChangeNotification";
static NSString * const PAWCurrentLocationDidChangeNotification = @"PAWCurrentLocationDidChangeNotification";
static NSString * const PAWPostCreatedNotification = @"PAWPostCreatedNotification";

// UI strings:
static NSString * const kPAWWallCantViewPost = @"Can’t view post! Get closer.";

// NSUserDefaults
static NSString * const PAWUserDefaultsFilterDistanceKey = @"filterDistance";

typedef double PAWLocationAccuracy;

#endif // Anywall_PAWConstants_h
