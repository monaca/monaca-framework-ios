//
//  RawStatementNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "RawStatementNode.h"
#import "NodeVisitor.h"


@implementation RawStatementNode

+ (RawStatementNode *)nodeWithToken:(Token *)token {
    return [[[RawStatementNode alloc] initWithToken:token] autorelease];
}

- (id)initWithToken:(Token *)token {
	self = [super init];
	if (self != nil) {
		raw_ = [token retain];
	}
	return self;
}

- (NSString *)getRawString {
	return raw_.value;
}

- (void)accept:(id <NodeVisitor>)visitor value:(id)val {
	[visitor visitRawStatementNode:self value:val];
}

- (NSString *)description {
	return @"raw";
}

- (void)dealloc {
	[raw_ release];
	[super dealloc];
}

@end