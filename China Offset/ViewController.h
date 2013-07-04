//
//  ViewController.h
//  China Offset
//
//  Created by Brian Eng on 6/30/13.
//  Copyright (c) 2013 Brian Eng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *actualGPSLabel;
@property (strong, nonatomic) IBOutlet UILabel *pinGPSLabel;
@property (strong, nonatomic) IBOutlet UILabel *gpsOffsetLabel;

@property (nonatomic) CLLocationCoordinate2D latlong;
@property (nonatomic) CLLocationCoordinate2D droppedAt;
@property (nonatomic, strong) CLLocationManager *myLocationManager;

@end
