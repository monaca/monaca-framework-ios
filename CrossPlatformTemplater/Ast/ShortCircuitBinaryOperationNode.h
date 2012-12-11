//
//  ShortCircuitBinaryOperationNode.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/03.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"
#import "Value.h"


//
// The ShortCircuitBinaryOperatonNode class is the abstract class for
// the AndOperarionNode class and the OrOperationNode class.
//
@interface ShortCircuitBinaryOperationNode : NSObject<Node> {
 @private
    id<Node> left_;
    id<Node> right_;
}

// Returns an autoreleased instance of ShortCircuitBinaryOperationNode with OrOperator.
+ (id)nodeWithOrOperator:(id<Node>)left right:(id<Node>)right;

// Returns an autoreleased instance of ShortCircuitBinaryOperationNode with AndOperator.
+ (id)nodeWithAndOperator:(id<Node>)left right:(id<Node>)right;

// Designated initializer.
- (id)initWithNodes:(id<Node>)left right:(id<Node>)right;

// Returns YES, if it is necessary to evaluate right terms.
- (BOOL)willEvaluateRight:(id<Value>)left;

// Returns an autoreleased instance of Value, which is represents the result of this node.
- (id<Value>)operate:(id<Value>)left right:(id<Value>)right;

@property(retain) id<Node> left;
@property(retain) id<Node> right;

@end


//
// The AndOperationNode class represents "||" operation.
//
@interface AndOperationNode : ShortCircuitBinaryOperationNode
@end


//
// The OrOperationNode class represents "&&" operation.
//
@interface OrOperationNode : ShortCircuitBinaryOperationNode
@end