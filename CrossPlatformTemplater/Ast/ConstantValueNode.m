//
//  ConstantValueNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/02.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "ConstantValueNode.h"
#import "NodeVisitor.h"
#import "NSMutableArray+Stack.h"


@implementation ConstantValueNode
@synthesize id = id_, names = names_, left = left_, name = name_;

+ (ConstantValueNode *)nodeWithToken:(Token *)token {
    return [[[ConstantValueNode alloc] initWithToken:token] autorelease];
}

+ (ConstantValueNode *)nodeWithToken:(Token *)token left:(ConstantValueNode *)left {
    return [[[ConstantValueNode alloc] initWithToken:token left:left] autorelease];
}

// Designated initializer.
- (id)initWithToken:(Token *)id {
    self = [super init];
    if (self != nil) {
        id_ = [id retain];
        name_ = [[id value] retain];
        names_ = [[NSMutableArray arrayWithObject:[self name]] retain];
    }
    return self;
}

- (id)initWithToken:(Token *)id left:(ConstantValueNode *)left {
    self = [self initWithToken:id];
    if (self != nil) {
        left_ = [left retain];
        [names_ push:left.name];
    }
    return self;
}

- (void)dealloc {
    [id_ release];
    [name_ release];
    [names_ release];
    [left_ release];
    [super dealloc];
}

- (void)accept:(id<NodeVisitor>)visitor value:(id)val {
    [visitor visitConstantValueNode:self value:(id)val];
}

@end
