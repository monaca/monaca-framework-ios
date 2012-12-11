//
//  TemplateExecuter.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/29.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Ast.h"
#import "Template.h"

#import "NSMutableArray+Stack.h"
#import "NSString+HTML.h"
#import "MonacaTemplateEngine.h"


//
// The Printer class.
//
@implementation Printer
- (id)init {
	self = [super init];
	if (self != nil) {
		buffer_ = [[NSMutableString alloc] init];
	}
	return self;
}

- (void)print:(NSString *)str {
	[buffer_ appendString:str];
}

- (NSString *)description {
	return buffer_;
}

- (void)dealloc {
    [buffer_ release];
    [super dealloc];
}
@end


//
// The TemplateExecuter class.
//
@implementation TemplateExecuter

+ (DictValue *)buildConstants {
    // Refresh the symbol dictionary.
    [SymbolValue clear];
    
    UIDevice *dev = [UIDevice currentDevice];
    DictValue *consts = [DictValue value];
    
    // Symbols.
    [consts set:[SymbolValue get:@"Android"] forKey:@"Android"];
    [consts set:[SymbolValue get:@"IOS"] forKey:@"IOS"];
    
    // Devices.
    DictValue *device = [DictValue value];
    [device set:[consts get:@"IOS"] forKey:@"Platform"];
    [device set:[StringValue valueWithString:[dev name]] forKey:@"Name"];
    [device set:[dev uniqueIdentifier] forKey:@"UUID"];
    [consts set:device forKey:@"Device"];
    
    // Network.
    DictValue *network = [DictValue value];
    [consts set:network forKey:@"Network"];
    
    // Boolean.
    [consts set:[TrueValue getInstance] forKey:@"true"];
    [consts set:[FalseValue getInstance] forKey:@"false"];
    
    // Application.
    DictValue *app = [DictValue value];
    [app set:[MonacaTemplateEngine getApplicationRootPath] forKey:@"WWWDir"];
    [consts set:app forKey:@"App"];
    
    NSParameterAssert(consts);
    return consts;
}

// Designated initializer.
- (id)init {
    self = [super init];
    if (self != nil) {
        constants_ = [TemplateExecuter buildConstants];
    }
    return self;
}

- (void)execute:(Template *)template withPrinter:(Printer *)printer {
	NSParameterAssert(template.rootNode);
    TemplateExecuter *executer = [[ExecuterVisitor alloc] init:template];
	[template.rootNode accept:(id)executer value:printer];
    [executer release];
}

- (NSString *)execute:(Template *)template {
	NSParameterAssert(template.rootNode);
	Printer *printer = [[[Printer alloc] init] autorelease];
	[self execute:template withPrinter:printer];
	return [printer description];
}

@end



//
// The ExecuterVisitor class.
//
@implementation ExecuterVisitor

+ (ExecuterVisitor *)visitorWithTemplate:(Template *)template
                               constants:(DictValue *)constants {
    return [[[ExecuterVisitor alloc] initWithTemplate:template
                                            constants:constants] autorelease];
}

- (id)initWithTemplate:(Template *)template constants:(DictValue *)constants {
    NSParameterAssert(constants);
    self = [super init];
    if (self != nil) {
		blockNameStack_ = [[NSMutableArray array] retain];
		templateStack_ = [[NSMutableArray array] retain];
		[templateStack_ push:template];
        constants_ = [constants retain];
        evaluator_ = [[ExpressionEvaluator visitorWithValue:constants] retain];
	}
	return self;
}

// TODO(nhiroki): Obsolete.
- (id)init:(Template *)template {
    // TODO(nhiroki): It is suspicious to call buildConstans.
    return [self initWithTemplate:template constants:[TemplateExecuter buildConstants]];
}

- (void)dealloc {
    [blockNameStack_ release];
    [templateStack_ release];
    [constants_ release];
    [evaluator_ release];
	[super dealloc];
}

- (void)visitEchoStatementNode:(EchoStatementNode *)node value:(Printer *)printer {
    NSString *result = [(id)[evaluator_ eval:[node expression]] description];
    
    // Evaluate pipe decorator.
    if ([node.apply.value isEqualToString:@"raw"]) {
        // Nothing to do.
    } else {
        result = [NSString stringByEncodingHTMLEntities:result];
    }
    [printer print:result];
}

- (void)visitIfStatementNode:(IfStatementNode *)node value:(Printer *)printer {
    id<Value> condition = [evaluator_ eval:[node expression]];
    
    if (condition != [FalseValue getInstance]) {
        [[node statements] accept:self value:printer];
    } else {
        [[node elseStatement] accept:self value:printer];
    }
}

- (void)visitBlockStatementNode:(BlockStatementNode *)node value:(Printer *)printer {
	NSString *blockName = [node getBlockName];
	[blockNameStack_ push:blockName];
	
	Template *template = (Template *)[templateStack_ peek];
	BlockStatementNode *block = [template getBlock:blockName];
	[block.statements accept:self value:printer];
	
	[blockNameStack_ pop];
}

- (void)visitIncludeStatementNode:(IncludeStatementNode *)node value:(Printer *)printer {
    NSString* path = [TemplateCompiler normalizePath:[node getPath] base:((Template*)[templateStack_ peek]).path];
	Template *template = [[templateStack_ peek] getDependency:path];
	[templateStack_ push:template];
	[template.rootNode accept:self value:printer];
	[templateStack_ pop];
}

- (void)visitParentStatementNode:(ParentStatementNode *)node value:(Printer *)printer {
	Template *parent = ((Template *)[templateStack_ peek]).parent;
	[templateStack_ push:parent];
	
	StatementsNode *child =
        ((BlockStatementNode *)[parent getBlock:[blockNameStack_ peek]]).statements;
	if (child != nil) {
		[child accept:self value:printer];
    } else {
		[NSException raise:@"RuntimeException"
                    format:@"null block occured. block name: %s", [blockNameStack_ peek]];
    }
	
	[templateStack_ pop];
}

- (void)visitRawStatementNode:(RawStatementNode *)node value:(Printer *)printer {
	[printer print:[node getRawString]];
}

- (void)visitStatementsNode:(StatementsNode *)node value:(Printer *)printer {
	for (id<Node> child in node.nodes_) {
		[child accept:self value:printer];
    }
}

- (void)visitTopStatementNode:(TopStatementsNode *)node value:(Printer *)printer {
	[self visitStatementsNode:node value:printer];
}

@end


//
// The ExpressionEvaluator class.
//
@implementation ExpressionEvaluator

+ (ExpressionEvaluator *)visitorWithValue:(DictValue *)constantDict {
    return [[[ExpressionEvaluator alloc] initWithValue:constantDict] autorelease];
}

- (id)initWithValue:(DictValue *)constantDict {
    NSParameterAssert(constantDict);
    self = [super init];
    if (self != nil) {
        constantDict_ = [constantDict retain];
    }
    return self;
}

- (void)dealloc {
    [constantDict_ release];
    [super dealloc];
}

- (id<Value>)eval:(id<Node>)expression {
    NSMutableArray *stack = [NSMutableArray array];
    [expression accept:self value:stack];
    return [stack pop];
}

- (void)visitEchoStatementNode:(EchoStatementNode *)node value:(id)value {
    // Nothing to do.
}

// Override.
- (void)visitConstantValueNode:(ConstantValueNode *)node value:(id)stack {
    NSParameterAssert(constantDict_);
    
    id value = constantDict_;
    for (NSString *cname in [node.names reverseObjectEnumerator])
        value = [value get:cname];
    
    [stack push:value];
}

// Override.
- (void)visitStringValueNode:(StringValueNode *)node value:(id)stack {
    [stack push:[node value]];
}

// Override.
- (void)visitBinaryOperationNode:(BinaryOperationNode *)node value:(id)stack {
    [[node left] accept:self value:stack];
    [[node right] accept:self value:stack];
    [stack push:[node operate:[stack pop] right:[stack pop]]];
}

// Override.
- (void)visitShortCircuitBinaryOperationNode:(ShortCircuitBinaryOperationNode *)node
                                       value:(id)stack {
    [[node left] accept:self value:stack];
    id<Value> left = [stack pop];
    
    if ([node willEvaluateRight:left]) {
        [[node right] accept:self value:stack];
        [stack push:[node operate:left right:[stack pop]]];
    } else {
        [stack push:left];
    }
}

// Override.
- (void)visitUnaryOperationNode:(UnaryOperationNode *)node value:(id)stack {
    [[node node] accept:self value:stack];
    [stack push:[node operate:[stack pop]]];
}

- (void)visit:(id<Node>)node value:(id)stack {
    NSAssert(false, @"Not reached.");
}

@end