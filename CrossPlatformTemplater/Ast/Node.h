//
//  Node.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/24.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Token.h"

@protocol NodeVisitor;

@protocol Node
- (void)accept:(id <NodeVisitor>)visitor value:(id)val;
@end

@class BlockStatementNode;
@class IncludeStatementNode;
@class StatementsNode;
@class ExtendsStatementNode;
@class ParentStatementNode;
@class RawStatementNode;
@class StatementsNode;
@class TopStatementsNode;

@class BinaryOperationNode;
@class ConstantValueNode;
@class EchoStatementNode;
@class IfStatementNode;
@class ShortCircuitBinaryOperationNode;
@class StringValueNode;
@class UnaryOperationNode;