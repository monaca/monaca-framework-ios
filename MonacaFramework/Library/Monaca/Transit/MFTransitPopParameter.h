//
//  MFTransitPopParamter.h
//  HealthPlanet
//
//  Created by Mitsunori KUBOTA on 13/05/01.
//  Copyright (c) 2013年 Asial Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface MFTransitPopParameter : NSObject {
    @protected
    CATransition *transition_;
    BOOL hasDefaultPopAnimation_;
    NSString *target_;
}

+ (MFTransitPopParameter*)parseOptionsDict:(NSDictionary*)options;

@property (retain, readonly) CATransition *transition;
@property (assign, readonly) BOOL hasDefaultPopAnimation;
@property (retain, readonly) NSString *target;

@end
