//
//  MFUIChecker.m
//  MonacaFramework
//
//  Created by yasuhiro on 13/05/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFUIChecker.h"
#import "NativeComponentsInternal.h"
#import "NativeComponents.h"

@interface RootNode : NSObject
+ (void)parse:(NSDictionary *)dict;
@end

@interface ContainerNode : NSObject
+ (void)parse:(NSDictionary *)dict withPosition:(NSString *)position;
@end

@interface ToolBarNode : NSObject
+ (void)parse:(NSDictionary *)dict withPosition:(NSString *)position;
@end

@interface TabBarNode : NSObject
+ (void)parse:(NSDictionary *)dict withPosition:(NSString *)position;
@end

@interface ComponentNode : NSObject
+ (void)parse:(NSDictionary *)dict withPosition:(NSString *)position;
@end

@interface StyleNode : NSObject
+ (void)parse:(NSDictionary *)dict withComponent:(NSString *)component;
@end

@implementation MFUIChecker

+ (void)checkUI:(NSDictionary *)uidict
{
    [RootNode parse:uidict];
}

+ (NSString *)dictionaryKeysToString:(NSDictionary *)dict
{
    NSEnumerator* enumerator = [dict keyEnumerator];
    NSString *string = @"[";
    id object = [enumerator nextObject];
    while (object) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\"%@\"", object]];
        object = [enumerator nextObject];
        if (object)
            string = [string stringByAppendingString:@", "];
    }
    return [string stringByAppendingString:@"]"];
}

@end

@implementation RootNode

+ (NSDictionary *)getValidDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:NSDictionary.class forKey:kNCPositionTop];
    [dict setValue:NSDictionary.class forKey:kNCPositionBottom];
    [dict setValue:NSDictionary.class forKey:kNCPositionMenu];
    return dict;
}

+ (void)parse:(NSDictionary *)dict
{
    NSDictionary *validDict = [self getValidDictionary];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(@"Error: %@ key \"%@\" is not one of %@", @"<root>", key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
    }
    NSDictionary *Dict;
    if ((Dict = [dict objectForKey:kNCPositionTop])) {
        [ContainerNode parse:Dict withPosition:kNCPositionTop];
    }
    if ((Dict = [dict objectForKey:kNCPositionBottom])) {
        [ContainerNode parse:Dict withPosition:kNCPositionBottom];
    }
    if ((Dict = [dict objectForKey:kNCPositionMenu])) {
        //        [ContainerNode parse:Dict withPosition:kNCPositionMenu];
    }
}

@end

@implementation ContainerNode

+ (void)parse:(NSDictionary *)dict withPosition:(NSString *)position
{
    NSString *container = [dict objectForKey:kNCTypeContainer];
    if (container == nil) {
        NSLog(@"Error: missing required key \"%@\" in \"%@\"", kNCTypeContainer, position);
    }
    
    if ([container isEqualToString:kNCContainerToolbar]) {
        [ToolBarNode parse:dict withPosition:position];
    }
    if ([container isEqualToString:kNCContainerTabbar]) {
        [TabBarNode parse:dict withPosition:position];
    }
}

@end

@implementation ToolBarNode

+ (NSDictionary *)getValidDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:NSString.class forKey:kNCTypeContainer];
    [dict setValue:NSDictionary.class forKey:kNCTypeStyle];
    [dict setValue:NSDictionary.class forKey:kNCTypeIOSStyle];
    [dict setValue:NSDictionary.class forKey:kNCTypeAndroidStyle];
    [dict setValue:NSString.class forKey:kNCTypeID];
    [dict setValue:NSArray.class forKey:kNCTypeLeft];
    [dict setValue:NSArray.class forKey:kNCTypeCenter];
    [dict setValue:NSArray.class forKey:kNCTypeRight];
    return dict;
}

+ (void)parse:(NSDictionary *)dict withPosition:(NSString *)position
{
    NSDictionary *validDict = [self getValidDictionary];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(@"Error: %@ key \"%@\" is not one of %@", position, key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
    }
    NSArray *array;
    if ((array = [dict objectForKey:kNCTypeLeft])) {
        for (NSDictionary *Dict in array) {
            [ComponentNode parse:Dict withPosition:kNCTypeLeft];
        }
    }
    if ((array = [dict objectForKey:kNCTypeCenter])) {
        for (NSDictionary *Dict in array) {
            [ComponentNode parse:Dict withPosition:kNCTypeCenter];
        }
    }
    if ((array = [dict objectForKey:kNCTypeRight])) {
        for (NSDictionary *Dict in array) {
            [ComponentNode parse:Dict withPosition:kNCTypeRight];
        }
    }
}

@end


@implementation TabBarNode

+ (NSDictionary *)getValidDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:NSString.class forKey:kNCTypeContainer];
    [dict setValue:NSDictionary.class forKey:kNCTypeStyle];
    [dict setValue:NSDictionary.class forKey:kNCTypeIOSStyle];
    [dict setValue:NSDictionary.class forKey:kNCTypeAndroidStyle];
    [dict setValue:NSString.class forKey:kNCTypeID];
    [dict setValue:NSArray.class forKey:kNCTypeItems];
    return dict;
}

+ (void)parse:(NSDictionary *)dict withPosition:(NSString *)position
{
    NSString *container = [dict objectForKey:kNCTypeItems];
    if (container == nil) {
        NSLog(@"Error: missing required key \"%@\" in \"%@\"", kNCTypeItems, position);
    }
    NSDictionary *validDict = [self getValidDictionary];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(@"Error: %@ key \"%@\" is not one of %@", position, key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
    }
    NSArray *array;
    if ((array = [dict objectForKey:kNCTypeRight])) {
        for (NSDictionary *Dict in array) {
            [ComponentNode parse:Dict withPosition:kNCTypeItems];
        }
    }
}

@end

@implementation ComponentNode

+ (NSDictionary *)getValidDictionary:(NSString *)component
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:NSString.class forKey:kNCStyleComponent];
    [dict setValue:NSDictionary.class forKey:kNCTypeStyle];
    [dict setValue:NSDictionary.class forKey:kNCTypeIOSStyle];
    [dict setValue:NSDictionary.class forKey:kNCTypeAndroidStyle];
    [dict setValue:NSString.class forKey:kNCTypeID];
    [dict setValue:NSDictionary.class forKey:kNCTypeEvent];
    if ([component isEqualToString:kNCComponentButton]) {
        return dict;
    }
    if ([component isEqualToString:kNCComponentBackButton]) {
        return dict;
    }
    if ([component isEqualToString:kNCComponentLabel]) {
        [dict removeObjectForKey:kNCTypeEvent];
        return dict;
    }
    if ([component isEqualToString:kNCComponentSearchBox]) {
        return dict;
    }
    if ([component isEqualToString:kNCComponentSegment]) {
        return dict;
    }
    if ([component isEqualToString:kNCComponentTabbarItem]) {
        [dict removeObjectForKey:kNCTypeEvent];
        [dict setValue:NSString.class forKey:kNCTypeLink];
        return dict;
    }
    
    return  nil;
}

+ (void)parse:(NSDictionary *)dict withPosition:(NSString *)position
{
    NSString *component = [dict objectForKey:kNCStyleComponent];
    if (component == nil) {
        NSLog(@"Error: missing required key \"%@\" in \"%@\"", kNCStyleComponent, position);
        return;
    }
    NSDictionary *validDict = [self getValidDictionary:component];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(@"Error: %@ key \"%@\" is not one of %@", component, key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
    }
    [StyleNode parse:[dict objectForKey:kNCTypeStyle] withComponent:component];
}
@end

@implementation StyleNode

+ (NSDictionary *)getValidDictionary:(NSString *)component
{
    if ([component isEqualToString:kNCComponentButton]) {
        return [NCButton defaultStyles];
    }
    if ([component isEqualToString:kNCComponentBackButton]) {
        return [NCBackButton defaultStyles];
    }
    if ([component isEqualToString:kNCComponentLabel]) {
        return [NCLabel defaultStyles];
    }
    if ([component isEqualToString:kNCComponentSearchBox]) {
        return [NCSearchBox defaultStyles];
    }
    if ([component isEqualToString:kNCComponentSegment]) {
        return [NCSegment defaultStyles];
    }
    if ([component isEqualToString:kNCComponentTabbarItem]) {
        return [NCTabbarItem defaultStyles];
    }
    
    return  nil;
}

+ (void)parse:(NSDictionary *)dict withComponent:(NSString *)component
{
    NSDictionary *validDict = [self getValidDictionary:component];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(@"Error: %@ key \"%@\" is not one of %@", component, key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
    }
}

@end

