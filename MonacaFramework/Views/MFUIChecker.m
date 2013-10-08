//
//  MFUIChecker.m
//  MonacaFramework
//
//  Created by yasuhiro on 13/05/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFUIChecker.h"
#import "NativeComponents.h"

@interface RootNode : NSObject
+ (void)parse:(NSMutableDictionary *)dict;
@end

@interface ContainerNode : NSObject
+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position;
@end

@interface ToolBarNode : NSObject
+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position;
@end

@interface TabBarNode : NSObject
+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position;
@end

@interface ComponentNode : NSObject
+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position;
@end


@implementation MFUIChecker

+ (void)checkUI:(NSMutableDictionary *)uidict
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

+ (NSString *)arrayToString:(NSArray *)array
{
    NSString *string = @"[";
    for (id object in array) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\"%@\",", object]];
    }
    string = [string substringToIndex:([string length]-1)];
    return [string stringByAppendingString:@"]"];
}

+ (NSString *)valueType:(id)object
{
    NSString *class = NSStringFromClass([object class]);
    if ([class isEqualToString:@"__NSCFConstantString"] ||
        [class isEqualToString:@"__NSCFString"]) {
        NSString *str = object;
        NSRange range = [str rangeOfString:@"[^0-9.]" options:NSRegularExpressionSearch];
        if (range.location == NSNotFound && ![str isEqualToString:kNCUndefined]) {
            range = [str rangeOfString:@"[^0-9]" options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                return @"Float";
            } else {
                return @"Integer";
            }
        }
        range = [str rangeOfString:@"^#[0-9a-fA-F]{5}[0-9a-fA-F]$" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            return @"Color";
        }
        range = [str rangeOfString:@"^(true|false)$" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            return @"Boolean";
        }
        return @"String";
    }
    if ([class isEqualToString:@"__NSCFArray"] ||
        [class isEqualToString:@"__NSArrayI"] ||
        [class isEqualToString:@"NSArray"] ||
        [class isEqualToString:@"CDVJKArray"]) {
        return @"Array";
    }
    if ([class isEqualToString:@"__NSCFDictionary"] ||
        [class isEqualToString:@"__NSDictionaryI"]) {
        return @"Object";
    }
    if ([class isEqualToString:@"__NSCFNumber"] ||
        [class isEqualToString:@"NSDecimalNumber"]) {
        if (strcmp([object objCType], @encode(float)) == 0) {
            return @"Float";
        } else {
            return @"Integer";
        }
    }
    if ([class isEqualToString:@"__NSCFBoolean"]) {
        return @"Boolean";
    }
    
    return nil;
}

@end

@implementation RootNode

+ (NSDictionary *)getValidDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[NSDictionary dictionary] forKey:kNCPositionTop];
    [dict setValue:[NSDictionary dictionary] forKey:kNCPositionBottom];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeEvent];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeIOSStyle];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeAndroidStyle];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeStyle];
    [dict setValue:[NSString string] forKey:kNCPositionMenu];
    [dict setValue:kNCUndefined forKey:kNCTypeID];
    return dict;
}

+ (void)parse:(NSMutableDictionary *)dict
{
    NSDictionary *validDict = [self getValidDictionary];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(NSLocalizedString(@"Key is not one of valid keys", nil), @"page", key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
        if (![[MFUIChecker valueType:[dict objectForKey:key]] isEqualToString:[MFUIChecker valueType:[validDict valueForKey:key]]]) {
            NSLog(NSLocalizedString(@"Invalid value type", nil), kNCContainerPage , key,
                  [MFUIChecker valueType:[validDict objectForKey:key]], [dict valueForKey:key]);
            [dict removeObjectForKey:key];
            continue;
        }
    }
    NSMutableDictionary *Dict;
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

+ (NSDictionary *)getValidDictionary:(NSString *)position
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:kNCUndefined forKey:kNCContainerToolbar];
    if ([position isEqualToString:kNCPositionTop]) {
        return dict;
    }
    if ([position isEqualToString:kNCPositionBottom]) {
        [dict setValue:kNCUndefined forKey:kNCContainerTabbar];
        return dict;
    }
    
    return nil;
}
+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position
{
    NSString *container = [dict objectForKey:kNCTypeContainer];
    if (container == nil) {
        NSLog(NSLocalizedString(@"Missing required key", nil), kNCTypeContainer, position);
        [dict removeAllObjects];
        return;
    }
    NSDictionary *validValue = [self getValidDictionary:position];
    if ([validValue objectForKey:container] == nil) {
        NSLog(NSLocalizedString(@"Value not in one of valid values", nil), position, container, [MFUIChecker dictionaryKeysToString:validValue]);
        [dict removeAllObjects];
        return;
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
    [dict setValue:kNCUndefined forKey:kNCTypeContainer];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeStyle];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeIOSStyle];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeAndroidStyle];
    [dict setValue:kNCUndefined forKey:kNCTypeID];
    [dict setValue:[NSArray array] forKey:kNCTypeLeft];
    [dict setValue:[NSArray array] forKey:kNCTypeCenter];
    [dict setValue:[NSArray array] forKey:kNCTypeRight];
    return dict;
}

+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position
{
    NSDictionary *validDict = [self getValidDictionary];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(NSLocalizedString(@"Key is not one of valid keys", nil), position, key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
        if (![[MFUIChecker valueType:[dict objectForKey:key]] isEqualToString:[MFUIChecker valueType:[validDict valueForKey:key]]]) {
            NSLog(NSLocalizedString(@"Invalid value type", nil), position , key,
                   [MFUIChecker valueType:[validDict objectForKey:key]], [dict valueForKey:key]);
            [dict removeObjectForKey:key];
            continue;
        }
    }
    NSArray *array;
    if ((array = [dict objectForKey:kNCTypeLeft])) {
        for (NSMutableDictionary *Dict in array) {
            [ComponentNode parse:Dict withPosition:kNCTypeLeft];
        }
    }
    if ((array = [dict objectForKey:kNCTypeCenter])) {
        for (NSMutableDictionary *Dict in array) {
            [ComponentNode parse:Dict withPosition:kNCTypeCenter];
        }
    }
    if ((array = [dict objectForKey:kNCTypeRight])) {
        for (NSMutableDictionary *Dict in array) {
            [ComponentNode parse:Dict withPosition:kNCTypeRight];
        }
    }
}

@end


@implementation TabBarNode

+ (NSDictionary *)getValidDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:kNCUndefined forKey:kNCTypeContainer];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeStyle];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeIOSStyle];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeAndroidStyle];
    [dict setValue:kNCUndefined forKey:kNCTypeID];
    [dict setValue:[NSArray array] forKey:kNCTypeItems];
    return dict;
}

+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position
{
    NSString *container = [dict objectForKey:kNCTypeItems];
    if (container == nil) {
        NSLog(NSLocalizedString(@"Missing required key", nil), kNCTypeItems, position);
    }
    NSDictionary *validDict = [self getValidDictionary];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(NSLocalizedString(@"Key is not one of valid keys", nil), position, key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
    }
    NSArray *array;
    if ((array = [dict objectForKey:kNCTypeRight])) {
        for (NSMutableDictionary *Dict in array) {
            [ComponentNode parse:Dict withPosition:kNCTypeItems];
        }
    }
}

@end

@implementation ComponentNode

+ (NSDictionary *)getValidDictionary:(NSString *)component
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:kNCUndefined forKey:kNCStyleComponent];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeStyle];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeIOSStyle];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeAndroidStyle];
    [dict setValue:kNCUndefined forKey:kNCTypeID];
    [dict setValue:[NSDictionary dictionary] forKey:kNCTypeEvent];
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
        [dict setValue:kNCUndefined forKey:kNCTypeLink];
        return dict;
    }
    
    return  nil;
}

+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position
{
    NSString *component = [dict objectForKey:kNCStyleComponent];
    if (component == nil) {
        NSLog(NSLocalizedString(@"Missing required key", nil), kNCStyleComponent, position);
        return;
    }
    NSDictionary *validDict = [self getValidDictionary:component];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(NSLocalizedString(@"Key is not one of valid keys", nil), component, key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
    }
}
@end
