//
//  IfStatementNode.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/02.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@class StatementsNode;


@interface IfStatementNode : NSObject<Node> {
 @private
    id<Node> expression_;
    id<Node> elseStatement_;
    StatementsNode *statements_;
}

// Returns an autoreleased instance of IfStatementNode.
+ (IfStatementNode *)nodeWithNodes:(id<Node>)expression statements:(StatementsNode *)statements elseStatement:(id<Node>)elseStatement;

// Designated initializer.
- (id)initWithNodes:(id<Node>)expression statements:(StatementsNode *)statements elseStatement:(id<Node>)elseStatement;

@property(retain) id<Node> expression;
@property(retain) id<Node> elseStatement;
@property(retain) StatementsNode *statements;
@end
