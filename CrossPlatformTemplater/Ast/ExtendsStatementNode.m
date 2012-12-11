//
//  ExtendsStatementNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "ExtendsStatementNode.h"
#import "NodeVisitor.h"


@implementation ExtendsStatementNode

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
	[visitor visitExtendsStatementNode:self value:val];
}

// (Override).
- (NSString *)description {
	return @"extends";
}

// (Override).
- (void)dealloc {
	[path_ release];
	[super dealloc];
}
@end

