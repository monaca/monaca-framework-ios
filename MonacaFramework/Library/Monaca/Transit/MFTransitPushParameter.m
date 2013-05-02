//
//  MFTransitPushParameter.m
//  HealthPlanet
//
//  Created by Mitsunori KUBOTA on 13/04/30.
//  Copyright (c) 2013年 Asial Corporation. All rights reserved.
//

#import "MFTransitPushParameter.h"

@implementation MFTransitPushParameter

- (id)init
{
    return [super init];
}

- (id)init:(CATransition*)transition withClearStack:(BOOL)clearStack hasDefaultPushAnimation:(BOOL)hasDefaultPushAnimation
{
    self = [super init];
    
    if (self != nil) {
        transition_ = transition;
        clearStack_ = clearStack;
        hasDefaultPushAnimation_ = hasDefaultPushAnimation;
    }
    
    return self;
}

- (BOOL)clearStack
{
    return clearStack_;
}

- (CATransition*)transition
{
    return transition_;
}

- (BOOL)hasDefaultPushAnimation
{
    return hasDefaultPushAnimation_;
}

+ (MFTransitPushParameter*)parseOptionsDict:(NSDictionary*)options
{
    CATransition* transition = nil;
    BOOL hasDefaultPushAnimation = YES, clearStack = NO;
    
    // "animation" parameter parsing
    {
        id animationParam = [options objectForKey:@"animation"];
    
        if (animationParam == nil) {
            transition = nil;
            hasDefaultPushAnimation = YES;
        } else if ([animationParam isKindOfClass:NSString.class]) {
            NSString *animationName = (NSString*)animationParam;
            
            if ([animationName isEqualToString:@"slide"] || [animationName isEqualToString:@"slideLeft"]) {
            
                // animation : "slide" or "slideLeft"
                transition = nil;
                hasDefaultPushAnimation = YES;
                
            } else if ([animationName isEqualToString:@"slideRight"]) {
            
                // animation : "slideRight"
                transition = [CATransition animation];
                transition.duration = 0.4f;
                transition.type = kCATransitionPush;
                transition.subtype = kCATransitionFromLeft;
                [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
                hasDefaultPushAnimation = NO;
                
            } else if ([animationName isEqualToString:@"lift"]) {
            
                // animation : "lift"
                transition = [CATransition animation];
                transition.duration = 0.4f;
                transition.type = kCATransitionMoveIn;
                transition.subtype = kCATransitionFromTop;
                [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
                hasDefaultPushAnimation = NO;
                
            } else {
                NSLog(@"unknown animation type: %@", animationName);
            }
        } else if ([animationParam isKindOfClass:NSNumber.class]) {
            if ([animationParam isEqualToNumber:[NSNumber numberWithBool:NO]]) {
            
                // animation : "none"
                transition = nil;
                hasDefaultPushAnimation = NO;
            }
        }
    }
    
    // "clearStack" parameter parsing
    {
        id clearStackParam = [options objectForKey:@"clearStack"];
        if (clearStackParam != nil && ![clearStackParam isEqualToNumber:[NSNumber numberWithBool:NO]]) {
            clearStack = YES;
        }
    }
    
    return [[MFTransitPushParameter alloc] init:transition withClearStack:clearStack hasDefaultPushAnimation:hasDefaultPushAnimation];
}

@end
