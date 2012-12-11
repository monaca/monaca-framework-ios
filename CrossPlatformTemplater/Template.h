//
//  Template.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/29.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "Node.h"

// The Template class represents compiled template.
@interface Template : NSObject {
 @private
	// The parent template object. 
	Template *parent_;
	
	// |blockDictionary_| includes parent's block statement.
	NSMutableDictionary *blockDictionary_;
	
	// |dependency_| has template objects, which |self| relies on. 
	NSMutableDictionary *dependency_;
	
	// The root node object.
	TopStatementsNode *rootNode_;
	
	// The path to template file.
	NSString *path_;
}

- (id)init:(NSString *)path root:(TopStatementsNode *)rootNode parent:(Template *)parent blockDictionary:(NSMutableDictionary *)blockDictionary dependency:(NSMutableDictionary *)dependency;
- (BOOL)hasParent;
- (void)setBlock:(BlockStatementNode *)block blockName:(NSString *)blockName;
- (BlockStatementNode *)getBlock:(NSString *)blockName;
- (void)addDependency:(Template *)template path:(NSString *)path;
- (Template *)getDependency:(NSString *)path;
- (NSString *)path;

@property(assign) Template *parent;
@property(assign) TopStatementsNode *rootNode;

@end
