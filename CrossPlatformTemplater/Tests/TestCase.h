//
//  TestCase.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/04/07.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GHUnitIOS/GHUnit.h>


@interface TestCase : NSObject {
	NSMutableString *description_;
	NSMutableDictionary *inputs_;
	NSMutableString *expect_;
}
- (id)init;
+ (TestCase *)initWithContentsOfFile:(NSString *)filename;
@property(assign) NSMutableString *description_;
@property(assign) NSMutableDictionary *inputs_;
@property(assign) NSMutableString *expect_;
@end
