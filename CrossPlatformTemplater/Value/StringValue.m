//
//  StringValue.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/03.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "StringValue.h"


//
// StringValue.
//
@implementation StringValue
@synthesize str = str_;

+ (StringValue *)valueWithString:(NSString *)str {
    return [[[StringValue alloc] initWithString:str] autorelease];
}

- (id)initWithString:(NSString *)str {
    self = [super init];
    if (self != nil) {
        str_ = [str copy];
    }
    return self;
}

- (void)dealloc {
    [str_ release];
    [super dealloc];
}

// Override.
- (BOOL)isEqual:(id<Value>)value {
    return [(id)value isKindOfClass:[self class]] && [[(StringValue *)value str] isEqualToString:str_];
}

// Override.
- (NSString *)description {
    return str_;
}

@end
