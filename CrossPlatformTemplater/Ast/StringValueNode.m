//
//  StringValueNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/03.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "StringValueNode.h"
#import "NodeVisitor.h"


//
// StringValueNode class.
//
@implementation StringValueNode
@synthesize token = token_, value = value_;

+ (StringValueNode *)nodeWithToken:(Token *)token {
    return [[[StringValueNode alloc] initWithToken:token] autorelease];
}

- (id)initWithToken:(Token *)token {
    self = [super init];
    if (self != nil) {
        token_ = [token retain];
        value_ = [[token value] retain];
    }
    return self;
}

- (void)dealloc {
    [token_ release];
    [(id)value_ release];
    [super dealloc];
}

// Override.
- (void)accept:(id<NodeVisitor>)visitor value:(id)val {
    [visitor visitStringValueNode:self value:val];
}

@end
