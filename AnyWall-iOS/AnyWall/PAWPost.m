//
//  PAWPost.m
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import "PAWPost.h"

#import "PAWConstants.h"

@interface PAWPost ()

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFFile *image;
@property (nonatomic, strong) NSArray *invited;
@property (nonatomic, assign) MKPinAnnotationColor pinColor;

@end

@implementation PAWPost

#pragma mark -
#pragma mark Init

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                          andTitle:(NSString *)title
                            andDate:(NSDate *)date
                       andSubtitle:(NSString *)subtitle {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.title = title;
        self.date = date;
        self.subtitle = subtitle;
    }
    return self;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                          andTitle:(NSString *)title
                           andDate:(NSDate *)date
                       andSubtitle:(NSString *)subtitle
                          andImage:(PFFile *)image{
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.title = title;
        self.date = date;
        self.subtitle = subtitle;
        self.image = image;
    }
    return self;
}

- (instancetype)initWithPFObject:(PFObject *)object {
    PFGeoPoint *geoPoint = object[PAWParsePostLocationKey];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    NSString *title = object[PAWParsePostTextKey];
    NSDate *date = object[PAWParsePostDateKey];
    NSArray *invited = object[@"invited"];
    
    if(object[PAWParsePostImageKey] != nil && object[@"invite"] != nil){
    PFFile *image = object[PAWParsePostImageKey];
        NSString *subtitle = object[PAWParsePostUserKey][PAWParsePostNameKey] ?: object[PAWParsePostUserKey][PAWParsePostUsernameKey];
        
        self = [self initWithCoordinate:coordinate andTitle:title andDate:date andSubtitle:subtitle andImage:image];
        if (self) {
            self.object = object;
            self.user = object[PAWParsePostUserKey];
            self.date = date;
            self.image = image;
            self.invited = invited;
        }
    }
    else if(object[PAWParsePostImageKey] != nil){
        PFFile *image = object[PAWParsePostImageKey];
        NSString *subtitle = object[PAWParsePostUserKey][PAWParsePostNameKey] ?: object[PAWParsePostUserKey][PAWParsePostUsernameKey];
        
        self = [self initWithCoordinate:coordinate andTitle:title andDate:date andSubtitle:subtitle andImage:image];
        if (self) {
            self.object = object;
            self.user = object[PAWParsePostUserKey];
            self.date = date;
            self.image = image;
           
        }
    }
    
    else if(object[@"invited"] != nil){
        PFFile *image = object[PAWParsePostImageKey];
        NSString *subtitle = object[PAWParsePostUserKey][PAWParsePostNameKey] ?: object[PAWParsePostUserKey][PAWParsePostUsernameKey];
        
        self = [self initWithCoordinate:coordinate andTitle:title andDate:date andSubtitle:subtitle andImage:image];
        if (self) {
            self.object = object;
            self.user = object[PAWParsePostUserKey];
            self.date = date;
            self.invited = invited;
        }
    }
    else{
        NSString *subtitle = object[PAWParsePostUserKey][PAWParsePostNameKey] ?: object[PAWParsePostUserKey][PAWParsePostUsernameKey];

        self = [self initWithCoordinate:coordinate andTitle:title andDate:date andSubtitle:subtitle];
        if (self) {
            self.object = object;
            self.user = object[PAWParsePostUserKey];
            self.date = date;
            
        }
    
    }

        return self;
}

#pragma mark -
#pragma mark Equal

- (BOOL)isEqual:(id)other {
    if (![other isKindOfClass:[PAWPost class]]) {
        return NO;
    }

    PAWPost *post = (PAWPost *)other;

    if (post.object && self.object) {
        // We have a PFObject inside the PAWPost, use that instead.
        return [post.object.objectId isEqualToString:self.object.objectId];
    }

    // Fallback to properties
    return ([post.title isEqualToString:self.title] &&
            [post.subtitle isEqualToString:self.subtitle] &&
            [post.date isEqual:self.date] &&
            post.coordinate.latitude == self.coordinate.latitude &&
            post.coordinate.longitude == self.coordinate.longitude);
}

#pragma mark -
#pragma mark Accessors

- (void)setTitleAndSubtitleOutsideDistance:(BOOL)outside {
    if (outside) {
        self.title = kPAWWallCantViewPost;
        self.subtitle = nil;
        self.date = nil;
        self.image = nil;
        self.pinColor = MKPinAnnotationColorRed;
    } else {
        if(self.object[PAWParsePostImageKey] != nil){
            self.image = self.object[PAWParsePostImageKey];
        }
        self.title = self.object[PAWParsePostTextKey];
        self.subtitle = self.object[PAWParsePostUserKey][PAWParsePostNameKey] ?:
        self.object[PAWParsePostUserKey][PAWParsePostUsernameKey];
        self.date = self.object[PAWParsePostDateKey];
        self.pinColor = MKPinAnnotationColorGreen;
    }
}

@end
