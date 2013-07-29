//
//  MFTransitPopParamter.h
//  HealthPlanet
//
//  Created by Mitsunori KUBOTA on 13/05/01.
//  Copyright (c) 2013年 Asial Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MFTransitParameter.h"

@interface MFTransitPopParameter : MFTransitParameter {
    @protected
    CATransition *transition_;
    BOOL hasDefaultPopAnimation_;
}

+ (MFTransitPopParameter*)parseOptionsDict:(NSDictionary*)options;

@property (retain, readonly) CATransition *transition;
@property (assign, readonly) BOOL hasDefaultPopAnimation;

@end
