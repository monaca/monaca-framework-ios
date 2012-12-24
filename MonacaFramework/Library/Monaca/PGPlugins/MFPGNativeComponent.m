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

@interface MFPGNativeComponent()
- (void)updateNCManagerPropertyStyle:(NSMutableDictionary *)properties style:(NSMutableDictionary *)currentStyle;
@end

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
    if (arguments.count == 4) {
        // Monaca.updateUIStyle("id", {...}).
        NSString *propertyKey = [arguments objectAtIndex:3];
        NSString *propertyValue = [arguments objectAtIndex:2];
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
        id component = [[MFUtility currentTabBarController].ncManager componentForID:key];
        if (!component) {
            NSLog(@"[debug] No such component: %@", key);
            
            return;
        }
        
        // Overwrite style of the native component.
        NSMutableDictionary *properties = [[MFUtility currentTabBarController].ncManager propertiesForID:key];
        NSMutableDictionary *currentStyle = [NSMutableDictionary dictionaryWithDictionary:[properties objectForKey:kNCTypeStyle]];
        [currentStyle addEntriesFromDictionary:style];
        [currentStyle addEntriesFromDictionary:[properties objectForKey:kNCTypeIOSStyle]];

        // Update top toolbar style.
        if ([component isKindOfClass:[NSString class]] && [component isEqualToString:kNCContainerTabbar]) {
            MFTabBarController *controller = [MFUtility currentTabBarController];
            [self updateNCManagerPropertyStyle:properties style:currentStyle];
            [controller updateTopToolbar:currentStyle];
            return;
        }
        
        // Update bottom toolbar style.
        if ([component isKindOfClass:[UIToolbar class]]) {
            UIToolbar *toolbar = (UIToolbar *)component;
            [self updateNCManagerPropertyStyle:properties style:currentStyle];
            [MFTabBarController updateBottomToolbar:toolbar with:currentStyle];
            return;
        }

        // Update bottom tabbar item style.
        if ([component isKindOfClass:[UITabBarItem class]]) {
            UITabBarItem *item = (UITabBarItem *)component;
            [self updateNCManagerPropertyStyle:properties style:currentStyle];
            [NCTabbarItemBuilder update:item with:currentStyle];
            return;
        }
        
        // Update bottom tabbar style.
        if ([component isKindOfClass:[MFTabBarController class]]) {
            MFTabBarController *tabbar = (MFTabBarController *)component;
            [self updateNCManagerPropertyStyle:properties style:currentStyle];
            [MFTabBarController updateBottomTabbarStyle:tabbar with:currentStyle];
            return;
        }
        
        NCContainer *container = (NCContainer *)component;
        
        [self updateNCManagerPropertyStyle:properties style:currentStyle];
        if ([container.type isEqualToString:kNCComponentButton]) {
            [NCButtonBuilder update:container.component with:currentStyle];
        } else if ([container.type isEqualToString:kNCComponentBackButton]) {
            [NCBackButtonBuilder update:container.component with:currentStyle];
        } else if ([container.type isEqualToString:kNCComponentLabel]) {
            [NCLabelBuilder update:container.component with:currentStyle];
        } else if ([container.type isEqualToString:kNCComponentSearchBox]) {
            [NCSearchBoxBuilder update:container.component with:currentStyle];
        } else if ([container.type isEqualToString:kNCComponentSegment]) {
            [NCSegmentBuilder update:container.component with:currentStyle];
        } else {
            NSLog(@"[debug] Unknown container type %@", container.type);
        }
        [self updateNCManagerPropertyStyle:properties style:currentStyle];
    }
}

- (void)retrieve:(NSMutableArray *)arguments withDict:(NSDictionary *)options {
    NSString *callbackID = [arguments objectAtIndex:0];
    NSString *key = [arguments objectAtIndex:1];
    NSString *propertyKey = [arguments objectAtIndex:2];

    if (key) {
        id component = [[MFUtility currentTabBarController].ncManager componentForID:key];
        if (!component) {
            NSLog(@"[debug] No such component: %@", key);
            return;
        }

        NCContainer *container = (NCContainer *)component;
        if (![container isKindOfClass:[NSString class]] && [container.type isEqualToString:kNCComponentSearchBox]) {
            NSMutableDictionary *properties = [[MFUtility currentTabBarController].ncManager propertiesForID:key];
            NSMutableDictionary *style = [NSMutableDictionary dictionary];
            [style addEntriesFromDictionary:[properties objectForKey:kNCTypeStyle]];
            [style addEntriesFromDictionary:[NCSearchBoxBuilder retrieve:container.component]];
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[style objectForKey:propertyKey]];
            [self writeJavascript:[pluginResult toSuccessCallbackString:callbackID]];
            return;
        }

        CDVPluginResult *pluginResult = nil;
        NSMutableDictionary *properties = [[MFUtility currentTabBarController].ncManager propertiesForID:key];
        NSString *property = [[properties objectForKey:kNCTypeStyle] objectForKey:propertyKey];
        
        // FIXME(nhiroki): デフォルト値を持つキーに対してはうまく取得できない。
        // また、ネイティブコンポーネント機構を介さずに UIKit で変更されるパラメータについても適切に取得できない (activeIndex など)。
        if ([property isKindOfClass:[NSNumber class]]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[property intValue]];
        } else if ([property isKindOfClass:[NSString class]]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:property];
        } else if ([property isKindOfClass:[NSArray class]]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:(NSArray *)property];
        } else {
            NSLog(@"[debug] Unknown property: %@", property);
        }
        [self writeJavascript:[pluginResult toSuccessCallbackString:callbackID]];
        return;
    }
}

- (void)updateNCManagerPropertyStyle:(NSMutableDictionary *)properties style:(NSMutableDictionary *)currentStyle {
    [[properties objectForKey:kNCTypeStyle] addEntriesFromDictionary:currentStyle];
}

@end
