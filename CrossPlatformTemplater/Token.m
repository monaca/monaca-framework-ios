//
//  Token.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/24.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "Token.h"


@implementation Token

@synthesize symbol = symbol_, line = line_, value = value_;

+ (id)tokenWithSymbol:(int)symbol lineNumber:(int)line value:(id)value {
    return [[[Token alloc] initWithSymbol:symbol lineNumber:line value:value] autorelease];
}

// Designated initializer.
- (id)initWithSymbol:(int)symbol lineNumber:(int)line value:(id)value {
    self = [super init];
    if (self != nil) {
        self.symbol = symbol;
        self.line = line;
        self.value = value;
    }
    return self;
}

- (void)dealloc {
    self.value = nil;
	[super dealloc];
}

@end