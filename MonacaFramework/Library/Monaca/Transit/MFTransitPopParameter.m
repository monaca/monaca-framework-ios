//
//  MFTransitPopParamter.m
//  HealthPlanet
//
//  Created by Mitsunori KUBOTA on 13/05/01.
//  Copyright (c) 2013年 Asial Corporation. All rights reserved.
//

#import "MFTransitPopParameter.h"

@implementation MFTransitPopParameter

@synthesize transition = transition_;
@synthesize hasDefaultPopAnimation = hasDefaultPopAnimation_;

- (id)init
{
    self = [super init];

    if (self != nil) {

    }

    return self;
}

- (void)setHasDefaultPopAnimation:(BOOL)hasDefaultPopAnimation
{
    hasDefaultPopAnimation_ = hasDefaultPopAnimation;
}

#pragma mark private method end -

+ (MFTransitPopParameter*)parseOptionsDict:(NSDictionary*)options
{
    CATransition *transition = nil;
    BOOL hasDefaultPopAnimation = YES;
    
    // "animation" option parsing
    {
        id animationParam = [options objectForKey:@"animation"];
    
        if (animationParam == nil) {
            transition = nil;
            hasDefaultPopAnimation = YES;
        } else if ([animationParam isKindOfClass:NSString.class]) {
            NSString *animationName = (NSString*)animationParam;
            
            if ([animationName isEqualToString:@"lift"]) {
            
                // animation : "lift"
                transition = [CATransition animation];
                transition.duration = 0.4f;
                transition.type = kCATransitionReveal;
                transition.subtype = [self detectAnimation:kCATransitionFromTop];
                [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
                hasDefaultPopAnimation = YES;
                
            } else if ([animationName isEqualToString:@"slide"] || [animationName isEqualToString:@"slideLeft"]) {
            
                // animation : "slide" or "slideLeft"
                transition = nil;
                hasDefaultPopAnimation = YES;
                
            } else {
                NSLog(@"unknown pop animation type: %@", animationName);
            }
        } else if ([animationParam isKindOfClass:NSNumber.class]) {
            if ([animationParam isEqualToNumber:[NSNumber numberWithBool:NO]]) {
            
                // animation : false
                transition = nil;
                hasDefaultPopAnimation = NO;
            }
        }
    }

    MFTransitPopParameter *parameter = [[MFTransitPopParameter alloc] init];
    parameter.hasDefaultPopAnimation = hasDefaultPopAnimation;
    
    return parameter;
}
@end
