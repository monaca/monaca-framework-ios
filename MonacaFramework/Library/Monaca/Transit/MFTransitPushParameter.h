//
//  MFTransitPushParameter.h
//  HealthPlanet
//
//  Created by Mitsunori KUBOTA on 13/04/30.
//  Copyright (c) 2013年 Asial Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface MFTransitPushParameter : NSObject {
    @protected
    CATransition *transition_;
    BOOL hasDefaultPushAnimation_;
    BOOL clearStack_;
    NSString *target_;
}

+ (MFTransitPushParameter*)parseOptionsDict:(NSDictionary*)options;

@property (assign, readonly) BOOL clearStack;
@property (retain, readonly) CATransition *transition;
@property (assign, readonly) BOOL hasDefaultPushAnimation;
@property (retain, readonly) NSString *target;

@end
