//
//  TemplateExecuter.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/29.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NodeVisitor.h"
#import "TemplateCompiler.h"
#import "DictValue.h"


@class Template;
@class ExpressionEvaluator;


//
// The Printer class is used to show template executer output.
//
@interface Printer : NSObject {
 @private
	NSMutableString *buffer_;
}

- (void)print:(NSString *)str;

@end


//
// The TemplateExecuter class is used to execute AST.
//
@interface TemplateExecuter : NSObject {
 @private
    DictValue *constants_;
}

// Returns an autoreleased instance of DictValue, which contains preset constants in template engine. 
+ (DictValue *)buildConstants;

- (void)execute:(Template *)template withPrinter:(Printer *)printer;
- (NSString *)execute:(Template *)template;

@end


//
// The ExecuterVisitor class is used to visit each AST nodes, and print them.
//
@interface ExecuterVisitor : NSObject <NodeVisitor> {
 @protected
	NSMutableArray *blockNameStack_;
	NSMutableArray *templateStack_;
    DictValue *constants_;
    ExpressionEvaluator *evaluator_;
}

// Returns an autoreleased instance of the ExecuterVisitor class.
+ (ExecuterVisitor *)visitorWithTemplate:(Template *)template constants:(DictValue *)constants;

// Designated initializer.
- (id)initWithTemplate:(Template *)template constants:(DictValue *)constants;

// TODO(nhiroki): Obsolete.
- (id)init:(Template *)template;

@end


//
// The ExpressionEvaluator class.
//
@interface ExpressionEvaluator : NSObject<NodeVisitor> {
 @private
    DictValue *constantDict_;
}

// Returns an autoreleased instance of the ExpressionEvaluator class.
+ (ExpressionEvaluator *)visitorWithValue:(DictValue *)constantDict;

// Designated initializer.
- (id)initWithValue:(DictValue *)constantDict;

- (id<Value>)eval:(id<Node>)expression;

@end