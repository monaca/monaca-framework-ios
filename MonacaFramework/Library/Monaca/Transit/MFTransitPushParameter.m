//
//  MFTransitPushParameter.m
//  HealthPlanet
//
//  Created by Mitsunori KUBOTA on 13/04/30.
//  Copyright (c) 2013年 Asial Corporation. All rights reserved.
//

#import "MFTransitPushParameter.h"

@implementation MFTransitPushParameter

@synthesize transition = transition_;
@synthesize clearStack = clearStack_;
@synthesize hasDefaultPushAnimation = hasDefaultPushAnimation_;

- (id)init
{
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

#pragma mark - private method

- (void)setClearStack:(BOOL)clearStack
{
    clearStack_ = clearStack;
}

- (void)setTarget:(NSString *)target
{
    target_ = target;
}

- (void)setTransition:(CATransition *)transition
{
    transition_ = transition;
}

- (void)setHasDefaultPushAnimation:(BOOL)hasDefaultPushAnimation
{
    hasDefaultPushAnimation_ = hasDefaultPushAnimation;
}

#pragma mark private method end -

+ (MFTransitPushParameter*)parseOptionsDict:(NSDictionary*)options
{ 
    CATransition* transition = nil;
    BOOL hasDefaultPushAnimation = YES, clearStack = NO;
    NSString *target = nil;
    
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
                transition.type = kCATransitionMoveIn;
                transition.subtype = [self detectAnimation:kCATransitionFromLeft];
                [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
                hasDefaultPushAnimation = NO;
                
            } else if ([animationName isEqualToString:@"lift"]) {
            
                // animation : "lift"
                transition = [CATransition animation];
                transition.duration = 0.4f;
                transition.type = kCATransitionMoveIn;
                transition.subtype = [self detectAnimation:kCATransitionFromTop];
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
    
    // "target" parameter parsing
    target = [self parseTargetParameter:[options objectForKey:@"target"]];
    
    MFTransitPushParameter *_self = [[MFTransitPushParameter alloc] init];
    _self.clearStack = clearStack;
    _self.transition = transition;
    _self.hasDefaultPushAnimation = hasDefaultPushAnimation;
    _self.target = target;
    
    return _self;
}

@end
