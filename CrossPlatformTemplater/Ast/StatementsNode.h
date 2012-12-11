//
//  StatementsNode.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"


@interface StatementsNode : NSObject<Node> {
 @private
	NSMutableArray *nodes_;
}

// Returns an autoreleased instance of StatementsNode, which is built from token.
+ (StatementsNode *)nodeWithToken:(Token *)token;

// Returns an autoreleased instance of StatementsNode, which is built from Nodes.
+ (StatementsNode *)nodeWithNodes:(StatementsNode *)left right:(id<Node>)right;

- (id)initWithNodes:(StatementsNode *)left right:(id<Node>)right;

@property(assign) NSMutableArray *nodes_;

@end
