//
//  Pinnotation.m
//  China Offset
//
//  Created by Brian Eng on 7/1/13.
//  Copyright (c) 2013 Brian Eng. All rights reserved.
//

#import "Pinnotation.h"

@implementation Pinnotation
@synthesize coordinate;

- (NSString *)subtitle{
    return nil;
}

- (NSString *)title{
    return nil;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord {
    coordinate=coord;
    return self;
}

-(CLLocationCoordinate2D)coord
{
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    coordinate = newCoordinate;
}

@end
