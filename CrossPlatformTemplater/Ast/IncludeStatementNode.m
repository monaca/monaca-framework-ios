//
//  IncludeStatementNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "IncludeStatementNode.h"
#import "NodeVisitor.h"


//
// Include statement node class.
//
@implementation IncludeStatementNode

// Designated initializer.
- (id)initWithToken:(Token *)path {
	self = [super init];
	if (self != nil) {
		path_ = [path retain];
	}
	return self;
}

- (NSString *)getPath {
	return path_.value;
}

- (void)accept:(id <NodeVisitor>)visitor value:(id)val {
	[visitor visitIncludeStatementNode:self value:val];
}

- (NSString *)description {
	return @"include";
}

- (void)dealloc {
	[path_ release];
	[super dealloc];
}

@end