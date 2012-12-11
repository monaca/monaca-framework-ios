//
//  UnaryOperationNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/03.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "UnaryOperationNode.h"
#import "NodeVisitor.h"
#import "TrueValue.h"
#import "FalseValue.h"


//
// UnaryOperationNode class.
//
@implementation UnaryOperationNode
@synthesize node = node_;

+ (NotOperationNode *)nodeWithNotOperator:(id<Node>)node {
    return [[[NotOperationNode alloc] initWithNode:node] autorelease];
}

- (id)initWithNode:(id<Node>)node {
    self = [super init];
    if (self != nil) {
        node_ = node;
    }
    return self;
}

// Virtual.
- (id<Value>)operate:(id<Value>)value {
    return nil;
}

// Override.
- (void)accept:(id<NodeVisitor>)visitor value:(id)val {
    [visitor visitUnaryOperationNode:self value:val];
}

@end


//
// NotOperationNode class.
//
@implementation NotOperationNode

- (id<Value>)operate:(id<Value>)value {
    return [[TrueValue getInstance] isEqual:value]
                ? (id<Value>)[FalseValue getInstance]
                : (id<Value>)[TrueValue getInstance];
}

@end