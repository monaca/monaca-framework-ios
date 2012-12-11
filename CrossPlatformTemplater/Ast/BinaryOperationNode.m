//
//  BinaryOperationNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/04/27.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "BinaryOperationNode.h"
#import "NodeVisitor.h"
#import "Value.h"
#import "TrueValue.h"
#import "FalseValue.h"


@implementation BinaryOperationNode
@synthesize left = left_, right = right_;

+ (BinaryOperationNode *)nodeWithEqualOperator:(id<Node>)left right:(id<Node>)right {
	return [[[EqualOperationNode alloc] initWithNodesAndOperator:left right:right] autorelease];
}

+ (BinaryOperationNode *)nodeWithNotEqualOperator:(id<Node>)left right:(id<Node>)right {
    return [[[NotEqualOperationNode alloc] initWithNodesAndOperator:left right:right] autorelease];
}

- (id)initWithNodesAndOperator:(id<Node>)left right:(id<Node>)right {
    self = [super init];
    if (self != nil) {
        left_ = [(id)left retain];
        right_ = [(id)right retain];
    }
    return self;
}

// Virtual.
- (id<Value>)operate:(id<Value>)left right:(id<Value>)right {
    return nil;
}

// Override.
- (void)accept:(id<NodeVisitor>)visitor value:(id)val {
	[visitor visitBinaryOperationNode:self value:val];
}

- (void)dealloc {
    [(id)left_ release];
    [(id)right_ release];
    [super dealloc];
}

@end



//
// Operator classes.
//

@implementation EqualOperationNode
- (id<Value>)operate:(id<Value>)left right:(id<Value>)right {
	return [left isEqual:right] ? (id<Value>)[TrueValue getInstance] : (id<Value>)[FalseValue getInstance];
}
@end

@implementation NotEqualOperationNode
- (id<Value>)operate:(id<Value>)left right:(id<Value>)right {
	return [left isEqual:right] ? (id<Value>)[FalseValue getInstance] : (id<Value>)[TrueValue getInstance];
}
@end