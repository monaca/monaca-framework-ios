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
}


- (id)init:(CATransition*)transition hasDefaultPopAnimation:(BOOL)hasDefaultPopAnimation;

- (CATransition *)transition;
- (BOOL)hasDefaultPopAnimation;

+ (MFTransitPopParameter*)parseOptionsDict:(NSDictionary*)options;

@end
