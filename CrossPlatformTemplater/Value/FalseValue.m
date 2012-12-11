//
//  FalseValue.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/04/27.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "FalseValue.h"


/*
 * The FalseValue class represents false value in the template engine.
 * This class's object is singleton.
 */
@implementation FalseValue

static FalseValue *instance_;

// Returns the singleton instance.
+ (FalseValue *)getInstance {
	@synchronized(self) {
		if (!instance_) {
			instance_ = [[self alloc] init];
		}
	}
	return instance_;
}

// Override.
+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (!instance_) {
			instance_ = [super allocWithZone:zone];
			return instance_;
		}
	}
	return nil;
}

// Override.
- (id)copyWithZone:(NSZone *)zone {
	return self;
}

// Override.
- (id)retain {
	return self;
}

// Override.
- (unsigned)retainCount {
	return UINT_MAX;
}

// Override.
- (void)release {
}

// Override.
- (id)autorelease {
	return self;
}

- (BOOL)isEqual:(id<Value>)value {
	return [(id)value isKindOfClass:[self class]];
}

// Override.
- (NSString *)description {
	return @"<false>";
}

@end
