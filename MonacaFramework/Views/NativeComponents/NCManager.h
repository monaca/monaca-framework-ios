//
//  NCManager.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/29.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NativeComponentsInternal.h"

@interface NCManager : NSObject {
 @private
    NSMutableDictionary *properties_;
    NSMutableDictionary *components_;
}

- (NSMutableDictionary *)propertiesForID:(NSString *)cid;
- (id)componentForID:(NSString *)cid;
- (void)setComponent:(id)component forID:(NSString *)cid;

@property(nonatomic, retain) NSMutableDictionary *properties;
@property(nonatomic, retain) NSMutableDictionary *components;

@end
