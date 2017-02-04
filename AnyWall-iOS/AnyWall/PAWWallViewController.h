//
//  PAWWallViewController.h
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@class PAWWallViewController;

@protocol PAWWallViewControllerDelegate <NSObject>

- (void)wallViewControllerWantsToPresentSettings:(PAWWallViewController *)controller;
- (void)wallViewControllerWantsToPresentFriend:(PAWWallViewController *)controller;

@end

@class PAWPost;

@interface PAWWallViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    MKDirectionsRequest *request;
    MKDirections *directions;

}
@property (nonatomic, strong) CLLocation *currentLocation;
- (void)gotDirections:(MKDirections *)theDirections;

@property (nonatomic, weak) id<PAWWallViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) NSMutableArray *allPosts;
- (IBAction)postButtonSelected:(id)sender;

@end

@protocol PAWWallViewControllerHighlight <NSObject>

- (void)highlightCellForPost:(PAWPost *)post;
- (void)unhighlightCellForPost:(PAWPost *)post;

@end
