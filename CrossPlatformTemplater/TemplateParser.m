//
//  TemplateParser.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/04/01.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "TemplateParser.h"

#include "forte_lexer.h"
#include "forte_parser.h"

@implementation TemplateParser

@synthesize rootNode = rootNode_;

- (TopStatementsNode *)parse:(NSString *)text {
	scanner = [[TemplateScanner alloc] init:text];
	
	// Parse template file.
	if (yyparse(self) != 0) {
		[NSException raise:@"RuntimeException"
					format:@"Illegal template format.:%@", text];
	}
	
	NSLog(@"[DEBUG] Parse Result: %@", rootNode_);
	return (TopStatementsNode *)rootNode_;
}

@end