//
//  UnaryOperationNode.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/03.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"
#import "Value.h"


@class NotOperationNode;

//
// UnaryOperationNode class.
//
@interface UnaryOperationNode : NSObject<Node> {
 @private
    id<Node> node_;
}

// Returns an autoreleased instance of NotOperationNode.
+ (NotOperationNode *)nodeWithNotOperator:(id<Node>)node;

// Designated initializer.
- (id)initWithNode:(id<Node>)node;

// Returns an autoreleased instance of Value, which is represents the result of this node.
- (id<Value>)operate:(id<Value>)value;

@property(retain) id<Node> node;

@end


//
// NotOperationNode class.
//
@interface NotOperationNode : UnaryOperationNode
@end