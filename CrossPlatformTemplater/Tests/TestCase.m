//
//  TestCase.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/04/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "TestCase.h"


// Reads description section.
static BOOL readDescriptionSection(NSString *line, TestCase *file,
								   NSTextCheckingResult *match) {
	if (match.numberOfRanges > 0) {
		NSString *substr = [line substringWithRange:[match rangeAtIndex:1]];
		if (![substr isEqualToString:@"description"])
			return NO;
		return YES;
	}
	[file.description_ appendString:line];
	return YES;
}

// Reads expect section.
static BOOL readExpectSection(NSString *line, TestCase *file,
							  NSTextCheckingResult *match) {
	if (match.numberOfRanges > 0) {
		NSString *substr = [line substringWithRange:[match rangeAtIndex:1]];
		if (![substr isEqualToString:@"expect"])
			return NO;
		return YES;
	}
	[file.expect_ appendString:line];
	return YES;
}

// Reads input section.
static BOOL readInputSection(NSString *line, TestCase *file,
							 NSTextCheckingResult *match) {
	static NSString *input_name;
	NSError *error;
	
	NSRegularExpression *regex =
		[NSRegularExpression regularExpressionWithPattern:@"input:(.*)"
												  options:0 error:&error];

	// TODO(nhiroki): This is very dirty codes,
	// so I will re-implement here soon (ex. "---input:a---").
	if (match.numberOfRanges > 0) {
		NSString *substr = [line substringWithRange:[match rangeAtIndex:1]];

		// Treat a executoer test case. The test case includes input name.
		match = [regex firstMatchInString:substr
								  options:0
									range:NSMakeRange(0, substr.length)];
		if (match.numberOfRanges > 0) {
			// Start new input section.
			input_name = [substr substringWithRange:[match rangeAtIndex:1]];
			[file.inputs_ setObject:[NSMutableString string] forKey:input_name];
			return YES;
		}
		
		// Treat a lexer test case. The test case does not include input name
		// (ex. "---input---").
		regex = [NSRegularExpression regularExpressionWithPattern:@"input"
														options:0 error:&error];
		match = [regex firstMatchInString:substr
								  options:0
									range:NSMakeRange(0, substr.length)];
		if (match.numberOfRanges > 0) {
			input_name = @"lex";
			[file.inputs_ setObject:[NSMutableString string] forKey:input_name];
			return YES;
		}
		
		return NO;
	}
	
	[[file.inputs_ objectForKey:input_name] appendString:line];
	return YES;
}

// Returns YES if next input section exists.
static BOOL hasInputSection(NSString *text, TestCase *file, NSRange *range) {
	NSRange subrange = [text lineRangeForRange:NSMakeRange(range->location, 0)];
	NSString *line = [text substringWithRange:subrange];

	NSError *error;
	NSTextCheckingResult *match = nil;
	NSRegularExpression *regex =
		[NSRegularExpression regularExpressionWithPattern:@"---input(.*)---"
												  options:0 error:&error];
		
	match = [regex firstMatchInString:line
							  options:0
								range:NSMakeRange(0, line.length)];
	if (match.numberOfRanges > 0)
		return YES;
	return NO;
}

// Reads each sections in test case file.
static void readSection(BOOL (*p)(NSString *, TestCase *,
								  NSTextCheckingResult *),
						NSString *text, TestCase *file, NSRange *range) {
        NSLog(@"readInputSection");
    
	while (range->length > 0) {
		NSRange subrange =
			[text lineRangeForRange:NSMakeRange(range->location, 0)];
		NSString *line = [text substringWithRange:subrange];
		NSError *error;

		NSRegularExpression *regex = 
			[NSRegularExpression regularExpressionWithPattern:@"---(.+)---"
													  options:0 error:&error];
		NSTextCheckingResult *match = [regex firstMatchInString:line
														options:0
											range:NSMakeRange(0, line.length)];
		
		// Call each section functions.
		if (!(*p)(line, file, match))
			return;
		
		// Move next line.
		range->location = NSMaxRange(subrange);
		range->length -= subrange.length;
	}
}



@implementation TestCase
@synthesize description_, inputs_, expect_;

// Designated initializer.
- (id)init {
	self = [super init];
	if (self != nil) {
		description_ = [NSMutableString string];
		inputs_ = [NSMutableDictionary dictionary];
		expect_ = [NSMutableString string];
	}
	return self;
}

// (Override).
- (NSString *)description {
	NSMutableString *str = [NSMutableString stringWithString:@""];
	
	[str appendFormat:@"[DESCRIPTION]\n%@\n", description_];
	
	NSString *key;
	for (key in inputs_) {
		[str appendFormat:@"[INPUT:%@]\n", key];
		[str appendFormat:@"%@\n\n", [inputs_ objectForKey:key]];
	}
	
	[str appendFormat:@"[EXPECT]\n%@\n", expect_];
	
	return [NSString stringWithString:str];
}

// Parses test case file from filename (e.g. "exe001.testcase").
+ (TestCase *)initWithContentsOfFile:(NSString *)filename {
	TestCase *file = [[[TestCase alloc] init] autorelease];
	
	// Read test case from file.
	NSError *error;
	NSString *path = [[NSBundle mainBundle] pathForResource:filename
													 ofType:nil];
	NSString *text = [NSString stringWithContentsOfFile:path
											   encoding:NSUTF8StringEncoding
												  error:&error];
	NSRange range = NSMakeRange(0, [text length]);
    
	// Rarse each sections.
	readSection(readDescriptionSection, text, file, &range);
	while (hasInputSection(text, file, &range)) {
		readSection(readInputSection, text, file, &range);
	}
	readSection(readExpectSection, text, file, &range);
	
	// Remove linefeed character.
	NSString *key, *value;
	for (key in [file.inputs_ allKeys]) {
		value = [file.inputs_ objectForKey:key];
		[file.inputs_ setObject:[value substringToIndex:[value length]-1] forKey:key];
	}

	return file;
}
@end


