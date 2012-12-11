//
//  Compiler.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/24.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Template;
@class TemplateResourceDictionary;
@class BlockStatementNode;


@interface TemplateCompiler : NSObject {
 @private
	TemplateResourceDictionary *templateResourceDictionary_;
}

- (id)init:(TemplateResourceDictionary *)templateResourceDictionary;
- (Template *)compileFrom:(NSString *)path withDictionary:(NSMutableDictionary *)templateDictionary;
- (Template *)compileFrom:(NSString *)path;
+ (NSString *)normalizePath:(NSString *)path base:(NSString *)base;

@end



@interface TemplateResource : NSObject {
 @private
	NSMutableDictionary *blockDictionary_;
	NSString *parentPath_;
	NSMutableSet *dependency_;
}

- (id)init;
- (void)set:(NSString *)name node:(BlockStatementNode *)block;
- (void)addDependency:(NSString *)path;

@property(assign) NSMutableDictionary *blockDictionary;
@property(assign) NSMutableSet *dependency;
@property(assign) NSString *parentPath;

@end