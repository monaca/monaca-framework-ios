//
//  DictValue.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/03.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "DictValue.h"
#import "NullValue.h"


//
// The DictValue class.
//
@implementation DictValue

@synthesize dict = dict_;

+ (DictValue *)value {
    return [[[DictValue alloc] init] autorelease];
}

// Designated initializer.
- (id)init {
    self = [super init];
    if (self != nil) {
        dict_ = [[NSMutableDictionary dictionary] retain];
    }
    return self;
}

- (void)dealloc {
    [dict_ release];
    [super dealloc];
}

- (void)set:(id)value forKey:(NSString *)key {
    [dict_ setObject:value forKey:key];
}

- (BOOL)exists:(NSString *)key {
	if ([dict_ objectForKey:key] != nil) {
        return YES;
	}
	return NO;
}

- (id<Value>)get:(NSString *)key {
    if ([self exists:key]) {
        return [dict_ objectForKey:key];
    }
    return (id<Value>)[NullValue getInstance];
}

// Override.
- (BOOL)isEqual:(id<Value>)value {
    return [[self dict] isEqualToDictionary:[(DictValue *)value dict]];
}

// Override.
- (NSString *)description {
	return @"<dict>";
}

@end