//
//  ShortCircuitBinaryOperationNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/03.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "ShortCircuitBinaryOperationNode.h"
#import "NodeVisitor.h"
#import "TrueValue.h"
#import "FalseValue.h"


//
// ShortCircuitBinaryOperationNode.
//
@implementation ShortCircuitBinaryOperationNode
@synthesize left = left_, right = right_;

+ (id)nodeWithOrOperator:(id<Node>)left right:(id<Node>)right {
    return [[[OrOperationNode alloc] initWithNodes:left right:right] autorelease];
}

+ (id)nodeWithAndOperator:(id<Node>)left right:(id<Node>)right {
    return [[[AndOperationNode alloc] initWithNodes:left right:right] autorelease];
}

- (id)initWithNodes:(id<Node>)left right:(id<Node>)right {
    self = [super init];
    if (self != nil) {
        self.left = left;
        self.right = right;
    }
    return self;
}

// Virtual.
- (BOOL)willEvaluateRight:(id<Value>)left {
    return NO;
}

// Virtual.
- (id<Value>)operate:(id<Value>)left right:(id<Value>)right {
    return nil;
}

// Override.
- (void)accept:(id<NodeVisitor>)visitor value:(id)val {
    [visitor visitShortCircuitBinaryOperationNode:self value:val];
}

- (void)dealloc {
    [(id)left_ release];
    [(id)right_ release];
    [super dealloc];
}

@end


//
// AndOperationNode.
//
@implementation AndOperationNode 

// Returns YES, if |left|'s value is true.
- (BOOL)willEvaluateRight:(id<Value>)left {
    return [[TrueValue getInstance] isEqual:left];
}

- (id<Value>)operate:(id<Value>)left right:(id<Value>)right {
    id<Value> tval = [TrueValue getInstance];
    id<Value> fval = [FalseValue getInstance];
    return [tval isEqual:right] ? tval : fval;
}

@end


//
// OrOperationNode.
//
@implementation OrOperationNode

// Returns YES, if |left|'s value is false.
- (BOOL)willEvaluateRight:(id<Value>)left {
    return [[FalseValue getInstance] isEqual:left];
}

- (id<Value>)operate:(id<Value>)left right:(id<Value>)right {
    id<Value> tval = [TrueValue getInstance];
    id<Value> fval = [FalseValue getInstance];
    return [tval isEqual:right] ? tval : fval;
}

@end