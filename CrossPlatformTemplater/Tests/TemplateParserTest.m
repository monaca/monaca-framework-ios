//
//  TemplateParserTest.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/04/05.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "Forte.h"
#include "forte_lexer.h"
#include "forte_parser.h"
#import "TestCase.h"


@interface TemplateParserTest : GHTestCase {}
@end

@implementation TemplateParserTest

+ (NSString *) testpath:(NSString *)testname {
    return [NSString stringWithFormat:@"template_engine_testcases/lexer/%@", testname];
}

// Tests template lexer.
- (void)runner:(NSString *)filename {
	TestCase *file = [TestCase initWithContentsOfFile:[[self class] testpath:filename]];
	GHTestLog(@"%@", [file description]);
	
	NSString *key, *text;
	for (key in file.inputs_)
		text = [file.inputs_ objectForKey:key];
	
	NSParameterAssert(text != nil);
	
	scanner = [[TemplateScanner alloc] init:text];
	
	NSString *token;
	NSMutableString *tokens = [NSMutableString string];
	GHTestLog(@"[Result]");
	while ((token = [scanner next]) != nil) {
		GHTestLog(@"%@", token);
		[tokens appendString:token];
		[tokens appendString:@"\n"];
	}

	GHAssertEqualStrings([tokens substringToIndex:[tokens length]-1], file.expect_, @"Failed");
}

- (void)testLexer001 { [self runner:@"001.testcase"]; }
- (void)testLexer002 { [self runner:@"002.testcase"]; }
- (void)testLexer003 { [self runner:@"003.testcase"]; }
- (void)testLexer004 { [self runner:@"004.testcase"]; }
- (void)testLexer005 { [self runner:@"005.testcase"]; }
- (void)testLexer006 { [self runner:@"006.testcase"]; }
- (void)testLexer007 { [self runner:@"007.testcase"]; }
- (void)testLexer008 { [self runner:@"008.testcase"]; }
- (void)testLexer009 { [self runner:@"009.testcase"]; }
- (void)testLexer010 { [self runner:@"010.testcase"]; }
- (void)testLexer011 { [self runner:@"011.testcase"]; }
- (void)testLexer012 { [self runner:@"012.testcase"]; }
- (void)testLexer013 { [self runner:@"013.testcase"]; }
- (void)testLexer014 { [self runner:@"014.testcase"]; }
- (void)testLexer015 { [self runner:@"015.testcase"]; }

@end
