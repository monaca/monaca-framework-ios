//
//  Template.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/29.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Template.h"


@implementation Template
@synthesize parent = parent_, rootNode = rootNode_;

- (id)init:(NSString *)path root:(TopStatementsNode *)rootNode parent:(Template *)parent blockDictionary:(NSMutableDictionary *)blockDictionary dependency:(NSMutableDictionary *)dependency {
	self = [super init];
	if (self != nil) {
		path_ = [path retain];
		rootNode_ = [rootNode retain];
		parent_ = [parent retain];
		blockDictionary_ = [blockDictionary retain];
		dependency_ = [dependency retain];
	}
	return self;
}

- (void)dealloc {
    [path_ release];
    [(id)rootNode_ release];
    [parent_ release];
    [blockDictionary_ release];
    [dependency_ release];
    [super dealloc];
}

- (NSString*)path {
    return path_;
}

// Returns whether this template object has parent template or not.
- (BOOL)hasParent {
	return parent_ != nil;
}

// Sets block node.
- (void)setBlock:(BlockStatementNode *)block blockName:(NSString *)blockName {
	[blockDictionary_ setObject:block forKey:blockName];
}

// Get a BlockStatementNode object from block name.
- (BlockStatementNode *)getBlock:(NSString *)blockName {
	BlockStatementNode *node = [blockDictionary_ objectForKey:blockName];
	if (node != nil)
		return node;
	if ([self hasParent])
		return [parent_ getBlock:blockName];
	return nil;
}

// Add a Template object which |self| relies on.
- (void)addDependency:(Template *)template path:(NSString *)path {
	[dependency_ setObject:template forKey:path];
}

// Get a Template object which |self| relies on.
// Returns nil if |dependency_| does not contains |path|.
- (Template *)getDependency:(NSString *)path {
	return [dependency_ objectForKey:path];
}

@end