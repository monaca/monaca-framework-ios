//
//  NodeVisitor.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/24.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@protocol NodeVisitor
 @optional
- (void)visit:(id<Node>)node value:(id)val;
- (void)visitBlockStatementNode:(BlockStatementNode *)node value:(id)val;
- (void)visitStatementsNode:(StatementsNode *)node value:(id)val;
- (void)visitTopStatementNode:(TopStatementsNode *)node value:(id)val;
- (void)visitExtendsStatementNode:(ExtendsStatementNode *)node value:(id)val;
- (void)visitIncludeStatementNode:(IncludeStatementNode *)node value:(id)val;
- (void)visitParentStatementNode:(ParentStatementNode *)node value:(id)val;
- (void)visitRawStatementNode:(RawStatementNode *)node value:(id)val;

- (void)visitBinaryOperationNode:(BinaryOperationNode *)node value:(id)value;
- (void)visitConstantValueNode:(ConstantValueNode *)node value:(id)value;
- (void)visitEchoStatementNode:(EchoStatementNode *)node value:(id)value;
- (void)visitIfStatementNode:(IfStatementNode *)node value:(id)value;
- (void)visitShortCircuitBinaryOperationNode:(ShortCircuitBinaryOperationNode *)node value:(id)value;
- (void)visitStringValueNode:(StringValueNode *)node value:(id)value;
- (void)visitUnaryOperationNode:(UnaryOperationNode *)node value:(id)value;
@end
