//
//  BinaryOperationNode.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/04/27.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@protocol Value;

@protocol Operator
- (id<Value>)operate:(id<Value>)left right:(id<Value>)right;
@end

@interface BinaryOperationNode : NSObject <Node> {
 @private
	id<Node> left_;
	id<Node> right_;
}

// Returns an autoreleased instance of BinaryOperationNode with EqualOperator.
+ (BinaryOperationNode *)nodeWithEqualOperator:(id<Node>)left right:(id<Node>)right;

// Returns an autoreleased instance of BinaryOperationNode with NotEqualOperator.
+ (BinaryOperationNode *)nodeWithNotEqualOperator:(id<Node>)left right:(id<Node>)right;

// Designated initializer.
- (id)initWithNodesAndOperator:(id<Node>)left right:(id<Node>)right;

- (id<Value>)operate:(id<Value>)left right:(id<Value>)right;

@property(retain, nonatomic) id<Node> left;
@property(retain, nonatomic) id<Node> right;
@end



//
// Operator classes.
//

@interface EqualOperationNode : BinaryOperationNode
@end
    
@interface NotEqualOperationNode : BinaryOperationNode
@end