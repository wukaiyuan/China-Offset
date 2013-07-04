//
//  Pinnotation.h
//  China Offset
//
//  Created by Brian Eng on 7/1/13.
//  Copyright (c) 2013 Brian Eng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Pinnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
