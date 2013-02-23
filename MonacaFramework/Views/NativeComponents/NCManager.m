//
//  NCManager.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/29.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "NCManager.h"


static NSMutableDictionary *
search(NSString *cid, NSMutableDictionary *barStyle) {
    if ([[barStyle objectForKey:kNCTypeID] isEqualToString:cid]) {
        return barStyle;
    }
    
    NSArray *leftComponents = [barStyle objectForKey:kNCTypeLeft];
    for (NSMutableDictionary *dict in leftComponents) {
        if ([[dict objectForKey:kNCTypeID] isEqualToString:cid]) {
            return dict;
        }
    }
    
    NSArray *centerComponents = [barStyle objectForKey:kNCTypeCenter];
    for (NSMutableDictionary *dict in centerComponents) {
        if ([[dict objectForKey:kNCTypeID] isEqualToString:cid]) {
            return dict;
        }
    }
    
    NSArray *rightComponents = [barStyle objectForKey:kNCTypeRight];
    for (NSMutableDictionary *dict in rightComponents) {
        if ([[dict objectForKey:kNCTypeID] isEqualToString:cid]) {
            return dict;
        }
    }
    return nil;
}


@implementation NCManager

@synthesize properties = properties_;
@synthesize components = components_;

- (id)init
{
    self = [super init];
    if (nil != self) {
        self.properties = [[NSMutableDictionary alloc] init];
        self.components = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.components = nil;
    self.properties = nil;
}

/*
 * Returns dictionary which represents properties of a native component corresponding to the given ID.
 */
- (NSMutableDictionary *)propertiesForID:(NSString *)cid
{
    NSMutableDictionary *result = nil;
    
    NSMutableDictionary *topBarStyle = [self.properties objectForKey:kNCPositionTop];
    result = search(cid, topBarStyle);
    if (result) {
        return result;
    }
    
    NSMutableDictionary *bottomBarStyle = [self.properties objectForKey:kNCPositionBottom];
    result = search(cid, bottomBarStyle);
    if (result) {
        return result;
    }

    return nil;
}

- (id)componentForID:(NSString *)cid
{
    return [self.components objectForKey:cid];
}

- (void)setComponent:(id)component forID:(NSString *)cid
{
    if (component == nil || cid == nil) {
        return;
    }
    [self.components setValue:component forKey:cid];
}

@end
