//
//  TemplateResourceDictionary.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/04/01.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "TemplateResourceDictionary.h"


@implementation TemplateResourceDictionary

// Initializer.
- (id)init {
	self = [super init];
	if (self != nil) {
		dictionary_ = [[NSMutableDictionary dictionary] retain];
	}
	return self;
}

- (void)dealloc {
    [super dealloc];
    [dictionary_ release];
}

// Sets template text.
- (void)set:(NSString *)text forKey:(NSString *)path {
	[dictionary_ setObject:text forKey:path];
}

// Sets template text from template resource file.
- (void)setWithContentsOfFile:(NSString *)filename forKey:(NSString *)key {
	NSError *error = nil;
    
    NSLog(@"[KEY] %@", key);
    
	NSString *text = [NSString stringWithContentsOfFile:filename
											   encoding:NSUTF8StringEncoding
												  error:&error];
	if (text == nil) {
		[NSException raise:@"RuntimeException" format:@"File Not Found: %@", key];
	}
	[self set:text forKey:key];
}

// Checks whether |dictionary_| contains |path| or not.
- (BOOL)exists:(NSString *)path {
	if ([dictionary_ objectForKey:path] != nil) {
		 return YES;
	}
	return NO;
}

// Returns template text.
- (NSString *)get:(NSString *)path {
	return [dictionary_ objectForKey:path];
}
@end
