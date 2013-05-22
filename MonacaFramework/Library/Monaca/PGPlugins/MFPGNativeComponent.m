//
//  MFPGNativeComponent.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/12/09.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import "MFPGNativeComponent.h"
#import "NativeComponents.h"
#import "MFUtility.h"

@implementation MFPGNativeComponent
/*
- (void)badge:(NSMutableArray *)arguments withDict:(NSDictionary *)options
{
    if (arguments.count > 1) {
        NSInteger badgeNumber = [[arguments objectAtIndex:1] integerValue];
        [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
    }
}
 */

- (void)update:(NSMutableArray *)arguments withDict:(NSDictionary *)options
{
    NSString *key = [arguments objectAtIndex:1];

    // TODO(nhiroki): Validate arguments.
    NSMutableDictionary *style = nil;

    NSString *propertyKey;
    NSString *propertyValue;

    if (arguments.count == 4) {
        // Monaca.updateUIStyle("id", {...}).
        propertyKey = [arguments objectAtIndex:2];
        propertyValue = [arguments objectAtIndex:3];
        style = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:key, propertyKey, nil] forKeys:[NSArray arrayWithObjects:kNCTypeID, propertyValue, nil]];
    } else if (arguments.count == 3) {
        NSString *propertyKey = [arguments objectAtIndex:2];
        style = [NSMutableDictionary dictionaryWithObject:options forKey:propertyKey];
    } else if (arguments.count == 2) {
        style = [NSMutableDictionary dictionaryWithDictionary:options];
    } else {
        NSLog(@"[debug] Invalid arguments and options: %@, %@", arguments, options);
        return;
    }
    
    if (key) {
        id<UIStyleProtocol> component = [[(MFViewController *)self.viewController ncManager] componentForID:key];
        if (component == nil)
            component = [[MFUtility currentTabBarController].ncManager componentForID:key];
        if (!component) {
            NSLog(@"[debug] No such component: %@", key);
            return;
        }
        [component updateUIStyle:propertyValue forKey:propertyKey];
    }
}

- (void)retrieve:(NSMutableArray *)arguments withDict:(NSDictionary *)options {
    NSString *callbackID = [arguments objectAtIndex:0];
    NSString *key = [arguments objectAtIndex:1];
    NSString *propertyKey = [arguments objectAtIndex:2];

    if (key) {
        id<UIStyleProtocol> component = [[(MFViewController *)self.viewController ncManager] componentForID:key];
        if (component == nil)
            component = [[MFUtility currentTabBarController].ncManager componentForID:key];
        if (!component) {
            NSLog(@"[debug] No such component: %@", key);
            return;
        }
         NSString *property = [component retrieveUIStyle:propertyKey];
        CDVPluginResult *pluginResult = nil;
        
        if ([property isKindOfClass:[NSNumber class]]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:[property doubleValue]];
        } else if ([property isKindOfClass:[NSString class]]) {
            if ([property isEqualToString:kNCTrue] || [property isEqualToString:kNCFalse]
                || [property isEqualToString:kNCUndefined]) {
                if ([property isEqualToString:kNCUndefined])
                    property = @"undefined";
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"%%BOOL%%"];
                NSString *script = [pluginResult toSuccessCallbackString:callbackID];
                script = [script stringByReplacingOccurrencesOfString:@"\"%%BOOL%%\"" withString:property];
                [self writeJavascript:script];
                return;
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:property];
            }
        } else if ([property isKindOfClass:[NSArray class]]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:(NSArray *)property];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"N/A"];
            NSLog(@"[debug] Unknown property: %@", property);
        }
        [self writeJavascript:[pluginResult toSuccessCallbackString:callbackID]];
        return;
    }
}

@end
