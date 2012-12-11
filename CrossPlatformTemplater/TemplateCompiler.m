//
//  TemplateCompiler.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/24.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "TemplateCompiler.h"
#import "TemplateParser.h"
#import "NodeVisitor.h"
#import "Template.h"
#import "TemplateResourceDictionary.h"

#import "BlockStatementNode.h"
#import "ExtendsStatementNode.h"
#import "StatementsNode.h"


@interface CompilerVisitor : NSObject <NodeVisitor>
- (id)init:(NSString*)path;
@property (retain, nonatomic) NSString* path;
@end

@implementation TemplateCompiler
// Initializer.
- (id)init:(TemplateResourceDictionary *)templateResourceDictionary {
	self = [super init];
	if (self != nil) {
		templateResourceDictionary_ = templateResourceDictionary;
	}
	return self;
}

// Compiles a template from template resource path.
- (Template *)compileFrom:(NSString *)path
		   withDictionary:(NSMutableDictionary *)templateDictionary {
	NSParameterAssert(path != nil);
	
	Template *template = nil;
	if ((template = [templateDictionary objectForKey:path]) != nil) {
		return template;
	}
    
	// Parse template text.
	TemplateParser *parser = [[[TemplateParser alloc] init] autorelease];
	TopStatementsNode *rootNode =
		[parser parse:[templateResourceDictionary_ get:path]];

	// Compile abstract syntax tree.
	TemplateResource *source = [[[TemplateResource alloc] init] autorelease];
	[rootNode accept:[[[CompilerVisitor alloc] init: path] autorelease] value:source];

	// Parse and compile dependency template files.
	for (NSString *dependOn in source.dependency) {
		if (![templateResourceDictionary_ exists:dependOn]) {
        
			[templateResourceDictionary_ setWithContentsOfFile:dependOn forKey:dependOn];
		}
		[templateDictionary setObject:[self compileFrom:dependOn
										 withDictionary:templateDictionary]
							   forKey:dependOn];
	}
	
	// Generate template object.
	template = [[[Template alloc] init:path
                                  root:rootNode parent:nil 
                       blockDictionary:source.blockDictionary
                            dependency:templateDictionary]
                autorelease];
	if (source.parentPath != nil) {
		template.parent = [templateDictionary objectForKey:source.parentPath];
		template.rootNode = template.parent.rootNode;
	}

	[templateDictionary setObject:template forKey:path];
	return template;
}

- (Template *)compileFrom:(NSString *)path {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	return [self compileFrom:path withDictionary:dictionary];
}

+ (NSString*)normalizePath:(NSString*)path base:(NSString*)base {
    // resolve relative path
    NSURL *url = [NSURL fileURLWithPath:base];
    url = [url URLByDeletingLastPathComponent];
    url = [url URLByAppendingPathComponent:path];
    url = [url URLByStandardizingPath];

    return url.path;
}

@end



// The TemplateResource class is used to generate Template objects.
@implementation TemplateResource
@synthesize blockDictionary = blockDictionary_, dependency = dependency_, parentPath = parentPath_;

// Designated initializer.
-(id)init {
	self = [super init];
	if (self != nil) {
		blockDictionary_ = [NSMutableDictionary dictionary];
		parentPath_ = nil;
		dependency_ = [NSMutableSet set];
	}
	return self;
}

// Sets BlockStatementNode object to block dictionary.
-(void)set:(NSString *)name node:(BlockStatementNode *)block {
	[blockDictionary_ setObject:block forKey:name];
}

// Adds path to template files, which this template object relies on.  
-(void)addDependency:(NSString *)path {
	[dependency_ addObject:path];
}

@end


//
// The CompilerVisitor class is used to visit each nodes in AST,
// then processes them.
//
@implementation CompilerVisitor

@synthesize path = _path;

- (id)init:(NSString *)path {
    [self init];
    
    self.path = path;
    
    return self;
}

- (void)visitRawStatementNode:(RawStatementNode *)node value:(TemplateResource *)resource {
    // Nothing to do.
}

- (void)visitEchoStatementNode:(EchoStatementNode *)node value:(TemplateResource *)resource {
    // Nothing to do.
}

- (void)visitIfStatementNode:(IfStatementNode *)node value:(TemplateResource *)resource {
    // Nothing to do.
}

- (void)visitBinaryOperationNode:(BinaryOperationNode *)node value:(TemplateResource *)resource {
    NSAssert(false, @"Not reached.");
}

- (void)visitShortCircuitBinaryOperationNode:(ShortCircuitBinaryOperationNode *)node
                                       value:(TemplateResource *)resource {
    NSAssert(false, @"Not reached.");
}

- (void)visitStringValueNode:(StringValueNode *)node value:(TemplateResource *)resource {
    NSAssert(false, @"Not reached.");
}

- (void)visitUnaryOperationNode:(UnaryOperationNode *)node value:(TemplateResource *)resource {
    NSAssert(false, @"Not reached.");
}

- (void)visitBlockStatementNode:(BlockStatementNode *)node value:(TemplateResource *)resource {
	[resource set:node.identifier.value node:node];
	[node.statements accept:self value:resource];
}

- (void)visitStatementsNode:(StatementsNode *)node value:(TemplateResource *)resource {
	for (id<Node> child in node.nodes_) {
		[child accept:self value:resource];
	}
}

- (void)visitTopStatementNode:(TopStatementsNode *)node value:(TemplateResource *)resource {
	[self visitStatementsNode:(StatementsNode *)node value:resource];
}

- (void)visitExtendsStatementNode:(ExtendsStatementNode *)node value:(TemplateResource *)resource {
	[resource addDependency:[TemplateCompiler normalizePath:[node getPath] base:_path]];
	[resource setParentPath:[TemplateCompiler normalizePath:[node getPath] base:_path]];
}

- (void)visitIncludeStatementNode:(IncludeStatementNode *)node value:(TemplateResource *)resource {
	[resource addDependency:[TemplateCompiler normalizePath:[node getPath] base:_path]];
}

- (void)visitParentStatementNode:(ParentStatementNode *)node value:(TemplateResource *)resource {
    // Nothing to do.
}

- (void)visit:(id<Node>)node value:(TemplateResource *)resource {
    NSAssert(false, @"Not reached.");
}

- (void)visitConstantValueNode:(ConstantValueNode *)node value:(TemplateResource *)resource {
    NSAssert(false, @"Not reached.");    
}

- (void)dealloc {
    [self.path release];
    [super dealloc];
}

@end


