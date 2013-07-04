//
//  ViewController.m
//  China Offset
//
//  Created by Brian Eng on 6/30/13.
//  Copyright (c) 2013 Brian Eng. All rights reserved.
//

#import "ViewController.h"
#import "Pinnotation.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize myLocationManager = _myLocationManager;
@synthesize mapView = _mapView;
@synthesize actualGPSLabel = _actualGPSLabel;
@synthesize pinGPSLabel = _pinGPSLabel;
@synthesize gpsOffsetLabel = _gpsOffsetLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Try to start current user location tracking
    self.mapView.delegate=self;
    if ([CLLocationManager locationServicesEnabled]) {
        self.myLocationManager = [[CLLocationManager alloc] init];
        self.myLocationManager.delegate = self;
        [self.myLocationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services are not enabled");
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self recenterButton:nil];
}

- (IBAction)dropPinButton:(id)sender {
    //if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    
    //MKPointAnnotation *ann = [MKPointAnnotation new];
    Pinnotation *ann = [[Pinnotation alloc] initWithCoordinate:self.latlong];
    //ann.coordinate = self.latlong;
    self.droppedAt = self.latlong;
    NSLog(@"Pin Latitude = %f", ann.coordinate.latitude);
    NSLog(@"Pin Longitude = %f", ann.coordinate.longitude);
    //ann.title = @"Pin-droppin lovin";
    [self.mapView addAnnotation:ann];
    [self updatePinGPSLabel];
}

- (IBAction)saveOffsetButton:(id)sender {
    // Save to Parse database
    CLLocationCoordinate2D adjustedGPS;
    adjustedGPS = [self calculateChinaOffset:self.latlong];
    Pinnotation *ann = [[Pinnotation alloc] initWithCoordinate:adjustedGPS];
    self.droppedAt = self.latlong;
    NSLog(@"Pin Latitude = %f", ann.coordinate.latitude);
    NSLog(@"Pin Longitude = %f", ann.coordinate.longitude);
    //ann.title = @"Pin-droppin lovin";
    [self.mapView addAnnotation:ann];
    [self updatePinGPSLabel];
}

- (IBAction)recenterButton:(id)sender {
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    // Update
}

- (CLLocationCoordinate2D)calculateChinaOffset:(CLLocationCoordinate2D)gps {
    CLLocationCoordinate2D adjustedGPS;
    
    // First check if we are within "China"
    if (gps.latitude > 51 || gps.latitude < 16 || gps.longitude < 89 || gps.longitude > 133) {
        return gps;
    } else {
        double slope;
        double intercept;
        // Then calculate adjusted latitude
        if (gps.latitude < 26.65) {
            slope = 0.998501403;
            intercept = 0.030213652;
        } else if (gps.latitude >= 26.65 && gps.latitude < 33) {
            slope = 1.000388594;
            intercept = -0.014271135;
        } else if (gps.latitude >= 33 && gps.latitude < 37.633) {
            slope = 1.000388594;
            intercept = -0.014271135;
        } else if (gps.latitude >= 37.633 && gps.latitude < 42.867) {
            slope = 1.000388594;
            intercept = -0.014271135;
        } else {
            slope = 0.99996584;
            intercept = 0.003499177;
        }
        
        adjustedGPS.latitude = slope*gps.latitude+intercept;
        
        double z;
        double lngoffset;
        // Calculate adjusted longitude
        if (gps.longitude < 98.56742) {
            slope = -0.00022954;
            intercept = 0.019875135;
        } else if (gps.longitude >= 98.56742 && gps.longitude < 113.133) {
            slope = 0.000386032;
            intercept = -0.040023508;
        } else if (gps.longitude >= 113.133 && gps.longitude < 116.567) {
            slope = -0.000257757;
            intercept = 0.032556075;
        } else if (gps.longitude >= 116.567 && gps.longitude < 120.3) {
            slope = -0.000165213;
            intercept = 0.022210642;
        } else {
            slope = 0.000164918;
            intercept = -0.018132434;
        }
        
        z = slope*gps.longitude+intercept;
        lngoffset = z + 0.5*0.00016677*gps.latitude;
        adjustedGPS.longitude = gps.longitude + lngoffset;
    }
    return adjustedGPS;
}

#pragma mark - Geo functions
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    
    /* We received the new location */
    
    self.latlong = newLocation.coordinate;
    //NSLog(@"Latitude = %f", self.latlong.latitude);
    //NSLog(@"Longitude = %f", self.latlong.longitude);
    
    // Show current location
    [self updateActualGPSLabel];
    
    //self.center.latitude = newLocation.coordinate.latitude;
    //self.center.longitude = newLocation.coordinate.longitude;
    
}

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation {
    CLLocationCoordinate2D coordinate = userLocation.location.coordinate;
    MKCoordinateRegion reg =
    MKCoordinateRegionMakeWithDistance(coordinate, 600, 600);
    mapView.region = reg;
}

#pragma mark - Update label functions
- (void)updateActualGPSLabel {
    self.actualGPSLabel.text = [NSString stringWithFormat:@"%.5g, %.5g", self.latlong.latitude, self.latlong.longitude];
}

- (void)updatePinGPSLabel {
    self.pinGPSLabel.text = [NSString stringWithFormat:@"%.5g, %.5g", self.droppedAt.latitude, self.droppedAt.longitude];
    if (self.droppedAt.latitude != self.latlong.latitude || self.droppedAt.longitude != self.latlong.longitude) {
        self.gpsOffsetLabel.text = [NSString stringWithFormat:@"%.5g, %.5g", self.droppedAt.latitude-self.latlong.latitude, self.droppedAt.longitude-self.latlong.longitude];
        NSLog(@"Offset is %f,%f", self.droppedAt.latitude-self.latlong.latitude, self.droppedAt.longitude-self.latlong.longitude);
    }
}

#pragma mark - Annotation Delegate functions
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    
    NSLog(@"viewForAnnotation Run");
    if (annotation == mapView.userLocation) {
        return nil;
    }
    
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"];
        pin.animatesDrop = YES;
        pin.draggable = YES;
    } else {
        pin.annotation = annotation;
    }
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    //UIImageView *leftimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //leftimage.contentMode = UIViewContentModeScaleAspectFit;
    //leftimage.image = self.beginImage;
    
    //aView.leftCalloutAccessoryView = leftimage;
    
    NSLog(@"Stop poking me");
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        self.droppedAt = annotationView.annotation.coordinate;
        NSLog(@"Pin dropped at %f,%f", self.droppedAt.latitude, self.droppedAt.longitude);
        [self updatePinGPSLabel];
    }
}

@end
