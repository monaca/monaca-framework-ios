//
//  NSMutableArray+Stack.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "NSMutableArray+Stack.h"


@implementation NSMutableArray (Stack)
- (id)pop {
	id obj = [[[self lastObject] retain] autorelease];
	if (obj)
		[self removeLastObject];
	return obj;
}

- (void)push:(id)obj {
    NSParameterAssert(obj);
	[self addObject:obj];
}

- (id)peek {
	return [[[self lastObject] retain] autorelease];
}
@end