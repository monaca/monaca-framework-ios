//
//  NCBarButtonItem.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/28.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "NCBarButtonItem.h"

@implementation NCBarButtonItem

@synthesize hidden = _hidden;
@synthesize toolbar = _toolbar;

- (id)init
{
    self = [super init];

    if (self) {
        _hidden = NO;
    }

    return self;
}

#pragma mark - UIStyleProtocol

- (void)setUserInterface:(NSDictionary *)uidict
{
    for (id key in uidict) { 
        if ([_ncStyle objectForKey:key] == nil)
            continue;
        [_ncStyle setValue:[uidict valueForKey:key] forKey:key];
    }
}

- (void)applyUserInterface
{
    for (id key in [_ncStyle copy]) {
        [self updateUIStyle:[_ncStyle objectForKey:key] forKey:key];
    }
}

- (void)updateUIStyle:(id)value forKey:(NSString *)key {}

- (id)retrieveUIStyle:(NSString *)key
{
    if ([_ncStyle objectForKey:key] == nil) {
        // 例外処理
        return nil;
    }
    
    return [_ncStyle objectForKey:key];
}

@end
