//
//  StatementsNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "StatementsNode.h"
#import "RawStatementNode.h"
#import "NodeVisitor.h"


@implementation StatementsNode
@synthesize nodes_;

+ (StatementsNode *)nodeWithToken:(Token *)token {
    StatementsNode *left = [[[StatementsNode alloc] init] autorelease];
    id<Node> right = [RawStatementNode nodeWithToken:token];
    return [StatementsNode nodeWithNodes:left right:right];
}

+ (StatementsNode *)nodeWithNodes:(StatementsNode *)left right:(id<Node>)right {
    return [[[StatementsNode alloc] initWithNodes:left right:right] autorelease];
}

- (id)initWithNodes:(StatementsNode *)left right:(id<Node>)right {
    self = [self init];
    if (self != nil) {
        [nodes_ addObjectsFromArray:left.nodes_];
        [nodes_ addObject:right];
    }
    return self;
}

// Designated initializer.
- (id)init {
	self = [super init];
	if (self != nil) {
		nodes_ = [[NSMutableArray array] retain];
	}
	return self;
}
 
- (void)dealloc {
	[nodes_ release];
	[super dealloc];
}

// Override.
- (void)accept:(id <NodeVisitor>)visitor value:(id)val {
	[visitor visitStatementsNode:self value:val];
}

- (NSString *)description {
	NSMutableString *builder = [NSMutableString string];
	for (id node in nodes_) {
		[builder appendString:node];
		[builder appendString:@"\n"];
	}
	return builder;
}

@end
