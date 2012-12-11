//
//  TemplateExecuterTest.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/04/05.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "Forte.h"
#import "TestCase.h"


@interface TemplateExecuterTest : GHTestCase {}
@end

// The TemplateExecuterTest class is used to test TemplateExecuter class.
@implementation TemplateExecuterTest

+ (NSString *) testpath:(NSString *)testname {
    return [NSString stringWithFormat:@"template_engine_testcases/execution/%@", testname];
}

- (void)runner:(NSString *)filename {
	TestCase *file = [TestCase initWithContentsOfFile:[[self class] testpath:filename]];
	GHTestLog(@"%@", [file description]);
	
	NSString *key;
	TemplateResourceDictionary *dict =
		[[TemplateResourceDictionary alloc] init];
	for (key in file.inputs_) {
		[dict set:[file.inputs_ objectForKey:key] forKey:key];
	}
	
	// Compile.
	TemplateCompiler *driver = [[TemplateCompiler alloc] init:dict];
	// TODO(nhiroki): Change the argument of the method "compileFrom".
	Template *template = [driver compileFrom:@"a"];
	
	// Execute template object.
	NSString *result = [[[TemplateExecuter alloc] init] execute:template];
	
	GHTestLog(@"[RESULT]\n%@", result);
	GHAssertEqualStrings(result, file.expect_, @"Failed.");
}

- (void)testExecuter001 { [self runner:@"001.testcase"]; }
- (void)testExecuter002 { [self runner:@"002.testcase"]; }
- (void)testExecuter003 { [self runner:@"003.testcase"]; }
- (void)testExecuter004 { [self runner:@"004.testcase"]; }
- (void)testExecuter005 { [self runner:@"005.testcase"]; }
- (void)testExecuter006 { [self runner:@"006.testcase"]; }
- (void)testExecuter007 { [self runner:@"007.testcase"]; }
- (void)testExecuter008 { [self runner:@"008.testcase"]; }
- (void)testExecuter009 { [self runner:@"009.testcase"]; }
- (void)testExecuter010 { [self runner:@"010.testcase"]; }
- (void)testExecuter011 { [self runner:@"011.testcase"]; }
- (void)testExecuter012 { [self runner:@"012.testcase"]; }
- (void)testExecuter013 { [self runner:@"013.testcase"]; }
- (void)testExecuter014 { [self runner:@"014.testcase"]; }
- (void)testExecuter015 { [self runner:@"015.testcase"]; }
- (void)testExecuter016 { [self runner:@"016.testcase"]; }

@end
