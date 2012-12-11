//
//  TopStatementsNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "TopStatementsNode.h"


@implementation TopStatementsNode
+ (id)nodeWithNodes:(TopStatementsNode *)left right:(id <Node>)right {
	return [[[[self class] alloc] initWithNodes:left right:right] autorelease];
}

// Designated initializer.
- (id)initWithNodes:(TopStatementsNode *)left right:(id <Node>)right {
	return [super initWithNodes:left right:right];
}

// (Override).
- (NSString *)description {
	return @"This is TopStatementsNode";
}
@end
