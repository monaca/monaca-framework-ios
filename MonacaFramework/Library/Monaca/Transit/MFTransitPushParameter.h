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
}

- (id)init:(CATransition*)transition withClearStack:(BOOL)clearStack hasDefaultPushAnimation:(BOOL)hasDefaultPushAnimation;

- (BOOL)clearStack;
- (CATransition *)transition;
- (BOOL)hasDefaultPushAnimation;

+ (MFTransitPushParameter*)parseOptionsDict:(NSDictionary*)options;

@end
