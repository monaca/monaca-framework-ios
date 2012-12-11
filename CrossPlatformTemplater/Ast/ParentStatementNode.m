//
//  ParentStatementNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "ParentStatementNode.h"
#import "NodeVisitor.h"


@implementation ParentStatementNode

- (void)accept:(id <NodeVisitor>)visitor value:(id)val {
	[visitor visitParentStatementNode:self value:val];
}

- (NSString *)description {
	return @"parent";
}

- (void)dealloc {
	[super dealloc];
}

@end