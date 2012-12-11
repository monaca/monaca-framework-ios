//
//  SymbolValue.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/03.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "SymbolValue.h"


//
// The SymbolValue class.
//
@implementation SymbolValue

static NSMutableDictionary *dict_;

// Override.
+ (void)initialize {
    dict_ = [[NSMutableDictionary alloc] init];
}

+ (SymbolValue *)valueWithString:(NSString *)name {
    return [[[SymbolValue alloc] initWithString:name] autorelease];
}

+ (id<Value>)get:(NSString *)key {
    NSLog(@"key is %@", key);
    if ([dict_ objectForKey:key] == nil) {
        [dict_ setObject:[SymbolValue valueWithString:key] forKey:key];
    }
    return [dict_ objectForKey:key];
}

+ (void)clear {
    [dict_ removeAllObjects];
}

- (id)initWithString:(NSString *)name {
    self = [super init];
    if (self != nil) {
        name_ = [name copy];
    }
    return self;
}

- (void)dealloc {
    [name_ release];
    [super dealloc];
}

- (BOOL)isEqual:(id<Value>)value {
	return self == value;
}

// Override.
- (NSString *)description {
	return [NSString stringWithFormat:@"<symbol %@>", name_];
}

@end
