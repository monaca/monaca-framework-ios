//
//  MFTransitPushParameter.h
//  HealthPlanet
//
//  Created by Mitsunori KUBOTA on 13/04/30.
//  Copyright (c) 2013年 Asial Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MFTransitParameter.h"

@interface MFTransitPushParameter : MFTransitParameter {
    @protected
    CATransition *transition_;
    BOOL hasDefaultPushAnimation_;
    BOOL clearStack_;
}

+ (MFTransitPushParameter*)parseOptionsDict:(NSDictionary*)options;

@property (assign, readonly) BOOL clearStack;
@property (retain, readonly) CATransition *transition;
@property (assign, readonly) BOOL hasDefaultPushAnimation;

@end
