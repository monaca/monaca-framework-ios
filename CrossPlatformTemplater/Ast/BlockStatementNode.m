//
//  BlockStatementNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "BlockStatementNode.h"
#import "NodeVisitor.h"


@implementation BlockStatementNode
@synthesize identifier = identifier_, statements = statements_;

- (id)initWithToken:(Token *)identifier node:(StatementsNode *)statements {
	self = [super init];
	if (self != nil) {
		self.identifier = identifier;
		self.statements = statements;
	}
	return self;
}

- (void)dealloc {
    [identifier_ release];
    [statements_ release];
    [super dealloc];
}

// Returns block name;
- (NSString *)getBlockName {
	return identifier_.value;
}

- (void)accept:(id <NodeVisitor>)visitor value:(id)val {
	[visitor visitBlockStatementNode:self value:val];
}

- (NSString *)indent:(NSString *)str {
	NSScanner *scanner = [NSScanner scannerWithString:str];
	NSString *token = [NSString string];
	
	NSMutableString *builder = [NSMutableString string];
	
	while (![scanner isAtEnd]) {
		[scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet]
                                intoString:&token];
		[scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
		[builder appendString:token];
	}
	
	return [builder length] > 0
	? [builder substringToIndex:[builder length] - 1]
	: @"";
}

- (NSString *)description {
	return [NSString stringWithFormat:@"block:\n%@", [self indent:[statements_ description]]];
}

@end
